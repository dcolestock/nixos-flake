# Dendritic Pattern Transition Plan (Strict Two-Stage)

This plan transitions the configuration to the **Dendritic Pattern**. It prioritizes structural integrity and closure verification before any functional reorganization.

## Phase 1: Structural Wrap & Verify

In this stage, we move all files to `./modules`, wrap them as `flake-parts` modules, and adopt the mandatory `flake.nix` output. **Logic must not be moved between files yet.**

### 1.1 `flake.nix` Redistribution
The current `flake.nix` will be stripped. Below is the mapping of where every line of the current `flake.nix` logic is moved:

| Logic in Current `flake.nix` | New Location | Dendritic Pattern Implementation |
| :--- | :--- | :--- |
| `description`, `inputs` | `flake.nix` | Remains in `flake.nix` |
| `system`, `username_*` | `modules/core/variables.nix` | Defined as `let` bindings or `_module.args` |
| `pkgs` (with `allowUnfree`) | `modules/core/pkgs.nix` | Handled via `perSystem` or `nixpkgs` module |
| `pkgs-master` | `modules/core/pkgs.nix` | Passed as `_module.args` to be available globally |
| `nixosConfigurations.nixos` | `modules/hosts.nix` | Defined in `flake.nixosConfigurations` attribute |
| `homeConfigurations.*` | `modules/hosts.nix` | Defined in `flake.homeConfigurations` attribute |
| `formatter` | `modules/core/formatter.nix` | Defined in `perSystem.formatter` |

**Updated `flake.nix` Output:**
```nix
outputs =
  inputs:
  inputs.flake-parts.lib.mkFlake { inherit inputs; }
    (inputs.import-tree ./modules);
```

### 1.2 Module Wrapping (System)
Move each system file to `modules/` and wrap its content.
*   **Move**: `configuration.nix` -> `modules/nixos-base.nix`
*   **Wrap Pattern**:
    ```nix
    { inputs, ... }: {
      flake.modules.nixos.base = { pkgs, ... }: {
        # Original content of configuration.nix (minus imports)
      };
    }
    ```
*   **Repeat** for: `hardware-configuration.nix`, `bluetooth.nix`, `packages.nix`, `tailscale.nix`, `kdefix.nix`.
*   **Remove all `imports = [ ... ]` blocks.**

### 1.3 Module Wrapping (User)
Move each home-manager file to `modules/` and wrap it.
*   **Move**: `home/home.nix` -> `modules/home-base.nix`
*   **Wrap Pattern**:
    ```nix
    { inputs, ... }: {
      flake.modules.homeManager.base = { pkgs, ... }: {
        # Original content of home.nix (minus imports)
      };
    }
    ```
*   **Repeat** for: `neovim.nix`, `bash.nix`, `firefox.nix`, etc.

### 1.4 The "Glue" Modules
Create these to house the redistributed `flake.nix` logic:

**`modules/hosts.nix`**:
```nix
{ inputs, self, ... }: {
  flake = {
    nixosConfigurations.nixos = inputs.nixpkgs.lib.nixosSystem {
      specialArgs = { inherit inputs; };
      modules = [
        self.modules.nixos.base
        self.modules.nixos.hardware
        # ... other nixos modules ...
        inputs.home-manager.nixosModules.home-manager
        {
          home-manager.users.dan = {
            imports = [
              self.modules.homeManager.base
              self.modules.homeManager.neovim
              # ... other homeManager modules ...
            ];
          };
        }
      ];
    };
    homeConfigurations."dcoles1" = inputs.home-manager.lib.homeManagerConfiguration {
      # Logic from current flake.nix homeConfigurations
    };
  };
}
```

**`modules/core/pkgs.nix`**:
```nix
{ inputs, ... }: {
  perSystem = { system, ... }: {
    _module.args.pkgs = import inputs.nixpkgs {
      inherit system;
      config.allowUnfree = true;
    };
    _module.args.pkgs-master = import inputs.nixpkgs-master {
      inherit system;
      config.allowUnfree = true;
    };
  };
}
```

