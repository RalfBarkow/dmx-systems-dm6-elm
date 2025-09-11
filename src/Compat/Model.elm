module Compat.Model exposing
    ( Ext
    , createAssoc
    , createAssocAndAddToMap
    , defaultExt
    , makeMap
    , makeMapItem
    , makeMapItemR
    , makeMapR
    )

{-| A tiny compatibility layer to isolate upstream refactors.

A constructor/record convenience layer so
your app/tests don’t use raw constructors or upstream argument ordering directly.

Use these helpers instead of calling constructors / ModelAPI directly.

-}

import AppModel as AM exposing (Model)
import Compat.ModelAPI as ModelAPI
import Model as M exposing (Delta, Id, MapId, MapItem, MapItems, MapProps, Rectangle)



-- MAP ------------------------------------------------------------------------
-- Upstream (Sep 2025): Map id rect items


makeMap : MapId -> Rectangle -> MapItems -> M.Map
makeMap id rect items =
    M.Map id rect items


makeMapR : { a | id : MapId, rect : Rectangle, items : MapItems } -> M.Map
makeMapR r =
    M.Map r.id r.rect r.items



-- MAP ITEM -------------------------------------------------------------------


{-| Upstream (Aug 2025): MapItem id parentAssocId hidden pinned props
-}
makeMapItem : Id -> Id -> Bool -> Bool -> MapProps -> MapItem
makeMapItem id parentAssocId hidden pinned props =
    MapItem id parentAssocId hidden pinned props


makeMapItemR : { a | id : Id, parentAssocId : Id, hidden : Bool, pinned : Bool, props : MapProps } -> MapItem
makeMapItemR r =
    MapItem r.id r.parentAssocId r.hidden r.pinned r.props



-- ASSOC CREATION -------------------------------------------------------------


{-| Record-style wrapper; stable call-site even if upstream reorders args.
-}
createAssoc : { a | itemType : String, role1 : String, player1 : Id, role2 : String, player2 : Id } -> Model -> ( Model, Id )
createAssoc r model =
    -- Upstream: createAssoc itemType role1 player1 role2 player2 model
    ModelAPI.createAssoc r.itemType r.role1 r.player1 r.role2 r.player2 model


createAssocAndAddToMap : { a | itemType : String, role1 : String, player1 : Id, role2 : String, player2 : Id, mapId : MapId } -> Model -> ( Model, Id )
createAssocAndAddToMap r model =
    -- Upstream: createAssocAndAddToMap itemType role1 player1 role2 player2 mapId model
    ModelAPI.createAssocAndAddToMap r.itemType r.role1 r.player1 r.role2 r.player2 r.mapId model


type alias Ext =
    { journal : List Delta -- or List M.Delta if you prefer to qualify
    , showJournal : Bool
    }


defaultExt : Ext
defaultExt =
    { journal = [], showJournal = False }
