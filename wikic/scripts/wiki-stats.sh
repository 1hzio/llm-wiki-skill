#!/usr/bin/env bash
# wiki-stats.sh — Show LLM Wiki statistics
# Usage: wiki-stats.sh [wiki-path]

set -euo pipefail

WIKI_PATH="${1:-.}"

echo "=== LLM Wiki Stats ==="
echo ""

# Basic counts
total_files=$(find "$WIKI_PATH" -maxdepth 1 -name "*.md" | wc -l | tr -d ' ')
total_lines=$(cat "$WIKI_PATH"/*.md 2>/dev/null | wc -l | tr -d ' ')
total_chars=$(cat "$WIKI_PATH"/*.md 2>/dev/null | wc -c | tr -d ' ')
total_refs=$(grep -oh '\[\[[^]]*\]\]' "$WIKI_PATH"/*.md 2>/dev/null | wc -l | tr -d ' ')

# Estimate tokens (rough: 0.5 tokens per char for mixed content)
est_tokens=$((total_chars / 2))

echo "Files:           $total_files"
echo "Lines:           $total_lines"
echo "Characters:      $total_chars"
echo "Est. tokens:     ~$est_tokens"
echo "Cross-refs:      $total_refs"
echo ""

# Context usage
echo "--- Context Usage ---"
pct_200k=$(echo "scale=1; $est_tokens * 100 / 200000" | bc 2>/dev/null || echo "N/A")
pct_1m=$(echo "scale=1; $est_tokens * 100 / 1000000" | bc 2>/dev/null || echo "N/A")
echo "  Sonnet 200K:   ${pct_200k}%"
echo "  Opus 1M:       ${pct_1m}%"
echo ""

# Top 5 largest pages
echo "--- Largest Pages ---"
for f in "$WIKI_PATH"/*.md; do
  [ ! -f "$f" ] && continue
  basename_f=$(basename "$f" .md)
  case "$basename_f" in
    CLAUDE|index|log) continue ;;
  esac
  chars=$(wc -c < "$f" | tr -d ' ')
  echo "$chars $basename_f"
done | sort -rn | head -5 | while read -r chars name; do
  est=$((chars / 2))
  printf "  %-35s ~%s tokens\n" "$name" "$est"
done
echo ""

echo "=== Done ==="
