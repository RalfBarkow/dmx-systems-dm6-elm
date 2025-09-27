module Compat.FedWikiImport exposing
    ( Page
    , importPage
    , pageDecoder
    , storyItemDecoder
    )

import AppModel as AM
import Compat.ModelAPI as CAPI
import Json.Decode as D exposing (Decoder)
import ModelAPI exposing (currentMapId)
import String



-- TYPES


type alias Page =
    { title : String
    , story : List StoryItem
    }



-- Carry both type and text so we can create a label for any story block


type alias StoryItem =
    { typ : String
    , text : String
    }



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
    D.map2 StoryItem
        (D.maybe (D.field "type" D.string) |> D.map (Maybe.withDefault "unknown"))
        (D.maybe (D.field "text" D.string) |> D.map (Maybe.withDefault ""))


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

  - {} is valid -> title defaults to "empty"
  - Create one topic for the page title
  - Create one topic per story item that has non-empty text

-}
importPage : D.Value -> AM.Model -> ( AM.Model, Cmd msg )
importPage value model0 =
    case D.decodeValue pageDecoder value of
        Err _ ->
            let
                mid =
                    currentMapId model0

                ( model1, _ ) =
                    CAPI.createTopicAndAddToMap "empty" Nothing mid model0
            in
            ( model1, Cmd.none )

        Ok page ->
            let
                mid =
                    currentMapId model0

                titleLabel =
                    page.title
                        |> String.trim
                        |> (\t ->
                                if t == "" then
                                    "empty"

                                else
                                    t
                           )

                -- Create a topic for the page title
                ( model1, _ ) =
                    CAPI.createTopicAndAddToMap titleLabel Nothing mid model0

                -- Create one topic per story item (skip empty)
                modelN =
                    List.foldl
                        (\si m ->
                            let
                                raw =
                                    String.trim si.text

                                label =
                                    if raw == "" then
                                        -- fall back to the block type if no text
                                        si.typ

                                    else
                                        raw
                                            |> String.lines
                                            |> List.head
                                            |> Maybe.withDefault raw
                                            |> String.left 120
                            in
                            if String.trim label == "" then
                                m

                            else
                                let
                                    ( m2, _ ) =
                                        CAPI.createTopicAndAddToMap label Nothing mid m
                                in
                                m2
                        )
                        model1
                        page.story
            in
            ( modelN, Cmd.none )
