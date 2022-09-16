interface Triangle3d
    exposes [pixels, inPixels]
    imports [Quantity.{Quantity}]


Triangle3d units coordinates : [Pixels]

pixels : a -> Quantity a Pixels
pixels = \n ->
    Quantity.toQty n

inPixels : Quantity a Pixels -> a 
inPixels = \pix -> Quantity.fromQty pix