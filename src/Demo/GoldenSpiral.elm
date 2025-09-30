module Demo.GoldenSpiral exposing (view)

import Html exposing (Html)
import Svg exposing (Svg)
import Svg.Attributes as SA


{-| A golden–spiral-ish chain of tangent circles.
Each new circle’s radius = r \* phi^i and its center is placed
tangent to the previous circle, turning 90° each time.
-}
phi : Float
phi =
    (1 + sqrt 5) / 2


type alias Circle =
    { cx : Float, cy : Float, r : Float }


genCircles : Int -> Float -> List Circle
genCircles steps r0 =
    let
        go i theta prev acc =
            if i == steps then
                List.reverse acc

            else
                let
                    r =
                        r0 * (phi ^ toFloat i)

                    -- distance to stay tangent to previous
                    d =
                        case prev of
                            Nothing ->
                                0

                            Just p ->
                                p.r + r

                    ( dx, dy ) =
                        ( d * cos theta, d * sin theta )

                    ( cx, cy ) =
                        case prev of
                            Nothing ->
                                ( 0, 0 )

                            Just p ->
                                ( p.cx + dx, p.cy + dy )

                    me =
                        { cx = cx, cy = cy, r = r }

                    nextTheta =
                        theta + (pi / 2)
                in
                go (i + 1) nextTheta (Just me) (me :: acc)
    in
    go 0 0 Nothing []


{-| Simple auto-fit: compute bbox of circles to set a nice viewBox.
-}
bbox : List Circle -> { minX : Float, minY : Float, maxX : Float, maxY : Float }
bbox cs =
    case cs of
        [] ->
            { minX = 0, minY = 0, maxX = 0, maxY = 0 }

        c0 :: rest ->
            let
                init =
                    { minX = c0.cx - c0.r
                    , minY = c0.cy - c0.r
                    , maxX = c0.cx + c0.r
                    , maxY = c0.cy + c0.r
                    }
            in
            List.foldl
                (\c bb ->
                    { minX = min bb.minX (c.cx - c.r)
                    , minY = min bb.minY (c.cy - c.r)
                    , maxX = max bb.maxX (c.cx + c.r)
                    , maxY = max bb.maxY (c.cy + c.r)
                    }
                )
                init
                rest


toSvg : List Circle -> Svg msg
toSvg cs =
    let
        bb =
            bbox cs

        pad =
            16

        vbX =
            bb.minX - pad

        vbY =
            bb.minY - pad

        vbW =
            (bb.maxX - bb.minX) + 2 * pad

        vbH =
            (bb.maxY - bb.minY) + 2 * pad
    in
    Svg.svg
        [ SA.viewBox (String.fromFloat vbX ++ " " ++ String.fromFloat vbY ++ " " ++ String.fromFloat vbW ++ " " ++ String.fromFloat vbH)
        , SA.width "820"
        , SA.height "460"
        , SA.stroke "black"
        , SA.fill "none"
        , SA.strokeWidth "3"
        ]
        (List.map
            (\c ->
                Svg.circle
                    [ SA.cx (String.fromFloat c.cx)
                    , SA.cy (String.fromFloat c.cy)
                    , SA.r (String.fromFloat c.r)
                    ]
                    []
            )
            cs
        )


view : Html msg
view =
    -- tweak steps or r0 to taste
    let
        circles =
            genCircles 12 6
    in
    toSvg circles
