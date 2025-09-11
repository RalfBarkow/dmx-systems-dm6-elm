module Tests.Master exposing (tests)

-- import only the safe tests you want on master

import Model.AddItemToMapCycleTest
import Model.DefaultModelTest
import Test exposing (..)


tests : Test
tests =
    describe "Master suite"
        [ Model.DefaultModelTest.tests
        , Model.AddItemToMapCycleTest.tests
        ]
