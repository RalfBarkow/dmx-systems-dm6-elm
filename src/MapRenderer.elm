module MapRenderer exposing (viewMap)

import AppModel exposing (..)
import Compat.ModelAPI exposing (currentMapIdOf, getMapItemById)
import Config exposing (..)
import Dict
import Html exposing (Attribute, Html, div, input, textarea)
import Html.Attributes as Attr
import Html.Events as HE
import IconMenuAPI exposing (viewTopicIcon)
import Json.Decode as D
import Model exposing (..)
import ModelAPI
    exposing
        ( activeMap
        , defaultProps
        , fromPath
        , getMap
        , getMapId
        , getTopicLabel
        , getTopicPos
        , getTopicSize
        , isFullscreen
        , isItemInMap
        , isMapTopic
        , isSelected
        , isVisible
        )
import Mouse exposing (DragMode(..), DragState(..))
import Search exposing (ResultMenu(..))
import String exposing (fromFloat, fromInt, toLower, trim)
import Svg exposing (Svg, circle, g, path, rect, svg)
import Svg.Attributes as SA
import Svg.Events as SE
import SvgExtras exposing (cursorPointer, peAll, peNone, peStroke)
import Utils exposing (..)



-- Class tag used in Mouse messages for topics


topicCls : Class
topicCls =
    "dmx-topic"



-- if this errors because Class = List String, use: [ "topic", "monad" ]
-- CONFIG


lineFunc : Maybe AssocInfo -> Point -> Point -> Svg Msg
lineFunc =
    taxiLine



-- directLine
-- MODEL


type alias MapInfo =
    ( ( List (Html Msg), List (Svg Msg), List (Svg Msg) )
    , Rectangle
    , ( { w : String, h : String }
      , List (Attribute Msg)
      )
    )


type alias TopicRendering =
    ( List (Attribute Msg), List (Html Msg) )



-- VIEW
-- For a fullscreen map mapPath is empty


viewMap : MapId -> MapPath -> Model -> Html Msg
viewMap mapId mapPath model =
    let
        ( ( topicsHtml, assocsSvg, topicsSvg ), mapRect, ( svgSize, mapStyle ) ) =
            mapInfo mapId mapPath model
    in
    div
        mapStyle
        [ div
            (topicLayerStyle mapRect)
            (topicsHtml
                ++ limboTopic mapId model
            )
        , svg
            ([ SA.width svgSize.w, SA.height svgSize.h ] ++ svgStyle)
            [ g (gAttr mapId mapRect model)
                -- A) background rect: does NOT capture events (peNone)
                ([ rect
                    [ SA.x (String.fromFloat mapRect.x1)
                    , SA.y (String.fromFloat mapRect.y1)
                    , SA.width (String.fromFloat (mapRect.x2 - mapRect.x1))
                    , SA.height (String.fromFloat (mapRect.y2 - mapRect.y1))
                    , SA.fill "transparent"
                    , peNone
                    ]
                    []
                 ]
                    -- B) children group: DOES capture events (peAll)
                    ++ [ g [ peAll ] (assocsSvg ++ topicsSvg ++ viewLimboAssoc mapId model) ]
                    -- C) border: only the stroke is interactive (peStroke). Optional.
                    ++ [ rect
                            [ SA.x (String.fromFloat mapRect.x1)
                            , SA.y (String.fromFloat mapRect.y1)
                            , SA.width (String.fromFloat (mapRect.x2 - mapRect.x1))
                            , SA.height (String.fromFloat (mapRect.y2 - mapRect.y1))
                            , SA.fill "none"
                            , SA.stroke "#ddd"
                            , SA.strokeWidth "1"
                            , peStroke
                            ]
                            []
                       ]
                )
            ]
        ]


gAttr : MapId -> Rectangle -> Model -> List (Attribute Msg)
gAttr _ mapRect _ =
    [ SA.transform <|
        "translate("
            ++ fromFloat -mapRect.x1
            ++ " "
            ++ fromFloat -mapRect.y1
            ++ ")"
    ]


mapInfo : MapId -> MapPath -> Model -> MapInfo
mapInfo mapId mapPath model =
    let
        parentMapId =
            getMapId mapPath
    in
    case getMap mapId model.maps of
        Just map ->
            ( mapItems map mapPath model
            , map.rect
            , if isFullscreen mapId model then
                ( { w = "100%", h = "100%" }, [] )

              else
                ( { w = (map.rect.x2 - map.rect.x1) |> round |> fromInt
                  , h = (map.rect.y2 - map.rect.y1) |> round |> fromInt
                  }
                , whiteBoxStyle mapId map.rect parentMapId model
                )
            )

        Nothing ->
            ( ( [], [], [] ), Rectangle 0 0 0 0, ( { w = "0", h = "0" }, [] ) )


