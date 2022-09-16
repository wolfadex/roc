app "breakout"
    packages { pf: "platform/main.roc" }
    imports [pf.Game.{ Bounds, Elem, Event }, pf.Pixels.{Pixels}, pf.Quantity.{Quantity}]
    provides [program] { Model } to pf

paddleWidth = 0.2 # width of the paddle, as a % of screen width
paddleHeight = Pixels.pixels 50 # height of the paddle
paddleSpeed = Pixels.pixels 65 # how far the paddle moves per keypress
blockHeight = Pixels.pixels 80 # height of a block
blockBorder = 0.025 # border of a block, as a % of its width
ballSize = Pixels.pixels 55
numRows = 4
numCols = 8
numBlocks = numRows * numCols

Model : {
    # Screen height and width
    height : Quantity F32 Pixels,
    width : Quantity F32 Pixels,
    # Paddle X-coordinate
    paddleX : Quantity F32 Pixels,
    # Ball coordinates
    ballX : Quantity F32 Pixels,
    ballY : Quantity F32 Pixels,
    dBallX : Quantity F32 Pixels,
    # delta x - how much it moves per tick
    dBallY : Quantity F32 Pixels,
    # delta y - how much it moves per tick
}

init : Bounds -> Model
init = \{ width, height  } ->
    {
        # Screen height and width
        width,
        height,
        # Paddle X-coordinate
        paddleX: width |> Quantity.scaleBy 0.5 |> Quantity.minus (width |> Quantity.scaleBy 0.5 |> Quantity.scaleBy paddleWidth),
        # Ball coordinates
        ballX: width |> Quantity.scaleBy 0.5,
        ballY: height |> Quantity.scaleBy 0.4,
        # Delta - how much ball moves in each tick
        dBallX: Pixels.pixels 4,
        dBallY: Pixels.pixels 4,
    }

update : Model, Event -> Model
update = \model, event ->
    when event is
        Resize size ->
            { model & width: size.width, height: size.height }

        KeyDown Left ->
            { model & paddleX: model.paddleX |> Quantity.minus paddleSpeed }

        KeyDown Right ->
            { model & paddleX: model.paddleX |> Quantity.plus paddleSpeed }

        Tick _ ->
            tick model

        _ ->
            model

tick : Model -> Model
tick = \model ->
    model
    |> moveBall

moveBall : Model -> Model
moveBall = \model ->
    ballX = model.ballX |> Quantity.plus model.dBallX
    ballY = model.ballY |> Quantity.plus model.dBallY

    paddleTop = model.height |> Quantity.minus blockHeight |> Quantity.minus (paddleHeight |> Quantity.scaleBy 2)
    paddleLeft = model.paddleX
    paddleRight = paddleLeft |> Quantity.plus (model.width |> Quantity.scaleBy paddleWidth)

    # If its y used to be less than the paddle, and now it's greater than or equal,
    # then this is the frame where the ball collided with it.
    crossingPaddle = (model.ballY |> Quantity.lessThan paddleTop) && (ballY |> Quantity.greaterThanEqual paddleTop)

    # If it collided with the paddle, bounce off.
    directionChange =
        # if crossingPaddle && (ballX >= paddleLeft && ballX <= paddleRight) then
        if crossingPaddle && ((ballX |> Quantity.greaterThanEqual paddleLeft) && (ballX |> Quantity.lessThanEqual paddleRight)) then
            -1f32
        else
            1f32

    dBallX = model.dBallX |> Quantity.scaleBy directionChange
    dBallY = model.dBallY |> Quantity.scaleBy directionChange

    { model & ballX, ballY, dBallX, dBallY }

render : Model -> List Elem
render = \model ->

    blocks = List.map
        (List.range 0 numBlocks)
        \index ->
            col =
                Num.rem index numCols
                |> Num.toF32

            row =
                index
                // numCols
                |> Num.toF32

            red = col / Num.toF32 numCols
            green = row / Num.toF32 numRows
            blue = Num.toF32 index / Num.toF32 numBlocks

            color = { r: red * 0.8, g: 0.2 + green * 0.6, b: 0.2 + blue * 0.8, a: 1 }

            { row, col, color }

    blockWidth = model.width |> Quantity.divideBy numCols

    rects =
        List.joinMap
            blocks
            \{ row, col, color } ->
                # left = Num.toF32 col * blockWidth
                left = blockWidth |> Quantity.scaleBy col
                # top = Num.toF32 (row * blockHeight)
                top = blockHeight |> Quantity.scaleBy row
                # border = blockBorder * blockWidth
                border = blockWidth |> Quantity.scaleBy blockBorder

                outer = Rect {
                    left,
                    top,
                    width: blockWidth,
                    height: blockHeight,
                    color: { r: color.r * 0.8, g: color.g * 0.8, b: color.b * 0.8, a: 1 },
                }

                inner = Rect {
                    left: left |> Quantity.plus border,
                    top: top |> Quantity.plus border,
                    width: blockWidth |> Quantity.minus (border |> Quantity.scaleBy 2),
                    height: blockHeight |> Quantity.minus (border |> Quantity.scaleBy 2),
                    color,
                }

                [outer, inner]

    ball =
        color = { r: 0.7, g: 0.3, b: 0.9, a: 1.0 }
        width = ballSize
        height = ballSize
        left = model.ballX
        top = model.ballY

        Rect { left, top, width, height, color }

    paddle =
        color = { r: 0.8, g: 0.8, b: 0.8, a: 1.0 }
        width =  model.width |> Quantity.scaleBy paddleWidth
        height = paddleHeight
        left = model.paddleX
        top = model.height |> Quantity.minus blockHeight |> Quantity.minus height

        Rect { left, top, width, height, color }

    List.concat rects [paddle, ball]

program = { init, update, render }
