port module Storage exposing
    ( exportJSON
    , importJSON
    , modelDecoder
    , store
      -- keep both APIs so all callers work
    , storeModel
    , storeModelWith
    , storeWith
    )

-- Model, Item, Map, etc.

import AppModel as AM
import Compat.Display as Display
import Defaults exposing (editState, iconMenu, mouse, search)
import Dict exposing (Dict)
import Json.Decode as D
import Json.Decode.Pipeline exposing (hardcoded, required)
import Json.Encode as E
import Model as M exposing (..)



-- keep using M.Item, M.Map, etc.
-- JS sink


port persist : E.Value -> Cmd msg



-- ========= SAVE (pipeline-friendly, as your callers expect) =========


storeModel : AM.Model -> ( AM.Model, Cmd AM.Msg )
storeModel model =
    ( model, encodeModel model |> persist )


storeModelWith : ( AM.Model, Cmd AM.Msg ) -> ( AM.Model, Cmd AM.Msg )
storeModelWith ( model, cmd ) =
    ( model
    , Cmd.batch
        [ cmd
        , encodeModel model |> persist
        ]
    )



-- Back-compat aliases some modules import


store : AM.Model -> ( AM.Model, Cmd AM.Msg )
store =
    storeModel


storeWith : ( AM.Model, Cmd AM.Msg ) -> ( AM.Model, Cmd AM.Msg )
storeWith =
    storeModelWith



-- ========= IMPORT/EXPORT (no-ops in embed) =========


importJSON : () -> Cmd AM.Msg
importJSON _ =
    Cmd.none


exportJSON : () -> Cmd AM.Msg
exportJSON _ =
    Cmd.none



-- ========= ENCODE (for persist port) =========


encodeModel : AM.Model -> E.Value
encodeModel model =
    E.object
        [ ( "items", model.items |> Dict.values |> E.list encodeItem )
        , ( "maps", model.maps |> Dict.values |> E.list encodeMap )
        , ( "mapPath", E.list E.int model.mapPath )
        , ( "nextId", E.int model.nextId )
        ]


encodeItem : Item -> E.Value
encodeItem item =
    E.object
        [ case item.info of
            Topic topic ->
                ( "topic"
                , E.object
                    [ ( "id", E.int topic.id )
                    , ( "text", E.string topic.text )
                    , ( "icon", E.string <| Maybe.withDefault "" topic.iconName )
                    ]
                )

            Assoc assoc ->
                ( "assoc"
                , E.object
                    [ ( "id", E.int assoc.id )
                    , ( "type", E.string assoc.itemType )
                    , ( "role1", E.string assoc.role1 )
                    , ( "player1", E.int assoc.player1 )
                    , ( "role2", E.string assoc.role2 )
                    , ( "player2", E.int assoc.player2 )
                    ]
                )
        ]


encodeMap : Map -> E.Value
encodeMap map =
    E.object
        [ ( "id", E.int map.id )
        , ( "rect"
          , E.object
                [ ( "x1", E.float map.rect.x1 )
                , ( "y1", E.float map.rect.y1 )
                , ( "x2", E.float map.rect.x2 )
                , ( "y2", E.float map.rect.y2 )
                ]
          )
        , ( "items", map.items |> Dict.values |> E.list encodeMapItem )
        ]


encodeMapItem : MapItem -> E.Value
encodeMapItem item =
    E.object
        [ ( "id", E.int item.id )
        , ( "parentAssocId", E.int item.parentAssocId )
        , ( "hidden", E.bool item.hidden )
        , ( "pinned", E.bool item.pinned )
        , case item.props of
            MapTopic topicProps ->
                ( "topicProps"
                , E.object
                    [ ( "pos"
                      , E.object [ ( "x", E.float topicProps.pos.x ), ( "y", E.float topicProps.pos.y ) ]
                      )
                    , ( "size"
                      , E.object [ ( "w", E.float topicProps.size.w ), ( "h", E.float topicProps.size.h ) ]
                      )
                    , ( "display", encodeDisplayName topicProps.displayMode )
                    ]
                )

            MapAssoc _ ->
                ( "assocProps", E.object [] )
        ]


encodeDisplayName : DisplayMode -> E.Value
encodeDisplayName displayMode =
    E.string <|
        case displayMode of
            Monad LabelOnly ->
                "LabelOnly"

            Monad Detail ->
                "Detail"

            Container BlackBox ->
                "BlackBox"

            Container WhiteBox ->
                "WhiteBox"

            Container Unboxed ->
                "Unboxed"



