interface Quantity
    exposes [
        Quantity,
        toQty,
        fromQty,
        scaleBy,
        divideBy,
        minus,
        plus,
        lessThan,
        lessThanEqual,
        greaterThan,
        greaterThanEqual,
    ]
    imports []


Quantity a units := a


fromQty : Quantity a units -> a
fromQty = \@Quantity a ->
    a


toQty : a -> Quantity a units
toQty = \a ->
    @Quantity a

# a = Quantity.toQty 8
# 
# a |> Quantity.scaleBy 5 |> Quantity.fromQty == 40 == 8 * 5
# 
scaleBy : Quantity (Num a) units, (Num a) -> Quantity (Num a) units
scaleBy = \@Quantity a, scale ->
    @Quantity (scale * a)


divideBy : Quantity (Frac a) units, (Frac a) -> Quantity (Frac a) units
divideBy = \@Quantity a, divisor ->
    @Quantity (a / divisor)

# a = Quantity.toQty 8
# b = Quantity.toQty 5
# 
# a |> Quantity.minus b |> Quantity.fromQty == 3 == 8 - 5
# 
minus : Quantity (Num a) units, Quantity (Num a) units -> Quantity (Num a) units
minus = \@Quantity left, @Quantity right ->
    @Quantity (left - right)


plus : Quantity (Num a) units, Quantity (Num a) units -> Quantity (Num a) units
plus = \@Quantity left, @Quantity right ->
    @Quantity (left + right)


lessThan : Quantity (Num a) units, Quantity (Num a) units -> Bool
lessThan = \@Quantity left, @Quantity right ->
    left < right


lessThanEqual : Quantity (Num a) units, Quantity (Num a) units -> Bool
lessThanEqual = \@Quantity left, @Quantity right ->
    left <= right


greaterThan : Quantity (Num a) units, Quantity (Num a) units -> Bool
greaterThan = \@Quantity left, @Quantity right ->
    left > right


greaterThanEqual : Quantity (Num a) units, Quantity (Num a) units -> Bool
greaterThanEqual = \@Quantity left, @Quantity right ->
    left >= right