module MouseAPI exposing (mouseHoverHandler, mouseSubs, updateMouse)

import AppModel exposing (Model, Msg(..))
import Browser.Events as Events
import Config exposing (assocDelayMillis, topicH2, topicW2, whiteBoxPadding, whiteBoxRange)
import Debug
import Html exposing (Attribute)
import Html.Events exposing (on)
import IconMenuAPI exposing (closeIconMenu)
import Json.Decode as D
import Logger as L
import MapAutoSize exposing (autoSize)
import Model exposing (Class, Id, MapPath, Point)
import ModelAPI exposing (createDefaultAssocIn, fromPath, getMapId, getTopicPos, idDecoder, pathDecoder, select, setTopicPosByDelta)
import Mouse exposing (DragMode(..), DragState(..), MouseMsg(..))
import Random
import SearchAPI exposing (closeResultMenu)
import Storage exposing (storeModelWith)
import String exposing (fromInt)
import Task
import Time exposing (posixToMillis)
import Utils as U exposing (info)



-- VIEW


mouseHoverHandler : List (Attribute Msg)
mouseHoverHandler =
    [ on "mouseover" (mouseDecoder Over)
    , on "mouseout" (mouseDecoder Out)
    ]



-- UPDATE


updateMouse : MouseMsg -> Model -> ( Model, Cmd Msg )
updateMouse msg model =
    let
        _ =
            L.log "MouseMsg" msg
    in
    case msg of
        Down ->
            ( mouseDown model, Cmd.none )

        DownItem class id mapPath pos ->
            mouseDownOnItem model class id mapPath pos

        Move pos ->
            mouseMove model pos

        Up ->
            mouseUp model |> storeModelWith

        Over class id mapPath ->
            ( mouseOver model class id mapPath, Cmd.none )

        Out class id mapPath ->
            ( mouseOut model class id mapPath, Cmd.none )

        Time time ->
            ( timeArrived time model, Cmd.none )


mouseDown : Model -> Model
mouseDown model =
    { model | selection = [] }
        |> closeIconMenu
        |> closeResultMenu


mouseDownOnItem : Model -> Class -> Id -> MapPath -> Point -> ( Model, Cmd Msg )
mouseDownOnItem model cls id mapPath pos =
    let
        _ =
            L.log "DownItem"
                { cls = cls, id = id, mapPath = mapPath, pos = pos }
    in
    ( updateDragState model (WaitForStartTime cls id mapPath pos)
        |> select id mapPath
    , Task.perform (Mouse << Time) Time.now
    )


timeArrived : Time.Posix -> Model -> Model
timeArrived time model =
    case model.mouse.dragState of
        -- we just pressed down; capture the start time
        WaitForStartTime class id mapPath pos ->
            updateDragState model <| DragEngaged time class id mapPath pos

        -- after first move; decide DragTopic vs DrawAssoc by delay
        WaitForEndTime startTime class id mapPath pos ->
            let
                isTopic =
                    String.contains "dmx-topic" class
            in
            if not isTopic then
                model

            else
                let
                    delay =
                        posixToMillis time - posixToMillis startTime > assocDelayMillis

                    dragMode =
                        if delay then
                            DrawAssoc

                        else
                            DragTopic

                    mapId =
                        getMapId mapPath

                    origPos_ =
                        getTopicPos id mapId model.maps
                in
                case origPos_ of
                    Just origPos ->
                        updateDragState model (Drag dragMode id mapPath origPos pos Nothing)

                    Nothing ->
                        model

        -- while *engaged* or actually *dragging*, ignore extra ticks
        DragEngaged _ _ _ _ _ ->
            model

        Drag _ _ _ _ _ _ ->
            model

        -- idle → ignore ticks
        NoDrag ->
            model


