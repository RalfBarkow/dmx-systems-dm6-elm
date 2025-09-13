module AppRunner exposing (init, onFedWikiPage, subscriptions, update, view)

import AppModel as AM
import Browser
import Compat.FedWiki as CFW
import Config exposing (mainFont)
import Dict
import Html as H exposing (Attribute, Html, div)
import Html.Attributes as HA exposing (style)
import Json.Decode as D
import Json.Encode as E
import Main
import MapRenderer exposing (viewMap)
import ModelAPI exposing (activeMap)
import MouseAPI exposing (mouseHoverHandler, mouseSubs)
import Platform.Sub as Sub
import Utils exposing (info)


init : E.Value -> ( AM.UndoModel, Cmd AM.Msg )
init =
    Main.init


update : AM.Msg -> AM.UndoModel -> ( AM.UndoModel, Cmd AM.Msg )
update =
    Main.update


subscriptions : AM.UndoModel -> Sub.Sub AM.Msg
subscriptions =
    mouseSubs



-- Map-only element view (moved here from Main)


view : AM.UndoModel -> H.Html AM.Msg
view undoModel =
    let
        present =
            undoModel.present
    in
    div
        (mouseHoverHandler ++ appStyle)
        [ viewMap (activeMap present) [] present ]



-- Local copy of the minimal app styles needed for the embed view


appStyle : List (H.Attribute AM.Msg)
appStyle =
    [ HA.style "font-family" mainFont
    , HA.style "user-select" "none"
    , HA.style "line-height" "1.4"
    ]



-- Called by AppEmbed when the frame sends the current page’s JSON


onFedWikiPage : String -> AM.UndoModel -> ( AM.UndoModel, Cmd msg )
onFedWikiPage raw undoModel =
    case D.decodeString CFW.decodePage raw of
        Ok val ->
            let
                before =
                    Dict.size undoModel.present.items

                ( m1, cmd ) =
                    CFW.pageToModel val undoModel.present

                after =
                    Dict.size m1.items

                _ =
                    info "fedwiki.import"
                        { before = before
                        , after = after
                        , created = after - before
                        , activeMap = activeMap m1
                        }

                present1 =
                    { m1 | fedWikiRaw = raw }
            in
            ( { undoModel | present = present1 }
            , Cmd.none
            )

        Err _ ->
            let
                present0 =
                    undoModel.present

                present1 =
                    { present0 | fedWikiRaw = raw }
            in
            ( { undoModel | present = present1 }
            , Cmd.none
            )
