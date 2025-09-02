module Feature.DMX.Http exposing
    ( Config
    , defaultConfig
    , getTopic
    , getTopicmap
    , searchTopicsFulltext
    , topicDeepUrl
    , topicUrl
    )

import Http
import Json.Decode as D
import Json.Encode as E


type alias Config =
    { base : String
    , headers : List Http.Header
    }


defaultConfig : Config
defaultConfig =
    { base = "https://dmx.ralfbarkow.ch"
    , headers = [] -- add Authorization etc. here if you use Basic Auth
    }


topicUrl : Config -> Int -> String
topicUrl cfg topicId =
    cfg.base ++ "/core/topic/" ++ String.fromInt topicId


topicDeepUrl : Config -> Int -> String
topicDeepUrl cfg topicId =
    topicUrl cfg topicId ++ "?children=true&assocChildren=true"


{-| GET /core/topic/{id} → raw JSON (tweak the decoder once you freeze the shape)
-}
getTopic : Config -> Int -> (Result Http.Error D.Value -> msg) -> Cmd msg
getTopic cfg topicId toMsg =
    Http.request
        { method = "GET"
        , headers = cfg.headers
        , url = topicUrl cfg topicId
        , body = Http.emptyBody
        , expect = Http.expectJson toMsg D.value
        , timeout = Nothing -- Maybe Float
        , tracker = Just ("dmx:getTopic:" ++ String.fromInt topicId)
        }


{-| GET /topicmaps/{id}
-}
getTopicmap : Config -> Int -> (Result Http.Error D.Value -> msg) -> Cmd msg
getTopicmap cfg tmId toMsg =
    Http.request
        { method = "GET"
        , headers = cfg.headers
        , url = cfg.base ++ "/topicmaps/" ++ String.fromInt tmId
        , body = Http.emptyBody
        , expect = Http.expectJson toMsg D.value
        , timeout = Nothing
        , tracker = Just ("dmx:getTopicmap:" ++ String.fromInt tmId)
        }


{-| Example POST, if you wire a search endpoint.
Adjust path/payload to your DMX setup.
-}
searchTopicsFulltext :
    Config
    -> { query : String }
    -> (Result Http.Error D.Value -> msg)
    -> Cmd msg
searchTopicsFulltext cfg { query } toMsg =
    Http.request
        { method = "POST"
        , headers = cfg.headers
        , url = cfg.base ++ "/search/topics"
        , body = Http.jsonBody <| E.object [ ( "q", E.string query ) ]
        , expect = Http.expectJson toMsg D.value
        , timeout = Nothing
        , tracker = Just "dmx:searchTopicsFulltext"
        }
