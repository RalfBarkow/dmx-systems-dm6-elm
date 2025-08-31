module Feature.Diagram.LoF exposing
    ( LoF(..)
    , callingExample
    , crossingExample
    , reduce
    , rewriteOnce
    , viewCallingDemo
    , viewCrossingDemo
    , viewStructure
    )

import Html exposing (Html)
import Html.Attributes as HA
import Svg exposing (..)
import Svg.Attributes as SA


{-| Iconic containment AST
Void = unmarked state
Box x = (x)
Juxt [a,b..] = juxtaposition a b ...
-}
type LoF
    = Void
    | Box LoF
    | Juxt (List LoF)



-- EXAMPLES


callingExample : LoF
callingExample =
    -- ()()  ==>  ()
    Juxt [ Box Void, Box Void ]


crossingExample : LoF
crossingExample =
    -- (())  ==>  (void)  ==>  void   (Crossing removes a double nest)
    Box (Box Void)



-- REWRITE ENGINE (single small-step)
-- One-step, top-down rewrite


rewriteOnce : LoF -> LoF
rewriteOnce term =
    case term of
        -- CROSSING  (()) ⇒ ∅
        Box (Box Void) ->
            Void

        -- CALLING  ()() ⇒ ()
        Juxt [ Box Void, Box Void ] ->
            Box Void

        -- Juxtaposition neutral/shape rules
        Juxt [] ->
            Void

        Juxt [ x ] ->
            x

        Juxt (Void :: xs) ->
            Juxt xs

        Juxt (x :: Void :: xs) ->
            Juxt (x :: xs)

        -- Walk into children (stop after the first inner change)
        Box inner ->
            let
                inner1 =
                    rewriteOnce inner
            in
            if inner1 /= inner then
                Box inner1

            else
                Box inner

        Juxt xs ->
            Juxt (rewriteListOnce xs)

        -- Base
        Void ->
            Void


rewriteListOnce : List LoF -> List LoF
rewriteListOnce xs =
    case xs of
        [] ->
            []

        y :: ys ->
            let
                y1 =
                    rewriteOnce y
            in
            if y1 /= y then
                y1 :: ys

            else
                y :: rewriteListOnce ys


reduce : LoF -> LoF
reduce t =
    let
        t2 =
            rewriteOnce t
    in
    if t2 == t then
        t

    else
        reduce t2



-- RENDERING (iconic SVG)


{-| Compute layout size (w,h) for a term.
-}
measure : LoF -> ( Float, Float )
measure term =
    let
        padding =
            12

        baseW =
            60

        baseH =
            40

        gap =
            16
    in
    case term of
        Void ->
            ( baseW |> toFloat, baseH |> toFloat )

        Box inner ->
            let
                ( w, h ) =
                    measure inner
            in
            ( w + 2 * padding, h + 2 * padding )

        Juxt xs ->
            case xs of
                [] ->
                    ( toFloat baseW, toFloat baseH )

                _ ->
                    let
                        sizes =
                            List.map measure xs

                        wSum =
                            sizes
                                |> List.map Tuple.first
                                |> List.sum

                        maxH =
                            sizes
                                |> List.map Tuple.second
                                |> List.maximum
                                |> Maybe.withDefault (toFloat baseH)

                        totalW =
                            wSum + toFloat gap * toFloat (List.length xs - 1)
                    in
                    ( totalW, maxH )


{-| Render a term at (x,y) as nested rectangles. Returns SVG nodes.
-}
renderAt : Float -> Float -> LoF -> List (Svg msg)
renderAt x y term =
    let
        padding =
            12

        strokeW =
            "2"

        rect : Float -> Float -> Float -> Float -> Svg msg
        rect rx ry w h =
            Svg.rect
                [ SA.x (String.fromFloat rx)
                , SA.y (String.fromFloat ry)
                , SA.width (String.fromFloat w)
                , SA.height (String.fromFloat h)
                , SA.fill "none"
                , SA.stroke "currentColor"
                , SA.strokeWidth strokeW
                , SA.rx "6"
                , SA.ry "6"
                ]
                []
    in
    case term of
        Void ->
            -- Show the void as a faint dashed outline to keep layout visible
            [ Svg.rect
                [ SA.x (String.fromFloat x)
                , SA.y (String.fromFloat y)
                , SA.width "60"
                , SA.height "40"
                , SA.fill "none"
                , SA.stroke "currentColor"
                , SA.strokeOpacity "0.3"
                , SA.strokeDasharray "4,3"
                , SA.rx "6"
                , SA.ry "6"
                ]
                []
            ]

        Box inner ->
            let
                ( w, h ) =
                    measure term

                outer =
                    rect x y w h

                innerNodes =
                    renderAt (x + padding) (y + padding) inner
            in
            outer :: innerNodes

        Juxt xs ->
            let
                gap =
                    16

                step sub ( accNodes, cursorX ) =
                    let
                        ( w, _ ) =
                            measure sub

                        nodesHere =
                            renderAt cursorX y sub
                    in
                    ( accNodes ++ nodesHere, cursorX + w + gap )

                ( allNodes, _ ) =
                    List.foldl step ( [], x ) xs
            in
            allNodes