mapItems : Map -> MapPath -> Model -> ( List (Html Msg), List (Svg Msg), List (Svg Msg) )
mapItems map mapPath model =
    let
        newPath =
            map.id :: mapPath
    in
    map.items
        |> Dict.values
        |> List.filter isVisible
        |> List.foldr
            (\{ id, props } ( htmlTopics, assocs, topicsSvg ) ->
                case model.items |> Dict.get id of
                    Just { info } ->
                        case ( info, props ) of
                            ( Topic topic, MapTopic tProps ) ->
                                case effectiveDisplayMode topic.id tProps.displayMode model of
                                    Monad LabelOnly ->
                                        ( htmlTopics
                                        , assocs
                                        , viewTopicSvg topic tProps newPath model :: topicsSvg
                                        )

                                    Monad Detail ->
                                        ( viewTopic topic tProps newPath model :: htmlTopics
                                        , assocs
                                        , topicsSvg
                                        )

                                    _ ->
                                        ( viewTopic topic tProps newPath model :: htmlTopics
                                        , assocs
                                        , topicsSvg
                                        )

                            _ ->
                                logError "mapItems" ("problem with item " ++ fromInt id) ( htmlTopics, assocs, topicsSvg )

                    _ ->
                        logError "mapItems" ("problem with item " ++ fromInt id) ( htmlTopics, assocs, topicsSvg )
            )
            ( [], [], [] )


limboTopic : MapId -> Model -> List (Html Msg)
limboTopic mapId model =
    let
        activeMapId =
            activeMap model
    in
    if mapId == activeMapId then
        case model.search.menu of
            Open (Just topicId) ->
                if isItemInMap topicId activeMapId model then
                    case getMapItemById topicId activeMapId model.maps of
                        Just mapItem ->
                            if mapItem.hidden then
                                case model.items |> Dict.get topicId of
                                    Just { info } ->
                                        case ( info, mapItem.props ) of
                                            ( Topic topic, MapTopic props ) ->
                                                case effectiveDisplayMode topic.id props.displayMode model of
                                                    Monad LabelOnly ->
                                                        []

                                                    -- circle handled in SVG layer
                                                    Monad Detail ->
                                                        [ viewTopic topic props [] model ]

                                                    -- keep rich HTML detail
                                                    _ ->
                                                        [ viewTopic topic props [] model ]

                                            _ ->
                                                []

                                    _ ->
                                        []

                            else
                                -- already visible → nothing in limbo
                                []

                        Nothing ->
                            []

                else
                    -- not yet in map: render a preview for containers only
                    let
                        props =
                            defaultProps topicId topicSize model
                    in
                    case model.items |> Dict.get topicId of
                        Just { info } ->
                            case info of
                                Topic topic ->
                                    case effectiveDisplayMode topic.id props.displayMode model of
                                        Monad LabelOnly ->
                                            []

                                        -- circle handled in SVG layer
                                        Monad Detail ->
                                            [ viewTopic topic props [] model ]

                                        -- keep rich HTML detail
                                        _ ->
                                            [ viewTopic topic props [] model ]

                                _ ->
                                    []

                        _ ->
                            []

            _ ->
                []

    else
        []


viewTopicSvg : TopicInfo -> TopicProps -> MapPath -> Model -> Svg Msg
viewTopicSvg topic props mapPath model =
    let
        mapId =
            getMapId mapPath

        mark =
            monadMark topic.text

        rVal : Float
        rVal =
            (topicSize.h / 2) - topicBorderWidth

        rStr =
            fromFloat rVal

        cxStr =
            fromFloat props.pos.x

        cyStr =
            fromFloat props.pos.y

        dash =
            if isTargeted topic.id mapId model then
                "4 2"

            else
                "0"

        selected =
            isSelected topic.id mapId model

        shadowNodes : List (Svg Msg)
        shadowNodes =
            if selected then
                [ circle
                    [ SA.cx cxStr
                    , SA.cy cyStr
                    , SA.r rStr
                    , SA.fill "black"
                    , SA.fillOpacity "0.20"
                    , SA.transform "translate(5,5)"
                    ]
                    []
                ]

            else
                []

        mainNodes : List (Svg Msg)
        mainNodes =
            [ -- transparent hitbox: the event target
              rect
                ([ SA.x (fromFloat (props.pos.x - rVal))
                 , SA.y (fromFloat (props.pos.y - rVal))
                 , SA.width (fromFloat (rVal * 2))
                 , SA.height (fromFloat (rVal * 2))
                 , SA.fill "transparent"
                 , SA.pointerEvents "all"
                 , cursorPointer
                 ]
                    ++ svgTopicHandlers topic.id mapPath
                )
                []
            , circle
                [ SA.cx cxStr
                , SA.cy cyStr
                , SA.r rStr
                , SA.fill "white"
                , SA.stroke "black"
                , SA.strokeWidth (fromFloat topicBorderWidth ++ "px")
                , SA.strokeDasharray dash
                , SA.pointerEvents "none" -- <- let the hitbox handle it
                ]
                []
            , Svg.text_
                [ SA.x cxStr
                , SA.y cyStr
                , SA.textAnchor "middle"
                , SA.dominantBaseline "central"
                , SA.fontFamily mainFont
                , SA.fontSize (fromInt contentFontSize ++ "px")
                , SA.fontWeight topicLabelWeight
                , SA.fill "black"
                , SA.pointerEvents "none" -- <- text should not steal events
                ]
                [ Svg.text mark ]
            , Svg.title [] [ Svg.text (getTopicLabel topic) ]
            ]
    in
    g
        (svgTopicAttr topic.id mapPath
            ++ [ SA.transform "translate(0,0)" ]
        )
        mainNodes


