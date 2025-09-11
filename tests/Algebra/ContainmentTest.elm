module Algebra.ContainmentTest exposing (tests)

import Algebra.Containment as C
import Expect
import Test exposing (..)


d : Int -> C.Depth
d n =
    C.Depth n


tests : Test
tests =
    describe "Containment arithmetic (depth)"
        [ test "within is associative" <|
            \_ ->
                let
                    lhs =
                        C.within (d 1) (C.within (d 2) (d 3))

                    rhs =
                        C.within (C.within (d 1) (d 2)) (d 3)
                in
                Expect.equal lhs rhs
        , test "depth addition and multiplication basic laws" <|
            \_ ->
                Expect.all
                    [ \_ -> Expect.equal (C.within (d 2) (d 3)) (d 5)
                    , \_ -> Expect.equal (C.times (d 2) (d 3)) (d 6)
                    ]
                    ()
        , test "distributivity over depth (Int semantics)" <|
            \_ ->
                let
                    a =
                        d 2

                    b =
                        d 3

                    c =
                        d 4
                in
                Expect.equal
                    (C.times a (C.within b c))
                    (C.within (C.times a b) (C.times a c))
        ]
