mkdir -p scripts
cat > scripts/integrate-upstream.sh <<'EOF'
#!/usr/bin/env bash
set -euo pipefail

# Defaults (override with env vars)
UPSTREAM_REMOTE="${UPSTREAM_REMOTE:-upstream}"
MASTER_BRANCH="${MASTER_BRANCH:-master}"
MAIN_BRANCH="${MAIN_BRANCH:-main}"

# Flags
NO_FORMAT=0
NO_TEST=0
MERGE_MAIN_MODE="ff"   # ff | merge
while [[ $# -gt 0 ]]; do
  case "$1" in
    --no-format) NO_FORMAT=1; shift ;;
    --no-test)   NO_TEST=1; shift ;;
    --merge-main) MERGE_MAIN_MODE="merge"; shift ;;
    -h|--help)
      cat <<USAGE
Usage: $(basename "$0") [--no-format] [--no-test] [--merge-main]
  --no-format    Skip elm-format
  --no-test      Skip elm-test
  --merge-main   Use a merge commit from master into main (default tries fast-forward)
Env:
  UPSTREAM_REMOTE=upstream   Remote name for upstream
  MASTER_BRANCH=master       Your primary integration branch
  MAIN_BRANCH=main           Your main branch
USAGE
      exit 0
      ;;
    *) echo "Unknown arg: $1" >&2; exit 1 ;;
  esac
done

say() { printf "\033[1;36m▶ %s\033[0m\n" "$*"; }
warn() { printf "\033[1;33m⚠ %s\033[0m\n" "$*"; }
err() { printf "\033[1;31m✖ %s\033[0m\n" "$*"; }
ok() { printf "\033[1;32m✓ %s\033[0m\n" "$*"; }

need() { command -v "$1" >/dev/null 2>&1 || { err "Missing '$1' in PATH"; exit 127; }; }

ensure_clean() {
  if ! git diff --quiet || ! git diff --cached --quiet; then
    err "Working tree not clean. Commit or stash first."
    exit 2
  fi
}

ensure_remote() {
  if ! git remote get-url "$UPSTREAM_REMOTE" >/dev/null 2>&1; then
    err "Remote '$UPSTREAM_REMOTE' not found."
    warn "Add it with:  git remote add $UPSTREAM_REMOTE <git@github.com:dmx-systems/dm6-elm.git>"
    exit 2
  fi
}

run_elm_pipeline() {
  if [[ $NO_FORMAT -eq 0 ]]; then
    say "elm-format"
    npx elm-format src tests --yes
  else
    warn "Skipping elm-format (--no-format)"
  fi

  say "elm make (typecheck app)"
  npx elm make src/AppMain.elm --output=/dev/null

  if [[ $NO_TEST -eq 0 ]]; then
    say "elm-test"
    npx elm-test
  else
    warn "Skipping elm-test (--no-test)"
  fi
}

say "Pre-flight checks"
need git
need npx
ensure_remote
ensure_clean

say "Fetch all remotes"
git fetch --all --prune

say "Update local '${MASTER_BRANCH}' from origin"
git checkout "${MASTER_BRANCH}"
git pull --ff-only origin "${MASTER_BRANCH}" || true

say "Merge ${UPSTREAM_REMOTE}/master -> ${MASTER_BRANCH}"
if git merge --no-ff "${UPSTREAM_REMOTE}/master"; then
  ok "Merged upstream into ${MASTER_BRANCH}"
else
  err "Merge conflict in ${MASTER_BRANCH}."
  warn "Resolve conflicts, then run: git add -A && git commit"
  exit 3
fi

say "Run Elm pipeline on ${MASTER_BRANCH}"
run_elm_pipeline

say "Push ${MASTER_BRANCH} to origin"
git push origin "${MASTER_BRANCH}"

say "Update '${MAIN_BRANCH}' from origin"
git checkout "${MAIN_BRANCH}"
git pull --ff-only origin "${MAIN_BRANCH}" || true

if [[ "${MERGE_MAIN_MODE}" == "ff" ]]; then
  say "Fast-forward ${MAIN_BRANCH} to ${MASTER_BRANCH} (if possible)"
  if git merge --ff-only "${MASTER_BRANCH}"; then
    ok "Fast-forwarded ${MAIN_BRANCH}"
  else
    warn "Cannot fast-forward. Use --merge-main to create a merge commit."
    exit 4
  fi
else
  say "Merge ${MASTER_BRANCH} -> ${MAIN_BRANCH} (merge commit)"
  if git merge --no-ff "${MASTER_BRANCH}"; then
    ok "Merged ${MASTER_BRANCH} into ${MAIN_BRANCH}"
  else
    err "Merge conflict in ${MAIN_BRANCH}."
    warn "Resolve conflicts, then run: git add -A && git commit"
    exit 5
  fi
fi

say "Run Elm pipeline on ${MAIN_BRANCH}"
run_elm_pipeline

say "Push ${MAIN_BRANCH} to origin"
git push origin "${MAIN_BRANCH}"

ok "Done. ${UPSTREAM_REMOTE}/master → ${MASTER_BRANCH} → ${MAIN_BRANCH}"
EOF
chmod +x scripts/integrate-upstream.sh