### 1.5 Verification
1.  **Build**: `nixos-rebuild build --flake .#nixos`.
2.  **Closure Check**: Ensure the resulting closure is identical to the original (excluding necessary metadata/path changes).
3.  **Success Criterion**: The system is functional with **zero manual imports** in the module tree.

---

## Phase 2: Dendritic Reorganization (The Final Aspect Tree)

In this stage, we reorganize the "wrapped" modules from Phase 1 into a clean, aspect-oriented tree. Every file in `modules/` is now a `flake-parts` module that populates the `flake.modules` namespace.

### 2.1 Final File Tree & Aspect Mapping

Below is the complete, non-subjective file tree and the aspects they define.

```text
modules/
├── core/
│   ├── base.nix          # nixos.base, homeManager.base (StateVersion, i18n, users)
│   ├── packages.nix      # nixos.packages, homeManager.packages (Shared system/user pkgs)
│   ├── pkgs.nix          # Global package overrides (pkgs-master, allowUnfree)
│   └── variables.nix     # Global bindings (username_home, username_work)
├── hardware/
│   ├── base.nix          # nixos.hardware-base (hardware-configuration.nix)
│   ├── bluetooth.nix     # nixos.bluetooth
│   └── qmk.nix           # nixos.qmk
├── desktop/
│   ├── plasma.nix        # nixos.plasma, homeManager.plasma (kdefix.nix + dconf.nix)
│   └── fonts.nix         # nixos.fonts
├── network/
│   ├── tailscale.nix     # nixos.tailscale
│   └── base.nix          # nixos.networking (HostName, NetworkManager)
├── dev/
│   ├── neovim.nix        # nixos.neovim, homeManager.neovim (unifies LSPs and init.lua)
│   ├── python.nix        # homeManager.python (unifies python.nix + ruff)
│   └── rust.nix          # homeManager.rust (rustup, etc)
├── shell/
│   ├── bash.nix          # homeManager.bash
│   ├── fish.nix          # homeManager.fish
│   ├── tmux.nix          # homeManager.tmux
│   └── starship.nix      # homeManager.starship
├── apps/
│   ├── firefox.nix       # homeManager.firefox
│   ├── discord.nix       # homeManager.discord
│   └── distrobox.nix     # homeManager.distrobox
├── hosts.nix             # flake.nixosConfigurations, flake.homeConfigurations
└── formatter.nix         # perSystem.formatter
```

### 2.2 Aspect Consolidation Table

| New Aspect File | Class(es) Defined | Logic Consolidated From... |
| :--- | :--- | :--- |
| `core/base.nix` | `nixos`, `homeManager` | `configuration.nix` + `home/home.nix` |
| `desktop/plasma.nix`| `nixos`, `homeManager` | `kdefix.nix` + `home/dconf.nix` |
| `dev/neovim.nix` | `nixos`, `homeManager` | `home/neovim.nix` + `config/neovim.lua` |
| `network/tailscale.nix`| `nixos` | `tailscale.nix` |
| `hardware/base.nix` | `nixos` | `hardware-configuration.nix` |
| `core/packages.nix` | `nixos`, `homeManager` | `packages.nix` + `sharedprograms.nix` |

### 2.3 Implementation Detail: Shared Values
Each aspect file uses `let` bindings or `config` to communicate values across classes within the same file.

**Example (`modules/desktop/plasma.nix`):**
```nix
{ inputs, ... }: {
  flake.modules.nixos.plasma = { pkgs, ... }: {
    services.desktopManager.plasma6.enable = true;
    # ... logic from kdefix.nix ...
  };

  flake.modules.homeManager.plasma = { pkgs, ... }: {
    # ... logic from dconf.nix ...
  };
}
```

### 2.4 Simplified `hosts.nix`
The final `hosts.nix` becomes a declarative list of the aspects defined above.

```nix
{ self, inputs, ... }: {
  flake.nixosConfigurations.nixos = inputs.nixpkgs.lib.nixosSystem {
    specialArgs = { inherit inputs; };
    modules = [
      self.modules.nixos.base
      self.modules.nixos.hardware-base
      self.modules.nixos.plasma
      self.modules.nixos.neovim
      # ... etc ...
    ];
  };
}
```