-- ========= DECODE (for localStorage) =========


fullModelDecoder : D.Decoder AM.Model
fullModelDecoder =
    D.succeed AM.Model
        |> required "items" (D.list itemDecoder |> D.andThen tupleToDictDecoder)
        |> required "maps" (D.list mapDecoder |> D.andThen toDictDecoder)
        |> required "mapPath" (D.list D.int)
        |> required "nextId" D.int
        -- transient / components come from Defaults (no import cycles)
        |> hardcoded []
        -- selection
        |> hardcoded editState
        |> hardcoded ""
        -- measureText
        |> hardcoded mouse
        |> hardcoded search
        |> hardcoded iconMenu
        -- add these two to close the constructor:
        |> hardcoded Display.default
        |> hardcoded ""


modelDecoder : D.Decoder AM.Model
modelDecoder =
    -- Try legacy stored blob; otherwise start from an empty in-repo model
    D.oneOf
        [ fullModelDecoder
        , D.succeed
            { items = Dict.empty
            , maps = Dict.empty
            , mapPath = []
            , nextId = 1
            , selection = []
            , editState = editState
            , measureText = ""
            , mouse = mouse
            , search = search
            , iconMenu = iconMenu
            , display = Display.default
            , fedWikiRaw = ""
            }
        ]



-- ===== helpers for decode =====


itemDecoder : D.Decoder ( Id, ItemInfo )
itemDecoder =
    D.oneOf
        [ D.field "topic"
            (D.map2 Tuple.pair
                (D.field "id" D.int)
                (D.map Topic <|
                    D.map3 TopicInfo
                        (D.field "id" D.int)
                        (D.field "text" D.string)
                        (D.field "icon" D.string |> D.andThen maybeString)
                )
            )
        , D.field "assoc"
            (D.map2 Tuple.pair
                (D.field "id" D.int)
                (D.map Assoc <|
                    D.map6 AssocInfo
                        (D.field "id" D.int)
                        (D.field "type" D.string)
                        (D.field "role1" D.string)
                        (D.field "player1" D.int)
                        (D.field "role2" D.string)
                        (D.field "player2" D.int)
                )
            )
        ]


mapDecoder : D.Decoder Map
mapDecoder =
    D.map3 Map
        (D.field "id" D.int)
        (D.field "rect"
            (D.map4 Rectangle
                (D.field "x1" D.float)
                (D.field "y1" D.float)
                (D.field "x2" D.float)
                (D.field "y2" D.float)
            )
        )
        (D.field "items" (D.list mapItemDecoder |> D.andThen toDictDecoder))


mapItemDecoder : D.Decoder MapItem
mapItemDecoder =
    D.map5 MapItem
        (D.field "id" D.int)
        (D.field "parentAssocId" D.int)
        (D.field "hidden" D.bool)
        (D.field "pinned" D.bool)
        (D.oneOf
            [ D.field "topicProps"
                (D.map MapTopic
                    (D.map3 TopicProps
                        (D.field "pos" (D.map2 Point (D.field "x" D.float) (D.field "y" D.float)))
                        (D.field "size" (D.map2 Size (D.field "w" D.float) (D.field "h" D.float)))
                        (D.field "display" D.string |> D.andThen displayModeDecoder)
                    )
                )
            , D.field "assocProps" (D.succeed (MapAssoc AssocProps))
            ]
        )


tupleToDictDecoder : List ( Id, ItemInfo ) -> D.Decoder Items
tupleToDictDecoder tuples =
    tuples
        |> List.map (\( id, info ) -> ( id, Item id info ))
        |> Dict.fromList
        |> D.succeed


toDictDecoder : List { item | id : Id } -> D.Decoder (Dict Int { item | id : Id })
toDictDecoder items =
    items
        |> List.map (\item -> ( item.id, item ))
        |> Dict.fromList
        |> D.succeed


displayModeDecoder : String -> D.Decoder DisplayMode
displayModeDecoder str =
    case str of
        "LabelOnly" ->
            D.succeed (Monad LabelOnly)

        "Detail" ->
            D.succeed (Monad Detail)

        "BlackBox" ->
            D.succeed (Container BlackBox)

        "WhiteBox" ->
            D.succeed (Container WhiteBox)

        "Unboxed" ->
            D.succeed (Container Unboxed)

        _ ->
            D.fail <| "\"" ++ str ++ "\" is an invalid display mode"


maybeString : String -> D.Decoder (Maybe String)
maybeString str =
    D.succeed
        (if str == "" then
            Nothing

         else
            Just str
        )
