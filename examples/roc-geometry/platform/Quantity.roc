interface Quantity
    exposes [
        # Base operations on quantities
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
        # Complex values and operations
        Rate,
        per,
        for,
    ]
    imports []


Quantity a units := Frac a


fromQty : Quantity a units -> Frac a
fromQty = \@Quantity a ->
    a


toQty : Frac a -> Quantity a units
toQty = \a ->
    @Quantity a

# a = Quantity.toQty 8
# 
# a |> Quantity.scaleBy 5 |> Quantity.fromQty == 40 == 8 * 5
# 
scaleBy : Quantity a units, Frac a -> Quantity a units
scaleBy = \@Quantity a, scale ->
    @Quantity (scale * a)


divideBy : Quantity a units, Frac a -> Quantity a units
divideBy = \@Quantity a, divisor ->
    @Quantity (a / divisor)

# a = Quantity.toQty 8
# b = Quantity.toQty 5
# 
# a |> Quantity.minus b |> Quantity.fromQty == 3 == 8 - 5
# 
minus : Quantity a units, Quantity a units -> Quantity a units
minus = \@Quantity left, @Quantity right ->
    @Quantity (left - right)


plus : Quantity a units, Quantity a units -> Quantity a units
plus = \@Quantity left, @Quantity right ->
    @Quantity (left + right)


lessThan : Quantity a units, Quantity a units -> Bool
lessThan = \@Quantity left, @Quantity right ->
    left < right


lessThanEqual : Quantity a units, Quantity a units -> Bool
lessThanEqual = \@Quantity left, @Quantity right ->
    left <= right


greaterThan : Quantity a units, Quantity a units -> Bool
greaterThan = \@Quantity left, @Quantity right ->
    left > right


greaterThanEqual : Quantity a units, Quantity a units -> Bool
greaterThanEqual = \@Quantity left, @Quantity right ->
    left >= right

# Rates

Rate dependentUnits independentUnits : [
    Rate dependentUnits independentUnits
]


# distance |> Quantity.per time
# Like Meters/Second or Kilometers/Hour
per : Quantity a dependentUnits, Quantity a independentUnits -> Quantity a (Rate dependentUnits independentUnits)
per = \@Quantity dependentValue, @Quantity independentValue ->
    @Quantity (dependentValue / independentValue)


# hundredKilometersPerHour |> Quantity.for thirtyMinutes == fiftyKilometers
for : Quantity a (Rate dependentUnits independentUnits), Quantity a independentUnits -> Quantity a dependentUnits
for = \@Quantity rateOfChange, @Quantity independentValue ->
    @Quantity (rateOfChange * independentValue)