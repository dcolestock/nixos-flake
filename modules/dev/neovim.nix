{inputs, ...}: {
  flake.modules.homeManager.neovim = {
    pkgs,
    config,
    ...
  }: let
    vim-slime-cells = pkgs.vimUtils.buildVimPlugin {
      name = "vim-slime-cells";
      src = inputs.vim-slime-cells;
    };
    nvim-fundo = pkgs.vimUtils.buildVimPlugin {
      name = "fundo";
      dependencies = [pkgs.vimPlugins.promise-async];
      src = inputs.nvim-fundo;
    };
    recover-vim = pkgs.vimUtils.buildVimPlugin {
      name = "recover";
      src = inputs.recover-vim;
    };
    showkeys = pkgs.vimUtils.buildVimPlugin {
      name = "showkeys";
      src = inputs.showkeys;
    };
    mini = pkgs.vimUtils.buildVimPlugin {
      name = "mini.nvim";
      src = inputs.mini;
    };
  in {
    nix.nixPath = ["nixpkgs=${inputs.nixpkgs}"];
    programs.neovim = {
      enable = true;
      viAlias = true;
      vimAlias = true;
      withPython3 = true;
      package = inputs.neovim-nightly-overlay.packages.${pkgs.system}.default;
      extraPython3Packages = pyPkgs: with pyPkgs; [pynvim];
      extraPackages = with pkgs; [jq stylua ruff alejandra codespell sqruff shfmt lua-language-server nixd marksman basedpyright bash-language-server sql-formatter markdownlint-cli nodePackages.prettier prettierd rustfmt lazygit binutils gcc_multi];
      plugins = with pkgs.vimPlugins; [
        {
          plugin = mini;
          type = "lua";
          config = ''
            require("mini.ai").setup({})
            require("mini.animate").setup({})
            require("mini.basics").setup({})
            require("mini.bracketed").setup({})
            require("mini.cursorword").setup({})
            require("mini.icons").setup({})
            require("mini.indentscope").setup({})
            require("mini.pairs").setup({})
            require("mini.surround").setup({})
            require("mini.diff").setup({ view = { style = "sign" } })
            local notify = require("mini.notify")
            notify.setup({})
            vim.notify = notify.make_notify()
            local miniclue = require("mini.clue")
            miniclue.setup({
              triggers = {
                { mode = "n", keys = "<Leader>" }, { mode = "x", keys = "<Leader>" },
                { mode = "n", keys = "," }, { mode = "x", keys = "," },
                { mode = "n", keys = "]" }, { mode = "n", keys = "[" },
                { mode = "i", keys = "<C-x>" }, { mode = "n", keys = "g" },
                { mode = "x", keys = "g" }, { mode = "n", keys = "'" },
                { mode = "n", keys = "`" }, { mode = "x", keys = "'" },
                { mode = "x", keys = "`" }, { mode = "n", keys = '"' },
                { mode = "x", keys = '"' }, { mode = "i", keys = "<C-r>" },
                { mode = "c", keys = "<C-r>" }, { mode = "n", keys = "<C-w>" },
                { mode = "n", keys = "z" }, { mode = "x", keys = "z" },
              },
              clues = {
                miniclue.gen_clues.builtin_completion(), miniclue.gen_clues.g(),
                miniclue.gen_clues.marks(), miniclue.gen_clues.registers(),
                miniclue.gen_clues.windows(), miniclue.gen_clues.z(),
              },
            })
          '';
        }
        vim-tmux-navigator
        {
          plugin = vim-slime;
          type = "lua";
          optional = true;
          config = ''
            vim.api.nvim_create_autocmd("FileType", {
              desc = "Activate vim-slime for python",
              pattern = "python",
              once = true,
              callback = function()
                vim.g.slime_target = "tmux"
                vim.g.slime_cell_delimiter = "^#\\s*%%"
                vim.g.slime_default_config = { ["socket_name"] = "default", ["target_pane"] = "{bottom-right}" }
                vim.g.slime_dont_ask_default = 1
                vim.g.slime_bracketed_paste = 1
                vim.g.slime_no_mappings = 1
                vim.g.slime_python_ipython = 0
                function StartIPython()
                  vim.fn.system("tmux if -F '#{==:#{window_panes},1}' 'split-window -hdZ eval \"$(direnv export bash)\"; ipython'")
                end
                function UnhideSlimeAndClear()
                  local target_pane = vim.fn.shellescape(vim.g.slime_default_config["target_pane"])
                  vim.fn.system("tmux if -F '#{window_zoomed_flag}' 'resize-pane -Z'")
                  vim.fn.system("tmux send -t " .. target_pane .. " C-u")
                  StartIPython()
                end
                vim.cmd([[function! SlimeOverride_EscapeText_python(text)
                            lua UnhideSlimeAndClear()
                            if slime#config#resolve("python_ipython") && len(split(a:text,"\n")) > 1
                              return ["%cpaste -q\n", slime#config#resolve("dispatch_ipython_pause"), a:text, "--\n"]
                            else
                              let empty_lines_pat = '\(^\|\n\)\zs\(\s*\n\+\)\+'
                              let no_empty_lines = substitute(a:text, empty_lines_pat, "", "g")
                              let dedent_pat = '\(^\|\n\)\zs'.matchstr(no_empty_lines, '^\s*')
                              let dedented_lines = substitute(no_empty_lines, dedent_pat, "", "g")
                              let except_pat = '\(elif\|else\|except\|finally\)\@!'
                              let add_eol_pat = '\n\s[^\n]\+\n\zs\ze\('.except_pat.'\S\|$\)'
                              return substitute(dedented_lines, add_eol_pat, "\n", "g")
                            end
                          endfunction]])
                function Send_Ctrl_C()
                  local target_pane = vim.fn.shellescape(vim.g.slime_default_config["target_pane"])
                  vim.fn.system("tmux send -t " .. target_pane .. " C-c")
                end
                vim.keymap.set("n", ",r", "<Plug>SlimeCellsSend", { desc = "[Slime] Send" })
                vim.keymap.set("v", ",r", "<Plug>SlimeRegionSend", { desc = "[Slime] Send" })
                vim.keymap.set("n", ",R", "<Plug>SlimeCellsSendAndGoToNext", { desc = "[Slime] Send+Next" })
                vim.keymap.set("n", ",c", Send_Ctrl_C, { desc = "[Slime] Ctrl+C" })
                vim.keymap.set("n", ",l", StartIPython, { desc = "[Slime] Start IPython" })
                vim.keymap.set("n", ",j", "<Plug>SlimeCellsNext", { desc = "[Slime] Next Cell" })
                vim.keymap.set("n", ",k", "<Plug>SlimeCellsPrev", { desc = "[Slime] Prev Cell" })
                vim.cmd.packadd("vim-slime")
                vim.cmd.packadd("vimplugin-vim-slime-cells")
                StartIPython()
              end,
            })
          '';
        }
        {
          plugin = vim-slime-cells;
          optional = true;
        }
        vim-sleuth
        {
          plugin = nvim-lastplace;
          type = "lua";
          config = "require(\"nvim-lastplace\").setup({})";
        }
        {
          plugin = auto-save-nvim;
          type = "lua";
          config = "require(\"auto-save\").setup({})";
        }
        {
          plugin = nvim-fundo;
          type = "lua";
          config = "require(\"fundo\").setup({})\nvim.o.undofile = true";
        }
        plenary-nvim
        nvim-snippy
        cmp-snippy
        {
          plugin = nvim-lspconfig;
          type = "lua";
          config = ''
            local capabilities = require("cmp_nvim_lsp").default_capabilities()
            local lspconfig = require("lspconfig")
            lspconfig.bashls.setup({ capabilities = capabilities })
            lspconfig.lua_ls.setup({
              capabilities = capabilities,
              settings = { Lua = { runtime = { version = "LuaJIT" }, diagnostics = { globals = { "vim" } }, workspace = { library = vim.api.nvim_get_runtime_file("", true), checkThirdParty = false }, telemetry = { enable = false } } }
            })
            lspconfig.basedpyright.setup({
              capabilities = capabilities,
              settings = { basedpyright = { disableOrganizeImports = true, typeCheckingMode = "off" }, python = { analysis = { ignore = { "*" } } } }
            })
            lspconfig.ruff.setup({ capabilities = capabilities })
            lspconfig.nixd.setup({
              capabilities = capabilities,
              cmd = { "nixd" },
              settings = { nixd = { nixpkgs = { expr = "import <nixpkgs> { }" }, formatting = { command = { "alejandra" } } } }
            })
            lspconfig.marksman.setup({ capabilities = capabilities })
            lspconfig.rust_analyzer.setup({ capabilities = capabilities })
            local diag_config1 = {
              virtual_text = { severity = { max = vim.diagnostic.severity.WARN } },
              virtual_lines = { severity = { min = vim.diagnostic.severity.ERROR } }
            }
            local diag_config2 = { virtual_text = true, virtual_lines = false }
            vim.diagnostic.config(diag_config1)
            local diag_config_basic = false
            vim.keymap.set("n", "gK", function()
              diag_config_basic = not diag_config_basic
              if diag_config_basic then vim.diagnostic.config(diag_config2) else vim.diagnostic.config(diag_config1) end
            end, { desc = "Toggle diagnostic virtual_lines" })
          '';
        }
        {
          plugin = conform-nvim;
          type = "lua";
          config = ''
            require("conform").setup({
              formatters_by_ft = {
                lua = { "stylua" }, python = { "ruff_fix", "ruff_format" },
                javascript = { "prettierd", "prettier", stop_after_first = true },
                rust = { "rustfmt", lsp_format = "fallback" }, nix = { "alejandra" },
                sql = { "sqruff" }, json = { "jq" }, sh = { "shfmt" },
                ["*"] = { "injected", "codespell" }, ["_"] = { "trim_whitespace" },
              },
              formatters = {
                stylua = { prepend_args = { "--indent-type", "Spaces", "--indent-width", "2" } },
                shfmt = { prepend_args = { "-i", "2" } },
              },
            })
            vim.api.nvim_create_user_command("FormatDisable", function(args)
              if args.bang then vim.b.disable_autoformat = true else vim.g.disable_autoformat = true end
            end, { desc = "Disable autoformat-on-save", bang = true })
            vim.api.nvim_create_user_command("FormatEnable", function()
              vim.b.disable_autoformat = false
              vim.g.disable_autoformat = false
            end, { desc = "Re-enable autoformat-on-save" })
            vim.o.formatexpr = "v:lua.require'conform'.formatexpr()"
          '';
        }
        {
          plugin = nvim-cmp;
          type = "lua";
          config = ''
            local cmp = require("cmp")
            local lspkind = require("lspkind")
            cmp.setup({
              snippet = { expand = function(args) require("luasnip").lsp_expand(args.body) end },
              mapping = {
                ["<C-p>"] = cmp.mapping.select_prev_item(), ["<C-n>"] = cmp.mapping.select_next_item(),
                ["<C-space>"] = cmp.mapping.complete(), ["<C-e>"] = cmp.mapping.close(),
                ["<tab>"] = cmp.mapping.confirm({ select = true }),
              },
              formatting = { format = lspkind.cmp_format({ mode = "symbol_text", maxwidth = 50, show_labelDetails = true }) },
              sources = cmp.config.sources({ { name = "nvim_lsp" }, { name = "luasnip" } }, { { name = "buffer" }, { name = "path" }, { name = "treesitter" } }),
            })
            cmp.setup.cmdline({ "/", "?" }, { mapping = cmp.mapping.preset.cmdline(), sources = { { name = "buffer" } } })
          '';
        }
        cmp-nvim-lsp
        lspkind-nvim
        cmp-buffer
        cmp-path
        {
          plugin = cmp-cmdline;
          type = "lua";
          config = "local cmp = require(\"cmp\")\ncmp.setup.cmdline(\":\", { mapping = cmp.mapping.preset.cmdline(), sources = cmp.config.sources({ { name = \"path\" } }, { { name = \"cmdline\" } }) })";
        }
        cmp-treesitter
        luasnip
        cmp_luasnip
        vim-nix
        nvim-treesitter.withAllGrammars
        tokyonight-nvim
        sonokai
        gruvbox
        onedark-nvim
        papercolor-theme
        {
          plugin = lualine-nvim;
          type = "lua";
          config = "require(\"lualine\").setup({ options = { theme = \"onedark\" } })";
        }
        {
          plugin = bufferline-nvim;
          type = "lua";
          config = "require(\"bufferline\").setup({})\nvim.keymap.set(\"n\", \"<Leader>b\", \"<Cmd>BufferLineCycleNext<CR>\", { desc = \"Buffer Next\" })\nvim.keymap.set(\"n\", \"<Leader>B\", \"<Cmd>BufferLineCyclePrev<CR>\", { desc = \"Buffer Prev\" })";
        }
        {
          plugin = lazygit-nvim;
          type = "lua";
          config = "vim.keymap.set(\"n\", \"<Leader>gg\", \"<Cmd>LazyGit<CR>\", { desc = \"LazyGit\" })";
        }
        {
          plugin = telescope-nvim;
          type = "lua";
          config = ''
            require("telescope").setup({ extensions = { file_browser = { theme = "ivy", hijack_netrw = true } } })
            require("telescope").load_extension("fzf")
            require("telescope").load_extension("ui-select")
            vim.keymap.set("n", "<Leader>f", "<Nop>", { desc = "Telescope" })
            vim.keymap.set("n", "<Leader>fF", function() require("telescope.builtin").current_buffer_fuzzy_find(require("telescope.themes").get_dropdown({ winblend = 10, previewer = false })) end, { desc = "Fuzzy Search Current Buffer" })
            vim.keymap.set("n", "<Leader>ft", "<Cmd>Telescope<CR>", { desc = "Telescope" })
            vim.keymap.set("n", "<Leader>ff", "<Cmd>Telescope find_files<CR>", { desc = "Find File" })
            vim.keymap.set("n", "<Leader>fr", "<Cmd>Telescope oldfiles<CR>", { desc = "Open Recent File" })
            vim.keymap.set("n", "<Leader>fg", "<Cmd>Telescope live_grep<CR>", { desc = "Live Grep" })
            vim.keymap.set("n", "<Leader>fG", "<Cmd>Telescope git_files<CR>", { desc = "Git Files" })
            vim.keymap.set("n", "<Leader>fb", "<Cmd>Telescope buffers<CR>", { desc = "Buffers" })
            vim.keymap.set("n", "<Leader>fh", "<Cmd>Telescope help_tags<CR>", { desc = "Help" })
            vim.keymap.set("n", "<Leader>fs", "<Cmd>Telescope grep_string<CR>", { desc = "Current Word" })
            vim.keymap.set("n", "<Leader>fd", "<Cmd>Telescope diagnostics<CR>", { desc = "Diagnostics" })
            vim.keymap.set("n", "<Leader>fk", "<Cmd>Telescope keymaps<CR>", { desc = "Keymaps" })
            vim.keymap.set("n", "<Leader>fc", "<Cmd>lua require('telescope.builtin').colorscheme({enable_preview = true})<CR>", { desc = "Color Scheme" })
          '';
        }
        telescope-fzf-native-nvim
        telescope-ui-select-nvim
        {
          plugin = telescope-file-browser-nvim;
          type = "lua";
          config = "require(\"telescope\").load_extension(\"file_browser\")\nvim.keymap.set(\"n\", \"<Leader>fn\", \"<Cmd>Telescope file_browser path=%:p:h<CR>\", { desc = \"Browser\" })\nvim.keymap.set(\"n\", \"<Leader>fN\", \"<Cmd>Telescope file_browser<CR>\", { desc = \"Browser CWD\" })";
        }
        {
          plugin = alpha-nvim;
          type = "lua";
          config = "require(\"alpha\").setup(require(\"alpha.themes.startify\").config)\nvim.keymap.set(\"n\", \"<Leader>;\", \"<Cmd>Alpha<CR>\", { desc = \"Dashboard\" })";
        }
        {
          plugin = gitsigns-nvim;
          type = "lua";
          config = ''
            require("gitsigns").setup({
              on_attach = function(bufnr)
                local gitsigns = require("gitsigns")
                local function map(mode, l, r, desc) vim.keymap.set(mode, l, r, { buffer = bufnr, desc = desc }) end
                map("n", "]c", function() if vim.wo.diff then vim.cmd.normal({ "]c", bang = true }) else gitsigns.nav_hunk("next") end end, "Next Change")
                map("n", "[c", function() if vim.wo.diff then vim.cmd.normal({ "[c", bang = true }) else gitsigns.nav_hunk("prev") end end, "Prev Change")
                map("n", "<leader>hs", gitsigns.stage_hunk, "Stage Hunk")
                map("n", "<leader>hr", gitsigns.reset_hunk, "Reset Hunk")
                map("n", "<leader>hS", gitsigns.stage_buffer, "Stage Buffer")
                map("n", "<leader>hu", gitsigns.undo_stage_hunk, "Undo Stage Hunk")
                map("n", "<leader>hR", gitsigns.reset_buffer, "Reset Buffer")
                map("n", "<leader>hp", gitsigns.preview_hunk, "Preview Hunk")
                map("n", "<leader>hb", function() gitsigns.blame_line({ full = true }) end, "Blame Line")
                map("n", "<leader>hd", gitsigns.diffthis, "Diff This")
                map("n", "<leader>hD", function() gitsigns.diffthis("~") end, "Diff This")
                map("n", "<leader>tb", gitsigns.toggle_current_line_blame, "Toggle Blame Line")
                map("n", "<leader>td", gitsigns.toggle_deleted, "Toggle Deleted")
              end
            })
          '';
        }
        {
          plugin = neogit;
          type = "lua";
          config = "require(\"neogit\").setup({})";
        }
        {
          plugin = showkeys;
          type = "lua";
          config = "require(\"showkeys\").setup({ maxkeys = 7, show_count = true })\nvim.api.nvim_create_autocmd(\"VimEnter\", { callback = function() vim.cmd(\"ShowkeysToggle\") end })";
        }
        recover-vim
      ];
      initLua = builtins.readFile ../assets/config/neovim.lua;
    };
    xdg.configFile = {
      "nvim/queries".source = config.lib.file.mkOutOfStoreSymlink ../assets/nvimqueries;
      "nvim/sql_formatter.json".text = "{ \"language\": \"sqlite\", \"keywordCase\": \"upper\" }";
    };
    home.sessionPath = ["$HOME/.local/bin"];
  };
}
