module Compat.TestDefault exposing (defaultModel, suite)

import AppMain as AdapterMain
import AppModel as AM
import Dict
import Expect
import Json.Encode as E
import Test exposing (..)


defaultModel : AM.Model
defaultModel =
    Tuple.first (AdapterMain.init E.null)



-- Sanity checks for the adapter that accepts Json.Value (E.null → cold boot)


suite : Test
suite =
    describe "Compat default boot via adapter"
        [ test "init with E.null cold-boots to default model" <|
            \_ ->
                let
                    m =
                        Tuple.first (AdapterMain.init E.null)
                in
                Expect.equal [ 0 ] m.mapPath
        , test "home map (0) exists" <|
            \_ ->
                let
                    m =
                        Tuple.first (AdapterMain.init E.null)
                in
                Expect.equal True (Dict.member 0 m.maps)
        , test "nextId starts at 1" <|
            \_ ->
                let
                    m =
                        Tuple.first (AdapterMain.init E.null)
                in
                Expect.equal 1 m.nextId
        ]
