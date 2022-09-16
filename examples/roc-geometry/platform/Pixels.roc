interface Pixels
    exposes [pixels, inPixels]
    imports [Quantity.{Quantity}]


Pixels : [Pixels]

pixels : a -> Quantity a Pixels
pixels = \n ->
    Quantity.toQty n

inPixels : Quantity a Pixels -> a 
inPixels = \pix -> Quantity.fromQty pix