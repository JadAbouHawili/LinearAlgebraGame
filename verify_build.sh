#!/bin/bash
echo "Verifying Linear Algebra Game build configuration..."
echo "=================================================="
echo ""

# Check lean-toolchain
echo "1. Lean version:"
cat lean-toolchain
echo ""

# Check lakefile dependencies
echo "2. Dependencies in lakefile.lean:"
grep -E "require.*@ \"v[0-9]" lakefile.lean
echo ""

# Check if lake manifest exists
echo "3. Lake manifest status:"
if [ -f "lake-manifest.json" ]; then
    echo "✓ lake-manifest.json exists"
    grep '"name"' lake-manifest.json | head -5
else
    echo "✗ lake-manifest.json missing"
fi
echo ""

# Check main game file
echo "4. Main game module:"
if [ -f "Game.lean" ]; then
    echo "✓ Game.lean exists"
    head -3 Game.lean
else
    echo "✗ Game.lean missing"
fi
echo ""

echo "=================================================="
echo "To build from a fresh clone:"
echo "  1. git clone <repo>"
echo "  2. cd LinearAlgebraGame"
echo "  3. lake update"
echo "  4. lake build"
echo ""
echo "Note: First build may take 15+ minutes due to mathlib compilation"
