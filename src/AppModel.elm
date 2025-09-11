module AppModel exposing (..)

import Compat.Display as Disp
import Dict
import IconMenu exposing (IconMenuModel, IconMenuMsg)
import Model exposing (..)
import Mouse exposing (MouseModel, MouseMsg)
import Search exposing (SearchModel, SearchMsg)
import UndoList exposing (UndoList)


type alias UndoModel =
    UndoList Model


type alias Model =
    { items : Items -- TODO: represent container content independent from maps?
    , maps : Maps
    , mapPath : MapPath
    , nextId : Id

    ----- transient -----
    , selection : Selection
    , editState : EditState
    , measureText : String

    -- components
    , mouse : MouseModel
    , search : SearchModel
    , iconMenu : IconMenuModel

    --
    , display : Disp.DisplayConfig
    }


default : Model
default =
    { items = Dict.empty
    , maps =
        Dict.singleton 0
        -- map 0 is the "home map", it has no corresponding topic
        <|
            Map 0 (Rectangle 0 0 0 0) Dict.empty
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

    --
    , display = Disp.default
    }


resetTransientState : Model -> Model
resetTransientState model =
    { model
      ----- transient -----
        | selection = default.selection
        , editState = default.editState
        , measureText = default.measureText

        -- components
        , mouse = default.mouse
        , search = default.search
        , iconMenu = default.iconMenu
    }


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
    | Mouse MouseMsg
    | Search SearchMsg
    | IconMenu IconMenuMsg
