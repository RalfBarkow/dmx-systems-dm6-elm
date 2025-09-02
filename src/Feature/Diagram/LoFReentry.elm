module Feature.Diagram.LoFReentry exposing
    ( Model
    , Msg(..)
    , init
    , update
    , view
    , viewDemo
      -- quick embed without wiring into your Main
    )

{-| Experiments from _Wiedereintritt in die Form_ (pp. 60–61).

Step mapping (iconic → LoF AST, purely illustrative):

1.  ○ => Box Void
2.  m marks the outside => Box Void (annotation only)
3.  no mark inside (invariant)
4.  m = ○ => m ≡ Box Void
5.  insert m into the form => Juxt [Box Void, Box Void]
6.  indistinguishable => Juxt [Box Void, Box Void] ≡ Box Void

This component renders each step and offers Prev/Next controls.

-}

import Browser
import Html exposing (Html, button, div, text)
import Html.Attributes as HA
import Html.Events exposing (onClick)
import Svg exposing (..)
import Svg.Attributes as SA



-- MODEL


type alias Model =
    { step : Step }


type Step
    = S1_Circle
    | S2_MarkOutside
    | S3_NoMarkInside
    | S4_MarkIsCircle
    | S5_InsertMarkBack
    | S6_Indistinguishable


init : Model
init =
    { step = S1_Circle }



-- UPDATE


type Msg
    = Next
    | Prev
    | Reset


update : Msg -> Model -> Model
update msg model =
    case msg of
        Reset ->
            { model | step = S1_Circle }

        Prev ->
            { model | step = prev model.step }

        Next ->
            { model | step = next model.step }


prev : Step -> Step
prev step =
    case step of
        S1_Circle ->
            S1_Circle

        S2_MarkOutside ->
            S1_Circle

        S3_NoMarkInside ->
            S2_MarkOutside

        S4_MarkIsCircle ->
            S3_NoMarkInside

        S5_InsertMarkBack ->
            S4_MarkIsCircle

        S6_Indistinguishable ->
            S5_InsertMarkBack


next : Step -> Step
next step =
    case step of
        S1_Circle ->
            S2_MarkOutside

        S2_MarkOutside ->
            S3_NoMarkInside

        S3_NoMarkInside ->
            S4_MarkIsCircle

        S4_MarkIsCircle ->
            S5_InsertMarkBack

        S5_InsertMarkBack ->
            S6_Indistinguishable

        S6_Indistinguishable ->
            S6_Indistinguishable



-- VIEW


view : Model -> Html Msg
view model =
    div [ HA.style "display" "grid", HA.style "gap" "12px" ]
        [ viewTitle model.step
        , viewStep model.step
        , controls model.step
        ]


viewTitle : Step -> Html msg
viewTitle step =
    let
        t =
            case step of
                S1_Circle ->
                    "Erstes Experiment — Zieh einen Kreis."

                S2_MarkOutside ->
                    "Lass eine Markierung m das Äußere anzeigen."

                S3_NoMarkInside ->
                    "Keine Markierung zeigt das Innere an."

                S4_MarkIsCircle ->
                    "Lass die Markierung m ein Kreis sein (m = ○)."

                S5_InsertMarkBack ->
                    "Füge die Markierung erneut in die Form ein."

                S6_Indistinguishable ->
                    "Nun sind Kreis und Markierung ununterscheidbar: ○ ○ = ○"
    in
    div [ HA.style "font-weight" "600" ] [ text t ]


controls : Step -> Html Msg
controls step =
    div [ HA.style "display" "flex", HA.style "gap" "8px" ]
        [ button [ onClick Prev, HA.disabled (step == S1_Circle) ] [ text "◀ Prev" ]
        , button [ onClick Reset ] [ text "Reset" ]
        , button [ onClick Next, HA.disabled (step == S6_Indistinguishable) ] [ text "Next ▶" ]
        ]



-- Simple geometry helpers


circleAt : Float -> Float -> Float -> Svg msg
circleAt cx cy r =
    circle [ SA.cx (String.fromFloat cx), SA.cy (String.fromFloat cy), SA.r (String.fromFloat r), SA.fill "none", SA.stroke "black", SA.strokeWidth "2" ] []


labelAt : Float -> Float -> String -> Svg msg
labelAt x y s =
    text_ [ SA.x (String.fromFloat x), SA.y (String.fromFloat y), SA.fontSize "16px" ] [ Svg.text s ]


equalsAt : Float -> Float -> Svg msg
equalsAt x y =
    text_ [ SA.x (String.fromFloat x), SA.y (String.fromFloat y), SA.fontSize "22px" ] [ Svg.text "=" ]


viewStep : Step -> Html msg
viewStep step =
    svg [ SA.viewBox "0 0 420 180", SA.width "420px", SA.height "180px", SA.style "background:#fff" ]
        (case step of
            S1_Circle ->
                [ circleAt 210 90 45 ]

            S2_MarkOutside ->
                [ circleAt 210 90 45
                , labelAt 300 95 "m"
                ]

            S3_NoMarkInside ->
                [ circleAt 210 90 45
                , labelAt 300 95 "m"
                , labelAt 206 95 "" -- intentionally empty to emphasize “no mark inside”
                ]

            S4_MarkIsCircle ->
                [ labelAt 140 95 "m"
                , equalsAt 160 95
                , circleAt 210 90 45
                ]

            S5_InsertMarkBack ->
                [ circleAt 150 90 45
                , circleAt 270 90 45
                ]

            S6_Indistinguishable ->
                [ circleAt 120 90 45
                , circleAt 220 90 45
                , equalsAt 270 95
                , circleAt 340 90 45
                ]
        )



-- QUICK EMBED (no Main wiring needed)


viewDemo : Html msg
viewDemo =
    let
        -- static preview of the whole sequence stacked vertically
        frame s =
            svg [ SA.viewBox "0 0 420 180", SA.width "420px", SA.height "180px", SA.style "background:#fff; margin-bottom:8px; border:1px solid #ddd" ]
                (case s of
                    S1_Circle ->
                        [ circleAt 210 90 45 ]

                    S2_MarkOutside ->
                        [ circleAt 210 90 45, labelAt 300 95 "m" ]

                    S3_NoMarkInside ->
                        [ circleAt 210 90 45, labelAt 300 95 "m" ]

                    S4_MarkIsCircle ->
                        [ labelAt 140 95 "m", equalsAt 160 95, circleAt 210 90 45 ]

                    S5_InsertMarkBack ->
                        [ circleAt 150 90 45, circleAt 270 90 45 ]

                    S6_Indistinguishable ->
                        [ circleAt 120 90 45, circleAt 220 90 45, equalsAt 270 95, circleAt 340 90 45 ]
                )
    in
    div []
        (List.map frame
            [ S1_Circle, S2_MarkOutside, S3_NoMarkInside, S4_MarkIsCircle, S5_InsertMarkBack, S6_Indistinguishable ]
        )
