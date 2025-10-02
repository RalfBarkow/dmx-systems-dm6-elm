module AppRunner exposing
    ( Msg(..)
    , UndoModel
    , fromInner
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
import IconMenu
import Json.Decode as D
import Json.Encode as E
import Main
import Model exposing (EditMsg, NavMsg)
import ModelAPI exposing (activeMap)
import Mouse
import MouseAPI exposing (mouseSubs)
import Platform.Sub as Sub
import Search
import Types exposing (DisplayMode, Id, MapId, MapPath, Point)
import Utils as U



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



-- EXPLICIT WRAPPER MESSAGE (mirrors AM.Msg) + FedWiki


type Msg
    = AddTopic
    | MoveTopicToMap Id MapId Point Id MapPath Point
    | SwitchDisplay DisplayMode
    | Edit EditMsg
    | Nav NavMsg
    | Hide
    | Delete
    | Undo
    | Redo
    | Import
    | Export
    | NoOp
      -- components
    | Mouse Mouse.Msg
    | Search Search.Msg
    | IconMenu IconMenu.Msg
      -- external (kept in AppRunner)
    | FedWikiPage String



-- Map AppRunner.Msg -> AM.Msg (when delegating to Main)


toInner : Msg -> Maybe AM.Msg
toInner msg =
    case msg of
        AddTopic ->
            Just AM.AddTopic

        MoveTopicToMap a b c d e f ->
            Just (AM.MoveTopicToMap a b c d e f)

        SwitchDisplay d ->
            Just (AM.SwitchDisplay d)

        Edit m ->
            Just (AM.Edit m)

        Nav m ->
            Just (AM.Nav m)

        Hide ->
            Just AM.Hide

        Delete ->
            Just AM.Delete

        Undo ->
            Just AM.Undo

        Redo ->
            Just AM.Redo

        Import ->
            Just AM.Import

        Export ->
            Just AM.Export

        NoOp ->
            Just AM.NoOp

        Mouse m ->
            Just (AM.Mouse m)

        Search m ->
            Just (AM.Search m)

        IconMenu m ->
            Just (AM.IconMenu m)

        FedWikiPage _ ->
            Nothing



-- Map AM.Msg -> AppRunner.Msg (for Cmd/view/subs mapping)


fromInner : AM.Msg -> Msg
fromInner am =
    case am of
        AM.AddTopic ->
            AddTopic

        AM.MoveTopicToMap a b c d e f ->
            MoveTopicToMap a b c d e f

        AM.SwitchDisplay d ->
            SwitchDisplay d

        AM.Edit m ->
            Edit m

        AM.Nav m ->
            Nav m

        AM.Hide ->
            Hide

        AM.Delete ->
            Delete

        AM.Undo ->
            Undo

        AM.Redo ->
            Redo

        AM.Import ->
            Import

        AM.Export ->
            Export

        AM.NoOp ->
            NoOp

        AM.Mouse m ->
            Mouse m

        AM.Search m ->
            Search m

        AM.IconMenu m ->
            IconMenu m



-- Init: map Cmd AM.Msg -> Cmd AppRunner.Msg


init : E.Value -> ( UndoModel, Cmd Msg )
init =
    Main.init >> Tuple.mapSecond (Cmd.map fromInner)



-- WRAP update: handle FedWikiPage here, delegate everything else.


update : Msg -> AM.UndoModel -> ( AM.UndoModel, Cmd Msg )
update msg undo =
    case msg of
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
                                    U.info "fedwiki.story.stats"
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
                                    U.info "fedwiki.story.decode.err"
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
                            U.info "fedwiki.decode.ok"
                                { rawLen = String.length rawJson }

                        _ =
                            U.info "fedwiki.import"
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
                            U.info "fedwiki.decode.err"
                                { error = Debug.toString err
                                , rawLen = String.length rawJson
                                }
                    in
                    ( undo, Cmd.none )

        _ ->
            forward msg undo


forward : Msg -> UndoModel -> ( UndoModel, Cmd Msg )
forward msg undo =
    case toInner msg of
        Just inner ->
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
                    U.info "app.update.forward"
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
            ( undo1, Cmd.map fromInner cmd1 )

        Nothing ->
            ( undo, Cmd.none )


subscriptions : AM.UndoModel -> Sub.Sub Msg
subscriptions undo =
    Sub.map fromInner (mouseSubs undo)



-- Map-only element view (moved here from Main)


view : AM.UndoModel -> Browser.Document Msg
view undo =
    let
        doc =
            Main.view undo

        -- Browser.Document Main.Msg
    in
    { title = doc.title
    , body = List.map (H.map fromInner) doc.body
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
                    U.info "fedwiki.import"
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
