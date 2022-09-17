interface Triangle3d
    exposes [Triangle3d]
    imports [pf.Types, pf.Point3d.{Point3d}]


Triangle3d units coordinates := Types.Triangle3d units coordinates


from : Point3d units coordinates, Point3d units coordinates, Point3d units coordinates -> Triangle3d units coordinates
from = \p1, p2, p3 ->
    Triangle3d p1 p2 p3