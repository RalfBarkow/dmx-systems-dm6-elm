module FedWiki exposing
    ( decodePage
    , importString
    , importValue
    , renderAsMonad
    , summarizeLite
    , synopsisLite
    )

import AppModel as AM
import Compat.FedWiki as CFW
import Dict
import Json.Decode as D


decodePage : D.Decoder D.Value
decodePage =
    D.value


importValue : D.Value -> AM.Model -> ( AM.Model, Cmd AM.Msg )
importValue val model =
    CFW.pageToModel val model


importString : String -> AM.Model -> ( AM.Model, Cmd AM.Msg )
importString raw model =
    case D.decodeString decodePage raw of
        Ok val ->
            importValue val model

        Err _ ->
            ( model, Cmd.none )


summarizeLite :
    String
    -> Result String { title : String, total : Int, histogram : Dict.Dict String Int, sample : List { id : String, typ : String } }
summarizeLite raw =
    let
        storyItemLite =
            D.map2 (\id typ -> { id = id, typ = typ })
                (D.field "id" D.string)
                (D.field "type" D.string)

        liteDecoder =
            D.map2 (\title story -> { title = title, story = story })
                (D.field "title" D.string)
                (D.field "story" (D.list storyItemLite))
    in
    case D.decodeString liteDecoder raw of
        Err e ->
            Err (Debug.toString e)

        Ok { title, story } ->
            let
                total =
                    List.length story

                histogram =
                    List.foldl (\s acc -> Dict.update s.typ (\mi -> Just <| Maybe.withDefault 0 mi + 1) acc)
                        Dict.empty
                        story

                sample =
                    List.take 6 story
            in
            Ok { title = title, total = total, histogram = histogram, sample = sample }


renderAsMonad : String -> AM.Model -> AM.Model
renderAsMonad raw model =
    let
        ( m, _ ) =
            importString raw model
    in
    m


synopsisLite : String -> String
synopsisLite raw =
    case summarizeLite raw of
        Ok s ->
            let
                bucket ( k, v ) =
                    String.fromInt v
                        ++ " "
                        ++ k
                        ++ (if v == 1 then
                                ""

                            else
                                "s"
                           )

                parts =
                    s.histogram
                        |> Dict.toList
                        |> List.map bucket
                        |> String.join ", "
            in
            s.title
                ++ " — "
                ++ String.fromInt s.total
                ++ " blocks ("
                ++ parts
                ++ ")"

        Err _ ->
            "unknown — 0 blocks"
