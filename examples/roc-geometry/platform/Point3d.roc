interface Point3d
    exposes [Point3d, pixels, toPixels]
    imports [pf.Quantity.{Quantity}, pf.Pixels.{Pixels}]


Point3d a units coordinates := { x : Quantity a units, y : Quantity a units, z : Quantity a units }


pixels : Quantity a Pixels, Quantity a Pixels, Quantity a Pixels -> Point3d a Pixels coordinates
pixels = \x, y, z ->
    @Point3d { x, y, z }


toPixels : Point3d a Pixels coordinates -> { x : Quantity a Pixels, y : Quantity a Pixels, z : Quantity a Pixels }
toPixels = \@Point3d p ->
    p
