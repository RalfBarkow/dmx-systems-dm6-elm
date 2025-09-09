module AppMain exposing (init, main)

import AppModel as AM
import Browser
import Json.Decode as D
import Json.Encode as E
import Main
import Platform.Sub as Sub



-- Reuse AppModel's concrete types


type alias Model =
    AM.Model


type alias Msg =
    AM.Msg


main : Program D.Value Model Msg
main =
    Browser.document
        { init = init
        , update = Main.update
        , subscriptions = subscriptions
        , view = Main.view
        }



-- Accept any JSON and fall back to a tiny default flags object


init : D.Value -> ( Model, Cmd Msg )
init flagsVal =
    case D.decodeValue flagsDecoder flagsVal of
        Ok _ ->
            -- Pass the original JSON (it matched our expectations)
            Main.init flagsVal

        Err _ ->
            -- Fallback to {}-like flags encoded as JSON
            Main.init (E.object [ ( "slug", E.string "empty" ), ( "stored", E.string "{}" ) ])



-- Local flags decoder (since Main.flagsDecoder is not exported)


flagsDecoder : D.Decoder { slug : String, stored : String }
flagsDecoder =
    D.oneOf
        [ D.map2 (\slug stored -> { slug = slug, stored = stored })
            (D.field "slug" D.string)
            (D.field "stored" D.string)
        , D.map (\stored -> { slug = "empty", stored = stored })
            (D.field "stored" D.string)
        , D.succeed defaultFlags
        ]


defaultFlags : { slug : String, stored : String }
defaultFlags =
    { slug = "empty", stored = "{}" }



-- Minimal stub so you can run the local-first build immediately.
-- (If/when you re-export Main.subscriptions, replace this with Main.subscriptions.)


subscriptions : Model -> Sub.Sub Msg
subscriptions _ =
    Sub.none
