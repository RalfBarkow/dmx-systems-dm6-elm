module Compat.WikiLink.ParserTest exposing (tests)

import Compat.WikiLink.Parser as P
import Expect
import Test exposing (..)


expectOk : Result x a -> a
expectOk r =
    case r of
        Ok a ->
            a

        Err _ ->
            Debug.todo "Parser failed; see the test diff for details."


tests : Test
tests =
    describe "Compat.WikiLink.Parser.parseLine"
        [ test "plain text only" <|
            \_ ->
                "hello"
                    |> P.parseLine
                    |> expectOk
                    |> Expect.equal [ P.Plain "hello" ]
        , test "single wiki link in the middle" <|
            \_ ->
                "a [[DM6 Elm]] app"
                    |> P.parseLine
                    |> expectOk
                    |> Expect.equal
                        [ P.Plain "a "
                        , P.Wiki "DM6 Elm"
                        , P.Plain " app"
                        ]
        , test "multiple mixed with external link that has label" <|
            \_ ->
                "A [[One]] and [https://ex.com ext] and [[Two Three]]!"
                    |> P.parseLine
                    |> expectOk
                    |> Expect.equal
                        [ P.Plain "A "
                        , P.Wiki "One"
                        , P.Plain " and "
                        , P.ExtLink "https://ex.com" "ext"
                        , P.Plain " and "
                        , P.Wiki "Two Three"
                        , P.Plain "!"
                        ]
        , test "external link without label" <|
            \_ ->
                "go [https://ex.com] now"
                    |> P.parseLine
                    |> expectOk
                    |> Expect.equal
                        [ P.Plain "go "
                        , P.ExtLink "https://ex.com" ""
                        , P.Plain " now"
                        ]
        , test "starts with link" <|
            \_ ->
                "[[Start]] then text"
                    |> P.parseLine
                    |> expectOk
                    |> Expect.equal
                        [ P.Wiki "Start"
                        , P.Plain " then text"
                        ]
        , test "ends with link" <|
            \_ ->
                "text then [[End]]"
                    |> P.parseLine
                    |> expectOk
                    |> Expect.equal
                        [ P.Plain "text then "
                        , P.Wiki "End"
                        ]
        , test "consecutive wiki links" <|
            \_ ->
                "[[A]][[B]]"
                    |> P.parseLine
                    |> expectOk
                    |> Expect.equal
                        [ P.Wiki "A"
                        , P.Wiki "B"
                        ]
        , test "unicode inside wiki link preserved" <|
            \_ ->
                "see [[Zürich Café]]"
                    |> P.parseLine
                    |> expectOk
                    |> Expect.equal
                        [ P.Plain "see "
                        , P.Wiki "Zürich Café"
                        ]
        ]
