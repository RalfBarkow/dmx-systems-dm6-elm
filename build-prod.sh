#!/bin/sh
set -euo pipefail

# --- paths & files ------------------------------------------------------------
js="main.js"
min="main.min.js"
template="public/index.html"           # HTML template containing <script src="main.js">
html="public/dm6-elm.html"      # final standalone output
tools_js_src="scripts/localstorage-tools.js"

log_dst="src/Logger.elm"
log_prod_src="src/Logger/Prod/Logger.elm"
log_dev_src="src/Logger/Dev/Logger.elm"   # must exist

# --- guards -------------------------------------------------------------------
in_git() { git rev-parse --is-inside-work-tree >/dev/null 2>&1; }
is_tracked() { git ls-files --error-unmatch "$1" >/dev/null 2>&1; }

if ! in_git; then
  echo "ERROR: build-prod.sh expects to run inside a git worktree." >&2
  exit 1
fi

[ -f "$log_prod_src" ] || { echo "ERROR: $log_prod_src missing." >&2; exit 1; }
[ -f "$log_dev_src" ]  || { echo "ERROR: $log_dev_src missing."  >&2; exit 1; }
[ -f "$template" ]     || { echo "ERROR: $template missing."     >&2; exit 1; }
command -v pnpm >/dev/null 2>&1 || { echo "ERROR: pnpm not found. Use the Nix devshell or run 'corepack enable'."; exit 1; }
pnpm exec uglifyjs --version >/dev/null 2>&1 || { echo "ERROR: uglify-js not found in devDependencies. Run: pnpm add -D uglify-js"; exit 1; }

# --- cleanup: restore tracked file via git; fallback to Dev copy ------------
cleanup() {
  set +e
  if in_git && is_tracked "$log_dst"; then
    git restore --worktree --staged -- "$log_dst" || git checkout -- "$log_dst"
  else
    # Fallback for non-git or untracked file: restore Dev variant and normalize header
    cp -f "$log_dev_src" "$log_dst"
    awk 'NR==1{
           if ($0 ~ /^module[[:space:]]+[^[:space:]]+[[:space:]]+exposing[[:space:]]*\(.*\)/) {
             sub(/^module[[:space:]]+[^[:space:]]+/, "module Logger")
           } else {
             $0 = "module Logger exposing (..)"
           }
         }1' "$log_dst" > "$log_dst.tmp" && mv "$log_dst.tmp" "$log_dst"
  fi
  set -e
}
trap cleanup EXIT


# --- put PROD logger in place -------------------------------------------------
cp -f "$log_prod_src" "$log_dst"

# Ensure module header matches file path: change only the module name, keep exposing list
awk 'NR==1 {
        # Cases:
        # 1) module Logger.Prod exposing (...)
        if ($0 ~ /^module[[:space:]]+Logger\.Prod[[:space:]]+exposing[[:space:]]*\(.*\)/) {
            sub(/^module[[:space:]]+Logger\.Prod/, "module Logger")
        }
        # 2) module <Anything> exposing (...)  -> rename to Logger, keep exposing list
        else if ($0 ~ /^module[[:space:]]+[^[:space:]]+[[:space:]]+exposing[[:space:]]*\(.*\)/) {
            sub(/^module[[:space:]]+[^[:space:]]+/, "module Logger")
        }
        # 3) Fallback: if header is weird/missing exposing, use (..)
        if ($0 !~ /^module[[:space:]]+Logger[[:space:]]+exposing[[:space:]]*\(.*\)/) {
            $0 = "module Logger exposing (..)"
        }
     } { print }' "$log_dst" > "$log_dst.tmp" && mv "$log_dst.tmp" "$log_dst"


# Back-compat alias (older code might import Logger.log explicitly)
grep -q '^log[[:space:]]*:' "$log_dst" 2>/dev/null || cat >> "$log_dst" <<'EOF'