isTargeted : Id -> MapId -> Model -> Bool
isTargeted topicId mapId model =
    case model.mouse.dragState of
        Drag DragTopic _ (mapId_ :: _) _ _ target ->
            isTarget topicId mapId target && mapId_ /= topicId

        Drag DrawAssoc _ (mapId_ :: _) _ _ target ->
            isTarget topicId mapId target && mapId_ == mapId

        _ ->
            False



-- VIEW TOPIC


viewTopic : TopicInfo -> TopicProps -> MapPath -> Model -> Html Msg
viewTopic topic props mapPath model =
    let
        -- decide final mode (single source of truth)
        mode1 : DisplayMode
        mode1 =
            effectiveDisplayMode topic.id props.displayMode model

        -- choose renderer + a name we surface for quick DOM inspection
        ( topicFunc, rendererName ) =
            case mode1 of
                Container WhiteBox ->
                    ( whiteBoxTopic, "whiteBoxTopic" )

                Container BlackBox ->
                    ( blackBoxTopic, "blackBoxTopic" )

                Container Unboxed ->
                    ( unboxedTopic, "unboxedTopic" )

                Monad Detail ->
                    ( detailTopic, "detailTopic" )

                _ ->
                    ( labelTopic, "labelTopic" )

        -- renderer-provided attrs/children
        ( attrsFromRenderer, childrenFromRenderer ) =
            topicFunc topic props mapPath model

        -- IMPORTANT attribute order:
        --   1) htmlTopicAttr (ids, event handlers, drag)
        --   2) base pos/size + mode visuals
        --   3) renderer extras (e.g. scream/outline)
        --   4) diagnostics
        finalAttrs =
            htmlTopicAttr topic.id mapPath
                ++ topicStyleWithMode topic.id mode1 model
                ++ attrsFromRenderer
                ++ [ Attr.attribute "data-mode0" (displayModeToString props.displayMode)
                   , Attr.attribute "data-mode1" (displayModeToString mode1)
                   , Attr.attribute "data-renderer" rendererName
                   , boolAttr "data-isFedWikiPage" (isFedWikiPage topic.id model)
                   ]
    in
    Html.div finalAttrs childrenFromRenderer


{-| Extract the page title from Model.fedWikiRaw.
-}
fedWikiTitle : Model -> Maybe String
fedWikiTitle model =
    if String.isEmpty model.fedWikiRaw then
        Nothing

    else
        case D.decodeString (D.field "title" D.string) model.fedWikiRaw of
            Ok t ->
                let
                    s =
                        trim t
                in
                if String.isEmpty s then
                    Nothing

                else
                    Just s

            Err _ ->
                Nothing


{-| Get TopicInfo (if this Id refers to a Topic).
-}
topicInfoOf : Id -> Model -> Maybe TopicInfo
topicInfoOf topicId model =
    case Dict.get topicId model.items of
        Just { info } ->
            case info of
                Topic ti ->
                    Just ti

                _ ->
                    Nothing

        _ ->
            Nothing



-- Safe child-map existence check (no error logs)


hasChildMap : Id -> Model -> Bool
hasChildMap topicId model =
    Dict.member topicId model.maps


{-| A topic is considered the FedWiki page container iff:

it has a containerId

-}
isFedWikiPage : Id -> Model -> Bool
isFedWikiPage topicId model =
    case model.fedWiki.containerId of
        Just containerId ->
            containerId == topicId

        Nothing ->
            False



-- Effective mode decision (force FedWiki to WhiteBox; limbo tweaks)


effectiveDisplayMode : Id -> DisplayMode -> Model -> DisplayMode
effectiveDisplayMode topicId incoming model =
    let
        isLimbo =
            model.search.menu == Open (Just topicId)

        isFedWiki =
            isFedWikiPage topicId model

        decided : DisplayMode
        decided =
            if isFedWiki then
                Container WhiteBox

            else if isLimbo then
                case incoming of
                    Monad _ ->
                        Monad Detail

                    Container _ ->
                        Container WhiteBox

            else
                incoming

        _ =
            info "effectiveDisplayMode"
                ( topicId
                , { isFedWiki = isFedWiki
                  , isLimbo = isLimbo
                  , incoming = displayModeToString incoming
                  , result = displayModeToString decided
                  }
                )
    in
    decided



-- Tiny helpers for diagnostics + style composition


displayModeToString : DisplayMode -> String
displayModeToString mode =
    case mode of
        Monad Detail ->
            "Monad(Detail)"

        Monad LabelOnly ->
            "Monad(LabelOnly)"

        Container BlackBox ->
            "Container(BlackBox)"

        Container WhiteBox ->
            "Container(WhiteBox)"

        Container Unboxed ->
            "Container(Unboxed)"



-- Helper: turn a Bool into a data-* attribute value


