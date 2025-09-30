module Main exposing (main)

import Browser
import Demo.GoldenSpiral as GS
import Html exposing (Html)


main : Program () () (Html msg)
main =
    Browser.sandbox
        { init = ()
        , update = \_ m -> m
        , view = \_ -> GS.view
        }
