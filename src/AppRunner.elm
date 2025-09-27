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



-- --- FedWiki peek decoders & helpers (diagnostics only) ----------------------


type alias FWStoryLite =
    { id : String
    , typ : String
    }


type alias FWPageLite =
    { title : String
    , story : List FWStoryLite
    }


fwStoryLiteDecoder : D.Decoder FWStoryLite
fwStoryLiteDecoder =
    D.map2 FWStoryLite
        (D.field "id" D.string)
        (D.field "type" D.string)


fwPageLiteDecoder : D.Decoder FWPageLite
fwPageLiteDecoder =
    D.map2 FWPageLite
        (D.field "title" D.string)
        (D.field "story" (D.list fwStoryLiteDecoder))


typeHistogram : List FWStoryLite -> Dict.Dict String Int
typeHistogram items =
    let
        bump : String -> Dict.Dict String Int -> Dict.Dict String Int
        bump k =
            Dict.update k (\mi -> Just <| Maybe.withDefault 0 mi + 1)
    in
    List.foldl (\s acc -> bump s.typ acc) Dict.empty items


firstN : Int -> List FWStoryLite -> List FWStoryLite
firstN n xs =
    xs |> List.take n



-- local alias so we can expose UndoModel from this module


type alias UndoModel =
    AM.UndoModel



-- Our wrapper messages


type Msg
    = FromModel AM.Msg
    | FedWikiPage String
    | NoOp


init : E.Value -> ( AM.UndoModel, Cmd Msg )
init flags =
    let
        ( undo0, cmd0 ) =
            Main.init flags
    in
    ( undo0, Cmd.map FromModel cmd0 )



-- WRAP update: handle FedWikiPage here, delegate everything else.


update : Msg -> AM.UndoModel -> ( AM.UndoModel, Cmd Msg )
update msg undo =
    case msg of
        FromModel inner ->
            let
                beforeItems =
                    Dict.size undo.present.items

                beforeMaps =
                    Dict.size undo.present.maps

                beforeActive =
                    activeMap undo.present

                ( undo1, cmd1 ) =
                    Main.update inner undo

                afterItems =
                    Dict.size undo1.present.items

                afterMaps =
                    Dict.size undo1.present.maps

                afterActive =
                    activeMap undo1.present

                _ =
                    info "app.update.forward"
                        { itemsBefore = beforeItems
                        , itemsAfter = afterItems
                        , itemsDelta = afterItems - beforeItems
                        , mapsBefore = beforeMaps
                        , mapsAfter = afterMaps
                        , mapsDelta = afterMaps - beforeMaps
                        , activeBefore = beforeActive
                        , activeAfter = afterActive
                        }
            in
            ( undo1, Cmd.map FromModel cmd1 )

        FedWikiPage rawJson ->
            let
                -- Peek the payload BEFORE Compat import
                _ =
                    case D.decodeString fwPageLiteDecoder rawJson of
                        Ok lite ->
                            let
                                total =
                                    List.length lite.story

                                hist =
                                    typeHistogram lite.story

                                sample =
                                    firstN 6 lite.story

                                _ =
                                    info "fedwiki.story.stats"
                                        { title = lite.title
                                        , total = total
                                        , histogram = hist
                                        , sample = List.map (\s -> { id = s.id, typ = s.typ }) sample
                                        }
                            in
                            ()

                        Err err ->
                            let
                                _ =
                                    info "fedwiki.story.decode.err"
                                        { error = Debug.toString err
                                        , rawLen = String.length rawJson
                                        }
                            in
                            ()
            in
            -- Proceed with your existing Compat import
            case D.decodeString CFW.decodePage rawJson of
                Ok val ->
                    let
                        ( model1, _ ) =
                            CFW.pageToModel val undo.present

                        _ =
                            info "fedwiki.decode.ok"
                                { rawLen = String.length rawJson }

                        _ =
                            info "fedwiki.import"
                                { itemsBefore = Dict.size undo.present.items
                                , itemsAfter = Dict.size model1.items
                                , itemsCreated = Dict.size model1.items - Dict.size undo.present.items
                                , mapsBefore = Dict.size undo.present.maps
                                , mapsAfter = Dict.size model1.maps
                                , mapsDelta = Dict.size model1.maps - Dict.size undo.present.maps
                                }
                    in
                    ( { undo | present = { model1 | fedWikiRaw = rawJson } }
                    , Cmd.none
                    )

                Err err ->
                    let
                        _ =
                            info "fedwiki.decode.err"
                                { error = Debug.toString err
                                , rawLen = String.length rawJson
                                }
                    in
                    ( undo, Cmd.none )

        NoOp ->
            let
                _ =
                    info "noop" {}
            in
            ( undo, Cmd.none )


subscriptions : AM.UndoModel -> Sub.Sub Msg
subscriptions undo =
    Sub.map FromModel (mouseSubs undo)



-- Map-only element view (moved here from Main)


view : AM.UndoModel -> Browser.Document Msg
view undo =
    let
        doc =
            Main.view undo

        -- Browser.Document Main.Msg
    in
    { title = doc.title
    , body = List.map (H.map FromModel) doc.body
    }



-- Called by AppEmbed when the frame sends the current page’s JSON


onFedWikiPage : String -> AM.UndoModel -> ( AM.UndoModel, Cmd msg )
onFedWikiPage raw undoModel =
    case D.decodeString CFW.decodePage raw of
        Ok val ->
            let
                before =
                    Dict.size undoModel.present.items

                -- Importer creates the page topic AND all story items
                ( model1, _ ) =
                    CFW.pageToModel val undoModel.present

                after =
                    Dict.size model1.items

                _ =
                    info "fedwiki.import"
                        { before = before
                        , after = after
                        , created = after - before
                        , activeMap = activeMap model1
                        }
            in
            ( { undoModel | present = { model1 | fedWikiRaw = raw } }
            , Cmd.none
            )

        Err _ ->
            ( undoModel, Cmd.none )