boolAttr : String -> Bool -> Html.Attribute msg
boolAttr name value =
    Attr.attribute name
        (if value then
            "true"

         else
            "false"
        )



-- base (pos/size/etc.) + visuals that depend on mode


baseTopicStyles : Id -> Model -> List (Html.Attribute Msg)
baseTopicStyles tid model =
    topicStyle tid model


displayModeStyles : DisplayMode -> List (Html.Attribute Msg)
displayModeStyles mode =
    case mode of
        Container WhiteBox ->
            [ Attr.style "background" "white !important"
            , Attr.style "border" "1px solid #ddd !important"
            , Attr.style "border-radius" "6px"
            ]

        Container BlackBox ->
            [ Attr.style "background" "#222 !important"
            , Attr.style "color" "#fff !important"
            ]

        _ ->
            []


topicStyleWithMode : Id -> DisplayMode -> Model -> List (Html.Attribute Msg)
topicStyleWithMode tid mode model =
    baseTopicStyles tid model ++ displayModeStyles mode


whiteBoxStyle : Id -> Rectangle -> MapId -> Model -> List (Attribute Msg)
whiteBoxStyle topicId rect mapId model =
    let
        width =
            rect.x2 - rect.x1

        height =
            rect.y2 - rect.y1

        r =
            fromInt whiteBoxRadius ++ "px"
    in
    [ Attr.style "position" "absolute"
    , Attr.style "left" <| fromFloat -topicBorderWidth ++ "px"
    , Attr.style "top" <| fromFloat (topicSize.h - 2 * topicBorderWidth) ++ "px"
    , Attr.style "width" <| fromFloat width ++ "px"
    , Attr.style "height" <| fromFloat height ++ "px"
    , Attr.style "border-radius" <| "0 " ++ r ++ " " ++ r ++ " " ++ r
    , Attr.style "overflow" "hidden"
    , Attr.style "pointer-events" "none" -- pass clicks through to SVG
    ]
        ++ topicBorderStyle topicId mapId model
        ++ selectionStyle topicId mapId model


labelTopic : TopicInfo -> TopicProps -> MapPath -> Model -> TopicRendering
labelTopic topic props mapPath model =
    let
        mapId =
            getMapId mapPath
    in
    ( topicPosStyle props
        ++ topicFlexboxStyle topic props mapId model
        ++ selectionStyle topic.id mapId model
    , labelTopicHtml topic props mapId model
    )


labelTopicHtml : TopicInfo -> TopicProps -> MapId -> Model -> List (Html Msg)
labelTopicHtml topic props mapId model =
    let
        isEdit =
            model.editState == ItemEdit topic.id mapId

        textElem =
            if isEdit then
                input
                    ([ Attr.id <| "dmx-input-" ++ fromInt topic.id ++ "-" ++ fromInt mapId
                     , Attr.value topic.text
                     , Attr.style "pointer-events" "auto"
                     , HE.onInput (Edit << OnTextInput)
                     , HE.onBlur (Edit EditEnd)
                     , onEnterOrEsc (Edit EditEnd)
                     , stopPropagationOnMousedown NoOp
                     ]
                        ++ topicInputStyle
                    )
                    []

            else
                div
                    topicLabelStyle
                    [ Html.text <| getTopicLabel topic ]
    in
    [ div
        (topicIconBoxStyle props)
        [ viewTopicIcon topic.id model ]
    , textElem
    ]


detailTopic : TopicInfo -> TopicProps -> MapPath -> Model -> TopicRendering
detailTopic topic props mapPath model =
    let
        mapId =
            getMapId mapPath

        isEdit =
            model.editState == ItemEdit topic.id mapId

        textElem =
            if isEdit then
                textarea
                    ([ Attr.id <| "dmx-input-" ++ fromInt topic.id ++ "-" ++ fromInt mapId
                     , Attr.style "pointer-events" "auto"
                     , HE.onInput (Edit << OnTextareaInput)
                     , HE.onBlur (Edit EditEnd)
                     , onEsc (Edit EditEnd)
                     , stopPropagationOnMousedown NoOp
                     ]
                        ++ detailTextStyle topic.id mapId model
                        ++ detailTextEditStyle topic.id mapId model
                    )
                    [ Html.text topic.text ]

            else
                div
                    (detailTextStyle topic.id mapId model
                        ++ detailTextViewStyle
                    )
                    (multilineHtml topic.text)
    in
    ( detailTopicStyle props
    , [ div
            (topicIconBoxStyle props
                ++ detailTopicIconBoxStyle
                ++ selectionStyle topic.id mapId model
            )
            [ viewTopicIcon topic.id model ]
      , textElem
      ]
    )


detailTopicStyle : TopicProps -> List (Attribute Msg)
detailTopicStyle { pos } =
    [ Attr.style "display" "flex"
    , Attr.style "left" <| fromFloat (pos.x - topicW2) ++ "px"
    , Attr.style "top" <| fromFloat (pos.y - topicH2) ++ "px"
    ]


