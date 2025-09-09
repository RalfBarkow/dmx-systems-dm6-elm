module Compat.WikiLink.Regex exposing (parse, slug)

import Regex


parse : String -> List String
parse s =
    let
        re =
            Regex.fromString "\\[\\[([^\\]]+)\\]\\]"
                |> Maybe.withDefault Regex.never
    in
    Regex.find re s
        |> List.filterMap
            (\m ->
                case m.submatches of
                    first :: _ ->
                        first

                    [] ->
                        Nothing
            )
        |> List.filter (\t -> t /= "")


slug : String -> String
slug title =
    title
        |> String.toLower
        |> String.trim
        |> Regex.replace (Maybe.withDefault Regex.never (Regex.fromString "\\s+")) (\_ -> "-")
        |> Regex.replace (Maybe.withDefault Regex.never (Regex.fromString "[^a-z0-9-]")) (\_ -> "")
        |> Regex.replace (Maybe.withDefault Regex.never (Regex.fromString "-+")) (\_ -> "-")
