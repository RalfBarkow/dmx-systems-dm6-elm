module AppRunner exposing
    ( Msg(..)
    , UndoModel
    , init
    , onFedWikiPage
    , subscriptions
    , update
    , view
    )

import AppModel as AM
import Browser
import Compat.FedWiki as CFW
import Dict
import Html as H
import Json.Decode as D
import Json.Encode as E
import Main
import ModelAPI exposing (activeMap)
import MouseAPI exposing (mouseSubs)
import Platform.Sub as Sub
import Utils exposing (info)



-- local alias so we can expose UndoModel from this module


type alias UndoModel =
    AM.UndoModel



-- Our wrapper messages


type Msg
    = FromMain AM.Msg
    | FedWikiPage String
    | NoOp


init : E.Value -> ( AM.UndoModel, Cmd Msg )
init flags =
    let
        ( undo0, cmd0 ) =
            Main.init flags
    in
    ( undo0, Cmd.map FromMain cmd0 )



-- WRAP update: handle FedWikiPage here, delegate everything else.


update : Msg -> AM.UndoModel -> ( AM.UndoModel, Cmd Msg )
update msg undo =
    case msg of
        FromMain inner ->
            let
                ( undo1, cmd1 ) =
                    Main.update inner undo
            in
            ( undo1, Cmd.map FromMain cmd1 )

        FedWikiPage rawJson ->
            let
                ( undo1, _ ) =
                    onFedWikiPage rawJson undo
            in
            ( undo1, Cmd.none )

        NoOp ->
            ( undo, Cmd.none )


subscriptions : AM.UndoModel -> Sub.Sub Msg
subscriptions undo =
    Sub.map FromMain (mouseSubs undo)



-- Map-only element view (moved here from Main)


view : AM.UndoModel -> Browser.Document Msg
view undo =
    let
        doc =
            Main.view undo

        -- Browser.Document Main.Msg
    in
    { title = doc.title
    , body = List.map (H.map FromMain) doc.body
    }



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
            ( { undoModel | present = { m1 | fedWikiRaw = raw } }
            , Cmd.none
            )

        Err _ ->
            ( undoModel, Cmd.none )
