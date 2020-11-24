const std = @import("std");
const unicode = std.unicode;
const testing = std.testing;
const expectEqual = testing.expectEqual;
const expect = testing.expect;

extern fn malloc(size: usize) ?*u8;
extern fn free([*]u8) void;

const RocStr = struct {
    str_bytes: ?[*]u8,
    str_len: usize,

    pub fn empty() RocStr {
        return RocStr {
            .str_len = 0,
            .str_bytes = null
        };
    }

    // This takes ownership of the pointed-to bytes if they won't fit in a
    // small string, and returns a (pointer, len) tuple which points to them.
    pub fn init(bytes: [*]const u8, length: usize) RocStr {
        const rocStrSize = @sizeOf(RocStr);

        if (length < rocStrSize) {
            var ret_small_str = RocStr.empty();
            const target_ptr = @ptrToInt(&ret_small_str);
            var index : u8 = 0;
            // Zero out the data, just to be safe
            while (index < rocStrSize) {
                var offset_ptr = @intToPtr(*u8, target_ptr + index);
                offset_ptr.* = 0;
                index += 1;
            }

            index = 0;
            while (index < length) {
                var offset_ptr = @intToPtr(*u8, target_ptr + index);
                offset_ptr.* = bytes[index];
                index += 1;
            }

            // set the final byte to be the length
            const final_byte_ptr = @intToPtr(*u8, target_ptr + rocStrSize - 1);
            final_byte_ptr.* = @truncate(u8, length) ^ 0b10000000;

            return ret_small_str;
        } else {
            var new_bytes: [*]u8 = @ptrCast([*]u8, malloc(length));

            @memcpy(new_bytes, bytes, length);

            return RocStr {
                .str_bytes = new_bytes,
                .str_len = length
            };
        }
    }

    pub fn drop(self: RocStr) void {
        if (!self.is_small_str()) {
            const str_bytes: [*]u8 = self.str_bytes orelse unreachable;

            free(str_bytes);
        }
    }

    pub fn eq(self: RocStr, other: RocStr) bool {
        const self_bytes_ptr: ?[*]const u8 = self.str_bytes;
        const other_bytes_ptr: ?[*]const u8 = other.str_bytes;

        // If they are byte-for-byte equal, they're definitely equal!
        if (self_bytes_ptr == other_bytes_ptr and self.str_len == other.str_len) {
            return true;
        }

        const self_len = self.len();
        const other_len = other.len();

        // If their lengths are different, they're definitely unequal.
        if (self_len != other_len) {
            return false;
        }

        const self_bytes_nonnull: [*]const u8 = self_bytes_ptr orelse unreachable;
        const other_bytes_nonnull: [*]const u8 = other_bytes_ptr orelse unreachable;
        const self_u8_ptr: [*]const u8 = @ptrCast([*]const u8, &self);
        const other_u8_ptr: [*]const u8 = @ptrCast([*]const u8, &other);
        const self_bytes: [*]const u8 = if (self_len < @sizeOf(RocStr)) self_u8_ptr else self_bytes_nonnull;
        const other_bytes: [*]const u8 = if (other_len < @sizeOf(RocStr)) other_u8_ptr else other_bytes_nonnull;

        var index: usize = 0;

        // TODO rewrite this into a for loop
        while (index < self.str_len) {
            if (self_bytes[index] != other_bytes[index]) {
                return false;
            }

            index = index + 1;
        }

        return true;
    }

    pub fn is_small_str(self: RocStr) bool {
        return @bitCast(isize, self.str_len) < 0;
    }

    pub fn len(self: RocStr) usize {
        const bytes: [*]const u8 = @ptrCast([*]const u8, &self);
        const last_byte = bytes[@sizeOf(RocStr) - 1];
        const small_len = @as(usize, last_byte ^ 0b1000_0000);
        const big_len = self.str_len;

        // Since this conditional would be prone to branch misprediction,
        // make sure it will compile to a cmov.
        return if (self.is_small_str()) small_len else big_len;
    }

    // Given a pointer to some memory of length (self.len() + 1) bytes,
    // write this RocStr's contents into it as a nul-terminated C string.
    //
    // This is useful so that (for example) we can write into an `alloca`
    // if the C string only needs to live long enough to be passed as an
    // argument to a C function - like the file path argument to `fopen`.
    pub fn write_cstr(self: RocStr, dest: [*]u8) void {
        const len: usize = self.len();
        const small_src = @ptrCast(*u8, self);
        const big_src = self.str_bytes_ptr;

        // For a small string, copy the bytes directly from `self`.
        // For a large string, copy from the pointed-to bytes.

        // Since this conditional would be prone to branch misprediction,
        // make sure it will compile to a cmov.
        const src: [*]u8 = if (len < @sizeOf(RocStr)) small_src else big_src;

        @memcpy(dest, src, len);

        // C strings must end in 0.
        dest[len + 1] = 0;
    }

    test "RocStr.eq: equal" {
        const str1_len = 3;
        var str1: [str1_len]u8 = "abc".*;
        const str1_ptr: [*]u8 = &str1;
        var roc_str1 = RocStr.init(str1_ptr, str1_len);

        const str2_len = 3;
        var str2: [str2_len]u8 = "abc".*;
        const str2_ptr: [*]u8 = &str2;
        var roc_str2 = RocStr.init(str2_ptr, str2_len);

        // TODO: fix those tests
        // expect(roc_str1.eq(roc_str2));

        roc_str1.drop();
        roc_str2.drop();
    }

    test "RocStr.eq: not equal different length" {
        const str1_len = 4;
        var str1: [str1_len]u8 = "abcd".*;
        const str1_ptr: [*]u8 = &str1;
        var roc_str1 = RocStr.init(str1_ptr, str1_len);

        const str2_len = 3;
        var str2: [str2_len]u8 = "abc".*;
        const str2_ptr: [*]u8 = &str2;
        var roc_str2 = RocStr.init(str2_ptr, str2_len);

        expect(!roc_str1.eq(roc_str2));

        roc_str1.drop();
        roc_str2.drop();
    }

    test "RocStr.eq: not equal same length" {
        const str1_len = 3;
        var str1: [str1_len]u8 = "acb".*;
        const str1_ptr: [*]u8 = &str1;
        var roc_str1 = RocStr.init(str1_ptr, str1_len);

        const str2_len = 3;
        var str2: [str2_len]u8 = "abc".*;
        const str2_ptr: [*]u8 = &str2;
        var roc_str2 = RocStr.init(str2_ptr, str2_len);

        // TODO: fix those tests
        // expect(!roc_str1.eq(roc_str2));

        roc_str1.drop();
        roc_str2.drop();
    }
};

