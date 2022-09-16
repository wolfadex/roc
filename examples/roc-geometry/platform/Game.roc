interface Game
    exposes [Bounds, Elem, Event]
    imports [pf.Quantity.{Quantity}, pf.Pixels.{Pixels}]

Rgba : { r : F32, g : F32, b : F32, a : F32 }

Bounds : { height : Quantity F32 Pixels, width : Quantity F32 Pixels }

Elem : [
    Rect { color : Rgba, left : Quantity F32 Pixels, top : Quantity F32 Pixels, width : Quantity F32 Pixels, height : Quantity F32 Pixels },
    Text Str,
]

KeyCode : [Left, Right, Other]

Event : [
    Resize { width : Quantity F32 Pixels, height : Quantity F32 Pixels },
    KeyDown KeyCode,
    KeyUp KeyCode,
    Tick U128,
]