detailTextStyle : Id -> MapId -> Model -> List (Attribute Msg)
detailTextStyle topicId mapId model =
    let
        r =
            fromInt topicRadius ++ "px"
    in
    [ Attr.style "font-size" <| fromInt contentFontSize ++ "px"
    , Attr.style "width" <| fromFloat topicDetailMaxWidth ++ "px"
    , Attr.style "line-height" <| fromFloat topicLineHeight
    , Attr.style "padding" <| fromInt topicDetailPadding ++ "px"
    , Attr.style "border-radius" <| "0 " ++ r ++ " " ++ r ++ " " ++ r
    ]
        ++ topicBorderStyle topicId mapId model
        ++ selectionStyle topicId mapId model


detailTextViewStyle : List (Attribute Msg)
detailTextViewStyle =
    [ Attr.style "min-width" <| fromFloat (topicSize.w - topicSize.h) ++ "px"
    , Attr.style "max-width" "max-content"
    , Attr.style "white-space" "pre-wrap"
    , Attr.style "pointer-events" "none"
    ]


detailTextEditStyle : Id -> MapId -> Model -> List (Attribute Msg)
detailTextEditStyle topicId mapId model =
    let
        height =
            case getTopicSize topicId mapId model.maps of
                Just size ->
                    size.h

                Nothing ->
                    0
    in
    [ Attr.style "position" "relative"
    , Attr.style "top" <| fromFloat -topicBorderWidth ++ "px"
    , Attr.style "height" <| fromFloat height ++ "px"
    , Attr.style "font-family" mainFont -- <textarea> default is "monospace"
    , Attr.style "border-color" "black" -- <textarea> default is some lightgray
    , Attr.style "resize" "none"
    ]


blackBoxTopic : TopicInfo -> TopicProps -> MapPath -> Model -> TopicRendering
blackBoxTopic topic props mapPath model =
    let
        mapId =
            getMapId mapPath
    in
    ( topicPosStyle props
    , [ div
            (topicFlexboxStyle topic props mapId model
                ++ blackBoxStyle
            )
            (labelTopicHtml topic props mapId model
                ++ mapItemCount topic.id props model
            )
      , div
            (ghostTopicStyle topic mapId model)
            []
      ]
    )



-- RENDERERS (only WhiteBox shown; keep your other renderers unchanged)


whiteBoxTopic : TopicInfo -> TopicProps -> MapPath -> Model -> TopicRendering
whiteBoxTopic topic props mapPath model =
    let
        _ =
            info "whiteBoxTopic.called" { topicId = topic.id }

        ( styleLabel, childrenLabel ) =
            labelTopic topic props mapPath model

        whiteChrome =
            [ Attr.style "background" "white !important"
            , Attr.style "border" "1px solid #ddd !important"
            , Attr.style "border-radius" "6px"
            ]

        scream =
            [ Attr.style "outline" "4px solid magenta !important"
            , Attr.style "box-shadow" "0 0 0 3px rgba(255,0,255,0.35) inset !important"
            , Attr.attribute "data-renderer" "whiteBoxTopic"
            ]
    in
    ( styleLabel ++ whiteChrome ++ scream
    , childrenLabel
        ++ mapItemCount topic.id props model
        ++ [ viewMap topic.id mapPath model ]
    )


unboxedTopic : TopicInfo -> TopicProps -> MapPath -> Model -> TopicRendering
unboxedTopic topic props mapPath model =
    let
        ( style, children ) =
            labelTopic topic props mapPath model
    in
    ( style
    , children
        ++ mapItemCount topic.id props model
    )


mapItemCount : Id -> TopicProps -> Model -> List (Html Msg)
mapItemCount topicId props model =
    let
        itemCount =
            case effectiveDisplayMode topicId props.displayMode model of
                Monad _ ->
                    0

                Container _ ->
                    childCount topicId model
    in
    [ div
        itemCountStyle
        [ Html.text <| fromInt itemCount ]
    ]



-- Count only topics in the child map (map id == topic id)


childMapTopicCount : Id -> Model -> Int
childMapTopicCount topicId model =
    case Dict.get topicId model.maps of
        Just m ->
            m.items
                |> Dict.values
                |> List.filter isMapTopic
                |> List.filter isVisible
                |> List.length

        Nothing ->
            0



-- Unified child count (FedWiki-aware)


childCount : Id -> Model -> Int
childCount topicId model =
    if isFedWikiPage topicId model then
        List.length model.fedWiki.storyItemIds

    else
        childMapTopicCount topicId model



-- HTML topics


htmlTopicAttr : Id -> MapPath -> List (Attribute Msg)
htmlTopicAttr id mapPath =
    [ Attr.class "dmx-topic topic monad"
    , Attr.attribute "data-id" (fromInt id)
    , Attr.attribute "data-path" (fromPath mapPath)
    , Attr.style "cursor" "move"
    , HE.on "mousedown" (D.map (Mouse << Mouse.DownOnItem topicCls id mapPath) posDecoder)
    , HE.on "pointerdown" (D.map (Mouse << Mouse.DownOnItem topicCls id mapPath) posDecoder)
    ]



-- SVG monads