// Str.split

pub fn strSplitInPlace(
    array: [*]RocStr,
    array_len: usize,
    str_bytes: [*]const u8,
    str_len: usize,
    delimiter_bytes_ptrs: [*]const u8,
    delimiter_len: usize
) callconv(.C) void {
    var ret_array_index : usize = 0;
    var sliceStart_index : usize = 0;
    var str_index : usize = 0;

    if (str_len > delimiter_len) {
        const end_index : usize = str_len - delimiter_len + 1;
        while (str_index <= end_index) {
            var delimiter_index : usize = 0;
            var matches_delimiter = true;

            while (delimiter_index < delimiter_len) {
                var delimiterChar = delimiter_bytes_ptrs[delimiter_index];
                var strChar = str_bytes[str_index + delimiter_index];

                if (delimiterChar != strChar) {
                    matches_delimiter = false;
                    break;
                }

                delimiter_index += 1;
            }

            if (matches_delimiter) {
                const segment_len : usize = str_index - sliceStart_index;

                array[ret_array_index] = RocStr.init(str_bytes + sliceStart_index, segment_len);
                sliceStart_index = str_index + delimiter_len;
                ret_array_index += 1;
                str_index += delimiter_len;
            } else {
                str_index += 1;
            }
        }
    }

    array[ret_array_index] = RocStr.init(str_bytes + sliceStart_index, str_len - sliceStart_index);
}

