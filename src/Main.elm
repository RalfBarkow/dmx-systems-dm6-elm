module Main exposing (main)

import Browser
import Html exposing (Html, div, text)
import Svg exposing (Svg, circle, rect, svg)
import Svg.Attributes as SA
import Svg.Events as SE
import SvgExtras exposing (cursorPointer, peAll, peNone)



-- MODEL


type alias Model =
    { selectedCircle : Maybe String }


init : Model
init =
    { selectedCircle = Nothing }



-- UPDATE


type Msg
    = SelectCircle String


update : Msg -> Model -> Model
update msg model =
    case msg of
        SelectCircle circleId ->
            { model
                | selectedCircle =
                    if model.selectedCircle == Just circleId then
                        Nothing

                    else
                        Just circleId
            }



-- VIEW


view : Model -> Html Msg
view model =
    div []
        [ div [] [ text "Click circles to select/deselect" ]
        , div [] [ text <| "Selected: " ++ (model.selectedCircle |> Maybe.withDefault "None") ]
        , div [ SA.class "fedwiki-container" ]
            [ svg
                [ SA.width "100%"
                , SA.height "400px"
                , SA.viewBox "0 0 800 600"
                ]
                [ -- FedWiki container
                  rect
                    [ SA.x "50"
                    , SA.y "50"
                    , SA.width "700"
                    , SA.height "500"
                    , SA.fill "#f8f8f8"
                    , SA.stroke "#ddd"
                    , SA.strokeWidth "2"
                    , peNone -- Background doesn't intercept clicks
                    ]
                    []

                -- Selectable circles
                , viewCircle "circle1" 200 200 model
                , viewCircle "circle2" 400 200 model
                , viewCircle "circle3" 600 200 model
                ]
            ]
        ]


viewCircle : String -> Float -> Float -> Model -> Svg Msg
viewCircle circleId cx cy model =
    let
        isSelected =
            model.selectedCircle == Just circleId

        fillColor =
            if isSelected then
                "#4CAF50"

            else
                "#2196F3"
    in
    circle
        [ SA.cx (String.fromFloat cx)
        , SA.cy (String.fromFloat cy)
        , SA.r "40"
        , SA.fill fillColor
        , SA.stroke "#333"
        , SA.strokeWidth
            (if isSelected then
                "3"

             else
                "1"
            )
        , peAll
        , cursorPointer
        , SE.onClick (SelectCircle circleId)
        ]
        []



-- MAIN


main : Program () Model Msg
main =
    Browser.sandbox
        { init = init
        , view = view
        , update = update
        }
