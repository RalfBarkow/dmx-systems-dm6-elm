port module Main exposing (..)

import AppModel as AM
import Boxing exposing (boxContainer, unboxContainer)
import Browser
import Browser.Dom as Dom
import Compat.FedWiki as FW
import Config exposing (..)
import Dict
import Html exposing (Attribute, Html, br, div, text)
import Html.Attributes exposing (id, style)
import IconMenuAPI exposing (updateIconMenu, viewIconMenu)
import Json.Decode as D
import Json.Encode as E
import MapAutoSize exposing (autoSize)
import MapRenderer exposing (viewMap)
import Model exposing (..)
import ModelAPI exposing (..)
import MouseAPI exposing (mouseHoverHandler, mouseSubs, updateMouse)
import SearchAPI exposing (updateSearch, viewResultMenu)
import Storage exposing (modelDecoder, storeModel, storeModelWith)
import String exposing (fromFloat, fromInt)
import Task
import Toolbar exposing (viewToolbar)
import UndoList
import Utils exposing (..)



-- PORTS


port importJSON : () -> Cmd msg


port exportJSON : () -> Cmd msg



-- MAIN


main : Program E.Value AM.UndoModel AM.Msg
main =
    Browser.document
        { init = init
        , view = view
        , update = update
        , subscriptions = mouseSubs
        }


init : E.Value -> ( AM.UndoModel, Cmd AM.Msg )
init flags =
    ( initModel flags, Cmd.none ) |> reset


initModel : E.Value -> AM.Model
initModel flags =
    case flags |> D.decodeValue (D.null True) of
        Ok True ->
            let
                _ =
                    info "init" "localStorage: empty"
            in
            AM.default

        _ ->
            case flags |> D.decodeValue modelDecoder of
                Ok model ->
                    let
                        _ =
                            info "init"
                                ("localStorage: " ++ (model |> toString |> String.length |> fromInt) ++ " bytes")
                    in
                    model

                Err e ->
                    let
                        _ =
                            logError "init" "localStorage" e
                    in
                    AM.default



-- VIEW


view : AM.UndoModel -> Browser.Document AM.Msg
view ({ present } as undoModel) =
    Browser.Document
        "DM6 Elm"
        [ div
            (mouseHoverHandler
                ++ appStyle
            )
            ([ viewToolbar undoModel
             , viewMap (activeMap present) [] present -- mapPath = []
             ]
                ++ viewResultMenu present
                ++ viewIconMenu present
            )
        , div
            (id "measure" :: measureStyle)
            [ text present.measureText
            , br [] []
            ]
        ]


appStyle : List (Attribute AM.Msg)
appStyle =
    [ style "font-family" mainFont
    , style "user-select" "none"
    , style "-webkit-user-select" "none" -- Safari still needs vendor prefix
    ]


measureStyle : List (Attribute AM.Msg)
measureStyle =
    [ style "position" "fixed"
    , style "visibility" "hidden"
    , style "white-space" "pre-wrap"
    , style "font-family" mainFont
    , style "font-size" <| fromInt contentFontSize ++ "px"
    , style "line-height" <| fromFloat topicLineHeight
    , style "padding" <| fromInt topicDetailPadding ++ "px"
    , style "width" <| fromFloat topicDetailMaxWidth ++ "px"
    , style "min-width" <| fromFloat (topicSize.w - topicSize.h) ++ "px"
    , style "max-width" "max-content"
    , style "border-width" <| fromFloat topicBorderWidth ++ "px"
    , style "border-style" "solid"
    , style "box-sizing" "border-box"
    ]



-- UPDATE


update : AM.Msg -> AM.UndoModel -> ( AM.UndoModel, Cmd AM.Msg )
update msg ({ present } as undoModel) =
    let
        _ =
            case msg of
                AM.Mouse _ ->
                    msg

                _ ->
                    info "update" msg
    in
    case msg of
        AM.SetFedWikiRaw s ->
            ( { present | fedWikiRaw = s }, Cmd.none )
                |> push undoModel

        AM.FedWikiPage raw ->
            case D.decodeString FW.decodePage raw of
                Ok val ->
                    let
                        before =
                            Dict.size present.items

                        ( m1, cmd ) =
                            FW.pageToModel val present

                        after =
                            Dict.size m1.items

                        _ =
                            info "fedwiki.import" { before = before, after = after, created = after - before, activeMap = activeMap m1 }
                    in
                    ( { m1 | fedWikiRaw = raw }, cmd )
                        |> push undoModel

                Err _ ->
                    ( { present | fedWikiRaw = raw }, Cmd.none )
                        |> push undoModel

        AM.AddTopic ->
            createTopicIn topicDefaultText Nothing [ activeMap present ] present
                |> storeModel
                |> push undoModel

        AM.MoveTopicToMap topicId mapId origPos targetId targetMapPath pos ->
            moveTopicToMap topicId mapId origPos targetId targetMapPath pos present
                |> storeModel
                |> push undoModel

        AM.SwitchDisplay displayMode ->
            switchDisplay displayMode present
                |> storeModel
                |> swap undoModel

        AM.Search searchMsg ->
            updateSearch searchMsg undoModel

        AM.Edit editMsg ->
            updateEdit editMsg undoModel

        AM.IconMenu iconMenuMsg ->
            updateIconMenu iconMenuMsg undoModel

        AM.Mouse mouseMsg ->
            updateMouse mouseMsg undoModel

        AM.Nav navMsg ->
            updateNav navMsg present |> storeModel |> reset

        AM.Hide ->
            hide present |> storeModel |> push undoModel

        AM.Delete ->
            delete present |> storeModel |> push undoModel

        AM.Undo ->
            undo undoModel

        AM.Redo ->
            redo undoModel

        AM.Import ->
            ( present, importJSON () ) |> swap undoModel

        AM.Export ->
            ( present, exportJSON () ) |> swap undoModel

        AM.NoOp ->
            ( present, Cmd.none ) |> swap undoModel


