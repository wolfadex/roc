interface Types
    exposes [
        Point3d,
        toPoint3d,
        fromPoint3d,
        Direction3d,
        toDirection3d,
        fromDirection3d,
        Plane3d,
        toPlane3d,
        fromPlane3d,
        Vector3d,
        toVector3d,
        fromVector3d,
    ]
    imports []


Point3d a units coordinates := { x : Frac a, y : Frac a, z : Frac a }
toPoint3d = \args -> @Point3d args
fromPoint3d = \@Point3d args -> args


Direction3d a coordinates := { x : Frac a, y : Frac a, z : Frac a }
toDirection3d = \args -> @Direction3d args
fromDirection3d = \@Direction3d args -> args


Plane3d a units coordinates :=
    {
        originPoint : Point3d a units coordinates,
        normalDirection : Direction3d a coordinates
    }
toPlane3d = \args -> @Plane3d args
fromPlane3d = \@Plane3d args -> args


Vector3d a units coordinates := { x : Frac a, y : Frac a, z : Frac a }
toVector3d = \args -> @Vector3d args
fromVector3d = \@Vector3d args -> args