interface Plane3d
    exposes [Plane3d, through, nomalDirection]
    imports [
        pf.Types.{ Point3d, Direction3d },
    ]


Plane3d a units coordinates : Types.Plane3d a units coordinates


through : Direction3d a coordinates, Point3d a units coordinates -> Plane3d a units coordinates
through = \normalDir, originP ->
    Types.toPlane3d { originPoint: originP, normalDirection: normalDir }


nomalDirection : Plane3d a units coordinates -> Direction3d a coordinates
nomalDirection = \plane ->
    p = Types.fromPlane3d plane

    p.normalDirection