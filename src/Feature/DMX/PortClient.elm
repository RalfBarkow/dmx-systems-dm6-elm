module Feature.DMX.PortClient exposing (getTopicDeep)

import Json.Encode as E
import Ports.Dmx as Port


basePath : String
basePath =
    "/core"



-- leave relative; JS glue adds BASE


getTopicDeep :
    { topicId : Int
    , toMsg : Port.Response -> msg
    , onErr : Port.Error -> msg
    }
    -> ( Cmd msg, Sub msg )
getTopicDeep { topicId, toMsg, onErr } =
    let
        url =
            basePath
                ++ "/topic/"
                ++ String.fromInt topicId
                ++ "?children=true&assocChildren=true"

        req : Port.Request
        req =
            { id = "getTopicDeep:" ++ String.fromInt topicId
            , method = "GET"
            , url = url
            , headers = [] -- or add auth headers if you do Basic Auth
            , body = E.null
            , withCredentials = True -- include DMX session cookie
            }
    in
    ( Port.dmxRequest req
    , Sub.batch
        [ Port.dmxResponse toMsg
        , Port.dmxError onErr
        ]
    )
