module Feature.Move exposing
    ( Config
    , Deps
    , MoveArgs
    , Report
    , moveTopicToMap
    , moveTopicToMap_
    )

import AppModel exposing (Model)
import Model exposing (ContainerDisplay(..), DisplayMode(..), MapProps(..))
import Types
    exposing
        ( ContainerDisplay
        , DisplayMode
        , Id
        , MapId
        , MapItem
        , MapPath
        , MapProps
        , Maps
        , MonadDisplay
        , Point
        , TopicProps
        )



-- POLICY KNOBS


type alias Config =
    { whiteBoxPadding : Float
    , respectBlackBox : Bool
    , selectAfterMove : Bool
    , autosizeAfterMove : Bool
    }



-- HOST DEPS


type alias Deps =
    { createMapIfNeeded : Id -> Model -> ( Model, Bool )
    , getTopicProps : Id -> MapId -> Model -> Maybe TopicProps
    , addItemToMap : Id -> MapProps -> MapId -> Model -> Model
    , hideItem : Id -> MapId -> Model -> Model
    , setTopicPos : Id -> MapId -> Point -> Model -> Model
    , select : Id -> MapPath -> Model -> Model
    , autoSize : Model -> Model
    , getItem : Id -> Model -> Maybe MapItem
    , updateItem : Id -> (MapItem -> MapItem) -> Model -> Model
    , worldToLocal : Id -> Point -> Model -> Maybe Point
    , ownerToMapId :
        Id
        -> Model
        -> MapId -- NEW: map owner topic → MapId
    }



-- CALL ARGS


type alias MoveArgs =
    { topicId : Id
    , srcMapId : MapId
    , srcPos : Point
    , targetId : Id
    , targetMapPath : MapPath
    , dropWorld : Point
    }


type alias Report =
    { createdMap : Bool
    , promotedTarget : Bool
    , finalLocalPos : Point
    }



-- PUBLIC


moveTopicToMap : Deps -> Config -> MoveArgs -> Model -> ( Model, Report )
moveTopicToMap deps cfg args model0 =
    let
        ( model1, created ) =
            deps.createMapIfNeeded args.targetId model0

        beforePromote =
            deps.getItem args.targetId model1

        model2 =
            deps.updateItem args.targetId (promoteToWhiteBoxUnlessBlack cfg.respectBlackBox) model1

        afterPromote =
            deps.getItem args.targetId model2

        promoted =
            case ( beforePromote, afterPromote ) of
                ( Just a, Just b ) ->
                    a /= b

                _ ->
                    False

        localPos =
            deps.worldToLocal args.targetId args.dropWorld model2
                |> Maybe.withDefault (fallbackLocalPos cfg)

        props_ =
            deps.getTopicProps args.topicId args.srcMapId model2
                |> Maybe.map (\tp -> MapTopic { tp | pos = localPos })

        destMapId : MapId
        destMapId =
            deps.ownerToMapId args.targetId model2
    in
    case props_ of
        Nothing ->
            ( model0
            , { createdMap = False, promotedTarget = False, finalLocalPos = localPos }
            )

        Just newItemProps ->
            let
                model3 =
                    model2
                        |> deps.hideItem args.topicId args.srcMapId
                        |> deps.setTopicPos args.topicId args.srcMapId args.srcPos
                        |> deps.addItemToMap args.topicId newItemProps destMapId
                        |> (\m ->
                                if cfg.selectAfterMove then
                                    deps.select args.targetId args.targetMapPath m

                                else
                                    m
                           )
                        |> (\m ->
                                if cfg.autosizeAfterMove then
                                    deps.autoSize m

                                else
                                    m
                           )
            in
            ( model3
            , { createdMap = created
              , promotedTarget = promoted
              , finalLocalPos = localPos
              }
            )



-- Pipeline-friendly wrapper


moveTopicToMap_ :
    Deps
    -> Config
    -> Id
    -> MapId
    -> Point
    -> Id
    -> MapPath
    -> Point
    -> Model
    -> Model
moveTopicToMap_ deps cfg topicId mapId origPos targetId targetPath worldPos model =
    let
        ( m, _ ) =
            moveTopicToMap deps
                cfg
                { topicId = topicId
                , srcMapId = mapId
                , srcPos = origPos
                , targetId = targetId
                , targetMapPath = targetPath
                , dropWorld = worldPos
                }
                model
    in
    m



-- HELPERS


promoteToWhiteBoxUnlessBlack : Bool -> MapItem -> MapItem
promoteToWhiteBoxUnlessBlack respectBlackBox item =
    case item.props of
        MapTopic mt ->
            let
                newMode =
                    case mt.displayMode of
                        Container BlackBox ->
                            if respectBlackBox then
                                Container BlackBox

                            else
                                Container WhiteBox

                        Container _ ->
                            Container WhiteBox

                        Monad _ ->
                            Container WhiteBox
            in
            { item
                | hidden = False
                , props = MapTopic { mt | displayMode = newMode }
            }

        _ ->
            item


fallbackLocalPos : Config -> Point
fallbackLocalPos cfg =
    { x = cfg.whiteBoxPadding + 78
    , y = cfg.whiteBoxPadding + 12
    }
