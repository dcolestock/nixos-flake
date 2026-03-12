# Project Analysis: NixOS Configuration & The Dendritic Pattern

This document outlines the current state of the NixOS configuration and provides a deep dive into the **Dendritic Pattern**, followed by a roadmap for transitioning this project to that architecture.

## 1. Current Project Architecture

The current configuration follows a traditional, semi-modular structure common in many NixOS setups.

### Entry Points
*   **`flake.nix`**: The central entry point. It defines:
    *   **Inputs**: Standard dependencies (`nixpkgs`, `home-manager`, `agenix`) and specialized overlays (`neovim-nightly`, `deferred-apps`).
    *   **Outputs**:
        *   `nixosConfigurations.nixos`: The primary system configuration.
        *   `homeConfigurations."dcoles1"`: A standalone Home Manager configuration for work environments.
    *   **Variables**: Uses `specialArgs` and `extraSpecialArgs` to pass `inputs` and `username` down to sub-modules.

### System Configuration
*   **`configuration.nix`**: The main NixOS module. It imports several files in the root directory:
    *   `hardware-configuration.nix`: Auto-generated hardware settings.
    *   `packages.nix`: A list of system-wide packages.
    *   Feature-specific files: `bluetooth.nix`, `tailscale.nix`, `kdefix.nix`.
*   **Secrets**: Managed via `agenix` with files in the `secrets/` directory.

### Home Manager Configuration
*   **`home/default.nix`**: The entry point for the "dan" user's home configuration.
*   **Module structure**: Features are split into individual files (e.g., `neovim.nix`, `tmux.nix`, `firefox.nix`) and imported manually in `home/default.nix`.
*   **Scripts**: Custom scripts are stored in `home/scripts/` and linked via Home Manager.

### Observed Patterns
*   **Manual Imports**: Modules are explicitly listed in `imports = [ ... ]` blocks.
*   **Separation of Concerns**: Logic is split by "class" (System vs. User) rather than by "feature". For example, `neovim` configuration is entirely within the `home/` directory, while `bluetooth` is in the root.
*   **Direct Assignment**: Most configurations are done via direct assignment to existing options (e.g., `programs.neovim.enable = true`) rather than defining custom feature flags.

---

## 2. The Dendritic Pattern

The **Dendritic Pattern**, popularized by Shahar "Dawn" Or (`mightyiam`), is a Nix configuration architecture that treats every file as a top-level module and organizes logic by **feature** rather than system class.

### Core Principles
1.  **Every File is a Module**: Every `.nix` file (except `flake.nix`) is a standard Nixpkgs module.
2.  **Feature-Centricity**: Instead of `system/` and `user/` directories, logic is grouped by feature. A `modules/neovim.nix` file would handle:
    *   System-wide dependencies (LSPs, compilers).
    *   Home Manager configuration (init.lua, plugins).
    *   System-wide settings (default editor, environment variables).
3.  **Top-Level Evaluation**: Typically uses a framework like `flake-parts` to evaluate modules at a higher level. This allows modules to be "class-agnostic"—the same module code can contribute to NixOS, Home Manager, or even `nix-darwin` simultaneously.
4.  **Auto-Discovery (Recursive Imports)**: Employs tools like `import-tree` or simple recursive Nix functions to automatically import every file in a `modules/` directory. This removes the "import boilerplate" and allows files to be moved or renamed without breaking the flake.
5.  **Option-Driven Interface**: Features are exported as custom options (e.g., `features.neovim.enable = true`). This provides a clean API for host configurations to enable or disable entire features without touching the implementation details.

### Implementation Goals
*   **Locality of Behavior**: All code related to "Neovim" or "Gaming" is in one place.
*   **Scalability**: Adding a new host or user becomes a matter of enabling the desired feature flags.
*   **Reduced Friction**: No more updating multiple `default.nix` files when adding a new configuration file.

---

## 3. Gap Analysis

| Feature | Current State | Dendritic Goal |
| :--- | :--- | :--- |
| **Organization** | Class-based (`configuration.nix` vs `home/`) | Feature-based (`modules/neovim.nix`) |
| **Imports** | Manual and explicit | Recursive and automatic |
| **Module Logic** | Direct assignment to global options | Encapsulated in custom feature options |
| **Cross-Class logic** | Fragmented (system and home are separate) | Unified (single module handles both) |
| **Framework** | Standard Flake | `flake-parts` (recommended) |

---

## 4. Proposed Transition Strategy

### Phase 1: Infrastructure
1.  **Introduce `flake-parts`**: Refactor `flake.nix` to use the `flake-parts` framework. This provides the structure needed for top-level module aggregation.
2.  **Define Top-Level Options**: Create a schema for `features` and `hosts`.

### Phase 2: Reorganization
1.  **Create `modules/` directory**: This will be the new home for all feature-based logic.
2.  **Implement Recursive Importer**: Add logic to `flake.nix` to automatically import everything in `modules/`.

### Phase 3: Module Migration (Incremental)
1.  **Consolidate Features**: Take a feature (e.g., `neovim`) and move its logic from `home/neovim.nix` and any system-level neovim settings into `modules/neovim.nix`.
2.  **Wrap in Options**: Update the module to use the `config.features.<name>.enable` pattern.
3.  **Handle Cross-Class Logic**: Use the `home-manager` module within the feature module to inject user-specific settings.

### Phase 4: Host Refactoring
1.  **Define the Host**: Update `nixosConfigurations.nixos` to be a minimal entry point that simply enables the desired features.
2.  **Cleanup**: Remove the old root-level `.nix` files and the `home/` directory once migration is complete.

---

## 5. Summary of Findings

The current project is well-structured for a traditional setup but will benefit significantly from the Dendritic Pattern as it grows. The pattern will reduce the cognitive load of managing system vs. user splits and make the configuration more "pluggable." The transition can be performed incrementally without breaking the system at each step.
