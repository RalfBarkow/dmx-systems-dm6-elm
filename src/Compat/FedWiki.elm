module Compat.FedWiki exposing
    ( Page
    , StoryItem(..)
    , decodePage
    , normalizeContent
    , pageToModel
    )

import AppModel as AM
import Compat.ModelAPI as CMA
import Json.Decode as D
import Model exposing (..)
import String exposing (trim)



-- TYPES


type alias Page =
    { title : String
    , story : List StoryItem
    }


type StoryItem
    = Paragraph { id : String, text : String }
    | Image { id : String, url : String, text : String }
    | Reference { id : String, text : String }
    | Unknown { id : String, type_ : String }



-- DECODERS


decodePage : D.Decoder Page
decodePage =
    D.map2 Page
        (D.field "title" D.string)
        (D.field "story" (D.list decodeStoryItem))


decodeStoryItem : D.Decoder StoryItem
decodeStoryItem =
    let
        base =
            D.map2 Tuple.pair
                (D.field "id" D.string)
                (D.field "type" D.string)
    in
    D.andThen
        (\( id, type_ ) ->
            case type_ of
                "paragraph" ->
                    D.map (\text -> Paragraph { id = id, text = text })
                        (D.field "text" D.string)

                "image" ->
                    D.map2 (\url text -> Image { id = id, url = url, text = text })
                        (D.field "url" D.string)
                        (D.field "text" (D.oneOf [ D.string, D.succeed "" ]))

                "reference" ->
                    D.map (\text -> Reference { id = id, text = text })
                        (D.field "text" D.string)

                _ ->
                    D.succeed (Unknown { id = id, type_ = type_ })
        )
        base



-- HELPERS


resetModel : AM.Model -> AM.Model
resetModel m =
    m


addTopic : AM.Model -> MapId -> String -> String -> Point -> AM.Model
addTopic model mapId text icon pos =
    let
        m1 =
            CMA.ensureMap mapId model

        -- NOTE: text first, then (Just icon), then mapId, then model
        ( m2, tid ) =
            CMA.createTopicAndAddToMap text (Just icon) mapId m1

        m3 =
            CMA.setTopicPos mapId tid pos m2
    in
    m3



-- MIRROR: every story item → topic on root map 0 in order


pageToModel : Page -> AM.Model -> AM.Model
pageToModel page model0 =
    let
        root =
            0

        stepY =
            120

        startX =
            240

        startY =
            120

        foldStory : StoryItem -> ( AM.Model, Float ) -> ( AM.Model, Float )
        foldStory item ( m, y ) =
            let
                m2 =
                    case item of
                        Paragraph rec ->
                            addTopic m root (normalizeContent rec.text) "file-text" { x = startX, y = y }

                        Reference rec ->
                            addTopic m root (normalizeContent rec.text) "link" { x = startX, y = y }

                        Image rec ->
                            addTopic m root (normalizeContent rec.url) "image" { x = startX, y = y }

                        Unknown rec ->
                            addTopic m root (normalizeContent ("<" ++ rec.type_ ++ ">")) "help-circle" { x = startX, y = y }
            in
            ( m2, y + stepY )

        ( model1, _ ) =
            List.foldl foldStory ( resetModel model0, startY ) page.story
    in
    model1



-- Treat a literal "{}" (ignoring surrounding whitespace) as empty text


normalizeContent : String -> String
normalizeContent s =
    if String.trim s == "{}" then
        ""

    else
        s
