module SmokeTest exposing (tests)

import Expect
import Test exposing (Test, describe, test)


tests : Test
tests =
    describe "smoke"
        [ test "sanity" <| \_ -> Expect.equal True True ]
