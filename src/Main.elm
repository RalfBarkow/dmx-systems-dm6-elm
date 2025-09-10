module Main exposing (..)

import AppModel exposing (..)
import Boxing exposing (boxContainer, unboxContainer)
import Browser
import Browser.Dom as Dom
import Compat.FedWiki as FW
import Compat.ModelAPI exposing (addItemToMap)
import Config exposing (..)
import Dict
import Html exposing (Attribute, Html, br, div, text)
import Html.Attributes exposing (id, style)
import IconMenuAPI exposing (updateIconMenu, viewIconMenu)
import Json.Decode as D
import Json.Encode as E
import Logger as L
import MapAutoSize exposing (autoSize)
import MapRenderer exposing (viewMap)
import Model exposing (..)
import ModelAPI exposing (activeMap, createMap, createTopicIn, deleteItem, getMapId, getSingleSelection, getTopicProps, hasMap, hideItem, isItemInMap, select, setDisplayMode, setTopicPos, setTopicSize, updateMapRect, updateTopicInfo, updateTopicProps)
import MouseAPI exposing (mouseHoverHandler, mouseSubs, updateMouse)
import SearchAPI exposing (updateSearch, viewResultMenu)
import Storage exposing (modelDecoder, storeModel, storeModelWith)
import String exposing (fromFloat, fromInt)
import Task
import UI.Toolbar exposing (viewToolbar)
import Utils as U



-- MAIN


main : Program E.Value Model Msg
main =
    Browser.document
        { init = init
        , view = view
        , update = update
        , subscriptions = mouseSubs
        }


trace : String -> ( Model, Cmd Msg ) -> ( Model, Cmd Msg )
trace tag (( _, _ ) as result) =
    let
        _ =
            L.log ("update." ++ tag) ""
    in
    result


traceWith : String -> String -> ( Model, Cmd Msg ) -> ( Model, Cmd Msg )
traceWith tag payload (( _, _ ) as result) =
    let
        _ =
            L.log
                ("update."
                    ++ tag
                    ++ (if payload == "" then
                            ""

                        else
                            " | " ++ payload
                       )
                )
                ""
    in
    result


describeDisplayMode : DisplayMode -> String
describeDisplayMode dm =
    case dm of
        Monad LabelOnly ->
            "Monad(LabelOnly)"

        Monad Detail ->
            "Monad(Detail)"

        Container BlackBox ->
            "Container(BlackBox)"

        Container WhiteBox ->
            "Container(WhiteBox)"

        Container Unboxed ->
            "Container(Unboxed)"



-- INIT


init : E.Value -> ( Model, Cmd Msg )
init flags =
    ( case flags |> D.decodeValue (D.null True) of
        Ok True ->
            let
                _ =
                    L.log "init" "localStorage: empty"
            in
            default

        _ ->
            case flags |> D.decodeValue modelDecoder of
                Ok model ->
                    let
                        _ =
                            L.log "init"
                                ("localStorage: " ++ (model |> L.toString |> String.length |> fromInt) ++ " bytes")
                    in
                    model

                Err e ->
                    let
                        _ =
                            U.logError "init" "localStorage" e
                    in
                    default
    , Cmd.none
    )



-- VIEW


view : Model -> Browser.Document Msg
view model =
    Browser.Document
        "DM6 Elm"
        [ div
            (mouseHoverHandler
                ++ appStyle
            )
            ([ viewToolbar model
             , viewMap (activeMap model) [] model -- mapPath = []
             ]
                ++ viewResultMenu model
                ++ viewIconMenu model
            )
        , div
            ([ id "measure" ]
                ++ measureStyle
            )
            [ text model.measureText
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


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    let
        _ =
            case msg of
                Mouse _ ->
                    msg

                _ ->
                    L.log "update" msg
    in
    case msg of
        SetFedWikiRaw s ->
            ( { model | fedWikiRaw = s }, Cmd.none )
                |> traceWith "fedwiki.raw" ("len=" ++ String.fromInt (String.length s))

        FedWikiPage raw ->
            let
                newModel =
                    case D.decodeString FW.decodePage raw of
                        Ok page ->
                            FW.pageToModel page model

                        Err _ ->
                            model
            in
            ( { newModel | fedWikiRaw = raw }, Cmd.none )
                |> traceWith "fedwiki" ("len=" ++ String.fromInt (String.length raw))

        AddTopic ->
            createTopicIn topicDefaultText Nothing [ activeMap model ] model
                |> storeModel
                |> trace "addTopic"

        MoveTopicToMap topicId mapId origPos targetId targetMapPath pos ->
            moveTopicToMap topicId mapId origPos targetId targetMapPath pos model
                |> storeModel
                |> traceWith "moveTopic"
                    ("topic="
                        ++ String.fromInt topicId
                        ++ " -> "
                        ++ String.fromInt targetId
                    )

        SwitchDisplay displayMode ->
            switchDisplay displayMode model
                |> storeModel
                |> traceWith "switchDisplay" (describeDisplayMode displayMode)

        Search searchMsg ->
            updateSearch searchMsg model
                |> trace "search"

        Edit editMsg ->
            updateEdit editMsg model
                |> trace "edit"

        IconMenu iconMenuMsg ->
            updateIconMenu iconMenuMsg model
                |> trace "iconMenu"

        Mouse mouseMsg ->
            updateMouse mouseMsg model
                |> trace "mouse"

        Nav navMsg ->
            updateNav navMsg model
                |> storeModel
                |> trace "nav"

        Hide ->
            hide model
                |> storeModel
                |> trace "hide"

        Delete ->
            delete model
                |> storeModel
                |> trace "delete"

        NoOp ->
            ( model, Cmd.none )


moveTopicToMap : Id -> MapId -> Point -> Id -> MapPath -> Point -> Model -> Model
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
                case isItemInMap topicId mapId model of
                    True ->
                        setDisplayMode topicId mapId displayMode modelAcc

                    False ->
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


updateEdit : EditMsg -> Model -> ( Model, Cmd Msg )
updateEdit msg model =
    case msg of
        EditStart ->
            startEdit model

        OnTextInput text ->
            onTextInput text model |> storeModel

        OnTextareaInput text ->
            onTextareaInput text model |> storeModelWith

        SetTopicSize topicId mapId size ->
            ( model
                |> setTopicSize topicId mapId size
                |> autoSize
            , Cmd.none
            )

        EditEnd ->
            ( endEdit model, Cmd.none )


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
                        U.logError "measureText" (L.toString err) NoOp
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
                        U.logError "focus" (L.toString e) NoOp
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
            { model
                | mapPath = topicId :: model.mapPath
                , selection = []
            }
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
    { newModel | selection = [] }
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
    { newModel | selection = [] }
        |> autoSize



-- Map-only element view for embedding


viewElementMap : Model -> Html Msg
viewElementMap model =
    div
        (mouseHoverHandler ++ appStyle)
        [ viewMap (activeMap model) [] model ]
