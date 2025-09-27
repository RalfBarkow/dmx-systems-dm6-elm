module Compat.ModelAPI exposing
    ( -- overlayed (guarded) write-path
      addItemToMap
    , addItemToMapDefault
    , createAssoc
    , createAssocAndAddToMap
    , createTopic
    , createTopicAndAddToMap
    , defaultProps
    , getMap
    , getMapItem
    , getMapItemById
    , getTopicProps
    , hideItem
    , isItemInMap
    , isMapTopic
    , select
    , setTopicPos
    )

import AppModel exposing (Model)
import Config exposing (topicSize)
import Dict
import Model exposing (..)
import ModelAPI as U



{- ==============================-
      Thin forwards to upstream
   -==============================
-}
-- force monads for topics


defaultProps : Id -> Size -> Model -> TopicProps
defaultProps id size model =
    let
        tp =
            U.defaultProps id size model
    in
    { tp | displayMode = Monad LabelOnly }



-- Delegate core guarded add (single source of truth)


addItemToMap : Id -> MapProps -> MapId -> Model -> Model
addItemToMap =
    U.addItemToMap



-- Forward when present on upstream


createAssoc : String -> String -> Id -> String -> Id -> Model -> ( Model, Id )
createAssoc =
    U.createAssoc


createTopicAndAddToMap : String -> Maybe IconName -> MapId -> Model -> ( Model, Id )
createTopicAndAddToMap title icon mapId model0 =
    let
        -- 1) create the topic (ensures nested map)
        ( model1, topicId ) =
            createTopic title icon model0

        -- 2) props
        props : MapProps
        props =
            MapTopic (U.defaultProps topicId topicSize model1)

        -- 3) add to requested map (guarded add normalizes/guards destination)
        model2 =
            U.addItemToMap topicId props mapId model1

        -- 4) select it on that path
        model3 =
            U.select topicId [ mapId ] model2
    in
    ( model3, topicId )



-- Polyfill: upstream removed this on nested-maps-fix.
-- We re-create it by (1) creating the assoc, then (2) adding its MapAssoc item to mapId.


createAssocAndAddToMap : String -> String -> Id -> String -> Id -> MapId -> Model -> ( Model, Id )
createAssocAndAddToMap itemType role1 player1 role2 player2 mapId model0 =
    let
        ( model1, assocId ) =
            U.createAssoc itemType role1 player1 role2 player2 model0

        model2 =
            U.addItemToMap assocId (MapAssoc AssocProps) mapId model1
    in
    ( model2, assocId )


createTopic : String -> Maybe IconName -> Model -> ( Model, Id )
createTopic =
    U.createTopic


getMapItemById : Id -> MapId -> Maps -> Maybe MapItem
getMapItemById =
    U.getMapItemById


isMapTopic : MapItem -> Bool
isMapTopic =
    U.isMapTopic


getTopicProps : Id -> MapId -> Dict.Dict MapId Map -> Maybe TopicProps
getTopicProps =
    U.getTopicProps


hideItem : Id -> MapId -> Model -> Model
hideItem =
    U.hideItem


setTopicPos : Id -> MapId -> Point -> Model -> Model
setTopicPos =
    U.setTopicPos


select : Id -> MapPath -> Model -> Model
select =
    U.select


getMap : MapId -> Dict.Dict MapId Map -> Maybe Map
getMap =
    U.getMap


getMapItem : Id -> Map -> Maybe MapItem
getMapItem =
    U.getMapItem



{- ========================================-
      Test/useful helpers (local, no upstream)
   -========================================
-}
-- Visible membership helper used by tests:
-- return True only if a (non-hidden) map item exists in the given map.


isItemInMap : Id -> MapId -> Model -> Bool
isItemInMap id mapId model =
    case getMapItemById id mapId model.maps of
        Just mi ->
            not mi.hidden

        Nothing ->
            False


{-| Default add used in tests and simple call-sites.
Creates default props and then calls the guarded `addItemToMap` below.
-}
addItemToMapDefault : Id -> MapId -> Model -> Model
addItemToMapDefault id mapId model =
    let
        tp : TopicProps
        tp =
            U.defaultProps id topicSize model
    in
    U.addItemToMap id (MapTopic tp) mapId model