moveTopicToMap : Id -> MapId -> Point -> Id -> MapPath -> Point -> AM.Model -> AM.Model
moveTopicToMap topicId mapId origPos targetId targetMapPath pos model =
    let
        ( newModel, created ) =
            createMapIfNeeded targetId model

        newPos =
            case created of
                True ->
                    Point
                        (topicW2 + whiteBoxPadding)
                        (topicH2 + whiteBoxPadding)

                False ->
                    pos

        props_ =
            getTopicProps topicId mapId newModel.maps
                |> Maybe.andThen (\props -> Just (MapTopic { props | pos = newPos }))
    in
    case props_ of
        Just props ->
            newModel
                |> hideItem topicId mapId
                |> setTopicPos topicId mapId origPos
                |> addItemToMap topicId props targetId
                |> select targetId targetMapPath
                |> autoSize

        Nothing ->
            model


createMapIfNeeded : Id -> AM.Model -> ( AM.Model, Bool )
createMapIfNeeded topicId model =
    if hasMap topicId model.maps then
        ( model, False )

    else
        ( model
            |> createMap topicId
            |> setDisplayModeInAllMaps topicId (Container BlackBox)
          -- A nested topic which becomes a container might exist in other maps as well, still as
          -- a monad. We must set the topic's display mode to "container" in *all* maps. Otherwise
          -- in the other maps it might be revealed still as a monad.
        , True
        )


setDisplayModeInAllMaps : Id -> DisplayMode -> AM.Model -> AM.Model
setDisplayModeInAllMaps topicId displayMode model =
    model.maps
        |> Dict.foldr
            (\mapId _ modelAcc ->
                case isItemInMap topicId mapId model of
                    True ->
                        setDisplayMode topicId mapId displayMode modelAcc

                    False ->
                        modelAcc
            )
            model


switchDisplay : DisplayMode -> AM.Model -> AM.Model
switchDisplay displayMode model =
    (case getSingleSelection model of
        Just ( containerId, mapPath ) ->
            let
                mapId =
                    getMapId mapPath
            in
            { model
                | maps =
                    case displayMode of
                        Monad _ ->
                            model.maps

                        Container BlackBox ->
                            boxContainer containerId mapId model

                        Container WhiteBox ->
                            boxContainer containerId mapId model

                        Container Unboxed ->
                            unboxContainer containerId mapId model
            }
                |> setDisplayMode containerId mapId displayMode

        Nothing ->
            model
    )
        |> autoSize



-- Text Edit


updateEdit : EditMsg -> AM.UndoModel -> ( AM.UndoModel, Cmd AM.Msg )
updateEdit msg ({ present } as undoModel) =
    case msg of
        EditStart ->
            startEdit present |> push undoModel

        OnTextInput text ->
            onTextInput text present |> storeModel |> swap undoModel

        OnTextareaInput text ->
            onTextareaInput text present |> storeModelWith |> swap undoModel

        SetTopicSize topicId mapId size ->
            ( present
                |> setTopicSize topicId mapId size
                |> autoSize
            , Cmd.none
            )
                |> swap undoModel

        EditEnd ->
            ( endEdit present, Cmd.none )
                |> swap undoModel


startEdit : AM.Model -> ( AM.Model, Cmd AM.Msg )
startEdit model =
    let
        newModel =
            case getSingleSelection model of
                Just ( topicId, mapPath ) ->
                    { model | editState = ItemEdit topicId (getMapId mapPath) }
                        |> setDetailDisplayIfMonade topicId (getMapId mapPath)
                        |> autoSize

                Nothing ->
                    model
    in
    ( newModel, focus newModel )


setDetailDisplayIfMonade : Id -> MapId -> AM.Model -> AM.Model
setDetailDisplayIfMonade topicId mapId model =
    model
        |> updateTopicProps topicId
            mapId
            (\props ->
                case props.displayMode of
                    Monad _ ->
                        { props | displayMode = Monad Detail }

                    _ ->
                        props
            )


