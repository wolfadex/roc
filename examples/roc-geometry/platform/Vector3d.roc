interface Vector3d
    exposes [Vector3d, toXyz, withLength, per, for, reverse]
    imports [pf.Quantity.{Quantity, Rate}, pf.Pixels.{Pixels}, pf.Direction3d.{Direction3d}]


Vector3d a units coordinates := { x : Frac a, y : Frac a, z : Frac a }


toXyz : Vector3d a units coordinates -> { x : Frac a, y : Frac a, z : Frac a }
toXyz = \@Vector3d v ->
    v


withLength : Direction3d a coordinates, Quantity a units -> Vector3d a units coordinates
withLength = \dir, qty ->
    d = Direction3d.toRecord dir
    a = Quantity.fromQty qty

    @Vector3d
        {
            x: a * d.x,
            y: a * d.y,
            z: a * d.z,
        }


per : Vector3d a dependentUnits coordinates, Quantity a independentUnits -> Vector3d a (Rate dependentUnits independentUnits) coordinates
per = \@Vector3d v, qty ->
    a = Quantity.fromQty qty

    @Vector3d
        {
            x: v.x / a,
            y: v.y / a,
            z: v.z / a,
        }


for : Vector3d a (Rate dependentUnits independentUnits) coordinates, Quantity a independentUnits -> Vector3d a dependentUnits coordinates
for = \@Vector3d v, qty ->
    a = Quantity.fromQty qty

    @Vector3d
        {
            x: v.x * a,
            y: v.y * a,
            z: v.z * a,
        }


reverse : Vector3d a units coordinates -> Vector3d a units coordinates
reverse = \@Vector3d v ->
    @Vector3d
        {
            x: -v.x,
            y: -v.y,
            z: -v.z,
        }