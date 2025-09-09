module Compat.WikiLink.RegexTest exposing (tests)

import Compat.WikiLink.Regex as WL
import Expect
import Test exposing (..)


tests : Test
tests =
    describe "Compat.WikiLink.Regex"
        [ describe "parse"
            [ test "extracts a single [[Title]]" <|
                \_ ->
                    "[[DM6 Elm]] app"
                        |> WL.parse
                        |> Expect.equal [ "DM6 Elm" ]
            , test "extracts multiple links in order" <|
                \_ ->
                    "foo [[One]] bar [[Two Three]] baz"
                        |> WL.parse
                        |> Expect.equal [ "One", "Two Three" ]
            , test "returns [] when there are no links" <|
                \_ ->
                    "no links here"
                        |> WL.parse
                        |> Expect.equal []
            , test "ignores external link tokens like [https://… label]" <|
                \_ ->
                    "mix [[Alpha]] and [https://example.com label] then [[Beta]]"
                        |> WL.parse
                        |> Expect.equal [ "Alpha", "Beta" ]
            , test "keeps Unicode and inner spaces as-is" <|
                \_ ->
                    "see [[  Montréal Café  ]] and [[Zürich]]"
                        |> WL.parse
                        |> Expect.equal [ "  Montréal Café  ", "Zürich" ]
            ]
        , describe "slug"
            [ test "basic punctuation removed, spaces collapsed to dashes" <|
                \_ ->
                    "Federated Wiki!"
                        |> WL.slug
                        |> Expect.equal "federated-wiki"
            , test "multiple spaces collapse to a single dash" <|
                \_ ->
                    "  DM6   Elm  "
                        |> WL.slug
                        |> Expect.equal "dm6-elm"
            , test "non-ascii letters dropped by minimal slug rule" <|
                \_ ->
                    "Zürich Café"
                        |> WL.slug
                        |> Expect.equal "zrich-caf"
            ]
        ]
