module AppEmbed exposing (main)

import AppMain as App
import AppModel exposing (Msg, UndoModel)
import Browser
import Html exposing (Html)
import Json.Encode as E



-- Convert Document -> Html for embedding


viewEmbed : UndoModel -> Html Msg
viewEmbed undoModel =
    let
        doc =
            App.view undoModel
    in
    Html.div [] doc.body


main : Program E.Value UndoModel Msg
main =
    Browser.element
        { init = App.init
        , update = App.update
        , subscriptions = App.subscriptions
        , view = viewEmbed
        }
