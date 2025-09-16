port module AppEmbed exposing (main)

import AppRunner as App exposing (Msg(..))
import Browser
import Html as H
import Json.Encode as E
import Model exposing (..)
import Platform.Sub as Sub



-- Live page JSON from the FedWiki frame (stringified page object)


port pageJson : (String -> msg) -> Sub msg


view : App.UndoModel -> H.Html App.Msg
view =
    App.view


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
