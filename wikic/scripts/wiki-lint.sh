#!/usr/bin/env bash
# wiki-lint.sh — Audit LLM Wiki health
# Usage: wiki-lint.sh [wiki-path]

set -euo pipefail

WIKI_PATH="${1:-.}"

echo "=== LLM Wiki Health Audit ==="
echo "Path: $WIKI_PATH"
echo ""

# Count files
total_files=$(find "$WIKI_PATH" -maxdepth 1 -name "*.md" | wc -l | tr -d ' ')
echo "Total pages: $total_files"
echo "Total lines: $(cat "$WIKI_PATH"/*.md 2>/dev/null | wc -l | tr -d ' ')"
echo ""

# Check for dead links
echo "--- Dead Links ---"
dead_count=0
if [ -f "$WIKI_PATH/index.md" ]; then
  (grep -oh '\[\[[^]]*\]\]' "$WIKI_PATH"/*.md 2>/dev/null || true) | sort -u | sed 's/\[\[//;s/\]\]//' | while read -r page; do
    if [ ! -f "$WIKI_PATH/${page}.md" ]; then
      echo "  [DEAD] [[${page}]] → ${page}.md not found"
      dead_count=$((dead_count + 1))
    fi
  done
else
  echo "  (no index.md found)"
fi
echo ""

# Check for orphan pages (no inbound links)
echo "--- Orphan Pages (no inbound [[links]]) ---"
for f in "$WIKI_PATH"/*.md; do
  [ ! -f "$f" ] && continue
  basename_f=$(basename "$f" .md)
  # Skip meta files
  case "$basename_f" in
    CLAUDE|index|log) continue ;;
  esac
  # Check if any other file links to this page
  refs=0
  for other in "$WIKI_PATH"/*.md; do
    [ ! -f "$other" ] && continue
    [ "$other" = "$f" ] && continue
    if grep -q "\[\[$basename_f\]\]" "$other"; then
      refs=$((refs + 1))
    fi
  done
  if [ "$refs" -eq 0 ]; then
    echo "  [ORPHAN] $basename_f (0 inbound links)"
  fi
done
echo ""

# Check for missing frontmatter
echo "--- Missing Frontmatter ---"
for f in "$WIKI_PATH"/*.md; do
  [ ! -f "$f" ] && continue
  basename_f=$(basename "$f" .md)
  case "$basename_f" in
    CLAUDE|index|log) continue ;;
  esac
  if ! head -1 "$f" | grep -q "^---"; then
    echo "  [NO FRONTMATTER] $basename_f"
  fi
done
echo ""

# Cross-reference stats
echo "--- Cross-Reference Stats ---"
total_refs=$(( ($( (grep -oh '\[\[[^]]*\]\]' "$WIKI_PATH"/*.md 2>/dev/null || true) | wc -l | tr -d ' ') ) ))
unique_refs=$(( ($( (grep -oh '\[\[[^]]*\]\]' "$WIKI_PATH"/*.md 2>/dev/null || true) | sort -u | wc -l | tr -d ' ') ) ))
echo "  Total [[references]]: $total_refs"
echo "  Unique pages referenced: $unique_refs"
echo ""

# Enrichment coverage
echo "--- Enrichment Coverage ---"
where_count=$(( ($( (grep -rl "关键文件\|Key Files\|Source Files" "$WIKI_PATH"/*.md 2>/dev/null || true) | wc -l | tr -d ' ') ) ))
why_count=$(( ($( (grep -rl "架构决策\|Design Decision\|Why" "$WIKI_PATH"/*.md 2>/dev/null || true) | wc -l | tr -d ' ') ) ))
whatnot_count=$(( ($( (grep -rl "反模式\|Anti-pattern\|What Not" "$WIKI_PATH"/*.md 2>/dev/null || true) | wc -l | tr -d ' ') ) ))
content_pages=$((total_files - 3)) # minus CLAUDE, index, log
echo "  Where (file paths): $where_count / $content_pages pages"
echo "  Why (decisions):    $why_count / $content_pages pages"
echo "  What Not (pitfalls): $whatnot_count / $content_pages pages"
echo ""

echo "=== Audit Complete ==="
