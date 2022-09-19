interface Direction3d
    exposes [Direction3d, xy, toRecord]
    imports [pf.Angle.{ Angle }]


Direction3d a coordinates := { x : Frac a, y : Frac a, z : Frac a }


xy : Angle a -> Direction3d a coordinates
xy = \angle ->
    theta = Angle.inRadians angle

    @Direction3d { x: Num.cos theta, y: Num.sin theta, z: 0 }


toRecord : Direction3d a coordinates -> { x : Frac a, y : Frac a, z : Frac a }
toRecord = \@Direction3d d ->
    d