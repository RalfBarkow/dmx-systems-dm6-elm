module Mouse.Pretty exposing (pretty)

import Mouse
import String


pretty : Mouse.Msg -> String
pretty m =
    case m of
        Mouse.Down ->
            "Down"

        Mouse.DownOnItem cls id path pos ->
            "DownOnItem "
                ++ cls
                ++ " "
                ++ String.fromInt id
                ++ " path="
                ++ pathString path
                ++ " pos="
                ++ posString pos

        Mouse.Move pos ->
            "Move " ++ posString pos

        Mouse.Up ->
            "Up"

        Mouse.Over cls id path ->
            "Over " ++ cls ++ " " ++ String.fromInt id ++ " path=" ++ pathString path

        Mouse.Out cls id path ->
            "Out " ++ cls ++ " " ++ String.fromInt id ++ " path=" ++ pathString path

        Mouse.Time _ ->
            "Time"


posString : { x : Float, y : Float } -> String
posString p =
    "{ x = " ++ String.fromFloat p.x ++ ", y = " ++ String.fromFloat p.y ++ " }"


pathString : List Int -> String
pathString ints =
    "[" ++ (ints |> List.map String.fromInt |> String.join ",") ++ "]"
