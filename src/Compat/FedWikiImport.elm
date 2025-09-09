module Compat.FedWikiImport exposing
    ( Page
    , importPage
    , pageDecoder
    , storyItemDecoder
    )

import AppModel as AM
import Compat.ModelAPI as CAPI
import Json.Decode as D exposing (Decoder)
import Model exposing (..)
import String



-- TYPES


type alias Page =
    { title : String
    , story : List StoryItem
    }


type StoryItem
    = Paragraph String
    | Unknown



-- DECODERS


titleDecoder : Decoder String
titleDecoder =
    D.maybe (D.field "title" D.string)
        |> D.map (Maybe.withDefault "empty")


paragraphTextDecoder : Decoder String
paragraphTextDecoder =
    D.maybe (D.field "text" D.string)
        |> D.map (Maybe.withDefault "")


storyItemDecoder : Decoder StoryItem
storyItemDecoder =
    D.oneOf
        [ D.field "type" D.string
            |> D.andThen
                (\t ->
                    if t == "paragraph" then
                        D.map Paragraph paragraphTextDecoder

                    else
                        D.succeed Unknown
                )
        , D.succeed Unknown
        ]


storyDecoder : Decoder (List StoryItem)
storyDecoder =
    D.maybe (D.field "story" (D.list storyItemDecoder))
        |> D.map (Maybe.withDefault [])


pageDecoder : Decoder Page
pageDecoder =
    D.map2 Page
        titleDecoder
        storyDecoder



-- IMPORT


{-| Import a FedWiki page JSON Value into the model.

Rules:

  - {} is valid -> title defaults to "empty"
  - Always create exactly one topic per page (even if story is empty)

-}
importPage : D.Value -> AM.Model -> ( AM.Model, Cmd msg )
importPage value model0 =
    case D.decodeValue pageDecoder value of
        Err _ ->
            let
                -- createTopic : String -> Maybe IconName -> AM.Model -> (AM.Model, Id)
                ( model1, topicId ) =
                    CAPI.createTopic "empty" Nothing model0
            in
            ( model1, Cmd.none )

        Ok page ->
            let
                normalizedTitle =
                    page.title
                        |> String.trim
                        |> (\t ->
                                if t == "" then
                                    "empty"

                                else
                                    t
                           )

                ( model1, topicId ) =
                    CAPI.createTopic normalizedTitle Nothing model0
            in
            ( model1, Cmd.none )
