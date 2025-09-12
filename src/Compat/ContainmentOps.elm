module Compat.ContainmentOps exposing
    ( boundaryCross
    , depthOf
    , moveDeeperBy
    , moveShallowerBy
    , multiplyDepth
    )

import Algebra.Containment as C
import AppModel as AM
import Model exposing (Id, MapPath, Point)
import ModelAPI
    exposing
        ( createDefaultAssocIn
        , fromPath
        , getMapId
        , getTopicPos
        , push
        , resetSelection
        , select
        , setTopicPosByDelta
        , swap
        )
import Random
import UndoList


boundaryCross : AM.UndoModel -> ( AM.Model, Cmd AM.Msg ) -> ( AM.UndoModel, Cmd AM.Msg )
boundaryCross =
    push


depthOf : AM.Model -> Id -> C.Depth
depthOf model id =
    let
        path =
            mapPathOf model id

        -- write this: where is the item currently?
    in
    C.toDepth path


moveDeeperBy : AM.Model -> Id -> Int -> AM.Model
moveDeeperBy model id k =
    let
        d0 =
            depthOf model id

        d1 =
            C.within d0 (C.Depth k)
    in
    Tuple.first <|
        recontainToDepth model
            { id = id
            , fromPath = mapPathOf model id
            , toPath = fromDepthToMapPath d1
            , origPos = getTopicPos id model
            , dropPos = getTopicPos id model
            }



-- implement using ensureMap + addItemToMap


moveShallowerBy : AM.Model -> Id -> Int -> AM.Model
moveShallowerBy model id k =
    moveDeeperBy model id -k


multiplyDepth : AM.Model -> Id -> Int -> AM.Model
multiplyDepth model id k =
    let
        d1 =
            C.times (depthOf model id) (C.Depth k)
    in
    recontainToDepth model id d1


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
    AM.Model
    ->
        { id : Id
        , fromPath : MapPath
        , toPath : MapPath
        , origPos : Point
        , dropPos : Point
        }
    -> ( AM.Model, Cmd AM.Msg )
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


{-| TEMP: resolve an item's map path.
TODO: replace with a real lookup once available upstream/compat.
-}
mapPathOf : AM.Model -> Id -> MapPath
mapPathOf model _ =
    model.mapPath


{-| Converts a C.Depth to a MapPath.
Replace this stub with the actual conversion logic as needed.
-}
fromDepthToMapPath : C.Depth -> MapPath
fromDepthToMapPath depth =
    -- Implement the conversion logic here
    []
