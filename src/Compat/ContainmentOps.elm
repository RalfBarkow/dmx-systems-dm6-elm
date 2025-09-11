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
