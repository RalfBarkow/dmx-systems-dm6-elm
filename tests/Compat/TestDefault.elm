module Compat.TestDefault exposing
    ( asUndo
    , defaultModel
    , defaultUndo
    )

import AppModel as AM
import Json.Encode as E
import Main


asUndo : AM.Model -> AM.UndoModel
asUndo m =
    { past = [], present = m, future = [] }



-- Keep a plain Model handy for tests that still want it


defaultModel : AM.Model
defaultModel =
    defaultUndo.present



-- What Main.init actually returns now (UndoModel)


defaultUndo : AM.UndoModel
defaultUndo =
    Tuple.first (Main.init E.null)
