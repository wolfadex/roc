app "breakout-2"
    packages { pf: "platform/main.roc" }
    imports [pf.Game.{ Bounds, Elem, Event }, pf.Pixels, pf.Quantity]
    provides [program] { Model } to pf

Model : { text : Str }

init : Bounds -> Model
init = \_ ->
    heightPx = Pixels.int 800
    height = Pixels.toInt heightPx
    { text: "Hello, World!" }

update : Model, Event -> Model
update = \model, _ -> model

render : Model -> List Elem
render = \model -> [Text model.text]

program = { init, update, render }