test "strSplitInPlace: no delimiter" {
    // Str.split "abc" "!" == [ "abc" ]

    var str: [3]u8 = "abc".*;
    const str_ptr: [*]const u8 = &str;

    var delimiter: [1]u8 = "!".*;
    const delimiter_ptr: [*]const u8 = &delimiter;

    var array: [1]RocStr = undefined;
    const array_ptr: [*]RocStr = &array;

    strSplitInPlace(
        array_ptr,
        1,
        str_ptr,
        3,
        delimiter_ptr,
        1
    );

    var expected = [1]RocStr{
        RocStr.init(str_ptr, 3),
    };

    expectEqual(array.len, expected.len);
    // TODO: fix those tests
    //expect(array[0].eq(expected[0]));

    for (array) |roc_str| {
        roc_str.drop();
    }

    for (expected) |roc_str| {
        roc_str.drop();
    }
}

test "strSplitInPlace: empty end" {
    const str_len: usize = 50;
    var str: [str_len]u8 = "1---- ---- ---- ---- ----2---- ---- ---- ---- ----".*;
    const str_ptr: [*]u8 = &str;

    const delimiter_len = 24;
    const delimiter: [delimiter_len:0]u8 = "---- ---- ---- ---- ----".*;
    const delimiter_ptr: [*]const u8 = &delimiter;

    const array_len : usize = 3;
    var array: [array_len]RocStr = [_]RocStr {
        undefined,
        undefined,
        undefined,
    };
    const array_ptr: [*]RocStr = &array;

        strSplitInPlace(
            array_ptr,
            array_len,
            str_ptr,
            str_len,
            delimiter_ptr,
            delimiter_len
        );

        const first_expected_str_len: usize = 1;
        var first_expected_str: [first_expected_str_len]u8 = "1".*;
        const first_expected_str_ptr: [*]u8 = &first_expected_str;
        var firstExpectedRocStr = RocStr.init(first_expected_str_ptr, first_expected_str_len);

        const second_expected_str_len: usize = 1;
        var second_expected_str: [second_expected_str_len]u8 = "2".*;
        const second_expected_str_ptr: [*]u8 = &second_expected_str;
        var secondExpectedRocStr = RocStr.init(second_expected_str_ptr, second_expected_str_len);

        // TODO: fix those tests
        // expectEqual(array.len, 3);
        // expectEqual(array[0].str_len, 1);
        // expect(array[0].eq(firstExpectedRocStr));
        // expect(array[1].eq(secondExpectedRocStr));
        // expectEqual(array[2].str_len, 0);
}

test "strSplitInPlace: delimiter on sides" {
    // Str.split "tttghittt" "ttt" == [ "", "ghi", "" ]

    const str_len: usize = 9;
    var str: [str_len]u8 = "tttghittt".*;
    const str_ptr: [*]u8 = &str;

    const delimiter_len = 3;
    var delimiter: [delimiter_len]u8 = "ttt".*;
    const delimiter_ptr: [*]u8 = &delimiter;

    const array_len : usize = 3;
    var array: [array_len]RocStr = [_]RocStr{
        undefined ,
        undefined,
        undefined,
    };
    const array_ptr: [*]RocStr = &array;

    strSplitInPlace(
        array_ptr,
        array_len,
        str_ptr,
        str_len,
        delimiter_ptr,
        delimiter_len
    );

    const expected_str_len: usize = 3;
    var expected_str: [expected_str_len]u8 = "ghi".*;
    const expected_str_ptr: [*]const u8 = &expected_str;
    var expectedRocStr = RocStr.init(expected_str_ptr, expected_str_len);

    // TODO: fix those tests
    // expectEqual(array.len, 3);
    // expectEqual(array[0].str_len, 0);
    // expect(array[1].eq(expectedRocStr));
    // expectEqual(array[2].str_len, 0);
}

