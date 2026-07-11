#!/bin/bash
#
# scripts/generate-viz.sh
# One-command (or near one-command) entrypoint for the full embeddings + viz pipeline.
#
# Usage:
#   ./scripts/generate-viz.sh
#   # or with container from embeddings/ dir
#
# After success:
#   open generated/viz.html          (macOS)
#   or cd generated && python3 -m http.server 8080

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
EMBEDDINGS_DIR="$ROOT_DIR/embeddings"
GENERATED_DIR="$ROOT_DIR/generated"

echo "============================================================"
echo "  Marble Skill Taxonomy — Semantic + Graph Visualization"
echo "  Embeddings + UMAP + 3D Force-Directed Explorer"
echo "============================================================"

cd "$EMBEDDINGS_DIR"

echo ""
echo "→ Building container image (this may take a few minutes the first time)..."
container build -t marble-taxonomy-embeddings .

echo ""
echo "→ Running generation pipeline inside container..."
container run --rm \
  -v "$ROOT_DIR/data":/data:ro \
  -v "$GENERATED_DIR":/app/generated \
  marble-taxonomy-embeddings

echo ""
echo "============================================================"
echo "✓ Generation complete."
echo ""
echo "Artifacts written to:"
echo "  $GENERATED_DIR/"
echo "  $GENERATED_DIR/chroma/          (vector database)"
echo "  $GENERATED_DIR/viz.html         (if copied) or use the HTML below"
echo ""

if [[ -f "$GENERATED_DIR/topics_with_layout.json" ]]; then
    COUNT=$(python3 -c '
import json, sys
try:
    print(json.load(open(sys.argv[1]))["count"])
except Exception:
    print("unknown")
' "$GENERATED_DIR/topics_with_layout.json" 2>/dev/null)
    echo "✓ $COUNT topics with 3D UMAP coordinates ready."
fi

echo ""
echo "To view the visualization:"
echo "  1. cd $GENERATED_DIR"
echo "  2. python3 -m http.server 8080"
echo "  3. Open http://localhost:8080/viz.html in your browser"
echo ""
echo "On macOS you can also try:"
echo "  open $GENERATED_DIR/viz.html"
echo ""
echo "See EMBEDDINGS.md for full documentation, how to change models, and"
echo "how to interpret the 'semantic diversity + prerequisite web' view."
echo "============================================================"
