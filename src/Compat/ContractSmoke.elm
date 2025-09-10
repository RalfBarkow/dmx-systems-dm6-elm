module Compat.ContractSmoke exposing (ok)
import Compat.ModelAPI as CMA
import Compat.FedWikiImport as CFWI
import Json.Decode as D
ok : Bool
ok =
    let _ = (CFWI.importPage, CMA.getExt, CMA.setExt) in True
