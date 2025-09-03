module Feature.Diagram.LoFReentryAll exposing
    ( Model
    , Msg(..)
    , init
    , update
    , view
    , viewDemo
    )

{-| All “Wiedereintritt in die Form” experiments (pp.60–66):

• Experiment 1 (pp.60–61)
• Experiment 2 (pp.62–63)
• Experiment 3 (pp.63–64)
• Experiment 4 (p.65)

This renders each experiment as a sequence of frames with Prev/Next controls.
The drawings are iconic, matching the book’s figures.

-}

import Browser
import Html exposing (Html, button, div, option, select, text)
import Html.Attributes as HA
import Html.Events exposing (onClick, onInput)
import Svg exposing (..)
import Svg.Attributes as SA



-- MODEL


type alias Model =
    { exp : Experiment
    , idx : Int
    }


type Experiment
    = E1
    | E2
    | E3
    | E4


init : Model
init =
    { exp = E1, idx = 0 }



-- UPDATE


type Msg
    = Prev
    | Next
    | Reset
    | Pick String


update : Msg -> Model -> Model
update msg model =
    case msg of
        Reset ->
            { model | idx = 0 }

        Prev ->
            { model | idx = max 0 (model.idx - 1) }

        Next ->
            let
                last =
                    List.length (frames model.exp) - 1
            in
            { model | idx = min last (model.idx + 1) }

        Pick tag ->
            let
                newExp =
                    case tag of
                        "E1" ->
                            E1

                        "E2" ->
                            E2

                        "E3" ->
                            E3

                        "E4" ->
                            E4

                        _ ->
                            E1
            in
            { exp = newExp, idx = 0 }



-- VIEW


view : Model -> Html Msg
view model =
    let
        fs =
            frames model.exp

        safeIdx =
            clamp 0 (List.length fs - 1) model.idx

        frame =
            List.drop safeIdx fs |> List.head
    in
    div [ HA.style "display" "grid", HA.style "gap" "12px", HA.style "max-width" "460px" ]
        [ titleBar model
        , case frame of
            Just f ->
                div []
                    [ div [ HA.style "font-weight" "600" ] [ Svg.text f.title ]
                    , f.svg
                    ]

            Nothing ->
                div [] [ Svg.text "No frame." ]
        , controls model fs
        ]


titleBar : Model -> Html Msg
titleBar model =
    let
        label =
            case model.exp of
                E1 ->
                    "Experiment 1 (pp. 60–61)"

                E2 ->
                    "Experiment 2 (pp. 62–63)"

                E3 ->
                    "Experiment 3 (pp. 63–64)"

                E4 ->
                    "Experiment 4 (p. 65)"
    in
    div [ HA.style "display" "flex", HA.style "gap" "8px", HA.style "align-items" "center" ]
        [ select [ onInput Pick ]
            [ option [ HA.value "E1", selectedIf (model.exp == E1) ] [ Svg.text "E1" ]
            , option [ HA.value "E2", selectedIf (model.exp == E2) ] [ Svg.text "E2" ]
            , option [ HA.value "E3", selectedIf (model.exp == E3) ] [ Svg.text "E3" ]
            , option [ HA.value "E4", selectedIf (model.exp == E4) ] [ Svg.text "E4" ]
            ]
        , div [ HA.style "opacity" "0.7" ] [ Svg.text label ]
        ]


controls : Model -> List (Frame Msg) -> Html Msg
controls model fs =
    let
        last =
            List.length fs - 1
    in
    div [ HA.style "display" "flex", HA.style "gap" "8px" ]
        [ button [ onClick Prev, HA.disabled (model.idx == 0) ] [ Svg.text "◀ Prev" ]
        , button [ onClick Reset ] [ Svg.text "Reset" ]
        , button [ onClick Next, HA.disabled (model.idx >= last) ] [ Svg.text "Next ▶" ]
        , div [ HA.style "margin-left" "auto", HA.style "opacity" "0.7" ]
            [ Svg.text <| String.fromInt (model.idx + 1) ++ "/" ++ String.fromInt (last + 1) ]
        ]



-- FRAMES


type alias Frame msg =
    { title : String
    , svg : Svg msg
    }


frames : Experiment -> List (Frame msg)
frames exp =
    case exp of
        E1 ->
            framesE1

        E2 ->
            framesE2

        E3 ->
            framesE3

        E4 ->
            framesE4



-- EXPERIMENT 1  (pp. 60–61)


framesE1 : List (Frame msg)
framesE1 =
    [ simple "Zieh einen Kreis."
        [ circleAt 210 90 45 ]
    , simple "Lass eine Markierung m das Äußere anzeigen."
        [ circleAt 210 90 45, labelAt 300 95 "m" ]
    , simple "Keine Markierung zeigt das Innere an."
        [ circleAt 210 90 45, labelAt 300 95 "m" ]
    , simple "Lass die Markierung m ein Kreis sein (m = ○)."
        [ labelAt 140 95 "m", equalsAt 160 95, circleAt 210 90 45 ]
    , simple "Füge die Markierung erneut in die Form ein."
        [ circleAt 150 90 45, circleAt 270 90 45 ]
    , simple "Nun sind Kreis und Markierung ununterscheidbar: ○ ○ = ○"
        [ circleAt 120 90 45, circleAt 220 90 45, equalsAt 270 95, circleAt 340 90 45 ]
    ]



-- EXPERIMENT 2  (pp. 62–63)


