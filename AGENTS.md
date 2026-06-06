# NixOS Flake — AGENTS.md

## Architecture

- **Nix flake** (flake-parts + [import-tree](https://github.com/vic/import-tree)): every `.nix` file under `modules/` is auto-loaded.
- **Dendritic pattern** — modules register into namespaces: `flake.modules.nixos.*`, `flake.modules.homeManager.*`, `flake.modules.shared.*`. See `.agents/skills/dendritic-nix/SKILL.md`.
- No `specialArgs` — cross-module values use `config.shared` (defined in `modules/core/options.nix`).
- Two users: `dan` (NixOS + home-manager, host `nixos`), `dcoles1` (home-manager only, work machine).

## Module layout

| Path | Namespace |
|------|-----------|
| `modules/core/*.nix` | `flake.modules.{nixos,homeManager,shared}.*` |
| `modules/shell/*.nix` | `flake.modules.homeManager.{bash,fish,tmux,...}` |
| `modules/apps/*.nix` | `flake.modules.homeManager.{distrobox,firefox}` |
| `modules/dev/*.nix` | `flake.modules.homeManager.{neovim,minimax,python}` |
| `modules/desktop/plasma.nix` | `flake.modules.{nixos,homeManager}.plasma` |
| `modules/hardware/*.nix` | `flake.modules.nixos.{base,bluetooth,qmk}` |
| `modules/shell/shared.nix` | `flake.modules.shared.shell` (aliases, envVars, flakePath) |
| `modules/network/tailscale.nix` | _not yet registered in hosts.nix_ |
| `modules/core/pkgs.nix` | `perSystem` block (pkgs setup) |
| `modules/core/packages.nix` | `flake.modules.{nixos,homeManager}.packages` |
| `modules/core/work.nix` | `flake.modules.homeManager.work` (for dcoles1) |

## Developer commands

| Command | What it does |
|---------|-------------|
| `nix flake update` | Update lockfile |
| `nh os switch` | Rebuild + switch generation (requires clean git) |
| `nh os test` | Test without switching |
| `switch` | Clean-git check → `nh os switch` |
| `switch-trace` | Same + `--show-trace --option eval-cache false` |
| `testnix` | `nh os test -- --show-trace --option eval-cache false` |
| `update` | `nix flake update` → pre-commit → commit → `nh os switch` |

All custom scripts are defined as `writeShellApplication` in `modules/shell/bash.nix`. They require a clean working tree.

## Formatting & linting

- **alejandra** — Nix formatter (declared in `modules/formatter.nix`, `.pre-commit-config.yaml`)
- Pre-commit hooks: `end-of-file-fixer`, `check-added-large-files`, `trailing-whitespace`, `alejandra-system`
- Python: `ruff` (line-length 100, py312, select ALL with excludes, configured in `modules/core/packages.nix`)

## LSP

- `nixd` configured in `opencode.json` and in neovim's nixd setup (alejandra as formatter)
- Neovim LSPs: basedpyright (Python), ruff, lua_ls, marksman, bashls, rust_analyzer, nixd

## Key conventions

- Module name = filename without `.nix` (e.g., `shell/fish.nix` → `flake.modules.homeManager.fish`)
- `config.shared.inputs` gives modules access to flake inputs
- `config.shared.pkgsMaster` = `nixpkgs-master` packages
- Assets live in `modules/assets/` (config files, scripts, nvim queries)
- `minimax` is a separate neovim config accessible via `NVIM_APPNAME=minimax nvim`
- SSH port: 33221
- `stateVersion`: NixOS 23.05, home dan 23.05, home dcoles1 23.11
- `result` symlink is gitignored; `flake.lock` is `-diff` in gitattributes

## Cross-references

- `.agents/skills/dendritic-nix/SKILL.md` — dendritic pattern reference (loadable skill)
- `opencode.json` — nixd LSP config
- `.pre-commit-config.yaml` — pre-commit hooks
- Remote: `git@github.com:dcolestock/nixos-flake.git`
