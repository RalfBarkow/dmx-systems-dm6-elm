module DMXPage exposing (main)

import Browser
import Feature.DMX.Decoders as Dmx
import Feature.DMX.Http as DmxHttp
import Html exposing (Html, br, div, text)
import Http
import Json.Decode as D
import Time



-- MODEL


type alias Model =
    { topic : Maybe Dmx.Topic
    , error : Maybe String
    }


exampleConfig : DmxHttp.Config
exampleConfig =
    { base = "" -- IMPORTANT: same-origin calls through the proxy
    , headers = []
    }


init _ =
    ( { topic = Nothing, error = Nothing }
    , Http.request
        { method = "GET"
        , headers = exampleConfig.headers
        , url = DmxHttp.topicDeepUrl exampleConfig 830082
        , body = Http.emptyBody
        , expect = Http.expectJson GotTopic Dmx.topicDecoder
        , timeout = Nothing
        , tracker = Just "dmx:topicmap"
        }
    )



-- MSG


type Msg
    = GotTopic (Result Http.Error Dmx.Topic)



-- UPDATE


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        GotTopic (Ok t) ->
            ( { model | topic = Just t }, Cmd.none )

        GotTopic (Err e) ->
            ( { model | error = Just (Debug.toString e) }, Cmd.none )



-- VIEW


view : Model -> Html Msg
view model =
    case model.topic of
        Just t ->
            let
                name =
                    Dmx.topicmapName t |> Maybe.withDefault "(no name)"

                toMs typeUri =
                    t
                        |> Dmx.childByType typeUri
                        |> Maybe.map Dmx.childValue
                        |> Maybe.andThen Dmx.valueToPosix
                        |> Maybe.map Time.posixToMillis
                        |> Maybe.map String.fromInt
                        |> Maybe.withDefault "?"
            in
            div []
                [ text ("Topicmap: " ++ name)
                , br [] []
                , text ("Created ms: " ++ toMs "dmx.timestamps.created")
                , br [] []
                , text ("Modified ms: " ++ toMs "dmx.timestamps.modified")
                ]

        Nothing ->
            case model.error of
                Just e ->
                    text ("Error: " ++ e)

                Nothing ->
                    text "Loading…"


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none



-- PROGRAM


main : Program () Model Msg
main =
    Browser.element
        { init = init
        , update = update
        , view = view
        , subscriptions = subscriptions
        }
