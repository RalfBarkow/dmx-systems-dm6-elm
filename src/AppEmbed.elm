port module AppEmbed exposing (main)

import AppModel as AM
import AppRunner as App exposing (Msg(..), UndoModel)
import Browser
import Compat.FedWiki as CFW
import Html exposing (Html)
import Json.Decode as D
import Json.Encode as E



-- Live page JSON from the FedWiki frame (stringified page object)


port pageJson : (String -> msg) -> Sub msg


storedDecoder : D.Decoder String
storedDecoder =
    D.oneOf
        [ D.field "stored" D.string -- your cold-boot.html passes this
        , D.field "pageJson" D.string -- future-proof alias
        , D.succeed "{}"
        ]


init : E.Value -> ( App.UndoModel, Cmd App.Msg )
init flagsValue =
    let
        ( undo0, cmd0 ) =
            App.init flagsValue

        raw =
            D.decodeValue storedDecoder flagsValue
                |> Result.withDefault "{}"

        undo1 =
            case D.decodeString CFW.decodePage raw of
                Ok val ->
                    let
                        ( model1, _ ) =
                            CFW.pageToModel val undo0.present
                    in
                    { undo0 | present = model1 }

                Err _ ->
                    undo0
    in
    ( undo1, cmd0 )


update : App.Msg -> App.UndoModel -> ( App.UndoModel, Cmd App.Msg )
update =
    App.update


view : App.UndoModel -> Html App.Msg
view =
    App.view


subscriptions : App.UndoModel -> Sub App.Msg
subscriptions undo =
    Sub.batch
        [ App.subscriptions undo -- Sub App.Msg
        , pageJson FedWikiPage -- Sub App.Msg
        ]


main : Program E.Value App.UndoModel App.Msg
main =
    Browser.element
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }
