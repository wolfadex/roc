interface Angle
    exposes [Angle, Radians, radians, inRadians, degrees, pi]
    imports [pf.Quantity.{Quantity}]


Angle a := Quantity a Radians

Radians : [Radians]


radians : Frac a -> Angle a
radians = \numRadians ->
    @Angle (Quantity.toQty numRadians)


inRadians : Angle a -> Frac a
inRadians = \@Angle numRadians ->
    Quantity.fromQty numRadians


degrees : Frac a -> Angle a
degrees = \numDegrees ->
    @Angle (Quantity.toQty (pi * (numDegrees / 180)))


# The value that JPL uses for interplanetary navigation, per
# https://www.jpl.nasa.gov/edu/news/2016/3/16/how-many-decimals-of-pi-do-we-really-need/
pi : Frac a
pi = 3.141592653589793