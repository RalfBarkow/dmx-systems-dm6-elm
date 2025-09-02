port module Solo exposing
    ( Aspect
    , Batch
    , SoloAction(..)
    , SoloIncoming(..)
    , Source
    , batchEncoder
    , fromSolo
    , incomingDecoder
    , openSolo
    )

import Json.Decode as D
import Json.Encode as E



-- What Solo expects (mirrors the plugin)


type alias Aspect =
    D.Value



-- If you know the JSONL schema, replace with a typed record and decoders.


type alias Source =
    { source : String
    , aspects : List Aspect
    }


type alias Batch =
    { type_ : String -- e.g. "batch"
    , sources : List Source
    , pageKey : Maybe String
    }



-- Messages coming back from the popup (Solo → page)


type SoloAction
    = DoInternalLink { title : String, context : D.Value, keepLineup : Bool, pageKey : Maybe String }
    | ShowResult { page : D.Value, keepLineup : Bool, pageKey : Maybe String }


type SoloIncoming
    = SoloMsg SoloAction
    | SoloUnknown D.Value



-- OUT: Elm → JS


port openSolo : E.Value -> Cmd msg



-- IN: JS → Elm


port fromSolo : (E.Value -> msg) -> Sub msg



-- Encoders (Elm → JS)


aspectEncoder : Aspect -> E.Value
aspectEncoder v =
    v


sourceEncoder : Source -> E.Value
sourceEncoder s =
    E.object
        [ ( "source", E.string s.source )
        , ( "aspects", E.list aspectEncoder s.aspects )
        ]


batchEncoder : Batch -> E.Value
batchEncoder b =
    E.object
        [ ( "type", E.string b.type_ )
        , ( "sources", E.list sourceEncoder b.sources )
        , ( "pageKey", Maybe.withDefault E.null (Maybe.map E.string b.pageKey) )
        ]



-- Decoders (JS → Elm)


doInternalLinkDecoder : D.Decoder SoloAction
doInternalLinkDecoder =
    D.map4
        (\title context keepLineup pageKey ->
            DoInternalLink { title = title, context = context, keepLineup = keepLineup, pageKey = pageKey }
        )
        (D.field "title" D.string)
        (D.field "context" D.value)
        (D.field "keepLineup" (D.maybe D.bool) |> D.map (Maybe.withDefault False))
        (D.field "pageKey" (D.nullable D.string))


showResultDecoder : D.Decoder SoloAction
showResultDecoder =
    D.map3
        (\page keepLineup pageKey ->
            ShowResult { page = page, keepLineup = keepLineup, pageKey = pageKey }
        )
        (D.field "page" D.value)
        (D.field "keepLineup" (D.maybe D.bool) |> D.map (Maybe.withDefault False))
        (D.field "pageKey" (D.nullable D.string))


incomingDecoder : D.Decoder SoloIncoming
incomingDecoder =
    D.field "action" D.string
        |> D.andThen
            (\action ->
                case action of
                    "doInternalLink" ->
                        D.map SoloMsg doInternalLinkDecoder

                    "showResult" ->
                        D.map SoloMsg showResultDecoder

                    _ ->
                        D.map SoloUnknown D.value
            )
