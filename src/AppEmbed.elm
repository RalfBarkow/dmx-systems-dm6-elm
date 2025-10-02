port module AppEmbed exposing (main)

import AppModel as AM
import AppRunner as App exposing (Msg(..), fromInner)
import Browser
import Html as H
import Json.Encode as E
import MapRenderer exposing (viewMap)
import Model exposing (..)
import ModelAPI exposing (activeMap)
import Platform.Sub as Sub



-- Incoming page JSON from the FedWiki frame (stringified page object)


port pageJson : (String -> msg) -> Sub msg



-- White-box the current FedWiki page container by rendering ONLY the current map fullscreen.
-- That means we show its contained story items (MapTopic) as circles (Monad LabelOnly),
-- not the outer container topic.


view : App.UndoModel -> H.Html App.Msg
view undo =
    let
        model : AM.Model
        model =
            undo.present

        currentMapId : Int
        currentMapId =
            case model.mapPath of
                m :: _ ->
                    m

                [] ->
                    activeMap model
    in
    -- Empty mapPath => fullscreen; you see inner story items as LabelOnly circles
    H.map App.fromInner (viewMap currentMapId [] model)


main : Program E.Value App.UndoModel App.Msg
main =
    Browser.element
        { init = App.init
        , update = App.update
        , subscriptions =
            \undo ->
                Sub.batch
                    [ App.subscriptions undo
                    , pageJson App.FedWikiPage
                    ]
        , view = view
        }
