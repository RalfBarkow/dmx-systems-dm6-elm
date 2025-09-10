# Build the façade modules directly
npx elm make src/Compat/ModelAPI.elm --output=/dev/null
npx elm make src/Compat/FedWikiImport.elm --output=/dev/null

# Smoke-test a tiny “contract” module that references the public API you promise:
cat > src/Compat/ContractSmoke.elm <<'EOF'
module Compat.ContractSmoke exposing (ok)
import Compat.ModelAPI as CMA
import Compat.FedWikiImport as CFWI
import Json.Decode as D
ok : Bool
ok =
    let _ = (CFWI.importPage) in True
EOF
npx elm make src/Compat/ContractSmoke.elm --output=/dev/null