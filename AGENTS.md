# Project policy

- Keep credentials, personal data and runtime state outside Git.
- Before Nix, initialize Git if needed and, when authorized, stage only reviewed source files
  with an explicit file list. Use Git-backed `.`; keep runtime evidence outside
  the source tree. `path:.` copies ignored files into the Nix store.
- Preserve existing user changes. Write documentation and CLI text in English.
- Derive version-sensitive documentation from source using `.dependency-docs.json`
  and the shared `project-docs` tool. Keep interpolation in Markdown templates;
  explicit fast/full checks must refresh docs after dependency/model updates.
  Older runner pins require a declared bootstrap check; do not copy versions by hand.
- Run `just fmt` and `just check` after meaningful changes. Full checks and
  builds require explicit authorization under the task workload policy. Checks
  are declared in `.project-checks.json` and never run on their own.
- Missing tools or offline dependencies are environment blockers, not failures.
  Enter the pinned toolchain with `nix develop .` (or reload direnv).
  `just lint --json` and `just verify --json` forward options to project-check.
- Do not stage, commit, push, publish or deploy without explicit authorization.
- Keep `just start`, `just test` and `just build` wired to actual project commands;
  replace blocked template recipes while implementing the application. Never
  claim tests pass because an empty discovery command returned success.
- `just fmt-check` checks formatting without writing. Use nixfmt, Ruff, rustfmt,
  Biome for web source, Prettier for documents/Astro, shfmt for shell and Just's
  formatter; keep file ownership separate and extend it for actual languages.
- For new dependencies and deliberate upgrades, verify current stable releases:
  prefer the latest supported LTS runtime, otherwise the latest stable version.
  Pin exact direct package versions and commit lockfiles; never leave `latest`
  or floating ranges as the reproducibility mechanism. Preserve reviewed pins
  during unrelated edits. Record compatibility reasons for older versions.
- Prefer TypeScript 7 or newer stable when compatible; verify framework/plugin
  support. Preview, nightly and prerelease channels require explicit selection.

## shell-away

- `src/` holds the code that runs on the client (`shell-away.sh`) and on the
  target (`bootstrap.sh`, `init.sh`, `remote-flake.nix`); `src/aliases.nix` and
  `src/prompt.nix` are the generated shell assets. `package.nix` bundles them.
- Only generated, non-secret assets may enter the remote payload. Never copy
  local history, credentials or environment into it.
- `scripts/test` runs every transport against local fixtures and never opens a
  real SSH connection. Keep it that way.