svgTopicAttr : Id -> MapPath -> List (Svg.Attribute Msg)
svgTopicAttr id mapPath =
    [ SA.class "dmx-topic topic monad"
    , SA.style "cursor: move"

    -- start drag from SVG (bypass global decoder)
    , SE.on "mousedown" (D.map (Mouse << Mouse.DownOnItem topicCls id mapPath) posDecoder)
    , SE.on "pointerdown" (D.map (Mouse << Mouse.DownOnItem topicCls id mapPath) posDecoder)

    -- keep model updated while dragging, independent from subs timing
    , SE.on "mousemove" (D.map (Mouse << Mouse.Move) posDecoder)
    , SE.on "pointermove" (D.map (Mouse << Mouse.Move) posDecoder)

    -- finish locally (global onMouseUp also handles it; having both is harmless)
    , SE.on "mouseup" (D.succeed (Mouse Mouse.Up))
    , SE.on "pointerup" (D.succeed (Mouse Mouse.Up))

    -- helpful for target highlighting during drag
    , SE.on "mouseenter" (D.succeed (Mouse (Mouse.Over topicCls id mapPath)))
    , SE.on "mouseleave" (D.succeed (Mouse (Mouse.Out topicCls id mapPath)))
    ]



-- TODO


assocGeometry : AssocInfo -> MapId -> Model -> Maybe ( Point, Point )
assocGeometry assoc mapId model =
    let
        pos1 =
            getTopicPos assoc.player1 mapId model.maps

        pos2 =
            getTopicPos assoc.player2 mapId model.maps
    in
    case Maybe.map2 (\p1 p2 -> ( p1, p2 )) pos1 pos2 of
        Just geometry ->
            Just geometry

        Nothing ->
            fail "assocGeometry" { assoc = assoc, mapId = mapId } Nothing


viewLimboAssoc : MapId -> Model -> List (Svg Msg)
viewLimboAssoc mapId model =
    case model.mouse.dragState of
        Drag DrawAssoc _ mapPath origPos pos _ ->
            if getMapId mapPath == mapId then
                [ lineFunc Nothing origPos (relPos pos mapPath model) ]

            else
                []

        _ ->
            []


{-| Transforms an absolute screen position to a map-relative position.
-}
relPos : Point -> MapPath -> Model -> Point
relPos pos mapPath model =
    let
        posAbs =
            absMapPos mapPath (Point 0 0) model
    in
    Point
        (pos.x - posAbs.x)
        (pos.y - posAbs.y)


{-| Recursively calculates the absolute position of a map.
"posAcc" is the position accumulated so far.
-}
absMapPos : MapPath -> Point -> Model -> Point
absMapPos mapPath posAcc model =
    case mapPath of
        [ mapId ] ->
            accumulateMapRect posAcc mapId model

        mapId :: parentMapId :: mapIds ->
            accumulateMapPos posAcc mapId parentMapId mapIds model

        [] ->
            logError "absMapPos" "mapPath is empty!" (Point 0 0)


accumulateMapPos : Point -> MapId -> MapId -> MapPath -> Model -> Point
accumulateMapPos posAcc mapId parentMapId mapIds model =
    let
        { x, y } =
            accumulateMapRect posAcc mapId model
    in
    case getTopicPos mapId parentMapId model.maps of
        Just mapPos ->
            absMapPos
                -- recursion
                (parentMapId :: mapIds)
                (Point
                    (x + mapPos.x - topicW2)
                    (y + mapPos.y + topicH2)
                )
                model

        Nothing ->
            Point 0 0



-- error is already logged


accumulateMapRect : Point -> MapId -> Model -> Point
accumulateMapRect posAcc mapId model =
    case getMap mapId model.maps of
        Just map ->
            Point
                (posAcc.x - map.rect.x1)
                (posAcc.y - map.rect.y1)

        Nothing ->
            Point 0 0



-- error is already logged
-- STYLE


topicStyle : Id -> Model -> List (Attribute Msg)
topicStyle id model =
    let
        isLimbo =
            model.search.menu == Open (Just id)

        isDragging =
            case model.mouse.dragState of
                Drag DragTopic id_ _ _ _ _ ->
                    id_ == id

                _ ->
                    False
    in
    [ Attr.style "position" "absolute"
    , Attr.style "opacity" <|
        if isLimbo then
            ".5"

        else
            "1"
    , Attr.style "z-index" <|
        if isDragging then
            "1"

        else
            "2"
    ]


selectionStyle : Id -> MapId -> Model -> List (Attribute Msg)
selectionStyle topicId mapId model =
    if isSelected topicId mapId model then
        [ Attr.style "box-shadow" "gray 5px 5px 5px" ]

    else
        []


topicFlexboxStyle : TopicInfo -> TopicProps -> MapId -> Model -> List (Attribute Msg)
topicFlexboxStyle topic props mapId model =
    let
        r12 =
            fromInt topicRadius ++ "px"

        r34 =
            case props.displayMode of
                Container WhiteBox ->
                    "0"

                _ ->
                    r12
    in
    [ Attr.style "display" "flex"
    , Attr.style "align-items" "center"
    , Attr.style "gap" "8px"
    , Attr.style "width" <| fromFloat topicSize.w ++ "px"
    , Attr.style "height" <| fromFloat topicSize.h ++ "px"
    , Attr.style "border-radius" <| r12 ++ " " ++ r12 ++ " " ++ r34 ++ " " ++ r34
    ]
        ++ topicBorderStyle topic.id mapId model


