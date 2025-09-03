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
        [ div [] [ text "Iconic Rendering (○ for Empty Container)" ]
        , br [] []
        , LoF.viewStructure (LoF.Box LoF.Void)
        , br [] []
        , LoF.viewCallingDemo
        , br [] []
        , LoF.viewCrossingDemo
        ]
