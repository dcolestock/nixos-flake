{
  pkgs,
  config,
  inputs,
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
  nix.nixPath = ["nixpkgs=${inputs.nixpkgs}"]; # points nixd to the correct version of nixpkgs
  programs.neovim = {
    enable = true;
    viAlias = true;
    vimAlias = true;
    withPython3 = true;
    package = inputs.neovim-nightly-overlay.packages.${pkgs.system}.default;
    extraPython3Packages = pyPkgs:
      with pyPkgs; [
        pynvim
        # jupyter_client

        # rope
        # toml
        # whatthepatch
      ];

    extraPackages = with pkgs; [
      ### Language Servers ###
      jq
      stylua
      ruff
      alejandra
      codespell
      sqruff
      # sqls
      shfmt

      lua-language-server
      # nodejs
      nixd
      # nil
      # rnix-lsp
      # nixfmt
      # statix - Client crashed when opening .nix file
      # deadnix
      # alejandra
      marksman
      # yamllint
      basedpyright
      # pylyzer
      ruff

      bash-language-server
      sql-formatter
      markdownlint-cli
      # nodePackages.jsonlint
      nodePackages.prettier
      prettierd
      # rust-analyzer -- Needs to be part of the cargo toolchain
      rustfmt

      lazygit

      # Toolchain for treesitter compilation
      binutils
      gcc_multi
    ];

    # Included
    # mini.animate
    # mini.basics # How much can I remove thanks to this?
    # mini.bufremove
    # mini.clue # Adjust Window Size
    # mini.cursorword
    # mini.indentscope # Keep animation?
    # mini.surround # Learn these hotkeys and usage

    # Investigate
    # mini.ai # Can it be used for ipython cells?
    # mini.align
    # mini.base16
    # mini.bracketed
    # mini.colors
    # mini.completion
    # mini.doc
    # mini.extra
    # mini.files
    # mini.fuzzy
    # mini.hipatterns
    # mini.hues
    # mini.jump
    # mini.jump2d
    # mini.map
    # mini.misc
    # mini.move
    # mini.operators
    # mini.pairs
    # mini.pick
    # mini.sessions
    # mini.splitjoin
    # mini.starter
    # mini.statusline
    # mini.tabline
    # mini.test
    # mini.visits

    # Exclude
    # mini.trailspace - Only highlights, list-charter + autoremove should be enough #TODO: autoremove on save
    # mini.comment - no longer needed as built in in neovim 0.10

    plugins = with pkgs.vimPlugins; [
      {
        plugin = mini;
        type = "lua";
        config =
          /*
          lua
          */
          ''
            require("mini.ai").setup({})
            require("mini.animate").setup({})
            require("mini.basics").setup({})
            require("mini.bracketed").setup({})
            require("mini.cursorword").setup({})
            require("mini.icons").setup({})
            require("mini.indentscope").setup({})
            require("mini.pairs").setup({})
            require("mini.surround").setup({})

            require("mini.diff").setup({
              view = {
                style = "sign",
              },
            })

            local notify = require("mini.notify")
            notify.setup({})
            vim.notify = notify.make_notify()

            local miniclue = require("mini.clue")
            miniclue.setup({
              triggers = {
                -- Leader triggers
                { mode = "n", keys = "<Leader>" },
                { mode = "x", keys = "<Leader>" },
                { mode = "n", keys = "," },
                { mode = "x", keys = "," },
                { mode = "n", keys = "]" },
                { mode = "n", keys = "[" },

                -- Built-in completion
                { mode = "i", keys = "<C-x>" },

                -- `g` key
                { mode = "n", keys = "g" },
                { mode = "x", keys = "g" },

                -- Marks
                { mode = "n", keys = "'" },
                { mode = "n", keys = "`" },
                { mode = "x", keys = "'" },
                { mode = "x", keys = "`" },

                -- Registers
                { mode = "n", keys = '"' },
                { mode = "x", keys = '"' },
                { mode = "i", keys = "<C-r>" },
                { mode = "c", keys = "<C-r>" },

                -- Window commands
                { mode = "n", keys = "<C-w>" },

                -- `z` key
                { mode = "n", keys = "z" },
                { mode = "x", keys = "z" },
              },

              clues = {
                -- Enhance this by adding descriptions for <Leader> mapping groups
                miniclue.gen_clues.builtin_completion(),
                miniclue.gen_clues.g(),
                miniclue.gen_clues.marks(),
                miniclue.gen_clues.registers(),
                miniclue.gen_clues.windows(),
                miniclue.gen_clues.z(),
              },
            })
          '';
      }

      vim-tmux-navigator

      {
        plugin = vim-slime;
        type = "lua";
        optional = true;
        config =
          /*
          lua
          */
          ''
            vim.api.nvim_create_autocmd("FileType", {
              desc = "Activate vim-slime for python",
              pattern = "python",
              once = true,
              callback = function()
                vim.g.slime_target = "tmux"
                vim.g.slime_cell_delimiter = "^#\\s*%%"
                vim.g.slime_default_config = {
                  ["socket_name"] = "default",
                  ["target_pane"] = "{bottom-right}",
                }
                vim.g.slime_dont_ask_default = 1
                vim.g.slime_bracketed_paste = 1
                vim.g.slime_no_mappings = 1
                vim.g.slime_python_ipython = 0 -- No %cpasted needed if using tmux's bracketed paste

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

                --vim.keymap.set('n', ',aa', UnhideSlimeAndClear, { desc = "[Slime] Scend" })
                --vim.keymap.set('n', '<leader>rv', '<Plug>SlimeConfig', { desc = "[Slime] Config" })
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

      # {
      #   plugin = jupyter-kernel-nvim;
      #   optional = true;
      #   type = "lua";
      #   config = /*lua*/ ''
      #     vim.api.nvim_create_autocmd('FileType', {
      #       desc = 'Activate jupyter-kernel for python',
      #       pattern = 'python',
      #       callback = function()
      #         vim.cmd.packadd('vimplugin-jupyter-kernel-nvim')
      #         require('jupyter-kernel.nvim').setup({})
      #         vim.keymap.set('n', ',a', '<Cmd>JupyterAttach<CR>', { desc = "[Jupyter] Attach" })
      #         vim.keymap.set('n', ',i', '<Cmd>JupyterInspect<CR>', { desc = "[Jupyter] Inspect" })
      #         vim.keymap.set('v', ',r', '<Cmd>JupyterExecute<CR>', { desc = "[Jupyter] Run" })
      #       end,
      #     })
      #   '';
      # }

      # codeium-vim
      vim-sleuth

      {
        plugin = nvim-lastplace;
        type = "lua";
        config =
          /*
          lua
          */
          ''
            require("nvim-lastplace").setup({})
          '';
      }

      {
        plugin = auto-save-nvim;
        type = "lua";
        config =
          /*
          lua
          */
          ''
            require("auto-save").setup({})
          '';
      }

      # Preserve undo history even with external edits
      {
        plugin = nvim-fundo;
        type = "lua";
        config =
          /*
          lua
          */
          ''
            require("fundo").setup({})
            vim.o.undofile = true
          '';
      }

      plenary-nvim
      nvim-snippy
      cmp-snippy

      {
        plugin = nvim-lspconfig;
        type = "lua";
        config =
          /*
          lua
          */
          ''
            local capabilities = require("cmp_nvim_lsp").default_capabilities()
            local lspconfig = require("lspconfig")
            -- Bash --
            lspconfig.bashls.setup({
              capabilities = capabilities,
            })

            -- Lua --
            lspconfig.lua_ls.setup({
              capabilities = capabilities,
              settings = {
                Lua = {
                  runtime = {
                    -- Tell the language server which version of Lua you're using (most likely LuaJIT in the case of Neovim)
                    version = "LuaJIT",
                  },
                  diagnostics = {
                    -- Get the language server to recognize the `vim` global
                    globals = { "vim" },
                  },
                  workspace = {
                    -- Make the server aware of Neovim runtime files
                    library = vim.api.nvim_get_runtime_file("", true),
                    checkThirdParty = false,
                  },
                  -- Do not send telemetry data containing a randomized but unique identifier
                  telemetry = {
                    enable = false,
                  },
                },
              },
            })

            -- lspconfig.sqls.setup{}
            -- Python --
            lspconfig.basedpyright.setup({
              capabilities = capabilities,
              settings = {
                basedpyright = {
                  -- Using Ruff's import organizer
                  disableOrganizeImports = true,
                  typeCheckingMode = "off",
                },
                python = {
                  analysis = {
                    -- Ignore all files for analysis to exclusively use Ruff for linting
                    ignore = { "*" },
                  },
                },
              },
            })

            -- ruff config is in local folders such as ~/.config/ruff
            lspconfig.ruff.setup({
              capabilities = capabilities,
              init_options = {
                settings = {
                  -- Any extra CLI arguments for `ruff` go here.
                  args = {},
                },
              },
            })

            -- Nix --
            -- lspconfig.nil_ls.setup({}) -- nix language server - no format
            -- lspconfig.rnix.setup({})
            lspconfig.nixd.setup({
              capabilities = capabilities,
              cmd = { "nixd" },
              settings = {
                nixd = {
                  nixpkgs = {
                    expr = "import <nixpkgs> { }",
                  },
                  formatting = {
                    command = { "alejandra" }, -- or nixfmt or nixpkgs-fmt
                  },
                  -- options = {
                  --   nixos = {
                  --       expr = '(builtins.getFlake "/PATH/TO/FLAKE").nixosConfigurations.CONFIGNAME.options',
                  --   },
                  --   home_manager = {
                  --       expr = '(builtins.getFlake "/PATH/TO/FLAKE").homeConfigurations.CONFIGNAME.options',
                  --   },
                  -- },
                },
              },
            })

            -- Markdown --
            lspconfig.marksman.setup({
              capabilities = capabilities,
            })

            -- Diagnostic --
            -- lspconfig.diagnosticls.setup{}

            lspconfig.rust_analyzer.setup({
              capabilities = capabilities,
            })
            local diag_config1 = {
              virtual_text = {
                severity = {
                  max = vim.diagnostic.severity.WARN,
                },
              },
              virtual_lines = {
                severity = {
                  min = vim.diagnostic.severity.ERROR,
                },
              },
            }
            local diag_config2 = {
              virtual_text = true,
              virtual_lines = false,
            }
            vim.diagnostic.config(diag_config1)
            local diag_config_basic = false
            vim.keymap.set("n", "gK", function()
              diag_config_basic = not diag_config_basic
              if diag_config_basic then
                vim.diagnostic.config(diag_config2)
              else
                vim.diagnostic.config(diag_config1)
              end
            end, { desc = "Toggle diagnostic virtual_lines" })
          '';
      }

      {
        plugin = conform-nvim;
        type = "lua";
        config =
          /*
          lua
          */
          ''
            require("conform").setup({
              formatters_by_ft = {
                lua = { "stylua" },
                python = { "ruff_fix", "ruff_format" },
                javascript = { "prettierd", "prettier", stop_after_first = true },
                rust = { "rustfmt", lsp_format = "fallback" },
                nix = { "alejandra" },
                sql = { "sqruff" },
                json = { "jq" },
                sh = { "shfmt" },
                ["*"] = { "injected", "codespell" },
                ["_"] = { "trim_whitespace" },
              },
              formatters = {
                stylua = {
                  prepend_args = { "--indent-type", "Spaces", "--indent-width", "2" },
                },
                shfmt = {
                  prepend_args = { "-i", "2" },
                },
              },
              -- log_level = vim.log.levels.TRACE,
              -- format_on_save = function(bufnr)
              --   -- Disable with a global or buffer-local variable
              --   if vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat then
              --     return
              --   end
              --   return { timeout_ms = 500, lsp_fallback = true }
              -- end,
            })
            -- require("conform").formatters.sql_formatter = {
            --   prepend_args = { "--config", vim.fn.expand("~/.config/nvim/sql_formatter.json") },
            -- }
            vim.api.nvim_create_user_command("FormatDisable", function(args)
              if args.bang then
                -- FormatDisable! will disable formatting just for this buffer
                vim.b.disable_autoformat = true
              else
                vim.g.disable_autoformat = true
              end
            end, {
              desc = "Disable autoformat-on-save",
              bang = true,
            })
            vim.api.nvim_create_user_command("FormatEnable", function()
              vim.b.disable_autoformat = false
              vim.g.disable_autoformat = false
            end, {
              desc = "Re-enable autoformat-on-save",
            })
            vim.o.formatexpr = "v:lua.require'conform'.formatexpr()"
          '';
      }

      ### Completion ###
      {
        plugin = nvim-cmp;
        type = "lua";
        config =
          /*
          lua
          */
          ''
            local cmp = require("cmp")
            local lspkind = require("lspkind")
            cmp.setup({
              snippet = {
                expand = function(args)
                  require("luasnip").lsp_expand(args.body)
                end,
              },
              mapping = {
                ["<C-p>"] = cmp.mapping.select_prev_item(),
                ["<C-n>"] = cmp.mapping.select_next_item(),
                ["<C-space>"] = cmp.mapping.complete(),
                ["<C-e>"] = cmp.mapping.close(),
                ["<tab>"] = cmp.mapping.confirm({ select = true }),
              },
              formatting = {
                format = lspkind.cmp_format({
                  mode = "symbol_text",
                  maxwidth = 50, -- prevent the popup from showing more than provided characters (e.g 50 will not show more than 50 characters)
                  -- can also be a function to dynamically calculate max width such as
                  -- maxwidth = function() return math.floor(0.45 * vim.o.columns) end,
                  ellipsis_char = "...", -- when popup menu exceed maxwidth, the truncated part would show ellipsis_char instead (must define maxwidth first)
                  show_labelDetails = true, -- show labelDetails in menu. Disabled by default
                }),
              },

              sources = cmp.config.sources({
                { name = "nvim_lsp" },
                { name = "luasnip" },
              }, {
                { name = "buffer" },
                { name = "path" },
                { name = "treesitter" },
              }),
            })
            cmp.setup.filetype("gitcommit", {
              sources = cmp.config.sources({
                { name = "git" }, -- You can specify the `git` source if [you were installed it](https://github.com/petertriho/cmp-git).
              }, {
                { name = "buffer" },
              }),
            })
            cmp.setup.cmdline({ "/", "?" }, {
              mapping = cmp.mapping.preset.cmdline(),
              sources = {
                { name = "buffer" },
              },
            })
          '';
      }
      cmp-nvim-lsp
      lspkind-nvim
      cmp-buffer
      cmp-path

      {
        plugin = cmp-cmdline;
        type = "lua";
        config =
          /*
          lua
          */
          ''
            cmp.setup.cmdline(":", {
              mapping = cmp.mapping.preset.cmdline(),
              sources = cmp.config.sources({
                { name = "path" },
              }, {
                { name = "cmdline" },
              }),
            })
          '';
      }

      cmp-treesitter

      luasnip
      cmp_luasnip

      # Language support
      vim-nix

      # null-ls-nvim
      # vim-markdown

      {
        plugin = nvim-treesitter.withAllGrammars;
        type = "lua";
        config =
          /*
          lua
          */
          ''
            require("nvim-treesitter.configs").setup({
              autotag = { enable = true },
              context_commentstring = { enable = true, enable_autocmd = false },
              highlight = {
                enable = true,
                disable = function(_, bufnr)
                  return vim.b[bufnr].large_buf
                end,
              },
              incremental_selection = {
                enable = true,
                keymaps = {
                  node_incremental = "v",
                },
              },
              indent = { enable = true },
              textobjects = {
                select = {
                  enable = true,
                  lookahead = true,
                  keymaps = {
                    ["ak"] = { query = "@block.outer", desc = "around block" },
                    ["ik"] = { query = "@block.inner", desc = "inside block" },
                    ["ac"] = { query = "@class.outer", desc = "around class" },
                    ["ic"] = { query = "@class.inner", desc = "inside class" },
                    ["a?"] = { query = "@conditional.outer", desc = "around conditional" },
                    ["i?"] = { query = "@conditional.inner", desc = "inside conditional" },
                    ["af"] = { query = "@function.outer", desc = "around function " },
                    ["if"] = { query = "@function.inner", desc = "inside function " },
                    ["al"] = { query = "@loop.outer", desc = "around loop" },
                    ["il"] = { query = "@loop.inner", desc = "inside loop" },
                    ["aa"] = { query = "@parameter.outer", desc = "around argument" },
                    ["ia"] = { query = "@parameter.inner", desc = "inside argument" },
                  },
                },
                move = {
                  enable = true,
                  set_jumps = true,
                  goto_next_start = {
                    ["]k"] = { query = "@block.outer", desc = "Next block start" },
                    ["]f"] = { query = "@function.outer", desc = "Next function start" },
                    ["]a"] = { query = "@parameter.inner", desc = "Next argument start" },
                  },
                  goto_next_end = {
                    ["]K"] = { query = "@block.outer", desc = "Next block end" },
                    ["]F"] = { query = "@function.outer", desc = "Next function end" },
                    ["]A"] = { query = "@parameter.inner", desc = "Next argument end" },
                  },
                  goto_previous_start = {
                    ["[k"] = { query = "@block.outer", desc = "Previous block start" },
                    ["[f"] = { query = "@function.outer", desc = "Previous function start" },
                    ["[a"] = { query = "@parameter.inner", desc = "Previous argument start" },
                  },
                  goto_previous_end = {
                    ["[K"] = { query = "@block.outer", desc = "Previous block end" },
                    ["[F"] = { query = "@function.outer", desc = "Previous function end" },
                    ["[A"] = { query = "@parameter.inner", desc = "Previous argument end" },
                  },
                },
                swap = {
                  enable = true,
                  swap_next = {
                    [">K"] = { query = "@block.outer", desc = "Swap next block" },
                    [">F"] = { query = "@function.outer", desc = "Swap next function" },
                    [">A"] = { query = "@parameter.inner", desc = "Swap next argument" },
                  },
                  swap_previous = {
                    ["<K"] = { query = "@block.outer", desc = "Swap previous block" },
                    ["<F"] = { query = "@function.outer", desc = "Swap previous function" },
                    ["<A"] = { query = "@parameter.inner", desc = "Swap previous argument" },
                  },
                },
              },
            })
          '';
      }

      # Color Schemes
      tokyonight-nvim
      sonokai
      gruvbox
      onedark-nvim
      papercolor-theme

      {
        plugin = lualine-nvim;
        type = "lua";
        config =
          /*
          lua
          */
          ''
            require("lualine").setup({
              options = {
                theme = "onedark",
              },
            })
          '';
      }

      {
        plugin = bufferline-nvim;
        type = "lua";
        config =
          /*
          lua
          */
          ''
            require("bufferline").setup({})
            vim.keymap.set("n", "<Leader>b", "<Cmd>BufferLineCycleNext<CR>", { desc = "Buffer Next" })
            vim.keymap.set("n", "<Leader>B", "<Cmd>BufferLineCyclePrev<CR>", { desc = "Buffer Prev" })
          '';
      }

      {
        plugin = lazygit-nvim;
        type = "lua";
        config =
          /*
          lua
          */
          ''
            vim.keymap.set("n", "<Leader>gg", "<Cmd>LazyGit<CR>", { desc = "LazyGit" })
          '';
      }

      {
        plugin = telescope-nvim;
        type = "lua";
        config =
          /*
          lua
          */
          ''
            require("telescope").setup({
              extensions = {
                file_browser = {
                  theme = "ivy",
                  hijack_netrw = true,
                },
              },
            })
            require("telescope").load_extension("fzf")
            require("telescope").load_extension("ui-select")
            vim.keymap.set("n", "<Leader>f", "<Nop>", { desc = "Telescope" })
            vim.keymap.set("n", "<Leader>fF", function()
              require("telescope.builtin").current_buffer_fuzzy_find(require("telescope.themes").get_dropdown({
                winblend = 10,
                previewer = false,
              }))
            end, { desc = "Fuzzy Search Current Buffer" })
            vim.keymap.set("n", "<Leader>ft", "<Cmd>Telescope<CR>", { desc = "Telescope" })
            vim.keymap.set("n", "<Leader>ff", "<Cmd>Telescope find_files<CR>", { desc = "Find File" })
            vim.keymap.set("n", "<Leader>fr", "<Cmd>Telescope oldfiles<CR>", { desc = "Open Recent File" })
            vim.keymap.set("n", "<Leader>fg", "<Cmd>Telescope live_grep<CR>", { desc = "Live Grep" })
            vim.keymap.set("n", "<Leader>fG", "<Cmd>Telescope git_files<CR>", { desc = "Git Files" })
            vim.keymap.set("n", "<Leader>fb", "<Cmd>Telescope buffers<CR>", { desc = "Buffers" })
            vim.keymap.set("n", "<Leader>fh", "<Cmd>Telescope help_tags<CR>", { desc = "Help" })
            vim.keymap.set("n", "<Leader>fs", "<Cmd>Telescope grep_string<CR>", { desc = "Current Word" })
            vim.keymap.set("n", "<Leader>fd", "<Cmd>Telescope diagnostics<CR>", { desc = "Diagnostics" })
            vim.keymap.set("n", "<Leader>fb", "<Cmd>Telescope buffers<CR>", { desc = "Buffers" })
            vim.keymap.set("n", "<Leader>fk", "<Cmd>Telescope keymaps<CR>", { desc = "Keymaps" })
            vim.keymap.set(
              "n",
              "<Leader>fc",
              "<Cmd>lua require('telescope.builtin').colorscheme({enable_preview = true})<CR>",
              { desc = "Color Scheme" }
            )
          '';
      }

      telescope-fzf-native-nvim
      telescope-ui-select-nvim

      {
        plugin = telescope-file-browser-nvim;
        type = "lua";
        config =
          /*
          lua
          */
          ''
            require("telescope").load_extension("file_browser")
            vim.keymap.set("n", "<Leader>fn", "<Cmd>Telescope file_browser path=%:p:h<CR>", { desc = "Browser" })
            vim.keymap.set("n", "<Leader>fN", "<Cmd>Telescope file_browser<CR>", { desc = "Browser CWD" })
          '';
      }

      {
        plugin = alpha-nvim;
        type = "lua";
        config =
          /*
          lua
          */
          ''
            require("alpha").setup(require("alpha.themes.startify").config)
            vim.keymap.set("n", "<Leader>;", "<Cmd>Alpha<CR>", { desc = "Dashboard" })
          '';
      }

      # Git
      {
        plugin = gitsigns-nvim;
        type = "lua";
        config =
          /*
          lua
          */
          ''
            require("gitsigns").setup({
              signs = {
                add = { text = "┃" },
                change = { text = "┃" },
                delete = { text = "_" },
                topdelete = { text = "‾" },
                changedelete = { text = "~" },
                untracked = { text = "┆" },
              },
              signs_staged = {
                add = { text = "┃" },
                change = { text = "┃" },
                delete = { text = "_" },
                topdelete = { text = "‾" },
                changedelete = { text = "~" },
                untracked = { text = "┆" },
              },
              signs_staged_enable = true,
              signcolumn = true, -- Toggle with `:Gitsigns toggle_signs`
              numhl = false, -- Toggle with `:Gitsigns toggle_numhl`
              linehl = false, -- Toggle with `:Gitsigns toggle_linehl`
              word_diff = false, -- Toggle with `:Gitsigns toggle_word_diff`
              watch_gitdir = {
                follow_files = true,
              },
              auto_attach = true,
              attach_to_untracked = false,
              current_line_blame = false, -- Toggle with `:Gitsigns toggle_current_line_blame`
              current_line_blame_opts = {
                virt_text = true,
                virt_text_pos = "eol", -- 'eol' | 'overlay' | 'right_align'
                delay = 1000,
                ignore_whitespace = false,
                virt_text_priority = 100,
                use_focus = true,
              },
              current_line_blame_formatter = "<author>, <author_time:%R> - <summary>",
              sign_priority = 6,
              update_debounce = 100,
              status_formatter = nil, -- Use default
              max_file_length = 40000, -- Disable if file is longer than this (in lines)
              preview_config = {
                -- Options passed to nvim_open_win
                border = "single",
                style = "minimal",
                relative = "cursor",
                row = 0,
                col = 1,
              },
              on_attach = function(bufnr)
                local gitsigns = require("gitsigns")

                local function map(mode, l, r, desc, opts)
                  opts = opts or {}
                  opts.buffer = bufnr
                  opts.desc = desc
                  vim.keymap.set(mode, l, r, opts)
                end

                -- Navigation
                map("n", "]c", function()
                  if vim.wo.diff then
                    vim.cmd.normal({ "]c", bang = true })
                  else
                    gitsigns.nav_hunk("next")
                  end
                end, "Next Change")

                map("n", "[c", function()
                  if vim.wo.diff then
                    vim.cmd.normal({ "[c", bang = true })
                  else
                    gitsigns.nav_hunk("prev")
                  end
                end, "Prev Change")

                -- Actions
                map("n", "<leader>t", "<Nop>", "Gitsigns")
                map("n", "<leader>hs", gitsigns.stage_hunk, "Stage Hunk")
                map("n", "<leader>hr", gitsigns.reset_hunk, "Reset Hunk")
                map("v", "<leader>hs", function()
                  gitsigns.stage_hunk({ vim.fn.line("."), vim.fn.line("v") })
                end, "Stage Hunk")
                map("v", "<leader>hr", function()
                  gitsigns.reset_hunk({ vim.fn.line("."), vim.fn.line("v") })
                end, "Reset Hunk")
                map("n", "<leader>hS", gitsigns.stage_buffer, "Stage Buffer")
                map("n", "<leader>hu", gitsigns.undo_stage_hunk, "Undo Stage Hunk")
                map("n", "<leader>hR", gitsigns.reset_buffer, "Reset Buffer")
                map("n", "<leader>hp", gitsigns.preview_hunk, "Preview Hunk")
                map("n", "<leader>hb", function()
                  gitsigns.blame_line({ full = true })
                end, "Blame Line")
                map("n", "<leader>hd", gitsigns.diffthis, "Diff This")
                map("n", "<leader>hD", function()
                  gitsigns.diffthis("~")
                end, "Diff This")
                map("n", "<leader>t", "<Nop>", "Toggle")
                map("n", "<leader>tb", gitsigns.toggle_current_line_blame, "Toggle Blame Line")
                map("n", "<leader>td", gitsigns.toggle_deleted, "Toggle Deleted")

                -- Text object
                map({ "o", "x" }, "ih", ":<C-U>Gitsigns select_hunk<CR>", "Select Hunk")
              end,
            })
          '';
      }
      {
        plugin = neogit;
        type = "lua";
        config =
          /*
          lua
          */
          ''
            require("neogit").setup({})
          '';
      }

      {
        plugin = showkeys;
        type = "lua";
        config =
          /*
          lua
          */
          ''
            require("showkeys").setup({
              maxkeys = 7,
              show_count = true,
            })
            vim.api.nvim_create_autocmd("VimEnter", {
              callback = function()
                vim.cmd("ShowkeysToggle")
              end,
            })
          '';
      }
      recover-vim
    ];

    extraLuaConfig = builtins.readFile ./config/neovim.lua;
  };
  xdg.configFile = with config.lib.file; {
    "nvim/queries".source = mkOutOfStoreSymlink ./nvimqueries;
    "nvim/sql_formatter.json".text = ''
      {
        "language": "sqlite",
        "keywordCase": "upper"
      }
    '';
  };
  home.sessionPath = ["$HOME/.local/bin"]; # fix for mason to work
}
