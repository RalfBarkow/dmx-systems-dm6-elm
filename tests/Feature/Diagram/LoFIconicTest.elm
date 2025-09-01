module Feature.Diagram.LoFIconicTest exposing (tests)

import Expect
import Feature.Diagram.LoF as LoF
import Feature.Diagram.LoFIconic as Iconic
import Test exposing (..)


tests : Test
tests =
    describe "Symbolic rendering"
        [ test "Void→∅" <|
            \_ -> Iconic.toSymbolic LoF.Void |> Expect.equal "∅"
        , test "Box Void→(∅)" <|
            \_ -> Iconic.toSymbolic (LoF.Box LoF.Void) |> Expect.equal "(∅)"
        , test "Juxtaposition→space separated" <|
            \_ ->
                Iconic.toSymbolic (LoF.Juxt [ LoF.Box LoF.Void, LoF.Void ])
                    |> Expect.equal "(∅) ∅"
        ]
