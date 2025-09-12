module Compat.FedWiki exposing
    ( decodePage
    , pageToModel
    , renderAsMonad
    )

import AppModel as AM
import Compat.FedWikiImport as FWI
import Json.Decode as D
import Platform.Cmd as Cmd



-- Old name, stable surface: decode raw JSON to a Value


decodePage : D.Decoder D.Value
decodePage =
    D.value



-- Old name, adapted: call the new importer and drop the Cmd for purity


pageToModel : D.Value -> AM.Model -> AM.Model
pageToModel val model =
    let
        ( m, _ ) =
            FWI.importPage val model
    in
    m



-- Convenience: raw JSON -> Value -> import -> Model (pure)


renderAsMonad : String -> AM.Model -> AM.Model
renderAsMonad raw model =
    case D.decodeString decodePage raw of
        Ok val ->
            pageToModel val model

        Err _ ->
            model
