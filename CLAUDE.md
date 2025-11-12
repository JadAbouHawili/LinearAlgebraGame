# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a **Linear Algebra Game** built using the [lean4game](https://github.com/leanprover-community/lean4game) framework. It's an educational game that teaches linear algebra concepts through interactive theorem proving in Lean 4, based on Sheldon Axler's "Linear Algebra Done Right" textbook.

## Build System and Development Commands

The project uses Lake (Lean 4's build system):

- `lake build` - Build the entire project (Note: This can take 15+ minutes for full mathlib builds - don't set timeouts)
- `lake clean` - Remove build outputs
- `lake update` - Update dependencies and save to manifest
- `lake exe <exe>` - Build and run an executable
- `lake env <cmd>` - Execute command in Lake's environment

**Important Build Note:** When running `lake build`, do not set time limits. Full builds with mathlib dependencies can take longer than 15 minutes, especially on first compilation.

## Project Structure

### Core Game Files
- `Game.lean` - Main game configuration with title, introduction, and world dependencies
- `Game/Data.lean` - Extensive mathlib imports for mathematical definitions
- `Game/Metadata/Metadata.lean` - Game metadata and server commands
- `Game/MyTactic.lean` - Custom tactic imports for the game

### Game Worlds (Educational Levels)
The game is organized into sequential worlds:

1. **TutorialWorld** (`Game/Levels/TutorialWorld/`) - Introduction to Lean 4 basics
2. **VectorSpaceWorld** (`Game/Levels/VectorSpaceWorld/`) - Vector space concepts
3. **LinearIndependenceSpanWorld** (`Game/Levels/LinearIndependenceSpanWorld/`) - Linear independence and span

Each world:
- Has a main `.lean` file (e.g., `TutorialWorld.lean`) that imports all levels
- Contains individual level files (`Level01.lean`, `Level02.lean`, etc.)
- Uses the `World`, `Level`, `Title`, `Introduction`, `Statement`, `Conclusion` commands

### Level Management
- `sofi.sh` - Script for reordering and renaming level files within worlds
- Levels must follow `L**.lean` or `L**_*****.lean` naming convention
- The script automatically updates level numbers and imports

## Key Dependencies

- **Lean 4.21.0** - The proof assistant (latest version)
- **mathlib 4.21.0** - Comprehensive mathematics library
- **lean4game 4.21.0** - Game framework (local or remote depending on `LEAN4GAME` env var)
- **checkdecls** - Declaration checking tool for blueprint verification (working)

## Development Workflow

1. **Adding New Levels**: Create level files following naming convention, then run `./sofi.sh <world_path>` to reorder
2. **Level Structure**: Each level includes `World`, `Level`, `Title`, `Introduction`, `Statement`, `Conclusion`
3. **Tactic Documentation**: Use `TacticDoc` and `NewTactic` commands to document tactics
4. **World Dependencies**: Configure in `Game.lean` (e.g., VectorSpaceWorld → LinearIndependenceSpanWorld)
5. **REQUIRED**: Always run `lake build` after making any fixes or changes to ensure changes are visible in the local game

## Mathematical Content

The game covers:
- Vector spaces and their properties
- Linear independence and span
- Bases and linear transformations
- Proof techniques using Lean 4 tactics (`rfl`, `apply`, `intro`, etc.)

## Local Development

For local development with the game framework:
- Set `LEAN4GAME.local=true` in Lake configuration
- Ensure the lean4game server is available at `../lean4game/server`
- Use `lake build` to compile the game
- The game generates a web interface for interactive theorem proving

## Architecture Notes

- **Game Framework Integration**: Uses lean4game's `GameServer.Commands` for web interface
- **Tactic System**: Imports extensive mathlib tactics while filtering some for educational purposes
- **World Organization**: Sequential progression with dependency management
- **Educational Design**: Focuses on proof techniques rather than computation

## Blueprint System

### Blueprint Documentation
The blueprint provides comprehensive mathematical documentation for all 45 levels across 5 worlds:
- **Tutorial World**: 10 levels introducing Lean 4 tactics
- **Vector Space World**: 6 levels on vector space fundamentals  
- **Linear Independence & Span World**: 10 levels on independence and spanning sets
- **Linear Maps World**: 11 levels on linear transformations
- **Inner Product World**: 8 levels on inner products and norms

### Checkdecls Integration
- **checkdecls** package from PatrickMassot/checkdecls is installed and working
- Verifies all Lean declarations referenced in the blueprint exist in the code
- `blueprint/lean_decls` lists 60+ theorem declarations
- CI workflow runs `lake exe checkdecls blueprint/lean_decls` to verify consistency
- Use comments in `lean_decls` file starting with `--`

## Game Quality Issues Fixed (July 26, 2025)

### Hint-Code Mismatch Issues
Multiple levels had hints that didn't match the actual proof code, causing player confusion:

#### Variable Naming Issues
- **Root Cause**: `funext` without explicit variable names defaults to `x`, not `v`
- **LinearIndependenceSpanWorld Level07**: Fixed all hints to use `x` instead of `v` after `funext x`
- **Impact**: 8+ hint corrections in the most complex proof level

#### Curly Brace Syntax Errors  
- **Root Cause**: Hints incorrectly used `{variable}` syntax instead of plain `variable`
- **Files Fixed**: Level03, Level06, Level09 (LinearIndependenceSpanWorld), Level04 (VectorSpaceWorld)
- **Pattern**: `obtain ⟨...⟩ := {hypothesis}` → `obtain ⟨...⟩ := hypothesis`
- **Impact**: 5 syntax corrections across multiple levels

### Game Stalling Issues
Critical issue where proofs would hang after completion:

#### Root Cause Analysis
- **Problem**: Proofs ending with rewrite tactics (`rw[...]`) that create trivial goals
- **Environment**: lean4game framework doesn't auto-close trivial goals like standard Lean
- **Symptom**: Game freezes/stalls when player completes the final rewrite

#### Files Fixed
1. **LinearIndependenceSpanWorld Level07** (Original report)
   - Added `rfl` after `rw[hf0 x hS, hg0 x hT]`
   - Most complex proof in the game

2. **DemoWorld L01_HelloWorld** (Discovered during systematic review)
   - Added `rfl` after `rw [g]`
   - Basic introductory level

3. **LinearMapsWorld Level06** (Discovered during systematic review)  
   - Added `rfl` after `rw [hT.2 a1 v1, hT.2 a2 v2]`
   - Linear combination preservation proof

4. **VectorSpaceWorld Level01** (Discovered during systematic review)
   - Added `rfl` after `rw[zero_add]`
   - First vector space theorem

#### Prevention Strategy
- All proofs ending with rewrites before `Conclusion` statements require explicit closing tactics
- Pattern: `rw[...]; rfl` instead of just `rw[...]`
- Systematic search methodology developed to find similar issues

### Development Guidelines Updated

#### Hint Writing Best Practices
1. **Variable Names**: Always specify explicit variable names in tactics (`funext x` not `funext`)
2. **Syntax Matching**: Ensure hint syntax exactly matches required code
3. **No Assumptions**: Don't assume Lean's default behaviors in educational contexts

#### Proof Completion Standards  
1. **Explicit Closing**: Always use explicit closing tactics (`rfl`, `simp`, `exact`) for trivial goals
2. **Game Environment**: lean4game requires more explicit proof steps than standard Lean
3. **Testing Protocol**: Verify proof completion doesn't stall in game environment

### Impact Summary
- **Total Issues Fixed**: 11 across 9 different levels
- **Stalling Issues**: 4 (prevented game freezes)
- **Hint Issues**: 7 (improved player experience)
- **Systematic Approach**: One reported issue led to discovering 3 additional similar problems

## Screenshots and Images Location

**Default picture folder**: `/mnt/e/pictures`

When asked to examine pictures or screenshots without a specific path, look in `/mnt/e/pictures` first.

Additional screenshot location: `/mnt/c/Users/zrtmr/OneDrive/Pictures/Screenshots`