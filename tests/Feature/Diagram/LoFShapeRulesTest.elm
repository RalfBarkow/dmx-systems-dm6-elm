module Feature.Diagram.LoFShapeRulesTest exposing (tests)

import Expect
import Test exposing (..)



-- Minimal LoF definition


type LoF
    = Void
    | Box LoF
    | Juxt (List LoF)



-- Version A (fixed with shape rules)


rewriteOnceA : LoF -> LoF
rewriteOnceA term =
    case term of
        Box (Box Void) ->
            Void

        Juxt xs ->
            case xs of
                (Box Void) :: (Box Void) :: rest ->
                    Juxt (Box Void :: rest)

                [] ->
                    Void

                [ x ] ->
                    x

                Void :: rest ->
                    Juxt rest

                x :: Void :: rest ->
                    Juxt (x :: rest)

                _ ->
                    Juxt (List.map rewriteOnceA xs)

        Box x ->
            let
                x1 =
                    rewriteOnceA x
            in
            if x1 /= x then
                Box x1

            else
                Box x

        Void ->
            Void



-- Version B (alternate spelling, same rules)


rewriteOnceB : LoF -> LoF
rewriteOnceB term =
    case term of
        Box (Box Void) ->
            Void

        Juxt [ Box Void, Box Void ] ->
            Box Void

        Juxt [] ->
            Void

        Juxt [ x ] ->
            x

        Juxt (Void :: xs) ->
            Juxt xs

        Juxt (x :: Void :: xs) ->
            Juxt (x :: xs)

        Box inner ->
            let
                inner1 =
                    rewriteOnceB inner
            in
            if inner1 /= inner then
                Box inner1

            else
                Box inner

        Juxt xs ->
            Juxt (List.map rewriteOnceB xs)

        Void ->
            Void



-- Shared reducer (applies rewrite until fixed point)


reduce : (LoF -> LoF) -> LoF -> LoF
reduce step t0 =
    let
        t1 =
            step t0
    in
    if t1 == t0 then
        t0

    else
        reduce step t1



-- Tests showing why shape rules matter


tests : Test
tests =
    describe "Shape-rule necessities"
        [ test "Juxt [] must normalize to Void" <|
            \_ ->
                Expect.equal
                    (reduce rewriteOnceA (Juxt []))
                    (reduce rewriteOnceB (Juxt []))
        , test "Juxt [x] must normalize to x" <|
            \_ ->
                let
                    x =
                        Box Void
                in
                Expect.equal
                    (reduce rewriteOnceA (Juxt [ x ]))
                    (reduce rewriteOnceB (Juxt [ x ]))
        , test "Void drops from head of Juxt" <|
            \_ ->
                let
                    t =
                        Juxt [ Void, Box Void ]
                in
                Expect.equal
                    (reduce rewriteOnceA t)
                    (reduce rewriteOnceB t)
        , test "Void drops from middle of Juxt" <|
            \_ ->
                let
                    t =
                        Juxt [ Box (Box Void), Void, Box Void ]
                in
                Expect.equal
                    (reduce rewriteOnceA t)
                    (reduce rewriteOnceB t)
        ]
