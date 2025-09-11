module Compat.TestDefault exposing
    ( defaultModel
    , defaultUndo
    )

import AppModel as AM
import Json.Encode as E
import Main



-- What Main.init actually returns now (UndoModel)


defaultUndo : AM.UndoModel
defaultUndo =
    Tuple.first (Main.init E.null)



-- Keep a plain Model handy for tests that still want it


defaultModel : AM.Model
defaultModel =
    defaultUndo.present
