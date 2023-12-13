{ pkgs, ... }: {
  programs.neovim = {
    enable = true;
    viAlias = true;
    vimAlias = true;
    extraPackages = with pkgs; [
      ### Language Servers ###
      nodePackages.bash-language-server
      lua-language-server
      nodejs
      nil
      rnix-lsp
      # nixfmt
      # statix - Client crashed when opening .nix file
      # deadnix
      # alejandra
      marksman
      # yamllint
      # nodePackages.diagnostic-languageserver - Causes error when doing lsp format on .nix files
      # nodePackages.markdownlint-cli
      # nodePackages.jsonlint

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
# mini.comment
# mini.cursorword
# mini.indentscope # Keep animation?
# mini.surround # Learn these hotkeys and usage
# mini.trailspace

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

    plugins = with pkgs.vimPlugins; [

      {
        plugin = mini-nvim;
        type = "lua";
        config = ''
          require('mini.animate').setup()
          require('mini.basics').setup()
          require('mini.comment').setup()
          require('mini.cursorword').setup()
          require('mini.indentscope').setup()
          require('mini.surround').setup()
          require('mini.trailspace').setup()

          local miniclue = require('mini.clue')
          miniclue.setup({
            triggers = {
              -- Leader triggers
              { mode = 'n', keys = '<Leader>' },
              { mode = 'x', keys = '<Leader>' },
              { mode = 'n', keys = ',' },
              { mode = 'x', keys = ',' },
              { mode = 'n', keys = ']' },
              { mode = 'n', keys = '[' },

              -- Built-in completion
              { mode = 'i', keys = '<C-x>' },

              -- `g` key
              { mode = 'n', keys = 'g' },
              { mode = 'x', keys = 'g' },

              -- Marks
              { mode = 'n', keys = "'" },
              { mode = 'n', keys = '`' },
              { mode = 'x', keys = "'" },
              { mode = 'x', keys = '`' },

              -- Registers
              { mode = 'n', keys = '"' },
              { mode = 'x', keys = '"' },
              { mode = 'i', keys = '<C-r>' },
              { mode = 'c', keys = '<C-r>' },

              -- Window commands
              { mode = 'n', keys = '<C-w>' },

              -- `z` key
              { mode = 'n', keys = 'z' },
              { mode = 'x', keys = 'z' },
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


# -- lvim.builtin.which_key.mappings["t"] = {
# --   name = "+Trouble",
# --   r = { "<cmd>Trouble lsp_references<cr>", "References" },
# --   f = { "<cmd>Trouble lsp_definitions<cr>", "Definitions" },
# --   d = { "<cmd>Trouble document_diagnostics<cr>", "Diagnostics" },
# --   q = { "<cmd>Trouble quickfix<cr>", "QuickFix" },
# --   l = { "<cmd>Trouble loclist<cr>", "LocationList" },
# --   w = { "<cmd>Trouble workspace_diagnostics<cr>", "Wordspace Diagnostics" },
# -- }

  # {
  #   "jpalardy/vim-slime",
  #   ft = { 'python' },
  #   config = function()
  #     vim.cmd([[
  #     let g:slime_target = "tmux"
  #     let g:slime_cell_delimiter = "^#\\s*%%"
  #     " let g:slime_default_config = { "socket_name": get(split($TMUX, ","), 0), "target_pane": "{bottom-right}" }
  #     let g:slime_default_config = { "socket_name": "default", "target_pane": "{bottom-right}" }
  #     let g:slime_dont_ask_default = 1
  #     " let g:slime_bracketed_paste = 1
  #     let g:slime_no_mappings = 1
  #     let g:slime_python_ipython = 1
  #     nmap <leader>rv <Plug>SlimeConfig
  #     vmap ,r <Plug>SlimeRegionSend
  #     nmap ,R <Plug>SlimeCellsSendAndGoToNext
  #     nmap ,r <Plug>SlimeCellsSend
  #     nmap ,c :<C-U>call Send_Ctrl_C()<CR>
  #     nmap ,l :<C-U>call StartIPython()<CR>
  #     nmap ,j <Plug>SlimeCellsNext
  #     nmap ,k <Plug>SlimeCellsPrev
  #
  #     function StartIPython()
  #       let l:target_pane = shellescape(g:slime_default_config["target_pane"])
  #       call system("tmux if -F '#{==:#{window_panes},1}' 'split-window -hd ipython'")
  #       call system("tmux send -t " . l:target_pane . " C-u")
  #       call system("tmux if -F '#{window_zoomed_flag}' 'resize-pane -Z'")
  #     endfunction
  #
  #     function SlimeOverride_EscapeText_python(text)
  #       call StartIPython()
  #       return ["%cpaste -q\n", g:slime_dispatch_ipython_pause, a:text, "--\n"]
  #     endfunction
  #
  #     function Send_Ctrl_C()
  #       let l:target_pane = shellescape(g:slime_default_config["target_pane"])
  #       call system("tmux send -t " . l:target_pane . " C-c")
  #     endfunction
  #
  #
  #     ]])
  #   end
  # },
  #
  # {
  #   'klafyvel/vim-slime-cells',
  #   requires = { { 'jpalardy/vim-slime', opt = true } },
  #   ft = { 'python' },
  # },

      codeium-vim
      vim-sleuth

      plenary-nvim
      nvim-snippy
      cmp-snippy

      {
        plugin = nvim-lspconfig;
        type = "lua";
        config = ''
          local lspconfig = require("lspconfig")
          -- Bash --
          lspconfig.bashls.setup{}

          -- Lua --
          lspconfig.lua_ls.setup{
            settings = {
              Lua = {
                runtime = {
                  -- Tell the language server which version of Lua you're using (most likely LuaJIT in the case of Neovim)
                  version = "LuaJIT",
                },
                diagnostics = {
                  -- Get the language server to recognize the `vim` global
                  globals = {"vim"},
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
          }

          -- Python --
          -- lspconfig.pyright.setup{}
          lspconfig.pylsp.setup{
            settings = {
              pylsp = {
                plugins = {
                  ruff = {
                    enable = true,
                    -- select = { "All" },
                    -- format = { "All" },
                  },
                  rope = { enabled = true },
                  rope_autoimport = { enabled = true },
                }
              }
            }
          }
          -- lspconfig.ruff_lsp.setup{}

          -- Nix --
          lspconfig.nil_ls.setup{} -- nix language server - no format
          lspconfig.rnix.setup{}

          -- Markdown --
          lspconfig.marksman.setup{}

          -- Diagnostic --
          -- lspconfig.diagnosticls.setup{}
        '';
      }

      ### Completion ###
      {
        plugin = nvim-cmp;
        type = "lua";
        config = ''
          local cmp = require("cmp")
          cmp.setup {
            snippet = {
              expand = function(args)
                require("luasnip").lsp_expand(args.body)
              end
            },
            mapping = {
              ["<C-p>"] = cmp.mapping.select_prev_item(),
              ["<C-n>"] = cmp.mapping.select_next_item(),
              ["<C-space>"] = cmp.mapping.complete(),
              ["<C-e>"] = cmp.mapping.close(),
              ["<tab>"] = cmp.mapping.confirm { select = true },
            },

            sources = cmp.config.sources({
              { name = "nvim_lsp" },
              { name = "luasnip" },
            }, {
              { name = "buffer" },
              { name = "path" },
              { name = "treesitter" },
            }),
          }
          cmp.setup.filetype("gitcommit", {
            sources = cmp.config.sources({
              { name = "git" }, -- You can specify the `git` source if [you were installed it](https://github.com/petertriho/cmp-git).
            }, {
              { name = "buffer" },
            })
          })
          cmp.setup.cmdline({ "/", "?" }, {
            mapping = cmp.mapping.preset.cmdline(),
            sources = {
              { name = "buffer" }
            }
          })
        '';
      }
      cmp-nvim-lsp
      cmp-buffer
      cmp-path

      {
        plugin = cmp-cmdline;
        type = "lua";
        config = ''
          cmp.setup.cmdline(":", {
            mapping = cmp.mapping.preset.cmdline(),
            sources = cmp.config.sources({
              { name = "path" }
            }, {
              { name = "cmdline" }
            })
          })
        '';
      }

      cmp-treesitter

      luasnip
      cmp_luasnip


      # Language support
      vim-slime
      vim-nix

      {
        plugin = null-ls-nvim;
        type = "lua";
        config = ''
        '';
      }

      vim-markdown

      nvim-treesitter.withAllGrammars

      # Color Schemes
      tokyonight-nvim
      sonokai
      gruvbox
      onedark-nvim
      papercolor-theme

      nvim-web-devicons

      {
        plugin = lualine-nvim;
        type = "lua";
        config = ''
          require("lualine").setup{
            options = {
              theme = "onedark"
            }
          }
        '';
      }

      {
        plugin = bufferline-nvim;
        type = "lua";
        config = ''
          require("bufferline").setup{}
          vim.keymap.set('n', '<Leader>b',  "<Cmd>BufferLineCycleNext<CR>", { desc = "Buffer Next" })
          vim.keymap.set('n', '<Leader>B',  "<Cmd>BufferLineCyclePrev<CR>", { desc = "Buffer Prev" })
        '';
      }

      {
        plugin = lazygit-nvim;
        type = "lua";
        config = ''
          vim.keymap.set('n', '<Leader>gg',  "<Cmd>LazyGit<CR>", { desc = "LazyGit" })
        '';
      }


      {
        plugin = telescope-nvim;
        type = "lua";
        config = ''
          pcall(require('telescope').load_extension, 'fzf')
          vim.keymap.set('n', '<Leader>f',  "<Nop>", { desc = "Telescope" })
          vim.keymap.set('n', '<Leader>fF',
            function()
              require('telescope.builtin').current_buffer_fuzzy_find(require('telescope.themes').get_dropdown {
                winblend = 10,
                previewer = false,
              })
            end, { desc = "Fuzzy Search Current Buffer" })
          vim.keymap.set('n', '<Leader>ff',  "<Cmd>Telescope find_files<CR>", { desc = "Find File" })
          vim.keymap.set('n', '<Leader>fr',  "<Cmd>Telescope oldfiles<CR>", { desc = "Open Recent File" })
          vim.keymap.set('n', '<Leader>fg',  "<Cmd>Telescope live_grep<CR>", { desc = "Live Grep" })
          vim.keymap.set('n', '<Leader>fG',  "<Cmd>Telescope git_files<CR>", { desc = "Git Files" })
          vim.keymap.set('n', '<Leader>fb',  "<Cmd>Telescope buffers<CR>", { desc = "Buffers" })
          vim.keymap.set('n', '<Leader>fh',  "<Cmd>Telescope help_tags<CR>", { desc = "Help" })
          vim.keymap.set('n', '<Leader>fs',  "<Cmd>Telescope grep_string<CR>", { desc = "Current Word" })
          vim.keymap.set('n', '<Leader>fd',  "<Cmd>Telescope diagnostics<CR>", { desc = "Diagnostics" })
          vim.keymap.set('n', '<Leader>fc',  "<Cmd>lua require('telescope.builtin').colorscheme({enable_preview = true})<CR>", { desc = "Color Scheme" })
        '';
      }
      {
        plugin = telescope-file-browser-nvim;
        type = "lua";
        config = ''
          require("telescope").setup()
          require("telescope").load_extension("file_browser")
          vim.keymap.set('n', '<Leader>fn',  "<Cmd>Telescope file_browser path=%:p:h<CR>", { desc = "Browser" })
          vim.keymap.set('n', '<Leader>fN',  "<Cmd>Telescope file_browser<CR>", { desc = "Browser CWD" })
        '';
      }

      {
        plugin = alpha-nvim;
        type = "lua";
        config = ''
          require("alpha").setup(require("alpha.themes.startify").config)
          vim.keymap.set('n', '<Leader>;',  "<Cmd>alpha<CR>", { desc = "Dashboard" })
        '';
      }

    ];

    extraConfig = ''
      lua << EOF
      ${builtins.readFile ./config/neovim.lua}
      EOF
    '';
  };
}
