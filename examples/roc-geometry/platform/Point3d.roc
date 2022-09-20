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
    imports [
        pf.Quantity.{ Quantity },
        pf.Pixels.{ Pixels },
        pf.Vector3d.{ Vector3d },
        pf.Types,
    ]


Point3d a units coordinates : Types.Point3d a units coordinates


xyz : Quantity a units, Quantity a units, Quantity a units -> Point3d a units coordinates
xyz = \x, y, z ->
    Types.toPoint3d
        {
            x: Quantity.fromQty x,
            y: Quantity.fromQty y,
            z: Quantity.fromQty z,
        }


pixels : Quantity a Pixels, Quantity a Pixels, Quantity a Pixels -> Point3d a Pixels coordinates
pixels = xyz



toPixels : Point3d a Pixels coordinates -> { x : Quantity a Pixels, y : Quantity a Pixels, z : Quantity a Pixels }
toPixels = \pnt ->
    p = Types.fromPoint3d pnt
    {
        x: Quantity.toQty p.x,
        y: Quantity.toQty p.y,
        z: Quantity.toQty p.z,
    }


translateBy : Point3d a units coordinates, Vector3d a units coordinates -> Point3d a units coordinates
translateBy = \pnt, vec ->
    p = Types.fromPoint3d pnt
    vecRec = Vector3d.toXyz vec
    
    Types.toPoint3d
        {
            x: p.x + vecRec.x,
            y: p.y + vecRec.y,
            z: p.z + vecRec.z,
        }


xCoordinate : Point3d a unites coordinates -> Quantity a units
xCoordinate = \pnt ->
    { x } = Types.fromPoint3d pnt
    
    Quantity.toQty x


yCoordinate : Point3d a unites coordinates -> Quantity a units
yCoordinate = \pnt ->
    { y } = Types.fromPoint3d pnt
    
    Quantity.toQty y


zCoordinate : Point3d a unites coordinates -> Quantity a units
zCoordinate = \pnt ->
    { z } = Types.fromPoint3d pnt
    
    Quantity.toQty z