mouseMove : Model -> Point -> ( Model, Cmd Msg )
mouseMove model pos =
    let
        _ =
            L.log "Move" { dragState = model.mouse.dragState, pos = pos }
    in
    case model.mouse.dragState of
        DragEngaged time class id mapPath pos_ ->
            ( updateDragState model <| WaitForEndTime time class id mapPath pos_
            , Task.perform (Mouse << Time) Time.now
            )

        WaitForEndTime _ _ _ _ _ ->
            ( model, Cmd.none )

        Drag _ _ _ _ _ _ ->
            ( performDrag model pos, Cmd.none )

        _ ->
            U.logError "mouseMove"
                "Received \"Move\" when dragState is not engaged/drag"
                ( model, Cmd.none )


performDrag : Model -> Point -> Model
performDrag model pos =
    let
        _ =
            L.log "performDrag" { dragState = model.mouse.dragState, pos = pos }
    in
    case model.mouse.dragState of
        Drag dragMode id mapPath origPos lastPos target ->
            let
                delta =
                    Point (pos.x - lastPos.x) (pos.y - lastPos.y)

                mapId =
                    getMapId mapPath

                nextModel =
                    case dragMode of
                        DragTopic ->
                            setTopicPosByDelta id mapId delta model

                        DrawAssoc ->
                            model
            in
            updateDragState nextModel (Drag dragMode id mapPath origPos pos target)
                |> autoSize

        _ ->
            U.logError "performDrag"
                "Received \"Move\" when dragState is not Drag"
                model


mouseUp : Model -> ( Model, Cmd Msg )
mouseUp model =
    let
        ( newModel, cmd ) =
            case model.mouse.dragState of
                Drag DragTopic id mapPath origPos _ (Just ( targetId, targetMapPath )) ->
                    let
                        _ =
                            L.log "mouseUp"
                                ("dropped "
                                    ++ fromInt id
                                    ++ " (map "
                                    ++ fromPath mapPath
                                    ++ ") on "
                                    ++ fromInt targetId
                                    ++ " (map "
                                    ++ fromPath targetMapPath
                                    ++ ") --> "
                                    ++ (if notDroppedOnOwnMap then
                                            "move topic"

                                        else
                                            "abort"
                                       )
                                )

                        mapId =
                            getMapId mapPath

                        notDroppedOnOwnMap =
                            mapId /= targetId

                        msg =
                            MoveTopicToMap id mapId origPos targetId targetMapPath
                    in
                    if notDroppedOnOwnMap then
                        ( model, Random.generate msg point )

                    else
                        ( model, Cmd.none )

                Drag DrawAssoc id mapPath _ _ (Just ( targetId, targetMapPath )) ->
                    let
                        _ =
                            L.log "mouseUp"
                                ("assoc drawn from "
                                    ++ fromInt id
                                    ++ " (map "
                                    ++ fromPath
                                        mapPath
                                    ++ ") to "
                                    ++ fromInt targetId
                                    ++ " (map "
                                    ++ fromPath targetMapPath
                                    ++ ") --> "
                                    ++ (if isSameMap then
                                            "create assoc"

                                        else
                                            "abort"
                                       )
                                )

                        mapId =
                            getMapId mapPath

                        isSameMap =
                            mapId == getMapId targetMapPath
                    in
                    if isSameMap then
                        ( createDefaultAssocIn id targetId mapId model, Cmd.none )

                    else
                        ( model, Cmd.none )

                Drag _ _ _ _ _ _ ->
                    let
                        _ =
                            L.log "mouseUp" "drag ended w/o target"
                    in
                    ( model, Cmd.none )

                DragEngaged _ _ _ _ _ ->
                    let
                        _ =
                            L.log "mouseUp" "drag aborted w/o moving"
                    in
                    ( model, Cmd.none )

                _ ->
                    U.logError "mouseUp"
                        ("Received \"Up\" message when dragState is " ++ L.toString model.mouse.dragState)
                        ( model, Cmd.none )
    in
    ( updateDragState newModel NoDrag, cmd )


