module Feature.DMX.Decoders exposing
    ( Assoc
    , Child
    , PlayerRef
    , Topic
    , Value(..)
    , assocId
    , assocTypeUri
    , childAssoc
    , childByType
    , childChildren
    , childDecoder
    , childId
    , childTypeUri
    , childValue
    , topicDecoder
    , topicmapName
    , valueToFloat
    , valueToInt
    , valueToPosix
    , valueToString
    )

import Dict exposing (Dict)
import Json.Decode as D
import Time exposing (Posix)



-- DOMAIN TYPES


type alias Topic =
    { id : Int
    , typeUri : String
    , value : Value
    , children : Dict String Child
    }



-- Wrap Child record to break self recursion


type Child
    = Child
        { id : Int
        , typeUri : String
        , value : Value
        , children : Dict String Child
        , assoc : Maybe Assoc
        }



-- Wrap Assoc record to break alias cycle with Child


type Assoc
    = Assoc
        { id : Int
        , typeUri : Maybe String
        , value : Maybe String
        , player1 : Maybe PlayerRef
        , player2 : Maybe PlayerRef
        , children : Dict String Child
        }


type alias PlayerRef =
    { topicId : Int
    , roleTypeUri : String
    }



-- DMX values we see: string | number | null (extend if you meet bool/array)


type Value
    = VString String
    | VNumber Float
    | VNull



-- DECODERS


topicDecoder : D.Decoder Topic
topicDecoder =
    D.map4 Topic
        (D.field "id" D.int)
        (D.field "typeUri" D.string)
        (D.field "value" valueDecoder)
        (D.field "children" (D.dict (D.lazy (\_ -> childDecoder))))


childDecoder : D.Decoder Child
childDecoder =
    D.map5
        (\id_ ty val ch assoc_ ->
            Child
                { id = id_
                , typeUri = ty
                , value = val
                , children = ch
                , assoc = assoc_
                }
        )
        (D.field "id" D.int)
        (D.field "typeUri" D.string)
        (D.field "value" valueDecoder)
        (D.field "children" (D.dict (D.lazy (\_ -> childDecoder))))
        (D.maybe (D.field "assoc" assocDecoder))


assocDecoder : D.Decoder Assoc
assocDecoder =
    let
        childrenDictDecoder : D.Decoder (Dict String Child)
        childrenDictDecoder =
            D.oneOf
                [ D.field "children" (D.dict (D.lazy (\_ -> childDecoder)))
                , D.succeed Dict.empty
                ]
    in
    D.map6
        (\id_ ty val p1 p2 ch ->
            Assoc
                { id = id_
                , typeUri = ty
                , value = val
                , player1 = p1
                , player2 = p2
                , children = ch
                }
        )
        (D.field "id" D.int)
        (D.maybe (D.field "typeUri" D.string))
        (D.maybe (D.field "value" D.string))
        (D.maybe (D.field "player1" playerRefDecoder))
        (D.maybe (D.field "player2" playerRefDecoder))
        childrenDictDecoder


playerRefDecoder : D.Decoder PlayerRef
playerRefDecoder =
    D.map2 PlayerRef
        (D.field "topicId" D.int)
        (D.field "roleTypeUri" D.string)


valueDecoder : D.Decoder Value
valueDecoder =
    D.oneOf
        [ D.map VString D.string
        , D.map VNumber D.float
        , D.null VNull
        ]



-- ACCESSORS (since Child/Assoc are custom types)


childId : Child -> Int
childId (Child r) =
    r.id


childTypeUri : Child -> String
childTypeUri (Child r) =
    r.typeUri


childValue : Child -> Value
childValue (Child r) =
    r.value


childChildren : Child -> Dict String Child
childChildren (Child r) =
    r.children


childAssoc : Child -> Maybe Assoc
childAssoc (Child r) =
    r.assoc


assocId : Assoc -> Int
assocId (Assoc a) =
    a.id


assocTypeUri : Assoc -> Maybe String
assocTypeUri (Assoc a) =
    a.typeUri



-- HELPERS


valueToString : Value -> Maybe String
valueToString v =
    case v of
        VString s ->
            Just s

        _ ->
            Nothing


valueToFloat : Value -> Maybe Float
valueToFloat v =
    case v of
        VNumber n ->
            Just n

        _ ->
            Nothing


valueToInt : Value -> Maybe Int
valueToInt v =
    case v of
        VNumber n ->
            Just (round n)

        _ ->
            Nothing


valueToPosix : Value -> Maybe Posix
valueToPosix v =
    valueToInt v |> Maybe.map Time.millisToPosix


childByType : String -> Topic -> Maybe Child
childByType typeUri topic =
    Dict.get typeUri topic.children


topicmapName : Topic -> Maybe String
topicmapName topic =
    childByType "dmx.topicmaps.topicmap_name" topic
        |> Maybe.map childValue
        |> Maybe.andThen valueToString
