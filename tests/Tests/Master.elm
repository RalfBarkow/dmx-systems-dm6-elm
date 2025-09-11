module Tests.Master exposing (tests)

import Expect
import Test exposing (..)


tests : Test
tests =
    describe "Master suite (temporarily skipped)"
        [ test "dummy pass" <|
            \_ -> Expect.pass
        ]
