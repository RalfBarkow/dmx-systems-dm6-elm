module Feature.DMX.DecodersTest exposing (tests)

import Dict
import Expect
import Feature.DMX.Decoders as Dmx
import Json.Decode as D
import Test exposing (..)
import Time


sampleJson : String
sampleJson =
    """
    {
      "id": 830082,
      "uri": "",
      "typeUri": "dmx.topicmaps.topicmap",
      "value": "dm6-elm",
      "children": {
        "dmx.topicmaps.topicmap_type_uri": {
          "id": 2167,
          "uri": "",
          "typeUri": "dmx.topicmaps.topicmap_type_uri",
          "value": "dmx.topicmaps.topicmap",
          "children": {},
          "assoc": {
            "id": 830089,
            "uri": "",
            "typeUri": "dmx.core.composition",
            "value": "",
            "children": {},
            "player1": { "topicId": 2167, "roleTypeUri": "dmx.core.child" },
            "player2": { "topicId": 830082, "roleTypeUri": "dmx.core.parent" }
          }
        },
        "dmx.topicmaps.topicmap_name": {
          "id": 830077,
          "uri": "",
          "typeUri": "dmx.topicmaps.topicmap_name",
          "value": "dm6-elm",
          "children": {},
          "assoc": {
            "id": 830085,
            "uri": "",
            "typeUri": "dmx.core.composition",
            "value": "",
            "children": {},
            "player1": { "topicId": 830077, "roleTypeUri": "dmx.core.child" },
            "player2": { "topicId": 830082, "roleTypeUri": "dmx.core.parent" }
          }
        },
        "dmx.timestamps.created": {
          "id": -1,
          "typeUri": "dmx.timestamps.created",
          "value": 1754553380950,
          "children": {},
          "assoc": { "id": -1, "children": {} }
        },
        "dmx.timestamps.modified": {
          "id": -1,
          "typeUri": "dmx.timestamps.modified",
          "value": 1754553380950,
          "children": {},
          "assoc": { "id": -1, "children": {} }
        }
      }
    }
    """


tests : Test
tests =
    describe "DMX Decoders"
        [ test "Decodes topic id/type/value" <|
            \_ ->
                case D.decodeString Dmx.topicDecoder sampleJson of
                    Ok t ->
                        Expect.all
                            [ \_ -> Expect.equal 830082 t.id
                            , \_ -> Expect.equal "dmx.topicmaps.topicmap" t.typeUri
                            , \_ -> Expect.equal (Just "dm6-elm") (Dmx.valueToString t.value)
                            ]
                            -- <-- apply a unit subject
                            ()

                    Err e ->
                        Expect.fail (D.errorToString e)
        , test "topicmap_name child exists and equals 'dm6-elm'" <|
            \_ ->
                case D.decodeString Dmx.topicDecoder sampleJson of
                    Ok t ->
                        Expect.equal (Just "dm6-elm") (Dmx.topicmapName t)

                    Err e ->
                        Expect.fail (D.errorToString e)
        , test "created/modified timestamps convert to millis (and Posix is constructible)" <|
            \_ ->
                case D.decodeString Dmx.topicDecoder sampleJson of
                    Ok t ->
                        let
                            createdMs =
                                t
                                    |> Dmx.childByType "dmx.timestamps.created"
                                    |> Maybe.map Dmx.childValue
                                    |> Maybe.andThen Dmx.valueToInt

                            modifiedMs =
                                t
                                    |> Dmx.childByType "dmx.timestamps.modified"
                                    |> Maybe.map Dmx.childValue
                                    |> Maybe.andThen Dmx.valueToInt

                            createdPosixOk =
                                createdMs
                                    |> Maybe.andThen (\ms -> Just (Time.millisToPosix ms))
                                    |> Maybe.map (\p -> Time.posixToMillis p)
                        in
                        Expect.all
                            [ \_ -> Expect.equal (Just 1754553380950) createdMs
                            , \_ -> Expect.equal (Just 1754553380950) modifiedMs
                            , \_ -> Expect.equal (Just 1754553380950) createdPosixOk
                            ]
                            -- <-- apply a unit subject
                            ()

                    Err e ->
                        Expect.fail (D.errorToString e)
        , test "assoc on topicmap_name is a composition with p1/p2" <|
            \_ ->
                case D.decodeString Dmx.topicDecoder sampleJson of
                    Ok t ->
                        let
                            assocType =
                                t
                                    |> Dmx.childByType "dmx.topicmaps.topicmap_name"
                                    |> Maybe.andThen Dmx.childAssoc
                                    |> Maybe.andThen Dmx.assocTypeUri
                        in
                        Expect.equal (Just "dmx.core.composition") assocType

                    Err e ->
                        Expect.fail (D.errorToString e)
        , test "Value helpers: number → int/posix; string → string; null → Nothing" <|
            \_ ->
                let
                    num =
                        Dmx.VNumber 42

                    str =
                        Dmx.VString "abc"

                    nul =
                        Dmx.VNull
                in
                Expect.all
                    [ \_ -> Expect.equal (Just 42) (Dmx.valueToInt num)
                    , \_ -> Expect.equal (Just "abc") (Dmx.valueToString str)
                    , \_ -> Expect.equal Nothing (Dmx.valueToString nul)
                    , \_ ->
                        case Dmx.valueToPosix (Dmx.VNumber 1000) of
                            Just p ->
                                -- 1 second epoch
                                Expect.equal 1000 (Time.posixToMillis p)

                            Nothing ->
                                Expect.fail "expected posix"
                    ]
                    -- <-- apply a unit subject
                    ()
        , test "assoc may be minimal (id only) and still decode (timestamps children)" <|
            \_ ->
                case D.decodeString Dmx.topicDecoder sampleJson of
                    Ok t ->
                        let
                            createdAssocId =
                                t
                                    |> Dmx.childByType "dmx.timestamps.created"
                                    |> Maybe.andThen Dmx.childAssoc
                                    |> Maybe.map Dmx.assocId
                        in
                        Expect.equal (Just -1) createdAssocId

                    Err e ->
                        Expect.fail (D.errorToString e)
        ]
