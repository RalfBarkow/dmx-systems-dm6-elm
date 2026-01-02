port module AppEmbed exposing (main)

import Browser
import Feature.MouseAPI as MouseAPI
import Feature.TextAPI as TextAPI
import Html as H
import Json.Decode as D
import Json.Encode as E
import Map
import Model exposing (Model, Msg(..))
import Main
import Undo exposing (UndoModel)



-- Incoming page JSON from the FedWiki frame (stringified page object)


port pageJson : (String -> msg) -> Sub msg



-- White-box the current FedWiki page container by rendering ONLY the current map fullscreen.
-- That means we show its contained story items (MapTopic) as circles (Monad LabelOnly),
-- not the outer container topic.


type alias Flags =
    { slug : String
    , stored : String
    }


flagsDecoder : D.Decoder Flags
flagsDecoder =
    D.map2 Flags
        (D.field "slug" D.string |> D.maybe |> D.map (Maybe.withDefault "empty"))
        (D.field "stored" D.string |> D.maybe |> D.map (Maybe.withDefault "{}"))


init : E.Value -> ( UndoModel, Cmd Msg )
init rawFlags =
    let
        flags =
            case D.decodeValue flagsDecoder rawFlags of
                Ok decoded ->
                    decoded

                Err _ ->
                    { slug = "empty", stored = "{}" }

        model =
            case D.decodeString D.value flags.stored of
                Ok value ->
                    case D.decodeValue Model.decoder value of
                        Ok decodedModel ->
                            decodedModel

                        Err _ ->
                            Model.init

                Err _ ->
                    Model.init
    in
    ( model, Cmd.none ) |> Undo.reset


view : UndoModel -> H.Html Msg
view undo =
    let
        model : Model
        model =
            undo.present

        currentBoxId =
            model.boxId
    in
    -- Empty mapPath => fullscreen; you see inner story items as LabelOnly circles
    Map.view currentBoxId [] model


subscriptions : UndoModel -> Sub Msg
subscriptions undo =
    Sub.batch
        [ MouseAPI.sub undo
        , TextAPI.sub
        , pageJson (\_ -> NoOp)
        ]


main : Program E.Value UndoModel Msg
main =
    Browser.element
        { init = init
        , update = Main.update
        , subscriptions = subscriptions
        , view = view
        }
