module Demo.LoFMain exposing (main)

import Browser
import Feature.Diagram.LoF as LoF
import Html exposing (Html, br, div, h2, text)


main : Program () () msg
main =
    Browser.sandbox
        { init = ()
        , update = \_ model -> model
        , view = \_ -> view
        }


view : Html msg
view =
    div []
        [ h2 [] [ text "LoF — Iconic Rendering (○ for Empty Container)" ]
        , LoF.viewStructure (LoF.Box LoF.Void)
        , br [] []
        , LoF.viewCallingDemo
        , br [] []
        , LoF.viewCrossingDemo
        ]
