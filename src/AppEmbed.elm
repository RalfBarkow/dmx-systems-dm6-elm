port module AppEmbed exposing (main)

import AppModel as AM
import Browser
import Html as H
import Json.Encode as E
import Main
import MouseAPI exposing (mouseSubs)
import Platform.Sub as Sub



-- Incoming page JSON from the frame


port pageJson : (String -> msg) -> Sub msg



-- Optional outgoing ports (keep if you use them)


port store : String -> Cmd msg


port persist : String -> Cmd msg



-- View: embed the active map from the undo model


viewElement : AM.UndoModel -> H.Html AM.Msg
viewElement =
    Main.viewElementMap



-- Program now runs over AM.UndoModel (not plain Model)


main : Program E.Value AM.UndoModel AM.Msg
main =
    Browser.element
        { init = Main.init
        , update = Main.update
        , subscriptions =
            \undoModel ->
                Sub.batch
                    [ mouseSubs undoModel
                    , pageJson AM.FedWikiPage
                    ]
        , view = viewElement
        }
