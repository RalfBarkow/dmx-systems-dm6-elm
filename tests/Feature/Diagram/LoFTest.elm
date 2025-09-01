module Feature.Diagram.LoFTest exposing (tests)

import Expect
import Feature.Diagram.LoF as LoF
import Html
import Test exposing (..)
import Test.Html.Query as Q
import Test.Html.Selector as S


tests : Test
tests =
    describe "LoF rules and rendering"
        [ test "Calling: ()() ⇒ ()" <|
            \_ ->
                Expect.equal
                    (LoF.reduce (LoF.Juxt [ LoF.Box LoF.Void, LoF.Box LoF.Void ]))
                    (LoF.Box LoF.Void)
        , test "Crossing: (()) ⇒ ∅ (Void)" <|
            \_ ->
                Expect.equal
                    (LoF.reduce (LoF.Box (LoF.Box LoF.Void)))
                    LoF.Void
        , test "Void renders as a circle (○)" <|
            \_ ->
                LoF.viewStructure LoF.Void
                    |> Q.fromHtml
                    |> Q.find [ S.tag "svg" ]
                    |> Q.find [ S.tag "circle" ]
                    |> (\_ -> Expect.pass)
        ]
