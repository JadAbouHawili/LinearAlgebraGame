import Lake
open Lake DSL

package Game where
  moreLeanArgs := #[
    "-Dtactic.hygienic=false",
    "-Dlinter.unusedVariables.funArgs=false",
    "-Dtrace.debug=false"
  ]
  moreServerOptions := #[
    ⟨`tactic.hygienic, false⟩,
    ⟨`linter.unusedVariables.funArgs, true⟩,
    ⟨`trace.debug, true⟩
  ]

@[default_target]
lean_lib Game

require GameServer from git
  "https://github.com/leanprover-community/lean4game.git" @ "v4.21.0" / "server"

require mathlib from git
  "https://github.com/leanprover-community/mathlib4.git" @ "v4.21.0"