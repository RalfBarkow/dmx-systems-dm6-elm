port module Ports.Dmx exposing
    ( Error
    , Request
    , Response
    , dmxError
    , dmxRequest
    , dmxResponse
    )

import Json.Decode as D exposing (Value)
import Json.Encode as E


type alias Request =
    { id : String
    , method : String -- "GET" | "POST" | "PUT" | "DELETE"
    , url : String -- absolute or same-origin
    , headers : List ( String, String )
    , body : E.Value -- E.null for GET/DELETE
    , withCredentials : Bool -- include cookies?
    }


type alias Response =
    { id : String
    , status : Int
    , ok : Bool
    , data : Value
    }


type alias Error =
    { id : String
    , message : String
    }


port dmxRequest : Request -> Cmd msg


port dmxResponse : (Response -> msg) -> Sub msg


port dmxError : (Error -> msg) -> Sub msg
