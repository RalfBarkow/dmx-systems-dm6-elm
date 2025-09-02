module Feature.DMX.Feature exposing
    ( Model
    , Msg(..)
    , init
    , subscriptions
    , update
    )

import Feature.DMX.Http as DmxHttp
import Http
import Json.Decode as D



-- MODEL


type alias Model =
    { lastTopic : Maybe D.Value
    , lastTopicmap : Maybe D.Value
    , error : Maybe String
    }


init : ( Model, Cmd Msg )
init =
    ( { lastTopic = Nothing
      , lastTopicmap = Nothing
      , error = Nothing
      }
    , DmxHttp.getTopic DmxHttp.defaultConfig 1 GotTopic
    )



-- MSG


type Msg
    = GotTopic (Result Http.Error D.Value)
    | GotTopicmap (Result Http.Error D.Value)
    | GotSearch (Result Http.Error D.Value)



-- UPDATE


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        GotTopic (Ok json) ->
            ( { model | lastTopic = Just json }, Cmd.none )

        GotTopic (Err e) ->
            ( { model | error = Just (Debug.toString e) }, Cmd.none )

        GotTopicmap (Ok json) ->
            ( { model | lastTopicmap = Just json }, Cmd.none )
