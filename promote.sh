#!/bin/bash
# Promote the staging site (next.superduperintelligence.ca) to the live site (superduperintelligence.ca).
# Run ONLY after Ninetentwo approves. Reads the GitHub token from a file and never prints it.
set -euo pipefail
NEXT_DIR=/workspace/superduperintelligence-next
MAIN_DIR=/workspace/superduperintelligence
TOKEN_FILE=/home/box/.config/aurora-secrets/github-anticontainmentsystem.token
TOKEN=$(cat "$TOKEN_FILE")
AUTH="Authorization: Basic $(printf 'x-access-token:%s' "$TOKEN" | base64 -w0)"
NAME=anticontainmentsystem; EMAIL=anticontainment.system@gmail.com
MSG="${1:-Promote staging to live}"

# 1. Make sure both repos are current.
git -C "$NEXT_DIR" -c http.extraHeader="$AUTH" pull -q --ff-only origin main
git -C "$MAIN_DIR" -c http.extraHeader="$AUTH" pull -q --ff-only origin main

# 2. Copy every tracked staging file except the staging-only ones.
cd "$NEXT_DIR"
git ls-files | grep -vxE 'CNAME|robots.txt|PROMOTE.md|promote.sh' | while read -r f; do
  mkdir -p "$MAIN_DIR/$(dirname "$f")"; cp "$f" "$MAIN_DIR/$f"
done

# 3. Restore the live settings.
cd "$MAIN_DIR"
echo superduperintelligence.ca > CNAME
printf 'User-agent: *\nAllow: /\n\nSitemap: https://superduperintelligence.ca/sitemap.xml\n' > robots.txt
python3 - <<'PY'
s = open('index.html').read()
s = s.replace('<meta name="robots" content="noindex,nofollow">', '<meta name="robots" content="index,follow">')
s = s.replace('<title>NEXT | ', '<title>')
open('index.html', 'w').write(s)
assert 'noindex' not in s and 'NEXT |' not in s
PY

# 4. Commit and push live.
git add -A $(cd "$NEXT_DIR" && git ls-files | grep -vxE 'PROMOTE.md|promote.sh') CNAME robots.txt
if git diff --cached --quiet; then echo "Nothing to promote."; exit 0; fi
git -c user.name="$NAME" -c user.email="$EMAIL" commit -qm "$MSG"
git -c http.extraHeader="$AUTH" push -q origin main
echo "Pushed live: $(git log --oneline -1)"
