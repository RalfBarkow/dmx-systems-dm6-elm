module Compat.TestUtil exposing (asUndo, present, viewBody)

import AppModel as AM
import Html exposing (Html)
import Main


asUndo : AM.Model -> AM.UndoModel
asUndo m =
    { past = []
    , present = m
    , future = []
    }


present : AM.UndoModel -> AM.Model
present u =
    u.present


viewBody : AM.Model -> List (Html AM.Msg)
viewBody m =
    (Main.view (asUndo m)).body
