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

    plugins = with pkgs.vimPlugins; [
      {
        plugin = which-key-nvim;
        type = "lua";
        config = ''

          local whichkey = require("which-key")
          whichkey.register({
            ["<Leader>l"] = {
              name = "LSP",
              f = { function() vim.lsp.buf.format { async = true } end, "Format" },
              d = { vim.lsp.buf.definition, "Definition" },
              D = { vim.lsp.buf.declaration, "Declaration" },
              i = { vim.lsp.buf.implementation, "Implementation" },
              r = { vim.lsp.buf.rename, "Rename" },
              R = { vim.lsp.buf.references, "References" },
              [" "] = { vim.lsp.buf.hover, "Hover" },
              a = { vim.lsp.buf.code_action, "Code Action" },
              s = { vim.lsp.buf.signature_help, "Signature Help" },
              p = {
                name = "Diagnostic",
                p = { vim.diagnostic.goto_prev, "Goto Prev" },
                n = { vim.diagnostic.goto_next, "Goto Next" },
                f = { vim.diagnostic.open_float, "Open Float" },
                s = { vim.diagnostic.setloclist, "Set Loc List" },
              },
            },
          })

          whichkey.register({
            ["<C-s>"] = { "<Cmd>w<CR>", "Save" },
            ["<CR>"] = { "<Cmd>nohlsearch<CR><CR>", "Clear Search Highlight" },
            [",,"] = { "<C-^>", "Active Most Recent Buffer" },
            -- ["<F2>"] = { "<Cmd>set number!<CR><CMD>set list!<Bar>set list?<CR>", "Remove Decorations" },
          })
          whichkey.register({
            ["<C-s>"] = { "<Cmd><Esc>w<CR>", "Save" },
          }, { mode = "i" })
          whichkey.register({
            ["p"] = { "\"_dP", "Paste Without Yanking" },
            [",'"] = { "<C-v>I'<Esc>gv$A',<ESC>gvgJ$r<Cmd>keeppatterns s/\\(.\\{-\\},\\)\\{10\\}/&\r/g<CR>", "Comma Separate and Quote List" },
          }, { mode = "v" })

          -- lvim.keys.normal_mode[",<Tab>"] = "<Cmd>tabNext<CR>"
          -- lvim.keys.normal_mode[",<S-Tab>"] = "<Cmd>tabprevious<CR>"
          -- -- lvim.keys.insert_mode["<Up>"] = "<Esc><Up>"
          -- -- lvim.keys.insert_mode["<Down>"] = "<Esc><Down>"
          -- lvim.builtin.which_key.mappings["x"] = {
          --   "<Cmd>enew | setlocal ft=python bt=nofile bh=hide noswapfile nu | file Scratch<CR>", "Scratch"
          -- }
          -- lvim.keys.insert_mode["<C-Del>"] = "<C-o>dw"
          -- -- for neoscroll support
          -- lvim.keys.visual_mode["<PageUp>"] = { "<C-b>", { remap = true } }
          -- lvim.keys.visual_mode["<PageDown>"] = { "<C-f>", { remap = true } }
          -- 
          -- 
          -- lvim.keys.insert_mode["<C-l>"] = "<Esc><C-w>l"
          -- lvim.keys.insert_mode["<C-h>"] = "<Esc><C-w>h"
          -- lvim.keys.insert_mode["<C-k>"] = "<Esc><C-w>k"
          -- lvim.keys.insert_mode["<C-j>"] = "<Esc><C-w>j"
        '';
      }

      vim-repeat
      # vim-surround
      # vim-fugitive
      # vim-rhubarb
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

      {
        plugin = vimwiki;
        type = "lua";
        config = ''
          whichkey.register({
            ["<Leader>w"] = { name= "Wiki" },
          })
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
        plugin = comment-nvim;
        type = "lua";
        config = ''
          require("Comment").setup{}
        '';
      }


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
          whichkey.register({
            ["<Leader>b"] = { "<Cmd>BufferLineCycleNext<CR>", "Buffer Next" },
            ["<Leader>B"] = { "<Cmd>BufferLineCyclePrev<CR>", "Buffer Prev" },
          })
        '';
      }

      {
        plugin = nvim-bufdel;
        type = "lua";
        config = ''
          whichkey.register({
            ["<Leader>c"] = { "<Cmd>BufDel<CR>", "Close Buffer" },
          })
        '';
      }

      {
        plugin = lazygit-nvim;
        type = "lua";
        config = ''
          whichkey.register({
            ["<Leader>gg"] = { "<Cmd>LazyGit<CR>", "LazyGit" },
          })
        '';
      }


      {
        plugin = telescope-nvim;
        type = "lua";
        config = ''
          pcall(require('telescope').load_extension, 'fzf')
          whichkey.register({
            ["<Leader>f"] = {
              name = "Find",
              f = { "<Cmd>Telescope find_files<CR>", "Find File" },
              F = { function()
                  require('telescope.builtin').current_buffer_fuzzy_find(require('telescope.themes').get_dropdown {
                    winblend = 10,
                    previewer = false,
                  })
                end, "Fuzzy Search Current Buffer" },
              r = { "<Cmd>Telescope oldfiles<CR>", "Open Recent File" },
              g = { "<Cmd>Telescope live_grep<CR>", "Live Grep" },
              G = { "<Cmd>Telescope git_files<CR>", "Git Files" },
              b = { "<Cmd>Telescope buffers<CR>", "Buffers" },
              h = { "<Cmd>Telescope help_tags<CR>", "Help" },
              s = { "<Cmd>Telescope grep_string<CR>", "Current Word" },
              d = { "<Cmd>Telescope diagnostics<CR>", "Diagnostics" },
              c = { "<Cmd>lua require('telescope.builtin').colorscheme({enable_preview = true})<CR>", "Color Scheme" },
            },
          })
        '';
      }
      {
        plugin = telescope-file-browser-nvim;
        type = "lua";
        config = ''
          require("telescope").setup()
          require("telescope").load_extension("file_browser")
          whichkey.register({
            ["<Leader>f"] = {
              n = { "<Cmd>Telescope file_browser path=%:p:h<CR>", "Browser" },
              N = { "<Cmd>Telescope file_browser<CR>", "Browser CWD"},
            },
          })
        '';
      }

      {
        plugin = neoscroll-nvim;
        type = "lua";
        config = ''
          require("neoscroll").setup{}
          whichkey.register({
            ["<PageUp>"] = { "<C-b>", "Page Up" },
            ["<PageDown>"] = { "<C-f>", "Page Down" },
          }, { mode = "", noremap = false })
        '';
      }
      {
        plugin = nvim-lastplace;
        type = "lua";
        config = ''
          require("nvim-lastplace").setup{}
        '';
      }
      vim-cursorword
      indent-blankline-nvim
      {
        plugin = indent-blankline-nvim;
        type = "lua";
        config = ''
          require("ibl").setup{}
        '';
      }

      {
        plugin = alpha-nvim;
        type = "lua";
        config = ''
          require("alpha").setup(require("alpha.themes.startify").config)
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
