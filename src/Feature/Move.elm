module Feature.Move exposing
    ( Config
    , Deps
    , MoveArgs
    , Report
    , moveTopicToMap
    )

{-| A small “Move” library extracted from Main.
It uses dictionary passing (Deps) so it knows nothing about your Model internals.
-}

-- Import your real types here (adjust module names as needed)
-- import Types exposing (Id, MapId, MapPath, Point, Model, MapItem, ItemProps(..), TopicProps, DisplayMode(..), DisplayContainer(..))
-- import Model exposing (Maps) -- if you have a Maps alias
-- TEMP placeholders; delete when you wire real types:


type alias Id =
    Int


type alias MapId =
    Int


type alias MapPath =
    List Int


type alias Point =
    { x : Float, y : Float }


type DisplayContainer
    = WhiteBox
    | BlackBox


type LabelMode
    = LabelOnly
    | LabelAndIcon


type DisplayMode
    = Monad LabelMode
    | Container DisplayContainer


type alias TopicProps =
    { displayMode : DisplayMode
    , pos : Point
    , size : { w : Float, h : Float }
    }


type ItemProps
    = MapTopic TopicProps
    | Other


type alias MapItem =
    { id : Id
    , hidden : Bool
    , props : ItemProps
    }


type alias Model =
    { maps : ()
    }



-- CONFIG (policy knobs)


type alias Config =
    { whiteBoxPadding : Float
    , respectBlackBox : Bool
    , selectAfterMove : Bool
    , autosizeAfterMove : Bool
    }



-- All host-provided functions live here (dictionary passing).


type alias Deps =
    { createMapIfNeeded : Id -> Model -> ( Model, Bool )
    , getTopicProps :
        Id
        -> MapId
        -> Model
        -> Maybe TopicProps -- <- was ... -> /* Maps */ a -> ...
    , addItemToMap : Id -> ItemProps -> Id -> Model -> Model
    , hideItem : Id -> MapId -> Model -> Model
    , setTopicPos : Id -> MapId -> Point -> Model -> Model
    , select : Id -> MapPath -> Model -> Model
    , autoSize : Model -> Model
    , getItem : Id -> Model -> Maybe MapItem
    , updateItem : Id -> (MapItem -> MapItem) -> Model -> Model
    , worldToLocal : Id -> Point -> Model -> Maybe Point
    }



-- Call arguments (mirrors your current function)


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



-- PUBLIC API ---------------------------------------------------------------


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
                        |> deps.addItemToMap args.topicId newItemProps args.targetId
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



-- Convenience wrapper (same signature as your old function; returns only Model)


moveTopicToMap_ : Deps -> Config -> Id -> MapId -> Point -> Id -> MapPath -> Point -> Model -> Model
moveTopicToMap_ deps cfg topicId mapId origPos targetId targetPath worldPos model =
    let
        ( m, _ ) =
            moveTopicToMap
                deps
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



-- HELPERS -----------------------------------------------------------------


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