topicPosStyle : TopicProps -> List (Attribute Msg)
topicPosStyle { pos } =
    [ Attr.style "left" <| fromFloat (pos.x - topicW2) ++ "px"
    , Attr.style "top" <| fromFloat (pos.y - topicH2) ++ "px"
    ]


topicIconBoxStyle : TopicProps -> List (Attribute Msg)
topicIconBoxStyle props =
    let
        r1 =
            fromInt topicRadius ++ "px"

        r4 =
            case props.displayMode of
                Container WhiteBox ->
                    "0"

                _ ->
                    r1
    in
    [ Attr.style "flex" "none"
    , Attr.style "width" <| fromFloat topicSize.h ++ "px"
    , Attr.style "height" <| fromFloat topicSize.h ++ "px"
    , Attr.style "border-radius" <| r1 ++ " 0 0 " ++ r4
    , Attr.style "background-color" "black"
    , Attr.style "pointer-events" "none"
    ]


detailTopicIconBoxStyle : List (Attribute Msg)
detailTopicIconBoxStyle =
    -- icon box correction as detail topic has no border, in contrast to label topic
    [ Attr.style "padding-left" <| fromFloat topicBorderWidth ++ "px"
    , Attr.style "width" <| fromFloat (topicSize.h - topicBorderWidth) ++ "px"
    ]


topicLabelStyle : List (Attribute Msg)
topicLabelStyle =
    [ Attr.style "font-size" <| fromInt contentFontSize ++ "px"
    , Attr.style "font-weight" topicLabelWeight
    , Attr.style "overflow" "hidden"
    , Attr.style "text-overflow" "ellipsis"
    , Attr.style "white-space" "nowrap"
    , Attr.style "pointer-events" "none"
    ]


topicInputStyle : List (Attribute Msg)
topicInputStyle =
    [ Attr.style "font-family" mainFont -- Default for <input> is "-apple-system" (on Mac)
    , Attr.style "font-size" <| fromInt contentFontSize ++ "px"
    , Attr.style "font-weight" topicLabelWeight
    , Attr.style "width" "100%"
    , Attr.style "position" "relative"
    , Attr.style "left" "-4px"
    , Attr.style "pointer-events" "initial"
    ]


blackBoxStyle : List (Attribute Msg)
blackBoxStyle =
    [ Attr.style "pointer-events" "none" ]


ghostTopicStyle : TopicInfo -> MapId -> Model -> List (Attribute Msg)
ghostTopicStyle topic mapId model =
    [ Attr.style "position" "absolute"
    , Attr.style "left" <| fromInt blackBoxOffset ++ "px"
    , Attr.style "top" <| fromInt blackBoxOffset ++ "px"
    , Attr.style "width" <| fromFloat topicSize.w ++ "px"
    , Attr.style "height" <| fromFloat topicSize.h ++ "px"
    , Attr.style "border-radius" <| fromInt topicRadius ++ "px"
    , Attr.style "pointer-events" "none"
    , Attr.style "z-index" "-1" -- behind topic
    ]
        ++ topicBorderStyle topic.id mapId model
        ++ selectionStyle topic.id mapId model


itemCountStyle : List (Attribute Msg)
itemCountStyle =
    [ Attr.style "font-size" <| fromInt contentFontSize ++ "px"
    , Attr.style "position" "absolute"
    , Attr.style "left" "calc(100% + 12px)"
    ]


topicBorderStyle : Id -> MapId -> Model -> List (Attribute Msg)
topicBorderStyle id mapId model =
    let
        targeted =
            case model.mouse.dragState of
                -- can't move a topic to a map where it is already
                -- can't create assoc when both topics are in different map
                Drag DragTopic _ (mapId_ :: _) _ _ target ->
                    isTarget id mapId target && mapId_ /= id

                Drag DrawAssoc _ (mapId_ :: _) _ _ target ->
                    isTarget id mapId target && mapId_ == mapId

                _ ->
                    False
    in
    [ Attr.style "border-width" <| fromFloat topicBorderWidth ++ "px"
    , Attr.style "border-style" <|
        if targeted then
            "dashed"

        else
            "solid"
    , Attr.style "box-sizing" "border-box"
    , Attr.style "background-color" "white"
    ]


isTarget : Id -> MapId -> Maybe ( Id, MapPath ) -> Bool
isTarget topicId mapId target =
    case target of
        Just ( targetId, targetMapPath ) ->
            case targetMapPath of
                targetMapId :: _ ->
                    topicId == targetId && mapId == targetMapId

                [] ->
                    False

        Nothing ->
            False


topicLayerStyle : Rectangle -> List (Attribute Msg)
topicLayerStyle mapRect =
    [ Attr.style "position" "absolute"
    , Attr.style "left" <| fromFloat -mapRect.x1 ++ "px"
    , Attr.style "top" <| fromFloat -mapRect.y1 ++ "px"
    ]


