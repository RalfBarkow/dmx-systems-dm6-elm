module Compat.FedWikiImportTest exposing (tests)

import AppModel as AM
import Compat.FedWiki as FW exposing (StoryItem(..))
import Dict
import Expect
import Json.Decode as D
import Test exposing (..)



-- Valid minimal FedWiki page JSON


sampleMinimal : String
sampleMinimal =
    """
    {
      "title": "minimal",
      "story": [],
      "journal": [
        {
          "type": "create",
          "item": {
            "title": "minimal",
            "story": []
          },
          "date": 1757401179004
        }
      ]
    }
    """



-- One paragraph whose text is "{}" — should render as empty


sampleBracesAsEmpty : String
sampleBracesAsEmpty =
    """
    {}
    """


tests : Test
tests =
    describe "FedWiki import"
        [ test "decodes minimal page" <|
            \_ ->
                case D.decodeString FW.decodePage sampleMinimal of
                    Ok page ->
                        Expect.equal page.title "minimal"

                    Err err ->
                        Expect.fail (D.errorToString err)
        , test "{} paragraph normalizes to empty and creates one topic" <|
            \_ ->
                case D.decodeString FW.decodePage sampleBracesAsEmpty of
                    Err err ->
                        Expect.fail (D.errorToString err)

                    Ok page ->
                        -- Assert normalization on the decoded StoryItem itself
                        let
                            normalizedFirstItemText =
                                case List.head page.story of
                                    Just (Paragraph r) ->
                                        FW.normalizeContent r.text

                                    _ ->
                                        "--unexpected--"
                        in
                        case normalizedFirstItemText of
                            "" ->
                                -- Also assert the model has exactly one item on root map
                                let
                                    model1 =
                                        FW.pageToModel page AM.default
                                in
                                case Dict.get 0 model1.maps of
                                    Nothing ->
                                        Expect.fail "root map missing"

                                    Just root ->
                                        Expect.equal (Dict.size root.items) 1

                            other ->
                                Expect.fail ("expected empty text, got: " ++ other)
        ]
