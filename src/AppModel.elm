module AppModel exposing (Model, Msg(..), UndoModel, default)

import Compat.Display as Display exposing (DisplayConfig)
import Dict
import IconMenu
import Model exposing (DisplayMode, EditMsg, EditState(..), Id, Items, Map, MapId, MapPath, Maps, NavMsg, Point, Rectangle, Selection)
import Mouse
import Search
import UndoList exposing (UndoList)



-- UNDO


type alias UndoModel =
    UndoList Model



-- MODEL (must match what Storage.elm builds)


type alias Model =
    { items : Items
    , maps : Maps
    , mapPath : MapPath
    , nextId : Id

    ----- transient -----
    , selection : Selection
    , editState : EditState
    , measureText : String

    -- components
    , mouse : Mouse.Model
    , search : Search.Model
    , iconMenu : IconMenu.Model

    -- Federated Wiki
    , display : DisplayConfig
    , fedWikiRaw : String
    }



-- DEFAULT


default : Model
default =
    { items = Dict.empty
    , maps =
        Dict.singleton 0
            -- map 0 is the "home map", it has no corresponding topic
            (Map 0 (Rectangle 0 0 0 0) Dict.empty)
    , mapPath = [ 0 ]
    , nextId = 1

    ----- transient -----
    , selection = []
    , editState = NoEdit
    , measureText = ""

    -- components
    , mouse = Mouse.init
    , search = Search.init
    , iconMenu = IconMenu.init

    -- Federated Wiki
    , display = Display.default
    , fedWikiRaw = ""
    }



-- MESSAGES


type Msg
    = AddTopic
    | MoveTopicToMap Id MapId Point Id MapPath Point -- start point, random point (for target)
    | SwitchDisplay DisplayMode
    | Edit EditMsg
    | Nav NavMsg
    | Hide
    | Delete
    | Undo
    | Redo
    | Import
    | Export
    | NoOp
      -- components
    | Mouse Mouse.Msg
    | Search Search.Msg
    | IconMenu IconMenu.Msg
