app "breakout"
    packages { pf: "platform/main.roc" }
    imports [
        pf.Game.{ Bounds, Elem, Event, Rgba },
        pf.Quantity.{ Quantity, Rate },
        pf.Pixels.{ Pixels },
        pf.Angle.{ Angle },
        pf.Point3d.{ Point3d },
        pf.Vector3d.{ Vector3d },
        pf.Direction3d.{ Direction3d },
        pf.Plane3d.{ Plane3d },
    ]
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

ScreenSpace : [ScreenSpace]

Tick : [Tick]

PixelsPerTick : Rate Pixels Tick

Model : {
    # Screen height and width
    height : Quantity F32 Pixels,
    width : Quantity F32 Pixels,
    # Paddle X-coordinate
    paddleX : Quantity F32 Pixels,
    ballPosition : Point3d F32 Pixels ScreenSpace,
    ballVelocity : Vector3d F32 PixelsPerTick ScreenSpace,
}

init : Bounds -> Model
init = \{ width, height  } ->
    {
        # Screen height and width
        width,
        height,
        # Paddle X-coordinate
        paddleX: width |> Quantity.scaleBy 0.5 |> Quantity.minus (width |> Quantity.scaleBy 0.5 |> Quantity.scaleBy paddleWidth),
        ballPosition: Point3d.pixels # 5.0f32 10.0f32 0.0f32,
                        (width |> Quantity.scaleBy 0.5)
                        (height |> Quantity.scaleBy 0.4)
                        (Pixels.pixels 0),
        ballVelocity: Direction3d.xy (Angle.degrees 45)
                        |> Vector3d.withLength (Pixels.pixels 4)
                        |> Vector3d.per (ticks 1)
    }

ticks : Frac a -> Quantity a Tick
ticks = \n -> Quantity.toQty n


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
    # ballTravelDistance : Vector3d F32 Pixels ScreenSpace
    ballTravelDistance = model.ballVelocity |> Vector3d.for (ticks 1)
    
    ballPosition : Point3d F32 Pixels ScreenSpace
    ballPosition =  model.ballPosition |> Point3d.translateBy ballTravelDistance

    paddleTop = model.height |> Quantity.minus blockHeight |> Quantity.minus (paddleHeight |> Quantity.scaleBy 2)
    paddleLeft = model.paddleX
    paddleRight = paddleLeft |> Quantity.plus (model.width |> Quantity.scaleBy paddleWidth)
    
    ballPositionPixels = Point3d.toPixels ballPosition

    ballPreviousPositionPixels = Point3d.toPixels model.ballPosition

    # If its y used to be less than the paddle, and now it's greater than or equal,
    # then this is the frame where the ball collided with it.
    crossingPaddle = (ballPreviousPositionPixels.y |> Quantity.lessThan paddleTop) && (ballPositionPixels.y |> Quantity.greaterThanEqual paddleTop) && ((ballPositionPixels.x |> Quantity.greaterThanEqual paddleLeft) && (ballPositionPixels.x |> Quantity.lessThanEqual paddleRight))

    crossingTop = (ballPreviousPositionPixels.y |> Quantity.greaterThan (Pixels.pixels 0)) && (ballPositionPixels.y |> Quantity.lessThanEqual (Pixels.pixels 0))

    crossingRightSide = (ballPreviousPositionPixels.x |> Quantity.plus ballSize |> Quantity.lessThan model.width) && (ballPositionPixels.x |> Quantity.plus ballSize |> Quantity.greaterThanEqual model.width)

    crossingLeftSide = (ballPreviousPositionPixels.x |> Quantity.greaterThan (Pixels.pixels 0)) && (ballPositionPixels.x |> Quantity.lessThanEqual (Pixels.pixels 0))

    # If it collided with the paddle, bounce off.
    ballVelocity =
        if crossingPaddle || crossingTop then
            (model.ballVelocity |> Vector3d.for (ticks 1))
                |> Vector3d.mirrorAcross (Plane3d.through Direction3d.negativeY ballPosition)
                |> Vector3d.per (ticks 1)
        else if crossingRightSide || crossingLeftSide then
            (model.ballVelocity |> Vector3d.for (ticks 1))
                |> Vector3d.mirrorAcross (Plane3d.through Direction3d.negativeX ballPosition)
                |> Vector3d.per (ticks 1)
        else
            model.ballVelocity

    { model & ballPosition, ballVelocity }

render : Model -> List Elem
render = \model ->

    blocks = List.map
        (List.range 0 numBlocks)
        \index ->
            col =
                Num.rem index numCols
                |> Num.toFrac

            row =
                index
                // numCols
                |> Num.toFrac

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
        left = Point3d.xCoordinate model.ballPosition
        top = Point3d.yCoordinate model.ballPosition

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