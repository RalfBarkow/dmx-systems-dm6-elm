module Feature.Diagram.LoFIconicDemo exposing (view)

import Feature.Diagram.LoF as LoF
import Feature.Diagram.LoFIconic as Iconic
import Html exposing (Html, div)
import Html.Attributes as HA


view : Html msg
view =
    div [ HA.style "display" "grid", HA.style "gap" "24px" ]
        [ Iconic.viewSideBySide { title = "Calling Example", term = LoF.callingExample }
        , Iconic.viewSideBySide { title = "Crossing Example", term = LoF.crossingExample }
        ]
