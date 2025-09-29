module Compat.ModelAPI exposing
    ( -- overlayed (guarded) write-path
      addItemToMap
    , addItemToMapDefault
    , childItemIdsOf
    , createAssoc
    , createAssocAndAddToMap
    , createTopic
    , createTopicAndAddToMap
    , currentMapIdOf
    , defaultProps
    , ensureChildMap
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

import AppModel as AM
import Config exposing (topicSize)
import Dict
import Model exposing (..)
import ModelAPI as MAPI
    exposing
        ( addItemToMap
        , createAssoc
        , createMap
        , createTopic
        , defaultProps
        , getMap
        , getMapItem
        , getMapItemById
        , getTopicProps
        , hasMap
        , hideItem
        , isMapTopic
        , select
        , setTopicPos
        )



{- ==============================-
      Thin forwards to upstream
   -==============================
-}
-- force monads for topics


defaultProps : Id -> Size -> AM.Model -> TopicProps
defaultProps id size model =
    let
        tp =
            MAPI.defaultProps id size model
    in
    { tp | displayMode = Monad LabelOnly }



-- Delegate core guarded add (single source of truth)


addItemToMap : Id -> MapProps -> MapId -> AM.Model -> AM.Model
addItemToMap =
    MAPI.addItemToMap



-- Forward when present on upstream


createAssoc : String -> String -> Id -> String -> Id -> AM.Model -> ( AM.Model, Id )
createAssoc =
    MAPI.createAssoc


createTopicAndAddToMap : String -> Maybe IconName -> MapId -> AM.Model -> ( AM.Model, Id )
createTopicAndAddToMap title icon mapId model0 =
    let
        -- 1) create the topic (ensures nested map)
        ( model1, topicId ) =
            createTopic title icon model0

        -- 2) props
        props : MapProps
        props =
            MapTopic (MAPI.defaultProps topicId topicSize model1)

        -- 3) add to requested map (guarded add normalizes/guards destination)
        model2 =
            MAPI.addItemToMap topicId props mapId model1

        -- 4) select it on that path
        model3 =
            MAPI.select topicId [ mapId ] model2
    in
    ( model3, topicId )



-- Polyfill: upstream removed this on nested-maps-fix.
-- We re-create it by (1) creating the assoc, then (2) adding its MapAssoc item to mapId.


createAssocAndAddToMap : String -> String -> Id -> String -> Id -> MapId -> AM.Model -> ( AM.Model, Id )
createAssocAndAddToMap itemType role1 player1 role2 player2 mapId model0 =
    let
        ( model1, assocId ) =
            MAPI.createAssoc itemType role1 player1 role2 player2 model0

        model2 =
            MAPI.addItemToMap assocId (MapAssoc AssocProps) mapId model1
    in
    ( model2, assocId )


createTopic : String -> Maybe IconName -> AM.Model -> ( AM.Model, Id )
createTopic =
    MAPI.createTopic


getMapItemById : Id -> MapId -> Maps -> Maybe MapItem
getMapItemById =
    MAPI.getMapItemById


isMapTopic : MapItem -> Bool
isMapTopic =
    MAPI.isMapTopic


getTopicProps : Id -> MapId -> Dict.Dict MapId Map -> Maybe TopicProps
getTopicProps =
    MAPI.getTopicProps


hideItem : Id -> MapId -> AM.Model -> AM.Model
hideItem =
    MAPI.hideItem


setTopicPos : Id -> MapId -> Point -> AM.Model -> AM.Model
setTopicPos =
    MAPI.setTopicPos


select : Id -> MapPath -> AM.Model -> AM.Model
select =
    MAPI.select


getMap : MapId -> Dict.Dict MapId Map -> Maybe Map
getMap =
    MAPI.getMap


getMapItem : Id -> Map -> Maybe MapItem
getMapItem =
    MAPI.getMapItem



{- ========================================-
      Test/useful helpers (local, no upstream)
   -========================================
-}
-- Visible membership helper used by tests:
-- return True only if a (non-hidden) map item exists in the given map.


isItemInMap : Id -> MapId -> AM.Model -> Bool
isItemInMap id mapId model =
    case getMapItemById id mapId model.maps of
        Just mi ->
            not mi.hidden

        Nothing ->
            False


{-| Default add used in tests and simple call-sites.
Creates default props and then calls the guarded `addItemToMap` below.
-}
addItemToMapDefault : Id -> MapId -> AM.Model -> AM.Model
addItemToMapDefault id mapId model =
    let
        tp : TopicProps
        tp =
            MAPI.defaultProps id topicSize model
    in
    MAPI.addItemToMap id (MapTopic tp) mapId model


{-| Return the child map id of a topic, if it exists.
In this model, a topic’s child map id == the topic id.
-}
currentMapIdOf : Id -> AM.Model -> Maybe MapId
currentMapIdOf topicId model =
    if hasMap topicId model.maps then
        Just topicId

    else
        Nothing


{-| Ensure a child map exists for `topicId`. Returns (updatedModel, childMapId).
No need to “attach” a map; creating it with id == topicId is sufficient.
-}
ensureChildMap : Id -> AM.Model -> ( AM.Model, MapId )
ensureChildMap topicId model =
    if hasMap topicId model.maps then
        ( model, topicId )

    else
        let
            model1 =
                createMap topicId model

            -- If you want default container styling like in Main.createMapIfNeeded,
            -- import and call setDisplayModeInAllMaps here.
            -- model2 = MAPI.setDisplayModeInAllMaps topicId (Container BlackBox) model1
        in
        ( model1, topicId )


childItemIdsOf : Id -> AM.Model -> List Id
childItemIdsOf topicId model =
    case currentMapIdOf topicId model of
        Just mapId ->
            case getMap mapId model.maps of
                Just map ->
                    Dict.keys map.items

                Nothing ->
                    []

        Nothing ->
            []
