interface Vector3d
    exposes [Vector3d, toXyz, withLength, per, for, reverse, mirrorAcross]
    imports [
        pf.Quantity.{ Quantity, Rate },
        pf.Types.{ Direction3d, Plane3d },
    ]


Vector3d a units coordinates : Types.Vector3d a units coordinates


toXyz : Vector3d a units coordinates -> { x : Frac a, y : Frac a, z : Frac a }
toXyz = \v ->
    Types.fromVector3d v


withLength : Direction3d a coordinates, Quantity a units -> Vector3d a units coordinates
withLength = \dir, qty ->
    d = Types.fromDirection3d dir
    a = Quantity.fromQty qty

    Types.toVector3d
        {
            x: a * d.x,
            y: a * d.y,
            z: a * d.z,
        }


per : Vector3d a dependentUnits coordinates, Quantity a independentUnits -> Vector3d a (Rate dependentUnits independentUnits) coordinates
per = \vec, qty ->
    v = Types.fromVector3d vec
    a = Quantity.fromQty qty

    Types.toVector3d
        {
            x: v.x / a,
            y: v.y / a,
            z: v.z / a,
        }


for : Vector3d a (Rate dependentUnits independentUnits) coordinates, Quantity a independentUnits -> Vector3d a dependentUnits coordinates
for = \vec, qty ->
    v = Types.fromVector3d vec
    a = Quantity.fromQty qty

    Types.toVector3d
        {
            x: v.x * a,
            y: v.y * a,
            z: v.z * a,
        }


reverse : Vector3d a units coordinates -> Vector3d a units coordinates
reverse = \vec ->
    v = Types.fromVector3d vec
    Types.toVector3d
        {
            x: -v.x,
            y: -v.y,
            z: -v.z,
        }


mirrorAcross : Vector3d a units coordinates, Plane3d a units coordinates -> Vector3d a units coordinates
mirrorAcross = \vec, plane ->
    v = Types.fromVector3d vec
    { normalDirection  } = Types.fromPlane3d plane
    n = Types.fromDirection3d normalDirection

    a00 = 1 - 2 * n.x * n.x

    a11 = 1 - 2 * n.y * n.y

    a22 = 1 - 2 * n.z * n.z

    a12 = -2 * n.y * n.z

    a02 = -2 * n.x * n.z

    a01 = -2 * n.x * n.y

    Types.toVector3d
        {
            x: a00 * v.x + a01 * v.y + a02 * v.z,
            y: a01 * v.x + a11 * v.y + a12 * v.z,
            z: a02 * v.x + a12 * v.y + a22 * v.z,
        }