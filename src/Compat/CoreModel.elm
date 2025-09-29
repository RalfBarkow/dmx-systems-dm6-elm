module Compat.CoreModel exposing
    ( CoreModel
    , empty
    , fromAppModel
    , toAppModel
    )

import AppModel as AM
import Compat.Display as CDisp
import Defaults as Def
import Dict
import Model exposing (..)



-- Minimal persistent model, independent of AppModel/UI.


type alias CoreModel =
    { items : Items
    , maps : Maps
    , mapPath : List MapId
    , nextId : Id
    }


empty : CoreModel
empty =
    { items = Dict.empty
    , maps = Dict.empty
    , mapPath = [ 0 ]
    , nextId = 1
    }



-- Project just the persistent bits from the full app model.


fromAppModel : AM.Model -> CoreModel
fromAppModel m =
    { items = m.items
    , maps = m.maps
    , mapPath = m.mapPath
    , nextId = m.nextId
    }



-- Lift a CoreModel into the full app model for rendering/storage.
-- Transient/UI fields are taken from AM.default.


toAppModel : { items : Items, maps : Maps, mapPath : MapPath, nextId : Id } -> AM.Model
toAppModel c =
    { items = c.items
    , maps = c.maps
    , mapPath = c.mapPath
    , nextId = c.nextId
    , selection = Def.selection
    , editState = Def.editState
    , measureText = Def.measureText
    , mouse = Def.mouse
    , search = Def.search
    , iconMenu = Def.iconMenu
    , display = CDisp.default
    , fedWikiRaw = "" -- or whatever raw you want to seed with
    , fedWiki =
        { storyItemIds = []
        , containerId = Nothing
        }
    }
