module Main exposing (..)

import AppModel exposing (..)
import Boxing exposing (boxContainer, unboxContainer)
import Browser
import Browser.Dom as Dom
import Compat.Model as CModel
import Config exposing (..)
import Dict exposing (Dict)
import Feature.Move
import Html exposing (Attribute, br, div, text)
import Html.Attributes exposing (id, style)
import IconMenuAPI exposing (updateIconMenu, viewIconMenu)
import Json.Decode as D
import Json.Encode as E
import MapAutoSize exposing (autoSize)
import MapRenderer exposing (viewMap)
import Model as M exposing (..)
import ModelAPI exposing (..)
import Mouse.Pretty as MousePretty
import MouseAPI exposing (mouseHoverHandler, mouseSubs, updateMouse)
import SearchAPI exposing (updateSearch, viewResultMenu)
import Storage exposing (exportJSON, importJSON, modelDecoder, store, storeWith)
import String exposing (fromFloat, fromInt)
import Task
import Toolbar exposing (viewToolbar)
import Types exposing (Id, MapId, MapItem, Maps, Point)
import UndoList
import Utils as U



-- MAIN


main : Program E.Value UndoModel Msg
main =
    Browser.document
        { init = init
        , view = view
        , update = update
        , subscriptions = mouseSubs
        }



-- INIT


init : E.Value -> ( UndoModel, Cmd Msg )
init flags =
    ( initModel flags, Cmd.none ) |> reset


initModel : E.Value -> Model
initModel flags =
    case flags |> D.decodeValue (D.null True) of
        Ok True ->
            let
                _ =
                    U.info "init" "localStorage: empty"
            in
            AppModel.default |> ensureCurrentMap

        _ ->
            case flags |> D.decodeValue modelDecoder of
                Ok model ->
                    let
                        _ =
                            U.info "init"
                                ("localStorage: " ++ (model |> U.toString |> String.length |> fromInt) ++ " bytes")
                    in
                    ensureCurrentMap model

                Err e ->
                    let
                        _ =
                            U.logError "init" "localStorage" e
                    in
                    AppModel.default |> ensureCurrentMap


type alias Id =
    Int


blankRect : M.Rectangle
blankRect =
    { x1 = 0, y1 = 0, x2 = 0, y2 = 0 }



-- adjust field names if your alias differs


emptyItems : M.MapItems
emptyItems =
    Dict.empty


mkRoot : M.MapId -> M.Map
mkRoot rid =
    CModel.makeMapR { id = rid, rect = blankRect, items = emptyItems }


ensureRootOnInit : Model -> Model
ensureRootOnInit model0 =
    if Dict.isEmpty model0.maps then
        let
            rid =
                model0.nextId

            root =
                mkRoot rid
        in
        { model0
            | maps = Dict.insert rid root model0.maps
            , mapPath = [ rid ]
            , nextId = rid + 1
        }

    else
        -- also make sure mapPath head points to an existing map
        ensureCurrentMap model0



-- VIEW


view : UndoModel -> Browser.Document Msg
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


appStyle : List (Attribute Msg)
appStyle =
    [ style "font-family" mainFont
    , style "user-select" "none"
    , style "-webkit-user-select" "none" -- Safari still needs vendor prefix
    ]


measureStyle : List (Attribute Msg)
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


update : Msg -> UndoModel -> ( UndoModel, Cmd Msg )
update msg ({ present } as undoModel) =
    let
        _ =
            case msg of
                Mouse _ ->
                    msg

                _ ->
                    U.info "update" msg
    in
    case msg of
        AddTopic ->
            createTopicIn topicDefaultText Nothing [ activeMap present ] present
                |> store
                |> push undoModel

        MoveTopicToMap topicId mapId origPos targetId targetMapPath pos ->
            moveTopicToMap topicId mapId origPos targetId targetMapPath pos present
                |> store
                |> push undoModel

        SwitchDisplay displayMode ->
            switchDisplay displayMode present
                |> store
                |> swap undoModel

        Search searchMsg ->
            updateSearch searchMsg undoModel

        Edit editMsg ->
            updateEdit editMsg undoModel

        IconMenu iconMenuMsg ->
            updateIconMenu iconMenuMsg undoModel

        Mouse mouseMsg ->
            updateMouse mouseMsg undoModel

        Nav navMsg ->
            updateNav navMsg present |> store |> reset

        Hide ->
            hide present |> store |> push undoModel

        Delete ->
            delete present |> store |> push undoModel

        Undo ->
            undo undoModel

        Redo ->
            redo undoModel

        Import ->
            ( present, importJSON () ) |> swap undoModel

        Export ->
            ( present, exportJSON () ) |> swap undoModel

        NoOp ->
            ( present, Cmd.none ) |> swap undoModel


