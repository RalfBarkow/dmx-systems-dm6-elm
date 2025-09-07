module Logger exposing (log, toString)

import Debug


log : String -> a -> a
log =
    Debug.log


toString : a -> String
toString =
    Debug.toString
