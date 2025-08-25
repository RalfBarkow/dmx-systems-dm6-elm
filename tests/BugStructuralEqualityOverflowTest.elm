module BugStructuralEqualityOverflowTest exposing (tests)

import Expect
import Test exposing (..)

type Nat = Z | S Nat

makeNat : Int -> Nat
makeNat n =
    List.foldl (\_ acc -> S acc) Z (List.repeat n ())

type alias Topic =
    { id : Int, deep : Nat }

type alias Assoc =
    { id : Int, player1 : Topic, player2 : Topic }

hasPlayerBad : Topic -> Assoc -> Bool
hasPlayerBad p a =
    a.player1 == p || a.player2 == p

makeTopic : Int -> Int -> Topic
makeTopic i depth =
    { id = i, deep = makeNat depth }

tests : Test
tests =
    only <|
        test "Structural equality overflows in _Utils_eqHelp on deep chain" <|
            \_ ->
                let
                    depth = 10000000
                    t1 = makeTopic 1 depth
                    t2 = makeTopic 1 depth
                    assocs = [ { id = 1, player1 = t1, player2 = t1 } ]
                in
                assocs
                    |> List.filter (hasPlayerBad t2)
                    |> List.length
                    |> Expect.equal 1