moveTopicToMap : Id -> MapId -> Point -> Id -> MapPath -> Point -> Model -> Model
moveTopicToMap topicId mapId origPos targetId targetPath dropWorld model =
    let
        cfg =
            { whiteBoxPadding = 8
            , respectBlackBox = True
            , selectAfterMove = True
            , autosizeAfterMove = True
            }
    in
    Feature.Move.moveTopicToMap_ moveDeps
        cfg
        topicId
        mapId
        origPos
        targetId
        targetPath
        dropWorld
        model


moveDeps : Feature.Move.Deps
moveDeps =
    { createMapIfNeeded = createMapIfNeeded
    , getTopicProps = \tid mid m -> getTopicProps tid mid m.maps
    , addItemToMap = addItemToMap
    , hideItem = hideItem
    , setTopicPos = setTopicPos
    , select = select
    , autoSize = autoSize
    , getItem = \tid m -> getItemAny tid m -- <— cross-map
    , updateItem = updateItemById -- <— cross-map
    , worldToLocal = worldToLocalPos -- <— cross-map
    , ownerToMapId = \ownerId _ -> ownerId -- keep if “mapId == ownerId”
    }


getItemFromModel : Id -> Model -> Maybe MapItem
getItemFromModel tid m =
    getMapItemById tid (activeMap m) m.maps



-- update the correct map when promoting target


updateItemById : Id -> (MapItem -> MapItem) -> Model -> Model
updateItemById targetId f model =
    case findItemInAnyMap targetId model.maps of
        Nothing ->
            model

        Just ( mid, _ ) ->
            let
                amendItems : Dict Id MapItem -> Dict Id MapItem
                amendItems =
                    Dict.update targetId (Maybe.map f)

                amendMap : Map -> Map
                amendMap m =
                    { m | items = amendItems m.items }

                maps2 : Maps
                maps2 =
                    Dict.update mid (Maybe.map amendMap) model.maps
            in
            { model | maps = maps2 }


worldToLocalPos : Id -> Point -> Model -> Maybe Point
worldToLocalPos targetId world model =
    getItemAny targetId model
        |> Maybe.andThen
            (\it ->
                case it.props of
                    MapTopic tp ->
                        Just
                            { x = world.x - tp.pos.x
                            , y = world.y - tp.pos.y
                            }

                    _ ->
                        Nothing
            )



-- Model-aware getter used by Feature.Move deps


getItemAny : Id -> Model -> Maybe MapItem
getItemAny tid model =
    findItemInAnyMap tid model.maps
        |> Maybe.map Tuple.second



-- Find (mapId, item) for a topic anywhere in the model


findItemInAnyMap : Id -> Maps -> Maybe ( MapId, MapItem )
findItemInAnyMap tid maps =
    Dict.foldl
        (\mid m acc ->
            case acc of
                Just _ ->
                    acc

                Nothing ->
                    Dict.get tid m.items
                        |> Maybe.map (\it -> ( mid, it ))
        )
        Nothing
        maps


createMapIfNeeded : Id -> Model -> ( Model, Bool )
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


setDisplayModeInAllMaps : Id -> DisplayMode -> Model -> Model
setDisplayModeInAllMaps topicId displayMode model =
    model.maps
        |> Dict.foldr
            (\mapId _ modelAcc ->
                if isItemInMap topicId mapId model then
                    setDisplayMode topicId mapId displayMode modelAcc

                else
                    modelAcc
            )
            model


switchDisplay : DisplayMode -> Model -> Model
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


updateEdit : EditMsg -> UndoModel -> ( UndoModel, Cmd Msg )
updateEdit msg ({ present } as undoModel) =
    case msg of
        EditStart ->
            startEdit present |> push undoModel

        OnTextInput text ->
            onTextInput text present |> store |> swap undoModel

        OnTextareaInput text ->
            onTextareaInput text present |> storeWith |> swap undoModel

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


startEdit : Model -> ( Model, Cmd Msg )
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