test "strSplitInPlace: three pieces" {
    // Str.split "a!b!c" "!" == [ "a", "b", "c" ]

    const str_len: usize = 5;
    var str: [str_len]u8 = "a!b!c".*;
    const str_ptr: [*]u8 = &str;

    const delimiter_len = 1;
    var delimiter: [delimiter_len]u8 = "!".*;
    const delimiter_ptr: [*]u8 = &delimiter;

    const array_len : usize = 3;
    var array: [array_len]RocStr = undefined;
    const array_ptr: [*]RocStr = &array;

    strSplitInPlace(
        array_ptr,
        array_len,
        str_ptr,
        str_len,
        delimiter_ptr,
        delimiter_len
    );

    var a: [1]u8 = "a".*;
    const a_ptr: [*]u8 = &a;

    var b: [1]u8 = "b".*;
    const b_ptr: [*]u8 = &b;

    var c: [1]u8 = "c".*;
    const c_ptr: [*]u8 = &c;

    var expected_array = [array_len]RocStr{
        RocStr{
            .str_bytes = a_ptr,
            .str_len = 1,
        },
        RocStr{
            .str_bytes = b_ptr,
            .str_len = 1,
        },
        RocStr{
            .str_bytes = c_ptr,
            .str_len = 1,
        }
    };

    // TODO: fix those tests
    // expectEqual(expected_array.len, array.len);
    // expect(array[0].eq(expected_array[0]));
    // expect(array[1].eq(expected_array[1]));
    // expect(array[2].eq(expected_array[2]));
}

// This is used for `Str.split : Str, Str -> Array Str
// It is used to count how many segments the input `_str`
// needs to be broken into, so that we can allocate a array
// of that size. It always returns at least 1.
pub fn countSegments(
    str_bytes: [*]u8,
    str_len: usize,
    delimiter_bytes_ptrs: [*]u8,
    delimiter_len: usize
) callconv(.C) usize {
    var count: usize = 1;

    if (str_len > delimiter_len) {
        var str_index: usize = 0;
        const end_cond: usize = str_len - delimiter_len + 1;

        while (str_index < end_cond) {
            var delimiter_index: usize = 0;

            var matches_delimiter = true;

            while (delimiter_index < delimiter_len) {
                const delimiterChar = delimiter_bytes_ptrs[delimiter_index];
                const strChar = str_bytes[str_index + delimiter_index];

                if (delimiterChar != strChar) {
                    matches_delimiter = false;
                    break;
                }

                delimiter_index += 1;
            }

            if (matches_delimiter) {
                count += 1;
            }

            str_index += 1;
        }
    }

    return count;
}

test "countSegments: long delimiter" {
    // Str.split "str" "delimiter" == [ "str" ]
    // 1 segment

    const str_len: usize = 3;
    var str: [str_len]u8 = "str".*;
    const str_ptr: [*]u8 = &str;

    const delimiter_len = 9;
    var delimiter: [delimiter_len]u8 = "delimiter".*;
    const delimiter_ptr: [*]u8 = &delimiter;

    const segments_count = countSegments(
        str_ptr,
        str_len,
        delimiter_ptr,
        delimiter_len
    );

    expectEqual(segments_count, 1);
}

test "countSegments: delimiter at start" {
    // Str.split "hello there" "hello" == [ "", " there" ]
    // 2 segments

    const str_len: usize = 11;
    var str: [str_len]u8 = "hello there".*;
    const str_ptr: [*]u8 = &str;

    const delimiter_len = 5;
    var delimiter: [delimiter_len]u8 = "hello".*;
    const delimiter_ptr: [*]u8 = &delimiter;

    const segments_count = countSegments(
        str_ptr,
        str_len,
        delimiter_ptr,
        delimiter_len
    );

    expectEqual(segments_count, 2);
}

test "countSegments: delimiter interspered" {
    // Str.split "a!b!c" "!" == [ "a", "b", "c" ]
    // 3 segments

    const str_len: usize = 5;
    var str: [str_len]u8 = "a!b!c".*;
    const str_ptr: [*]u8 = &str;

    const delimiter_len = 1;
    var delimiter: [delimiter_len]u8 = "!".*;
    const delimiter_ptr: [*]u8 = &delimiter;

    const segments_count = countSegments(
        str_ptr,
        str_len,
        delimiter_ptr,
        delimiter_len
    );

    expectEqual(segments_count, 3);
}

// Str.countGraphemeClusters
const grapheme = @import("helpers/grapheme.zig");