viewStructure : LoF -> Html msg
viewStructure term =
    let
        ( w, h ) =
            measure term

        pad =
            8

        wTotal =
            w + 2 * pad

        hTotal =
            h + 2 * pad
    in
    svg
        [ SA.viewBox ("0 0 " ++ String.fromFloat wTotal ++ " " ++ String.fromFloat hTotal)
        , SA.width (String.fromFloat (wTotal |> max 120))
        , SA.height (String.fromFloat (hTotal |> max 60))
        , SA.style "border:1px solid var(--border,#444); border-radius:10px; padding:4px;"
        ]
        (renderAt pad pad term)



-- READY-MADE DEMOS (before → after with a rule label & arrow)


viewCallingDemo : Html msg
viewCallingDemo =
    rulePanel "Calling  ()() ⇒ ()" callingExample (rewriteOnce callingExample)


viewCrossingDemo : Html msg
viewCrossingDemo =
    rulePanel "Crossing  (()) ⇒ ∅" crossingExample (rewriteOnce crossingExample)


rulePanel : String -> LoF -> LoF -> Html msg
rulePanel title before after =
    let
        left =
            viewStructure before

        right =
            viewStructure after
    in
    svg
        [ SA.viewBox "0 0 700 220"
        , SA.width "700"
        , SA.height "220"
        , SA.style "display:block; width:100%; max-width:700px;"
        ]
        ([ -- Title
           Svg.text_
            [ SA.x "20", SA.y "24", SA.fontFamily "monospace", SA.fontSize "16" ]
            [ Svg.text title ]
         ]
            ++ translate 20 40 (embed left)
            ++ [ arrow 330 110 360 110 ]
            ++ translate 380 40 (embed right)
        )



-- Helpers to embed Html (the small inner svg) into outer svg via foreignObject


embed : Html msg -> Svg msg
embed inner =
    foreignObject
        [ SA.x "0", SA.y "0", SA.width "300", SA.height "160" ]
        [ Html.div
            [ HA.style "width" "300px"
            , HA.style "height" "160px"
            ]
            [ inner ]
        ]


translate : Float -> Float -> Svg msg -> List (Svg msg)
translate dx dy node =
    [ g [ SA.transform ("translate(" ++ String.fromFloat dx ++ "," ++ String.fromFloat dy ++ ")") ] [ node ] ]


arrow : Float -> Float -> Float -> Float -> Svg msg
arrow x1 y1 x2 y2 =
    let
        head =
            6
    in
    g []
        [ line
            [ SA.x1 (String.fromFloat x1)
            , SA.y1 (String.fromFloat y1)
            , SA.x2 (String.fromFloat x2)
            , SA.y2 (String.fromFloat y2)
            , SA.stroke "currentColor"
            , SA.strokeWidth "2"
            ]
            []
        , polygon
            [ SA.points (arrowHeadPoints x1 y1 x2 y2 head)
            , SA.fill "currentColor"
            ]
            []
        ]


arrowHeadPoints : Float -> Float -> Float -> Float -> Float -> String
arrowHeadPoints x1 y1 x2 y2 size =
    let
        dx =
            x2 - x1

        dy =
            y2 - y1

        len =
            sqrt (dx * dx + dy * dy)

        ux =
            if len == 0 then
                0

            else
                dx / len

        uy =
            if len == 0 then
                0

            else
                dy / len

        px =
            -uy

        py =
            ux

        ax =
            x2

        ay =
            y2

        bx =
            x2 - ux * size + px * size

        by =
            y2 - uy * size + py * size

        cx =
            x2 - ux * size - px * size

        cy =
            y2 - uy * size - py * size
    in
    String.fromFloat ax
        ++ ","
        ++ String.fromFloat ay
        ++ " "
        ++ String.fromFloat bx
        ++ ","
        ++ String.fromFloat by
        ++ " "
        ++ String.fromFloat cx
        ++ ","
        ++ String.fromFloat cy