framesE2 : List (Frame msg)
framesE2 =
    [ simple "Lass eine Markierung m das Innere des Kreisumfanges bezeichnen."
        [ circleAt 210 90 45, labelAt 206 95 "m" ]
    , simple "Lass keine Markierung das Äußere bezeichnen (Außen unmarkiert)."
        [ circleAt 210 90 45, labelAt 206 95 "m" ]
    , simple "Evaluation: Die Markierung bezieht sich auf den Raum, in dem sie steht."
        [ circleAt 210 90 45, labelAt 206 95 "m", equalsAt 310 95 ]
    , simple "Lass m ein Kreis sein (m = ○)."
        [ labelAt 140 95 "m", equalsAt 160 95, circleAt 210 90 45 ]
    , simple "Füge die Markierung erneut in die Form des Kreises ein."
        [ ringAt 210 90 45 22 ]
    , simple "Nach der Evaluation (ikonische Relation)."
        [ ringAt 140 90 45 22, equalsAt 240 95, circleAt 310 90 45 ]
    ]



-- EXPERIMENT 3  (pp. 63–64)


framesE3 : List (Frame msg)
framesE3 =
    [ simple "Zieh einen Kreis."
        [ circleAt 210 90 45 ]
    , simple "Lass m das Äußere des Kreisumfanges bezeichnen."
        [ circleAt 210 90 45, labelAt 300 95 "m" ]
    , simple "Lass eine gleiche Markierung m das Innere bezeichnen."
        [ circleAt 210 90 45, labelAt 300 95 "m", labelAt 206 95 "m" ]
    , simple "Beide Seiten gleich markiert → keine Unterscheidung durch Wert."
        [ circleAt 210 90 45, labelAt 300 95 "m", labelAt 206 95 "m" ]
    , simple "Lass m wieder ein Kreis sein (m = ○)."
        [ labelAt 140 95 "m", equalsAt 160 95, circleAt 210 90 45 ]
    , simple "Füge die Markierung neuerlich in die Form des Kreises ein."
        [ ringAt 150 90 45 22, circleAt 300 90 45 ]
    , simple "Wegen identischer Markierungen kann der ursprüngliche Kreis gestrichen werden."
        [ ringAt 140 90 45 22, equalsAt 240 95, circleAt 310 90 45, circleAt 380 90 45 ]
    , simple "Im ersten Experiment: ○ ○ = ○."
        [ circleAt 140 90 45, circleAt 240 90 45, equalsAt 300 95, circleAt 360 90 45 ]
    , simple "Daher: (Ring ○) = ○ (ikonisch)."
        [ ringAt 140 90 45 22, circleAt 240 90 45, equalsAt 300 95, circleAt 360 90 45 ]
    ]



-- EXPERIMENT 4  (p. 65)


framesE4 : List (Frame msg)
framesE4 =
    [ simple "Zieh einen Kreis."
        [ circleAt 210 90 45 ]
    , simple "Lass das Äußere unmarkiert."
        [ circleAt 210 90 45 ]
    , simple "Lass das Innere unmarkiert."
        [ circleAt 210 90 45 ]
    , simple "Aus E1: ○ ○ = ○."
        [ circleAt 140 90 45, circleAt 240 90 45, equalsAt 300 95, circleAt 360 90 45 ]
    , simple "Durch Umkehren des läuternden Vorgangs: ○ = m (ikonisch)."
        [ circleAt 140 90 45, equalsAt 220 95, labelAt 270 95 "m" ]
    , simple "Wert des Kreisumfanges bzgl. Außenraums entspricht nun dem Wert der Markierung."
        [ circleAt 210 90 45, labelAt 300 95 "m" ]
    ]



-- BASIC DRAWING


simple : String -> List (Svg msg) -> Frame msg
simple title shapes =
    { title = title
    , svg = canvas shapes
    }


canvas : List (Svg msg) -> Svg msg
canvas shapes =
    svg
        [ SA.viewBox "0 0 420 180"
        , SA.width "420px"
        , SA.height "180px"
        , SA.style "background:#fff"
        ]
        shapes


circleAt : Float -> Float -> Float -> Svg msg
circleAt cx cy r =
    circle
        [ SA.cx (String.fromFloat cx)
        , SA.cy (String.fromFloat cy)
        , SA.r (String.fromFloat r)
        , SA.fill "none"
        , SA.stroke "black"
        , SA.strokeWidth "2"
        ]
        []


ringAt : Float -> Float -> Float -> Float -> Svg msg
ringAt cx cy outer inner =
    g []
        [ circleAt cx cy outer
        , circleAt cx cy inner
        ]


labelAt : Float -> Float -> String -> Svg msg
labelAt x y s =
    text_
        [ SA.x (String.fromFloat x)
        , SA.y (String.fromFloat y)
        , SA.fontSize "16px"
        ]
        [ Svg.text s ]


equalsAt : Float -> Float -> Svg msg
equalsAt x y =
    text_
        [ SA.x (String.fromFloat x)
        , SA.y (String.fromFloat y)
        , SA.fontSize "22px"
        ]
        [ Svg.text "=" ]


selectedIf : Bool -> Html.Attribute msg
selectedIf b =
    if b then
        HA.selected True

    else
        HA.selected False



-- QUICK DEMO (stack all frames for visual QA)


viewDemo : Html msg
viewDemo =
    let
        block label fs =
            div [ HA.style "margin-bottom" "16px" ]
                (div [ HA.style "font-weight" "700", HA.style "margin" "6px 0" ] [ Html.text label ]
                    :: List.map (\f -> div [ HA.style "margin-bottom" "8px", HA.style "border" "1px solid #ddd" ] [ f.svg ]) fs
                )
    in
    div []
        [ block "E1" framesE1
        , block "E2" framesE2
        , block "E3" framesE3
        , block "E4" framesE4
        ]
