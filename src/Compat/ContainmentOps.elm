module Compat.ContainmentOps exposing
    ( boundaryCross
    , depthOf
    , moveDeeperBy
    , moveShallowerBy
    , multiplyDepth
    )

import Algebra.Containment as C
import Model exposing (..)
import ModelAPI exposing (..)


depthOf : Model -> Id -> C.Depth
depthOf model id =
    let
        path =
            mapPathOf model id

        -- write this: where is the item currently?
    in
    C.toDepth path


moveDeeperBy : Model -> Id -> Int -> Model
moveDeeperBy model id k =
    let
        d0 =
            depthOf model id

        d1 =
            C.within d0 (C.Depth k)
    in
    recontainToDepth model id d1



-- implement using ensureMap + addItemToMap


moveShallowerBy : Model -> Id -> Int -> Model
moveShallowerBy model id k =
    moveDeeperBy model id -k


multiplyDepth : Model -> Id -> Int -> Model
multiplyDepth model id k =
    let
        d1 =
            C.times (depthOf model id) (C.Depth k)
    in
    recontainToDepth model id d1


boundaryCross : UndoModel -> ( Model, Cmd msg ) -> ( UndoModel, Cmd msg )
boundaryCross =
    push


{-| Commit a drop by (possibly) crossing a boundary.

Parameters (record):
id : dragged topic id
fromPath : path where drag started (source mapPath)
toPath : path where it is dropped (target mapPath)
origPos : original position (before drag) in source map
dropPos : drop position in target map

Returns: (unchanged model, Cmd Msg)

Note: we return `model` unchanged because the actual move is performed by your
`update` in response to `MoveTopicToMap`. This keeps “where to move” and “how to
apply it” decoupled.

-}
recontainToDepth :
    Model
    ->
        { id : Id
        , fromPath : MapPath
        , toPath : MapPath
        , origPos : Point
        , dropPos : Point
        }
    -> ( Model, Cmd AM.Msg )
recontainToDepth model { id, fromPath, toPath, origPos, dropPos } =
    let
        srcMapId =
            getMapId fromPath

        tgtMapId =
            getMapId toPath
    in
    if srcMapId == tgtMapId then
        -- same container → just keep state; caller may have already updated pos via preview
        ( model, Cmd.none )

    else
        -- cross-container → delegate to existing app message
        let
            mk : Point -> AM.Msg
            mk p =
                AM.MoveTopicToMap id srcMapId origPos id toPath p
        in
        ( model, Random.generate mk (Random.constant dropPos) )
