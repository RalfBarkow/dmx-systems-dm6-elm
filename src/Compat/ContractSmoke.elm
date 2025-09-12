module Compat.ContractSmoke exposing (ok)

import Compat.FedWikiImport as CFWI


ok : Bool
ok =
    let
        _ =
            CFWI.importPage
    in
    True
