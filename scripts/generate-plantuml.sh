#!/usr/bin/env bash
# Generates SVGs for staged .puml files and stages them.
set -euo pipefail

JAR="$HOME/.local/share/plantuml/plantuml.jar"

if [ -f "$JAR" ] && command -v java >/dev/null 2>&1; then
    run_plantuml() { java -jar "$JAR" -tsvg "$@"; }
elif command -v plantuml >/dev/null 2>&1; then
    run_plantuml() { plantuml -tsvg "$@"; }
else
    echo "PlantUML not found. Run ./setup.sh from the course repo (installs the jar) and make sure Java is installed." >&2
    exit 1
fi

files=$(git diff --cached --name-only --diff-filter=ACM | grep '\.puml$' || true)

for f in $files; do
    run_plantuml "$f"
    svg="${f%.puml}.svg"
    git add "$svg"
    echo "generated and staged $svg"
done