setDetailDisplayIfMonade : Id -> MapId -> Model -> Model
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


onTextInput : String -> Model -> Model
onTextInput text model =
    case model.editState of
        ItemEdit topicId _ ->
            updateTopicInfo topicId
                (\topic -> { topic | text = text })
                model

        NoEdit ->
            U.logError "onTextInput" "called when editState is NoEdit" model


onTextareaInput : String -> Model -> ( Model, Cmd Msg )
onTextareaInput text model =
    case model.editState of
        ItemEdit topicId mapId ->
            updateTopicInfo topicId
                (\topic -> { topic | text = text })
                model
                |> measureText text topicId mapId

        NoEdit ->
            U.logError "onTextareaInput" "called when editState is NoEdit" ( model, Cmd.none )


measureText : String -> Id -> MapId -> Model -> ( Model, Cmd Msg )
measureText text topicId mapId model =
    ( { model | measureText = text }
    , Dom.getElement "measure"
        |> Task.attempt
            (\result ->
                case result of
                    Ok elem ->
                        Edit
                            (SetTopicSize topicId
                                mapId
                                (Size elem.element.width elem.element.height)
                            )

                    Err err ->
                        U.logError "measureText" (U.toString err) NoOp
            )
    )


endEdit : Model -> Model
endEdit model =
    { model | editState = NoEdit }
        |> autoSize


focus : Model -> Cmd Msg
focus model =
    let
        nodeId =
            case model.editState of
                ItemEdit id mapId ->
                    "dmx-input-" ++ fromInt id ++ "-" ++ fromInt mapId

                NoEdit ->
                    U.logError "focus" "called when editState is NoEdit" ""
    in
    Dom.focus nodeId
        |> Task.attempt
            (\result ->
                case result of
                    Ok () ->
                        NoOp

                    Err e ->
                        U.logError "focus" (U.toString e) NoOp
            )



--


updateNav : NavMsg -> Model -> Model
updateNav navMsg model =
    case navMsg of
        Fullscreen ->
            fullscreen model

        Back ->
            back model


fullscreen : Model -> Model
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


back : Model -> Model
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
                    U.logError "back" "model.mapPath has a problem" ( 0, [ 0 ], [] )
    in
    { model
        | mapPath = mapPath

        -- , selection = selection -- TODO
    }
        |> adjustMapRect mapId 1
        |> autoSize


adjustMapRect : MapId -> Float -> Model -> Model
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


hide : Model -> Model
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


delete : Model -> Model
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


undo : UndoModel -> ( UndoModel, Cmd Msg )
undo undoModel =
    let
        newUndoModel =
            UndoList.undo undoModel

        newModel =
            resetTransientState newUndoModel.present
    in
    newModel
        |> store
        |> swap newUndoModel


redo : UndoModel -> ( UndoModel, Cmd Msg )
redo undoModel =
    let
        newUndoModel =
            UndoList.redo undoModel

        newModel =
            resetTransientState newUndoModel.present
    in
    newModel
        |> store
        |> swap newUndoModel


prettyMsg : Msg -> String
prettyMsg msg =
    case msg of
        Mouse m ->
            "Mouse." ++ MousePretty.pretty m

        Search m ->
            "Search." ++ U.toString m

        IconMenu m ->
            "IconMenu." ++ U.toString m

        Edit m ->
            "Edit." ++ U.toString m

        Nav m ->
            "Nav." ++ U.toString m

        -- 🔧 Missing branch added here
        MoveTopicToMap topicId mapId origPos targetId targetPath dropWorld ->
            let
                pathStr =
                    "[" ++ String.join "," (List.map fromInt targetPath) ++ "]"
            in
            "MoveTopicToMap T"
                ++ fromInt topicId
                ++ " from M"
                ++ fromInt mapId
                ++ " orig="
                ++ U.toString origPos
                ++ " → T"
                ++ fromInt targetId
                ++ " path="
                ++ pathStr
                ++ " drop="
                ++ U.toString dropWorld

        AddTopic ->
            "AddTopic"

        SwitchDisplay mode ->
            "SwitchDisplay." ++ U.toString mode

        Hide ->
            "Hide"

        Delete ->
            "Delete"

        Undo ->
            "Undo"

        Redo ->
            "Redo"

        Import ->
            "Import"

        Export ->
            "Export"

        NoOp ->
            "NoOp"
