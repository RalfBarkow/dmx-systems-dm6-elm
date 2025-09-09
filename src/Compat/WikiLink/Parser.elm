module Compat.WikiLink.Parser exposing (Segment(..), parseLine, slug)

import Parser
    exposing
        ( (|.)
        , (|=)
        , Parser
        , Step(..)
        , chompUntil
        , chompWhile
        , end
        , getChompedString
        , loop
        , oneOf
        , run
        , succeed
        , symbol
        )


type Segment
    = Plain String
    | Wiki String
    | ExtLink String String


parseLine : String -> Result (List Parser.DeadEnd) (List Segment)
parseLine input =
    run segments input


segments : Parser (List Segment)
segments =
    loop [] <|
        \rev ->
            oneOf
                [ end
                    |> Parser.map (\_ -> Done (List.reverse rev))
                , segmentParser
                    |> Parser.map (\seg -> Loop (seg :: rev))
                ]


segmentParser : Parser Segment
segmentParser =
    oneOf
        [ wikiLink
        , extLink
        , plainText
        ]


wikiLink : Parser Segment
wikiLink =
    succeed Wiki
        |. symbol "[["
        |= getChompedString (chompUntil "]]")
        |. symbol "]]"


extLink : Parser Segment
extLink =
    succeed ExtLink
        |. symbol "["
        |= getChompedString (chompWhile (\c -> c /= ' ' && c /= ']'))
        -- URL
        |= oneOf
            [ succeed identity
                |. chompWhile (\c -> c == ' ')
                |= getChompedString (chompUntil "]")

            -- label
            , succeed "" -- no label
            ]
        |. symbol "]"


plainText : Parser Segment
plainText =
    getChompedString (chompWhile (\c -> c /= '['))
        |> Parser.map Plain


slug : String -> String
slug =
    String.toLower
        >> String.trim
        >> String.split " "
        >> String.join "-"