onTextInput : String -> AM.Model -> AM.Model
onTextInput text model =
    case model.editState of
        ItemEdit topicId _ ->
            updateTopicInfo topicId
                (\topic -> { topic | text = text })
                model

        NoEdit ->
            logError "onTextInput" "called when editState is NoEdit" model


onTextareaInput : String -> AM.Model -> ( AM.Model, Cmd AM.Msg )
onTextareaInput text model =
    case model.editState of
        ItemEdit topicId mapId ->
            updateTopicInfo topicId
                (\topic -> { topic | text = text })
                model
                |> measureText text topicId mapId

        NoEdit ->
            logError "onTextareaInput" "called when editState is NoEdit" ( model, Cmd.none )


measureText : String -> Id -> MapId -> AM.Model -> ( AM.Model, Cmd AM.Msg )
measureText text topicId mapId model =
    ( { model | measureText = text }
    , Dom.getElement "measure"
        |> Task.attempt
            (\result ->
                case result of
                    Ok elem ->
                        AM.Edit
                            (SetTopicSize topicId
                                mapId
                                (Size elem.element.width elem.element.height)
                            )

                    Err err ->
                        logError "measureText" (toString err) AM.NoOp
            )
    )


endEdit : AM.Model -> AM.Model
endEdit model =
    { model | editState = NoEdit }
        |> autoSize


focus : AM.Model -> Cmd AM.Msg
focus model =
    let
        nodeId =
            case model.editState of
                ItemEdit id mapId ->
                    "dmx-input-" ++ fromInt id ++ "-" ++ fromInt mapId

                NoEdit ->
                    logError "focus" "called when editState is NoEdit" ""
    in
    Dom.focus nodeId
        |> Task.attempt
            (\result ->
                case result of
                    Ok () ->
                        AM.NoOp

                    Err e ->
                        logError "focus" (toString e) AM.NoOp
            )



--


updateNav : NavMsg -> AM.Model -> AM.Model
updateNav navMsg model =
    case navMsg of
        Fullscreen ->
            fullscreen model

        Back ->
            back model


fullscreen : AM.Model -> AM.Model
fullscreen model =
    case getSingleSelection model of
        Just ( topicId, _ ) ->
            { model | mapPath = topicId :: model.mapPath }
                |> resetSelection
                |> createMapIfNeeded topicId
                |> Tuple.first
                |> adjustMapRect topicId -1

        Nothing ->
            model


back : AM.Model -> AM.Model
back model =
    let
        ( mapId, mapPath, _ ) =
            case model.mapPath of
                prevMapId :: nextMapId :: mapIds ->
                    ( prevMapId
                    , nextMapId :: mapIds
                    , [ ( prevMapId, nextMapId ) ]
                    )

                _ ->
                    logError "back" "model.mapPath has a problem" ( 0, [ 0 ], [] )
    in
    { model
        | mapPath = mapPath

        -- , selection = selection -- TODO
    }
        |> adjustMapRect mapId 1
        |> autoSize


adjustMapRect : MapId -> Float -> AM.Model -> AM.Model
adjustMapRect mapId factor model =
    model
        |> updateMapRect mapId
            (\rect ->
                Rectangle
                    (rect.x1 + factor * 400)
                    -- TODO
                    (rect.y1 + factor * 300)
                    -- TODO
                    rect.x2
                    rect.y2
            )


hide : AM.Model -> AM.Model
hide model =
    let
        newModel =
            model.selection
                |> List.foldr
                    (\( itemId, mapPath ) modelAcc -> hideItem itemId (getMapId mapPath) modelAcc)
                    model
    in
    newModel
        |> resetSelection
        |> autoSize


delete : AM.Model -> AM.Model
delete model =
    let
        newModel =
            model.selection
                |> List.map Tuple.first
                |> List.foldr
                    (\itemId modelAcc -> deleteItem itemId modelAcc)
                    model
    in
    newModel
        |> resetSelection
        |> autoSize



-- Undo / Redo


undo : AM.UndoModel -> ( AM.UndoModel, Cmd AM.Msg )
undo undoModel =
    let
        newUndoModel =
            UndoList.undo undoModel

        newModel =
            AM.resetTransientState newUndoModel.present
    in
    newModel
        |> storeModel
        |> swap newUndoModel


redo : AM.UndoModel -> ( AM.UndoModel, Cmd AM.Msg )
redo undoModel =
    let
        newUndoModel =
            UndoList.redo undoModel

        newModel =
            AM.resetTransientState newUndoModel.present
    in
    newModel
        |> storeModel
        |> swap newUndoModel



-- Map-only element view for embedding (kept for AppEmbed compatibility)


viewElementMap : AM.UndoModel -> Html AM.Msg
viewElementMap undoModel =
    let
        present =
            undoModel.present
    in
    div
        (mouseHoverHandler ++ appStyle)
        [ viewMap (activeMap present) [] present ]