pub fn countGraphemeClusters(bytes_ptr: [*]u8, bytes_len: usize)  callconv(.C) usize {
    var bytes = bytes_ptr[0..bytes_len];
    var iter = (unicode.Utf8View.init(bytes) catch unreachable).iterator();

    var count: usize = 0;
    var grapheme_break_state: ?grapheme.BoundClass = null;
    var grapheme_break_state_ptr = &grapheme_break_state;
    var opt_last_codepoint: ?u21 = null;
    while (iter.nextCodepoint()) |cur_codepoint| {
        if (opt_last_codepoint) |last_codepoint| {
            var did_break = grapheme.isGraphemeBreak(
                last_codepoint,
                cur_codepoint,
                grapheme_break_state_ptr
            );
            if (did_break) {
                count += 1;
                grapheme_break_state = null;
            }
        }
        opt_last_codepoint = cur_codepoint;
    }

    // If there are no breaks, but the str is not empty, then there
    // must be a single grapheme
    if (bytes_len != 0) {
        count += 1;
    }

    return count;
}

test "countGraphemeClusters: empty string" {
    var bytes_arr = "".*;
    var bytes_len = bytes_arr.len;
    var bytes_ptr: [*]u8 = &bytes_arr;
    var count = countGraphemeClusters(bytes_ptr, bytes_len);
    expectEqual(count, 0);
}

test "countGraphemeClusters: ascii characters" {
    var bytes_arr = "abcd".*;
    var bytes_len = bytes_arr.len;
    var bytes_ptr: [*]u8 = &bytes_arr;
    var count = countGraphemeClusters(bytes_ptr, bytes_len);
    expectEqual(count, 4);
}

test "countGraphemeClusters: utf8 characters" {
    var bytes_arr = "ãxā".*;
    var bytes_len = bytes_arr.len;
    var bytes_ptr: [*]u8 = &bytes_arr;
    var count = countGraphemeClusters(bytes_ptr, bytes_len);
    expectEqual(count, 3);
}

test "countGraphemeClusters: emojis" {
    var bytes_arr = "🤔🤔🤔".*;
    var bytes_len = bytes_arr.len;
    var bytes_ptr: [*]u8 = &bytes_arr;
    var count = countGraphemeClusters(bytes_ptr, bytes_len);
    expectEqual(count, 3);
}

test "countGraphemeClusters: emojis and ut8 characters" {
    var bytes_arr = "🤔å🤔¥🤔ç".*;
    var bytes_len = bytes_arr.len;
    var bytes_ptr: [*]u8 = &bytes_arr;
    var count = countGraphemeClusters(bytes_ptr, bytes_len);
    expectEqual(count, 6);
}

test "countGraphemeClusters: emojis, ut8, and ascii characters" {
    var bytes_arr = "6🤔å🤔e¥🤔çpp".*;
    var bytes_len = bytes_arr.len;
    var bytes_ptr: [*]u8 = &bytes_arr;
    var count = countGraphemeClusters(bytes_ptr, bytes_len);
    expectEqual(count, 10);
}


// Str.startsWith

pub fn startsWith(
    bytes_ptr: [*]u8,
    bytes_len: usize,
    prefix_ptr: [*]u8,
    prefix_len: usize
) callconv(.C) bool {
    if(prefix_len > bytes_len) {
        return false;
    }

    // we won't exceed bytes_len due to the previous check
    var i : usize = 0;
    while(i < prefix_len) {
        if(bytes_ptr[i] != prefix_ptr[i]) {
            return false;
        }
        i += 1;
    }
    return true;
}


test "startsWith: 123456789123456789 starts with 123456789123456789" {
    const str_len: usize = 18;
    var str: [str_len]u8 = "123456789123456789".*;
    const str_ptr: [*]u8 = &str;

    expect(startsWith(str_ptr, str_len, str_ptr, str_len));
}

test "startsWith: 12345678912345678910 starts with 123456789123456789" {
    const str_len: usize = 20;
    var str: [str_len]u8 = "12345678912345678910".*;
    const str_ptr: [*]u8 = &str;

    const prefix_len: usize = 18;
    var prefix: [prefix_len]u8 = "123456789123456789".*;
    const prefix_ptr: [*]u8 = &str;

    expect(startsWith(str_ptr, str_len, prefix_ptr, prefix_len));
}