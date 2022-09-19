interface Point3d
    exposes [
        Point3d,
        pixels,
        toPixels,
        xyz,
        translateBy,
        xCoordinate,
        yCoordinate,
        zCoordinate,
    ]
    imports [pf.Quantity.{Quantity}, pf.Pixels.{Pixels}, pf.Vector3d.{Vector3d}]


Point3d a units coordinates := { x : Frac a, y : Frac a, z : Frac a }


xyz : Quantity a units, Quantity a units, Quantity a units -> Point3d a units coordinates
xyz = \x, y, z ->
    @Point3d
        {
            x: Quantity.fromQty x,
            y: Quantity.fromQty y,
            z: Quantity.fromQty z,
        }


pixels : Quantity a Pixels, Quantity a Pixels, Quantity a Pixels -> Point3d a Pixels coordinates
pixels = xyz



toPixels : Point3d a Pixels coordinates -> { x : Quantity a Pixels, y : Quantity a Pixels, z : Quantity a Pixels }
toPixels = \@Point3d p ->
    {
        x: Quantity.toQty p.x,
        y: Quantity.toQty p.y,
        z: Quantity.toQty p.z,
    }


translateBy : Point3d a units coordinates, Vector3d a units coordinates -> Point3d a units coordinates
translateBy = \@Point3d p, vec ->
    vecRec = Vector3d.toXyz vec
    
    @Point3d
        {
            x: p.x + vecRec.x,
            y: p.y + vecRec.y,
            z: p.z + vecRec.z,
        }


xCoordinate : Point3d a unites coordinates -> Quantity a units
xCoordinate = \@Point3d { x } -> Quantity.toQty x


yCoordinate : Point3d a unites coordinates -> Quantity a units
yCoordinate = \@Point3d { y } -> Quantity.toQty y


zCoordinate : Point3d a unites coordinates -> Quantity a units
zCoordinate = \@Point3d { z } -> Quantity.toQty z