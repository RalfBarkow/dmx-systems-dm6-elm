module AppRunner exposing
    ( Msg(..)
    , UndoModel
    , init
    , onFedWikiPage
    , subscriptions
    , update
    , view
    )

import AppModel as AM exposing (UndoModel)
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
import Storage
import Utils exposing (info)



-- local alias so we can expose UndoModel from this module


type alias UndoModel =
    AM.UndoModel



-- Our wrapper messages


type Msg
    = Up AM.Msg
    | FedWikiPage String


init : E.Value -> ( AM.UndoModel, Cmd Msg )
init flags =
    let
        ( undo0, cmd0 ) =
            Main.init flags
    in
    ( undo0, Cmd.map Up cmd0 )



-- WRAP update: handle FedWikiPage here, delegate everything else.


update : Msg -> AM.UndoModel -> ( AM.UndoModel, Cmd Msg )
update msg undo0 =
    case msg of
        FedWikiPage raw ->
            onFedWikiPage raw undo0

        Up m ->
            let
                ( undo1, cmd1 ) =
                    Main.update m undo0
            in
            ( undo1, Cmd.map Up cmd1 )


subscriptions : AM.UndoModel -> Sub.Sub Msg
subscriptions undo =
    -- or: mouseSubs undo |> Sub.map Up
    Sub.map Up (mouseSubs undo)



-- Map-only element view (moved here from Main)


view : AM.UndoModel -> H.Html Msg
view undoModel =
    let
        present =
            undoModel.present

        base : H.Html AM.Msg
        base =
            div
                (mouseHoverHandler ++ appStyle)
                [ viewMap (activeMap present) [] present ]
    in
    H.map Up base



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

                ( m1, _ ) =
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
            in
            ( { undoModel | present = m1 }
            , Cmd.none
            )

        Err _ ->
            ( undoModel, Cmd.none )
