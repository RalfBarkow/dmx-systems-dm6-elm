module UI.Icon exposing (sprite)

import Html exposing (Html)
import Html.Attributes as Attr
import Svg exposing (circle, defs, marker, path, svg, symbol)
import Svg.Attributes as SA


sprite : String -> Html msg
sprite prefix =
    svg
        [ SA.style "position:absolute;width:0;height:0;overflow:hidden"
        , Attr.attribute "aria-hidden" "true"
        , Attr.attribute "focusable" "false" -- ← Optional: prevents focus in older browsers
        ]
        [ defs []
            [ symbol [ SA.id (prefix ++ "topic-icon"), SA.viewBox "0 0 24 24" ]
                [ circle [ SA.cx "12", SA.cy "12", SA.r "8", SA.fill "currentColor" ] [] ]
            , marker
                [ SA.id (prefix ++ "arrow-marker")
                , SA.viewBox "0 0 10 10"
                , SA.refX "9"
                , SA.refY "5"
                , SA.markerWidth "6"
                , SA.markerHeight "6"
                , SA.orient "auto-start-reverse"
                ]
                [ path [ SA.d "M0,0 L10,5 L0,10 z", SA.fill "currentColor" ] [] ]
            ]
        ]