point : Random.Generator Point
point =
    let
        cx =
            topicW2 + whiteBoxPadding

        cy =
            topicH2 + whiteBoxPadding

        rw =
            whiteBoxRange.w

        rh =
            whiteBoxRange.h
    in
    Random.map2
        (\x y -> Point (cx + x) (cy + y))
        (Random.float 0 rw)
        (Random.float 0 rh)


mouseOver : Model -> Class -> Id -> MapPath -> Model
mouseOver model _ targetId targetMapPath =
    case model.mouse.dragState of
        Drag dragMode id mapPath origPos lastPos _ ->
            let
                mapId =
                    getMapId mapPath

                targetMapId =
                    getMapId targetMapPath

                target =
                    if ( id, mapId ) /= ( targetId, targetMapId ) then
                        -- TODO: mapId comparison needed?
                        Just ( targetId, targetMapPath )

                    else
                        Nothing
            in
            -- update target
            updateDragState model <| Drag dragMode id mapPath origPos lastPos target

        DragEngaged _ _ _ _ _ ->
            U.logError "mouseOver" "Received \"Over\" message when dragState is DragEngaged" model

        _ ->
            model


mouseOut : Model -> Class -> Id -> MapPath -> Model
mouseOut model _ _ _ =
    case model.mouse.dragState of
        Drag dragMode id mapPath origPos lastPos _ ->
            -- reset target
            updateDragState model <| Drag dragMode id mapPath origPos lastPos Nothing

        _ ->
            model


updateDragState : Model -> DragState -> Model
updateDragState ({ mouse } as model) dragState =
    { model | mouse = { mouse | dragState = dragState } }



-- SUBSCRIPTIONS
-- keep your existing subs like mouseDownSub / dragSub (shown here for clarity)


dragSub : Sub Msg
dragSub =
    Sub.batch
        [ Events.onMouseMove <|
            D.map Mouse <|
                D.map Move
                    (D.map2 Point
                        (D.field "clientX" D.float)
                        (D.field "clientY" D.float)
                    )
        , Events.onMouseUp (D.succeed (Mouse Up))
        ]



-- small helper: a 60fps-ish tick that feeds `Mouse Time`


timeTick : Sub Msg
timeTick =
    Time.every 16 (Mouse << Time)


mouseSubs : Model -> Sub Msg
mouseSubs model =
    case model.mouse.dragState of
        WaitForStartTime _ _ _ _ ->
            timeTick

        WaitForEndTime _ _ _ _ _ ->
            timeTick

        DragEngaged _ _ _ _ _ ->
            dragSub

        Drag _ _ _ _ _ _ ->
            dragSub

        NoDrag ->
            mouseDownSub


mouseDownSub : Sub Msg
mouseDownSub =
    Events.onMouseDown <|
        D.oneOf
            [ D.map Mouse <|
                D.map4 DownItem
                    (D.oneOf
                        [ D.at [ "target", "className" ] D.string -- HTML elements
                        , D.at [ "target", "className", "baseVal" ] D.string -- SVG elements
                        ]
                    )
                    (D.at [ "target", "dataset", "id" ] D.string |> D.andThen idDecoder)
                    (D.at [ "target", "dataset", "path" ] D.string |> D.andThen pathDecoder)
                    (D.map2 Point
                        -- TODO: no code doubling
                        (D.field "clientX" D.float)
                        (D.field "clientY" D.float)
                    )
            , D.succeed (Mouse Down)
            ]



-- TODO: no code doubling


mouseDecoder : (Class -> Id -> MapPath -> MouseMsg) -> D.Decoder Msg
mouseDecoder msg =
    D.map Mouse <|
        D.map3 msg
            (D.oneOf
                [ D.at [ "target", "className" ] D.string -- HTML elements
                , D.at [ "target", "className", "baseVal" ] D.string -- SVG elements
                ]
            )
            (D.at [ "target", "dataset", "id" ] D.string |> D.andThen idDecoder)
            (D.at [ "target", "dataset", "path" ] D.string |> D.andThen pathDecoder)
