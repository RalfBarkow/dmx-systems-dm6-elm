module Defaults exposing
    ( editState
    , iconMenu
    , measureText
    , mouse
    , search
    , selection
    )

import IconMenu exposing (..)
import Model exposing (EditState(..), Selection)
import Mouse exposing (..)
import Search exposing (..)


selection : Selection
selection =
    []


editState : EditState
editState =
    NoEdit


measureText : String
measureText =
    ""


mouse : Mouse.Model
mouse =
    Mouse.init


search : Search.Model
search =
    Search.init


iconMenu : IconMenu.Model
iconMenu =
    IconMenu.init
