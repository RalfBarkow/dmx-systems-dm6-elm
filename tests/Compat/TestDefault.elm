module Compat.TestDefault exposing (defaultModel, tests)

import AppMain as AdapterMain
import AppModel as AM
import Dict
import Expect
import Json.Encode as E
import Test exposing (..)



-- Expose a plain AppModel.Model (not the undo wrapper)


defaultModel : AM.Model
defaultModel =
    AdapterMain.init E.null
        |> Tuple.first
        |> .present


tests : Test
tests =
    describe "Compat.TestDefault"
        [ test "default model basics" <|
            \_ ->
                let
                    m =
                        defaultModel
                in
                Expect.all
                    [ \_ -> Expect.equal [ 0 ] m.mapPath
                    , \_ -> Expect.equal True (Dict.member 0 m.maps)
                    , \_ -> Expect.equal 1 m.nextId
                    ]
                    ()
        ]