-- Back-compat alias (older code imports `Logger.log`)
log : String -> a -> a
log =
    debug
EOF

# --- build & minify -----------------------------------------------------------
elm make src/AppMain.elm --optimize --output="$js"

pnpm exec uglifyjs "$js" \
  --compress "pure_funcs=[F2,F3,F4,F5,F6,F7,F8,F9,A2,A3,A4,A5,A6,A7,A8,A9],pure_getters,keep_fargs=false,unsafe_comps,unsafe" \
  | uglifyjs --mangle --output "$min"

echo "Initial size: $(wc -c < "$js") bytes ($js)"
echo "Minified size: $(wc -c < "$min") bytes ($min)"

# --- inline bundle into template ---------------------------------------------
tmp_js_escaped="$(mktemp)"
sed 's#</script>#<\\/script>#g' "$min" > "$tmp_js_escaped"

tmp_tools_escaped="$(mktemp)"
sed 's#</script>#<\\/script>#g' "$tools_js_src" > "$tmp_tools_escaped"

awk -v jsfile="$tmp_js_escaped" -v toolsfile="$tmp_tools_escaped" '
  BEGIN {
    while ((getline l < jsfile)    > 0) js = js l ORS;     close(jsfile)
    while ((getline t < toolsfile) > 0) tools = tools t ORS; close(toolsfile)
  }
  {
    if ($0 ~ /<script[[:space:]]+src=["'\''"]main\.js["'\''"][^>]*><\/script>[[:space:]]*$/ \
     || $0 ~ /<script[[:space:]]+src=["'\''"]main\.js["'\''"][^>]*>[[:space:]]*$/) {
      print "  <script>"
      printf "%s", js
      print "  </script>"
      replaced = 1
      next
    }

    if ($0 ~ /<\/body>/ && !injected) {
      print "  <div id=\"dm6-dev-tools\""
      print "       style=\"position:fixed;bottom:10px;right:10px;"
      print "              display:flex;gap:.5em;z-index:9999;"
      print "              background:#fff;border:1px solid #ddd;border-radius:8px;"
      print "              padding:.4em .6em;box-shadow:0 2px 10px rgba(0,0,0,.08);\">"
      print "    <button type=\"button\" onclick='\''exportLS()'\'' title=\"Export model\">⤓ Export</button>"
      print "    <button type=\"button\" onclick='\''importLSFile()'\'' title=\"Import model\">📂 Import</button>"
      print "  </div>"
      print "  <script>"
      printf "%s", tools
      print "  </script>"

      # Subscribe to Logger port if present (safe no-op otherwise)
      print "  <script>"
      print "    (function(){"
      print "      try {"
      print "        if (window.app && window.app.ports && window.app.ports.log && window.app.ports.log.subscribe) {"
      print "          window.app.ports.log.subscribe(function(line){ console.log(line); });"
      print "        }"
      print "      } catch (e) { /* ignore */ }"
      print "    })();"
      print "  </script>"

      injected = 1
      print
      next
    }

    print
  }
  END {
    if (!replaced)  { print "ERROR: Could not find <script src=\"main.js\"> in template to inline." > "/dev/stderr"; exit 42 }
    if (!injected)  { print "ERROR: Could not inject tools (no </body> seen)." > "/dev/stderr"; exit 43 }
  }
' "$template" > "$html"

rm -f "$tmp_js_escaped" "$tmp_tools_escaped"

grep -q "</script>" "$html" || { echo "ERROR: Missing </script> in $html" >&2; exit 1; }
printf "Standalone written to: %s\n" "$html"
printf "Size: %s bytes (gzipped: %s bytes)\n" "$(wc -c < "$html")" "$(gzip -c "$html" | wc -c)"

# --- open in browser ----------------------------------------------------------
if command -v open >/dev/null 2>&1; then
  open "$html"
elif command -v xdg-open >/dev/null 2>&1; then
  xdg-open "$html"
else
  echo "Open $html manually in your browser."
fi
