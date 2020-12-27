interface Dict2
    exposes [ isEmpty, map ]
    imports []

isEmpty : Dict * * -> Bool

## Convert each key and value in the #Dict to something new, by calling a conversion
## function on each of them. Then return a new #Map of the converted keys and values.
## 
## >>> Dict.map {{ 3.14 => "pi", 1.0 => "one" }} \{ key, value } -> { key:
## 
## >>> Dict.map {[ "", "a", "bc" ]} Str.isEmpty
## 
## `map` functions like this are common in Roc, and they all work similarly.
## See for example #Result.map, #List.map, and #Set.map.
map : List before, (before -> after) -> List after