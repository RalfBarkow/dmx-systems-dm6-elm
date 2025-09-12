module Tests.Main exposing (tests)

-- Everything master has…
-- …plus feature tests present only on main

import Domain.ReparentRulesTest
import Feature.OpenDoor.ButtonTest
import Feature.OpenDoor.CopyTest
import Feature.OpenDoor.StayVisibleTest
import Import.DmxCoreTopicTest
import Model.AddItemToMapCycleTest
import Model.DefaultModelTest
import Model.SelfContainmentInvariantTest
import Search.UpdateTest
import Storage.InitDecodeTest
import Test exposing (..)
import View.ToolbarButtonsTest


tests : Test
tests =
    describe "Main (feature) test suite"
        [ Domain.ReparentRulesTest.tests
        , Import.DmxCoreTopicTest.tests
        , Model.AddItemToMapCycleTest.tests
        , Model.DefaultModelTest.tests
        , Model.SelfContainmentInvariantTest.tests
        , Search.UpdateTest.tests
        , Storage.InitDecodeTest.tests
        , View.ToolbarButtonsTest.tests

        -- Feature-only:
        , Feature.OpenDoor.ButtonTest.tests
        , Feature.OpenDoor.CopyTest.tests
        , Feature.OpenDoor.StayVisibleTest.tests
        ]
