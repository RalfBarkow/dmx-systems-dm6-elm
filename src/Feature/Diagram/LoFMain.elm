module Feature.Diagram.LoFMain exposing (main)

import Browser
import Feature.Diagram.LoFReentryAll as Reentry
import Html exposing (Html)


main : Program () Reentry.Model Reentry.Msg
main =
    Browser.sandbox
        { init = Reentry.init
        , update = Reentry.update
        , view = Reentry.view
        }
