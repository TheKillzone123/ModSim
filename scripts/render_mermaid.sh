#!/usr/bin/env bash
set -euo pipefail

QUELL_ORDNER="docs/diagramme"
ZIEL_ORDNER="docs/figuren"

mkdir -p "$ZIEL_ORDNER"

if ! command -v npx >/dev/null 2>&1; then
  echo "Fehler: npx wurde nicht gefunden. Bitte Node.js/npm installieren."
  exit 1
fi

shopt -s nullglob
mmd_dateien=("$QUELL_ORDNER"/*.mmd)

if [[ ${#mmd_dateien[@]} -eq 0 ]]; then
  echo "Keine .mmd-Dateien im Ordner $QUELL_ORDNER gefunden."
  exit 0
fi

for datei in "${mmd_dateien[@]}"; do
  basisname="$(basename "$datei" .mmd)"

  echo "Rendere $datei -> $ZIEL_ORDNER/$basisname.pdf"
  npx -y @mermaid-js/mermaid-cli -i "$datei" -o "$ZIEL_ORDNER/$basisname.pdf"

  echo "Rendere $datei -> $ZIEL_ORDNER/$basisname.png"
  npx -y @mermaid-js/mermaid-cli -i "$datei" -o "$ZIEL_ORDNER/$basisname.png"
done

echo "Fertig: Alle Mermaid-Diagramme wurden aktualisiert."
