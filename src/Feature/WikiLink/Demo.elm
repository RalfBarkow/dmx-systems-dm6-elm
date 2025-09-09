module Feature.WikiLink.Demo exposing (main)

import Browser
import Compat.WikiLink.Parser as P
import Compat.WikiLink.Regex as R
import Html exposing (Html, button, div, h2, pre, text, textarea)
import Html.Attributes as HA
import Html.Events exposing (onClick, onInput)



-- MODEL


type alias Model =
    { input : String
    , parsedSegments : List P.Segment
    , wikiOnly : List String
    , slugs : List String
    }


init : () -> ( Model, Cmd Msg )
init _ =
    ( { input = "A [[One]] and [https://ex.com ext] and [[Two Three]]!"
      , parsedSegments = []
      , wikiOnly = []
      , slugs = []
      }
    , Cmd.none
    )



-- UPDATE


type Msg
    = SetInput String
    | RunParse


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        SetInput s ->
            ( { model | input = s }, Cmd.none )

        RunParse ->
            let
                segments =
                    case P.parseLine model.input of
                        Ok segs ->
                            segs

                        Err _ ->
                            []

                onlyWiki =
                    R.parse model.input

                slugs =
                    List.map R.slug onlyWiki
            in
            ( { model | parsedSegments = segments, wikiOnly = onlyWiki, slugs = slugs }
            , Cmd.none
            )



-- VIEW


view : Model -> Html Msg
view model =
    div [ HA.style "padding" "12px", HA.style "font" "14px/1.4 system-ui" ]
        [ h2 [] [ text "WikiLink Demo (Regex + Parser)" ]
        , textarea
            [ HA.value model.input
            , onInput SetInput
            , HA.style "width" "100%"
            , HA.style "height" "6rem"
            ]
            []
        , div [ HA.style "margin" "8px 0" ]
            [ button [ onClick RunParse ] [ text "Parse" ] ]
        , div []
            [ h2 [] [ text "Parser.parseLine → segments" ]
            , pre [] [ text (segmentsToString model.parsedSegments) ]
            , h2 [] [ text "Regex.parse → [[...]] only" ]
            , pre [] [ text (fromListString model.wikiOnly) ]
            , h2 [] [ text "Slug (Regex.slug over [[...]] results)" ]
            , pre [] [ text (fromListString model.slugs) ]
            ]
        ]


segmentsToString : List P.Segment -> String
segmentsToString segs =
    segs
        |> List.map
            (\s ->
                case s of
                    P.Plain t ->
                        "Plain " ++ Debug.toString t

                    P.Wiki t ->
                        "Wiki  " ++ Debug.toString t

                    P.ExtLink url label ->
                        "Ext   " ++ Debug.toString ( url, label )
            )
        |> String.join "\n"


fromListString : List String -> String
fromListString =
    Debug.toString



-- MAIN


main : Program () Model Msg
main =
    Browser.element { init = init, update = update, view = view, subscriptions = \_ -> Sub.none }
