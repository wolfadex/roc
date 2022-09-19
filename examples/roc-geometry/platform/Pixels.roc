interface Pixels
    exposes [pixels, inPixels]
    imports [Quantity.{Quantity}]


Pixels : [Pixels]

pixels : Frac a -> Quantity a Pixels
pixels = \n ->
    Quantity.toQty n

inPixels : Quantity a Pixels -> Frac a
inPixels = \pix -> Quantity.fromQty pix