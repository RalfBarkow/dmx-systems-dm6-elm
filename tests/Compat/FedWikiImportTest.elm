module Compat.FedWikiImportTest exposing (tests)

import AppModel as AM
import Compat.FedWikiImport as FW
import Expect
import Json.Decode as D
import Json.Encode as E
import Storage exposing (modelDecoder)
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


emptyModel : AM.Model
emptyModel =
    let
        json =
            """
            {
              "nextId": 1,
              "items": {},
              "maps": {
                "0": { "id": 0, "items": {} }
              }
            }
            """
    in
    case D.decodeString modelDecoder json of
        Ok m ->
            m

        Err err ->
            Debug.todo ("Bad empty model fixture: " ++ D.errorToString err)


tests : Test
tests =
    describe "FedWiki import"
        [ test "{} page normalizes title to 'empty' and creates one topic" <|
            \_ ->
                let
                    v =
                        case D.decodeString D.value "{}" of
                            Ok vv ->
                                vv

                            Err _ ->
                                Debug.todo "decode sanity"

                    ( model1, _ ) =
                        FW.importPage v emptyModel
                in
                Expect.equal model1.nextId (emptyModel.nextId + 1)
        , test "pageDecoder: {} yields title = \"empty\"" <|
            \_ ->
                case D.decodeString FW.pageDecoder "{}" of
                    Ok page ->
                        Expect.equal page.title "empty"

                    Err err ->
                        Expect.fail ("decoder failed: " ++ D.errorToString err)
        ]
