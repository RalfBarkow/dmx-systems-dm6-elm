module Compat.ContractSmoke exposing (ok)

import Compat.FedWikiImport as CFWI
import Compat.ModelAPI as CMA
import Json.Decode as D


ok : Bool
ok =
    let
        _ =
            ( CFWI.importPage, CMA.getExt, CMA.setExt )
    in
    True
