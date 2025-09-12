module Tests.Master exposing (tests)

import Domain.ReparentRulesTest
import Model.DefaultModelTest
import Search.UpdateTest
import Test exposing (..)
import View.ToolbarButtonsTest


tests : Test
tests =
    describe "Master (compat + invariants)"
        [ Domain.ReparentRulesTest.tests
        , Model.DefaultModelTest.tests
        , Search.UpdateTest.tests
        , View.ToolbarButtonsTest.tests
        ]
