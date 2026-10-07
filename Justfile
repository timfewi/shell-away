set shell := ["bash", ".just-shell"]
set positional-arguments

# Show available recipes.
default:
    @just --list

# Run declared fast checks; accepts project-check options such as --json.
lint *args:
    @project-check fast "$@"

# Run the declared full gate; accepts project-check options such as --json.
verify *args:
    @project-check full "$@"

# Format supported repository files using pinned tools.
fmt:
    @python3 .project-format.py write default

# Check formatting without changing files.
fmt-check:
    @python3 .project-format.py check default

# Alias for the declared fast gate.
check *args:
    @project-check fast "$@"

# Open a temporary shell on HOST, for example `just start user@host`.
start *args:
    @nix run .#shell-away -- "$@"

# Run the transport, shell and cleanup tests against local fixtures.
test:
    @bash scripts/test

# Build the package.
build:
    @nix build .#shell-away
