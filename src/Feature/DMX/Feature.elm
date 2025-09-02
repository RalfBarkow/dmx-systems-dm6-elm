module Feature.DMX.Feature exposing (Model, Msg(..), init, subscriptions, update)

import Feature.DMX.Decoders as Dmx
import Feature.DMX.PortClient as DmxPort
import Json.Decode as D
import Ports.Dmx as Port


type alias Model =
    { topic : Maybe Dmx.Topic
    , error : Maybe String
    }


type Msg
    = DmxOk Port.Response
    | DmxErr Port.Error


init : ( Model, Cmd Msg )
init =
    let
        ( cmd, subs ) =
            DmxPort.getTopicDeep
                { topicId = 830082
                , toMsg = DmxOk
                , onErr = DmxErr
                }
    in
    ( { topic = Nothing, error = Nothing }, cmd )


subscriptions : Model -> Sub Msg
subscriptions _ =
    -- we get the Sub back the same way as in init:
    DmxPort.getTopicDeep
        { topicId = 0 -- unused here, we only want subs; ids are carried in the response
        , toMsg = DmxOk
        , onErr = DmxErr
        }
        |> Tuple.second


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        DmxOk resp ->
            if resp.ok then
                case D.decodeValue Dmx.topicDecoder resp.data of
                    Ok t ->
                        ( { model | topic = Just t }, Cmd.none )

                    Err e ->
                        ( { model | error = Just ("decode: " ++ D.errorToString e) }
                        , Cmd.none
                        )

            else
                ( { model | error = Just ("HTTP " ++ String.fromInt resp.status) }
                , Cmd.none
                )

        DmxErr e ->
            ( { model | error = Just e.message }, Cmd.none )
