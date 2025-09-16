module Compat.ModelAPI exposing
    ( -- overlayed (guarded) write-path
      addItemToMap
    , addItemToMapDefault
    , createAssoc
    , createAssocAndAddToMap
    , createTopic
    , createTopicAndAddToMap
    , defaultProps
    , ensureMap
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

        -- 3) add to requested map (guarded add ensures destination map)
        model2 =
            addItemToMap topicId props mapId model1

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
            -- use the guarded write-path
            addItemToMap assocId (MapAssoc AssocProps) mapId model1
    in
    ( model2, assocId )


{-| Drop-in replacement for upstream createTopic:
create the Item AND ensure its per-topic map exists.
-}
createTopic : String -> Maybe IconName -> Model -> ( Model, Id )
createTopic title maybeIcon model0 =
    let
        ( model1, topicId ) =
            U.createTopic title maybeIcon model0
    in
    ( ensureMap topicId model1, topicId )


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


{-| Ensure a map exists in `model.maps`.
We give it a visible stage rect (matches your frame) instead of 0×0.
-}
ensureMap : MapId -> Model -> Model
ensureMap mapId m =
    if Dict.member mapId m.maps then
        m

    else
        { m
            | maps =
                Dict.insert
                    mapId
                    (Model.Map mapId (Model.Rectangle 0 0 1600 1200) Dict.empty)
                    m.maps
        }


{-| Default add used in tests and simple call-sites.
Creates default props and then calls the guarded `addItemToMap` below.
-}
addItemToMapDefault : Id -> MapId -> Model -> Model
addItemToMapDefault id mapId model =
    let
        base =
            model
                |> ensureMap 0
                |> ensureMap mapId

        tp : TopicProps
        tp =
            U.defaultProps id topicSize base
    in
    addItemToMap id (MapTopic tp) mapId base



{- ===============================-
      Overlay: guarded write-path
   -===============================
-}


isSelfContainment : Id -> MapId -> Bool
isSelfContainment itemId mapId =
    itemId == mapId


{-| True if adding (child -> parent) would introduce a cycle,
i.e. `parent` already (directly or indirectly) contains `child`.
We follow dmx.composition edges (player2 = parent, player1 = child).
-}
wouldCreateAncestralCycle : Model -> { parent : MapId, child : Id } -> Bool
wouldCreateAncestralCycle model { parent, child } =
    let
        childrenOf : MapId -> List Id
        childrenOf pid =
            model.items
                |> Dict.values
                |> List.filterMap
                    (\it ->
                        case it.info of
                            Assoc assoc ->
                                if assoc.itemType == "dmx.composition" && assoc.player2 == pid then
                                    Just assoc.player1

                                else
                                    Nothing

                            Topic _ ->
                                Nothing
                    )

        dfs seen cur =
            if List.member cur seen then
                False

            else if cur == parent then
                True

            else
                childrenOf cur |> List.any (dfs (cur :: seen))
    in
    dfs [] child


{-| Guarded add: refuse self-containment & ancestry cycles,
AND ensure both the destination map and the topic’s own nested map exist.
This prevents "illegal Map ID" during upstream updateMaps.
-}
addItemToMap : Id -> MapProps -> MapId -> Model -> Model
addItemToMap itemId props mapId model0 =
    if itemId == mapId then
        model0

    else if wouldCreateAncestralCycle model0 { parent = mapId, child = itemId } then
        model0

    else
        let
            props1 =
                case props of
                    MapTopic tp ->
                        MapTopic { tp | displayMode = Monad LabelOnly }

                    -- 🔴 force circles
                    _ ->
                        props
        in
        model0
            |> ensureMap mapId
            |> ensureMap itemId
            |> U.addItemToMap itemId props1 mapId
