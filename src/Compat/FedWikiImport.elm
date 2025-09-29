module Compat.FedWikiImport exposing
    ( Page
    , encodeFwMeta
    , importPage
    , pageDecoder
    , storyItemDecoder
    )

import AppModel as AM
import Compat.ModelAPI as CAPI
import Json.Decode as D exposing (Decoder)
import Json.Encode as E
import Model exposing (Id)
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
  - Create one topic for the page title (container)
  - Ensure it has a child map
  - Create one topic per story item **in the child map**
  - Persist lightweight meta (container + story ids) into `fedWikiRaw`

-}
importPage : D.Value -> AM.Model -> ( AM.Model, Cmd msg )
importPage value model0 =
    case D.decodeValue pageDecoder value of
        Err _ ->
            let
                mid =
                    currentMapId model0

                ( model1, titleId ) =
                    CAPI.createTopicAndAddToMap "empty" Nothing mid model0

                ( model2, childMid ) =
                    CAPI.ensureChildMap titleId model1

                -- no story items on error; still persist meta
                model3 =
                    { model2 | fedWikiRaw = encodeFwMeta titleId [] }
            in
            ( model1, Cmd.none )

        Ok page ->
            let
                mid =
                    currentMapId model0

                titleLabel : String
                titleLabel =
                    page.title
                        |> String.trim
                        |> (\t ->
                                if t == "" then
                                    "empty"

                                else
                                    t
                           )

                -- 1) Create a topic for the page title (container) in current map
                ( model1, titleId ) =
                    CAPI.createTopicAndAddToMap titleLabel Nothing mid model0

                -- 2) Ensure the container has a child map
                ( model2, childMid ) =
                    CAPI.ensureChildMap titleId model1

                -- 3) Create topics for each story item inside the CHILD map
                step :
                    StoryItem
                    -> ( List Id, AM.Model )
                    -> ( List Id, AM.Model )
                step si ( accIds, m ) =
                    let
                        raw =
                            String.trim si.text

                        label0 =
                            if raw == "" then
                                -- fall back to the block type if no text
                                String.trim si.typ

                            else
                                raw
                                    |> String.lines
                                    |> List.head
                                    |> Maybe.withDefault raw
                                    |> String.left 120
                                    |> String.trim

                        label =
                            if label0 == "" then
                                "empty"

                            else
                                label0
                    in
                    let
                        ( m2, id2 ) =
                            CAPI.createTopicAndAddToMap label Nothing childMid m
                    in
                    ( id2 :: accIds, m2 )

                ( revIds, model3 ) =
                    List.foldl step ( [], model2 ) page.story

                storyIds =
                    List.reverse revIds

                -- 4) Persist lightweight meta into fedWikiRaw (no Storage changes)
                modelN =
                    { model3 | fedWikiRaw = encodeFwMeta titleId storyIds }
            in
            ( modelN, Cmd.none )


encodeFwMeta : Int -> List Int -> String
encodeFwMeta containerId storyItemIds =
    E.encode 0 <|
        E.object
            [ ( "containerId", E.int containerId )
            , ( "storyItemIds", E.list E.int storyItemIds )
            ]
