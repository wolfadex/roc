interface Direction3d
    exposes [
        Direction3d,
        xy,
        toRecord,
        negativeX,
        negativeY,
        negativeZ,
        positiveX,
        positiveY,
        positiveZ,
    ]
    imports [pf.Angle.{ Angle }, pf.Types]


Direction3d a coordinates : Types.Direction3d a coordinates


negativeX : Direction3d a coordinates
negativeX = Types.toDirection3d { x: -1, y: 0, z: 0 }


negativeY : Direction3d a coordinates
negativeY = Types.toDirection3d { x: 0, y: -1, z: 0 }


negativeZ : Direction3d a coordinates
negativeZ = Types.toDirection3d { x: 0, y: 0, z: -1 }


positiveX : Direction3d a coordinates
positiveX = Types.toDirection3d { x: 1, y: 0, z: 0 }


positiveY : Direction3d a coordinates
positiveY = Types.toDirection3d { x: 0, y: 1, z: 0 }


positiveZ : Direction3d a coordinates
positiveZ = Types.toDirection3d { x: 0, y: 0, z: 1 }


xy : Angle a -> Direction3d a coordinates
xy = \angle ->
    theta = Angle.inRadians angle

    Types.toDirection3d { x: Num.cos theta, y: Num.sin theta, z: 0 }


toRecord : Direction3d a coordinates -> { x : Frac a, y : Frac a, z : Frac a }
toRecord = Types.fromDirection3d