svgStyle : List (Attribute Msg)
svgStyle =
    [ Attr.style "position" "absolute" -- occupy entire window height (instead 150px default height)
    , Attr.style "top" "0"
    , Attr.style "left" "0"
    ]



-- One possible line func
-- One possible line func


taxiLine : Maybe AssocInfo -> Point -> Point -> Svg Msg
taxiLine assoc pos1 pos2 =
    if abs (pos2.x - pos1.x) < 2 * assocRadius then
        -- straight vertical
        let
            xm =
                (pos1.x + pos2.x) / 2
        in
        Svg.path
            (SA.d ("M " ++ fromFloat xm ++ " " ++ fromFloat pos1.y ++ " V " ++ fromFloat pos2.y)
                :: lineStyle assoc
            )
            []

    else if abs (pos2.y - pos1.y) < 2 * assocRadius then
        -- straight horizontal
        let
            ym =
                (pos1.y + pos2.y) / 2
        in
        Svg.path
            (SA.d ("M " ++ fromFloat pos1.x ++ " " ++ fromFloat ym ++ " H " ++ fromFloat pos2.x)
                :: lineStyle assoc
            )
            []

    else
        -- 5 segment taxi line
        let
            sx =
                if pos2.x > pos1.x then
                    1

                else
                    -1

            -- sign x
            sy =
                if pos2.y > pos1.y then
                    -1

                else
                    1

            -- sign y
            ym =
                (pos1.y + pos2.y) / 2

            -- y mean
            x1 =
                fromFloat (pos1.x + sx * assocRadius)

            x2 =
                fromFloat (pos2.x - sx * assocRadius)

            y1 =
                fromFloat (ym + sy * assocRadius)

            y2 =
                fromFloat (ym - sy * assocRadius)

            sweep1 =
                if sy == 1 then
                    if sx == 1 then
                        1

                    else
                        0

                else if sx == 1 then
                    0

                else
                    1

            sweep2 =
                1 - sweep1

            sw1 =
                fromInt sweep1

            sw2 =
                fromInt sweep2

            r =
                fromFloat assocRadius
        in
        Svg.path
            (SA.d
                ("M "
                    ++ fromFloat pos1.x
                    ++ " "
                    ++ fromFloat pos1.y
                    ++ " V "
                    ++ y1
                    ++ " A "
                    ++ r
                    ++ " "
                    ++ r
                    ++ " 0 0 "
                    ++ sw1
                    ++ " "
                    ++ x1
                    ++ " "
                    ++ fromFloat ym
                    ++ " H "
                    ++ x2
                    ++ " A "
                    ++ r
                    ++ " "
                    ++ r
                    ++ " 0 0 "
                    ++ sw2
                    ++ " "
                    ++ fromFloat pos2.x
                    ++ " "
                    ++ y2
                    ++ " V "
                    ++ fromFloat pos2.y
                )
                :: lineStyle assoc
            )
            []


lineStyle : Maybe AssocInfo -> List (Attribute Msg)
lineStyle assoc =
    [ SA.stroke assocColor
    , SA.strokeWidth <| fromFloat assocWidth ++ "px"
    , SA.strokeDasharray <| lineDasharray assoc
    , SA.fill "none"
    ]


lineDasharray : Maybe AssocInfo -> String
lineDasharray maybeAssoc =
    case maybeAssoc of
        Just { itemType } ->
            case itemType of
                "dmx.association" ->
                    "5 0"

                -- solid
                "dmx.composition" ->
                    "5"

                -- dotted
                _ ->
                    "1"

        -- error
        Nothing ->
            "5 0"


{-| Pick a short “mark” for the monad interior.
Strategy:

  - prefer the first non-space “word” up to 3 chars
  - else first 2 visible chars
  - else "•"

-}
monadMark : String -> String
monadMark title =
    let
        trimmed =
            String.trim title

        word =
            trimmed
                |> String.words
                |> List.head
                |> Maybe.withDefault trimmed

        take n s =
            String.left n s
    in
    if String.isEmpty trimmed then
        "•"

    else if String.length word >= 1 then
        word |> take (Basics.min 3 (String.length word))

    else
        take (Basics.min 2 (String.length trimmed)) trimmed


posDecoder : D.Decoder Point
posDecoder =
    D.map2 Point
        (D.field "clientX" D.float)
        (D.field "clientY" D.float)


svgTopicHandlers : Id -> MapPath -> List (Svg.Attribute Msg)
svgTopicHandlers id mapPath =
    [ SE.on "pointerdown" (D.map (Mouse << Mouse.DownOnItem topicCls id mapPath) posDecoder)
    , SE.on "mousedown" (D.map (Mouse << Mouse.DownOnItem topicCls id mapPath) posDecoder)
    , SE.on "pointermove" (D.map (Mouse << Mouse.Move) posDecoder)
    , SE.on "mousemove" (D.map (Mouse << Mouse.Move) posDecoder)
    , SE.on "pointerup" (D.succeed (Mouse Mouse.Up))
    , SE.on "mouseup" (D.succeed (Mouse Mouse.Up))
    ]
