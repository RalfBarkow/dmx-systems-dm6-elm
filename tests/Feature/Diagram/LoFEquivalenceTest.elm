module Feature.Diagram.LoFEquivalenceTest exposing (tests)

import Expect
import Fuzz
import Test exposing (..)



-- ============================================================
-- Our Laws of Form type
-- ============================================================


type LoF
    = Void
    | Box LoF
    | Juxt (List LoF)



-- ============================================================
-- Version A (initial, only Calling + Crossing, plus shape rules)
-- ============================================================


rewriteOnceA : LoF -> LoF
rewriteOnceA term =
    case term of
        -- CROSSING  (()) ⇒ ∅
        Box (Box Void) ->
            Void

        -- CALLING  ()() ⇒ ()
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
                    Juxt (rewriteListOnceA xs)

        -- Walk into a Box
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


rewriteListOnceA : List LoF -> List LoF
rewriteListOnceA xs =
    case xs of
        [] ->
            []

        y :: ys ->
            let
                y1 =
                    rewriteOnceA y
            in
            if y1 /= y then
                y1 :: ys

            else
                y :: rewriteListOnceA ys


reduceA : LoF -> LoF
reduceA t0 =
    let
        t1 =
            rewriteOnceA t0
    in
    if t1 == t0 then
        t0

    else
        reduceA t1



-- ============================================================
-- Version B (alternate style, same rules)
-- ============================================================


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
            Juxt (rewriteListOnceB xs)

        Void ->
            Void


rewriteListOnceB : List LoF -> List LoF
rewriteListOnceB xs =
    case xs of
        [] ->
            []

        y :: ys ->
            let
                y1 =
                    rewriteOnceB y
            in
            if y1 /= y then
                y1 :: ys

            else
                y :: rewriteListOnceB ys


reduceB : LoF -> LoF
reduceB t0 =
    let
        t1 =
            rewriteOnceB t0
    in
    if t1 == t0 then
        t0

    else
        reduceB t1



-- ============================================================
-- Fuzzer for LoF terms (bounded depth)
-- ============================================================


lofFuzzer : Fuzz.Fuzzer LoF
lofFuzzer =
    Fuzz.intRange 0 3
        |> Fuzz.andThen (\depth -> genLoF depth)


genLoF : Int -> Fuzz.Fuzzer LoF
genLoF depth =
    if depth <= 0 then
        Fuzz.constant Void

    else
        Fuzz.oneOf
            [ Fuzz.constant Void
            , Fuzz.map Box (genLoF (depth - 1))
            , Fuzz.map Juxt (Fuzz.listOfLengthBetween 0 3 (genLoF (depth - 1)))
            ]



-- ============================================================
-- Tests
-- ============================================================


tests : Test
tests =
    describe "Equivalence of reduceA and reduceB"
        [ fuzz lofFuzzer "Both reducers yield the same normal form" <|
            \t ->
                Expect.equal (reduceA t) (reduceB t)
        ]
