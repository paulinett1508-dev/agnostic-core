#!/bin/bash
# Deploy Eruda Debug Report patches to all pending repos
# Usage: ./scripts/deploy-eruda-patches.sh
#
# This script clones each repo, creates a branch, applies the patch, and pushes.
# Requires: git with push access to paulinett1508-dev GitHub org

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PATCHES_DIR="$SCRIPT_DIR/../patches"
WORKDIR=$(mktemp -d)
BRANCH="feat/eruda-debug-report"

REPOS=(
  AlgodaoAtelie
  sicefsus-sistema
  SBR-ocomon-5.0
  CertiSYS
  FinanceFlow
  banana-prompts-firebase
  CRM-SBR
  joguinhos-jose
  temperodemamae
  florianorun
  SuperCartolaManagerv5-production
  sbr-monorepo
  agnvendas-painelsbr
)

echo "Working directory: $WORKDIR"
echo ""

for repo in "${REPOS[@]}"; do
  echo "=== $repo ==="
  patch_file="$PATCHES_DIR/$repo.patch"

  if [ ! -f "$patch_file" ]; then
    echo "  SKIP: patch not found"
    continue
  fi

  cd "$WORKDIR"
  git clone "https://github.com/paulinett1508-dev/$repo.git" 2>/dev/null
  cd "$repo"
  git checkout -b "$BRANCH" 2>/dev/null || git checkout "$BRANCH"
  git am "$patch_file"
  git push -u origin "$BRANCH"
  echo "  DONE"
  echo ""
done

echo "All patches deployed!"
echo "Clean up: rm -rf $WORKDIR"
