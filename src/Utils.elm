module Utils exposing (..)

import Html exposing (Attribute, Html, br, text)
import Html.Events exposing (keyCode, on, stopPropagationOn)
import Json.Decode as D
import Logger
import Model exposing (Class, Id, MapPath, Point)



-- Events


onEsc : msg -> Attribute msg
onEsc msg_ =
    on "keydown" (keyDecoder 27 msg_)


onEnterOrEsc : msg -> Attribute msg
onEnterOrEsc msg_ =
    on "keydown"
        (D.oneOf
            [ keyDecoder 13 msg_
            , keyDecoder 27 msg_
            ]
        )


keyDecoder : Int -> msg -> D.Decoder msg
keyDecoder key msg_ =
    let
        isKey code =
            if code == key then
                D.succeed msg_

            else
                D.fail "not that key"
    in
    keyCode |> D.andThen isKey


stopPropagationOnMousedown : msg -> Attribute msg
stopPropagationOnMousedown msg_ =
    stopPropagationOn "mousedown" <| D.succeed ( msg_, True )



-- Decoder


classDecoder : D.Decoder Class
classDecoder =
    D.oneOf
        [ D.at [ "target", "className" ] D.string -- HTML elements
        , D.at [ "target", "className", "baseVal" ] D.string -- SVG elements
        ]


idDecoder : D.Decoder Id
idDecoder =
    D.at [ "target", "dataset", "id" ] D.string
        |> D.andThen toIntDecoder


pathDecoder : D.Decoder MapPath
pathDecoder =
    D.at [ "target", "dataset", "path" ] D.string
        |> D.andThen toIntListDecoder


pointDecoder : D.Decoder Point
pointDecoder =
    D.map2 Point
        (D.field "clientX" D.float)
        (D.field "clientY" D.float)


toIntDecoder : String -> D.Decoder Int
toIntDecoder str =
    case String.toInt str of
        Just int ->
            D.succeed int

        Nothing ->
            D.fail <| "\"" ++ str ++ "\" is not an Int"


sequenceDecoders : List (D.Decoder a) -> D.Decoder (List a)
sequenceDecoders =
    List.foldr (D.map2 (::)) (D.succeed [])


toIntListDecoder : String -> D.Decoder (List Int)
toIntListDecoder str =
    let
        parseOne s =
            case String.toInt (String.trim s) of
                Just n ->
                    D.succeed n

                Nothing ->
                    D.fail <| "\"" ++ s ++ "\" is not an Int"
    in
    str
        |> String.trim
        |> String.split ","
        |> List.filter (\s -> s /= "")
        |> List.map parseOne
        |> sequenceDecoders



-- HTML


multilineHtml : String -> List (Html msg)
multilineHtml str =
    String.lines str
        |> List.foldr
            (\line linesAcc ->
                [ text line, br [] [] ] ++ linesAcc
            )
            []



-- Debug


logError : String -> String -> v -> v
logError funcName text val =
    Logger.log ("### ERROR @" ++ funcName ++ ": " ++ text) val


fail : String -> a -> v -> v
fail funcName args val =
    Logger.log ("--> @" ++ funcName ++ " failed " ++ Logger.toString args) val


call : String -> a -> v -> v
call funcName args val =
    Logger.log ("@" ++ funcName ++ " " ++ Logger.toString args ++ " -->") val


info : String -> v -> v
info funcName val =
    Logger.log ("@" ++ funcName) val


toString : a -> String
toString =
    Logger.toString
