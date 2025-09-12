module FedWiki exposing (renderAsMonad)

import AppModel as AM
import Json.Decode as D
import MapAutoSize exposing (autoSize)
import ModelAPI exposing (createTopicIn)


titleDecoder : D.Decoder String
titleDecoder =
    D.field "title" D.string


renderAsMonad : String -> AM.Model -> AM.Model
renderAsMonad raw model =
    case D.decodeString titleDecoder raw of
        Ok title ->
            createTopicIn title Nothing [ 0 ] model

        -- |> autoSize
        Err _ ->
            model
