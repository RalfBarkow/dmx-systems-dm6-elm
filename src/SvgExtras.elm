module SvgExtras exposing (cursorPointer, peAll, peNone, peStroke)

import Svg exposing (Attribute)
import Svg.Attributes as SA


peNone : Attribute msg
peNone =
    SA.style "pointer-events: none"


peStroke : Attribute msg
peStroke =
    SA.style "pointer-events: visibleStroke"


peAll : Attribute msg
peAll =
    SA.style "pointer-events: all"


cursorPointer : Attribute msg
cursorPointer =
    SA.style "cursor: pointer"
