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



-- Adapt Main.view (Document) to an element view (Html)


viewElement : AM.Model -> H.Html AM.Msg
viewElement =
    Main.viewElementMap



-- render only the map area


main : Program E.Value AM.Model AM.Msg
main =
    Browser.element
        { init = Main.init
        , update = Main.update
        , subscriptions =
            \m ->
                Sub.batch
                    [ mouseSubs m
                    , pageJson AM.FedWikiPage
                    ]
        , view = viewElement
        }
