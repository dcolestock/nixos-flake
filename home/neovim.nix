{ pkgs, ... }: {
  programs.neovim = {
    enable = true;
    viAlias = true;
    vimAlias = true;
    extraPython3Packages = pyPkgs: with pyPkgs; [ python-lsp-server ];

    extraPackages = with pkgs; [
      ### Language Servers ###
      nodePackages.bash-language-server
      lua-language-server
      # black
      # flake8
      pyright
      nil
      nixd
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
            ["<F2>"] = { "<Cmd>set number!<CR><CMD>set list!<Bar>set list?<CR>", "Remove Decorations" },
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
          -- Bash --
          require("lspconfig").bashls.setup{}

          -- Lua --
          require("lspconfig").lua_ls.setup{
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
          require("lspconfig").pyright.setup{}

          -- Nix --
          require("lspconfig").nil_ls.setup{} -- nix language server - no format
          require("lspconfig").nixd.setup{} -- nix language server - no format
          require("lspconfig").rnix.setup{}
          -- require("lspconfig").statix.setup{}

          -- Markdown --
          require("lspconfig").marksman.setup{}

          -- Diagnostic --
          -- require("lspconfig").diagnosticls.setup{}
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
      dracula-vim
      gruvbox
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
              theme = "dracula"
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
          require("indent_blankline").setup{
            show_trailing_blankline_indent = true,
            show_current_context = true,
            show_current_context_start = true,
            show_first_indent_level = false,
          }
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

#   -- NOTE: This is where your plugins related to LSP can be installed.
#   --  The configuration is done below. Search for lspconfig to find it below.
#   {
#     -- LSP Configuration & Plugins
#     'neovim/nvim-lspconfig',
#     dependencies = {
#       -- Automatically install LSPs to stdpath for neovim
#       { 'williamboman/mason.nvim', config = true },
#       'williamboman/mason-lspconfig.nvim',

#       -- Useful status updates for LSP
#       -- NOTE: `opts = {}` is the same as calling `require('fidget').setup({})`
#       { 'j-hui/fidget.nvim', tag = 'legacy', opts = {} },

#       -- Additional lua configuration, makes nvim stuff amazing!
#       'folke/neodev.nvim',
#     },
#   },

#   {
#     -- Autocompletion
#     'hrsh7th/nvim-cmp',
#     dependencies = {
#       -- Snippet Engine & its associated nvim-cmp source
#       'L3MON4D3/LuaSnip',
#       'saadparwaiz1/cmp_luasnip',

#       -- Adds LSP completion capabilities
#       'hrsh7th/cmp-nvim-lsp',

#       -- Adds a number of user-friendly snippets
#       'rafamadriz/friendly-snippets',
#     },
#   },

#   -- Useful plugin to show you pending keybinds.
#   { 'folke/which-key.nvim', opts = {} },
#   {
#     -- Adds git releated signs to the gutter, as well as utilities for managing changes
#     'lewis6991/gitsigns.nvim',
#     opts = {
#       -- See `:help gitsigns.txt`
#       signs = {
#         add = { text = '+' },
#         change = { text = '~' },
#         delete = { text = '_' },
#         topdelete = { text = '‾' },
#         changedelete = { text = '~' },
#       },
#       on_attach = function(bufnr)
#         vim.keymap.set('n', '<Leader>gp', require('gitsigns').prev_hunk, { buffer = bufnr, desc = '[G]o to [P]revious Hunk' })
#         vim.keymap.set('n', '<Leader>gn', require('gitsigns').next_hunk, { buffer = bufnr, desc = '[G]o to [N]ext Hunk' })
#         vim.keymap.set('n', '<Leader>ph', require('gitsigns').preview_hunk, { buffer = bufnr, desc = '[P]review [H]unk' })
#       end,
#     },
#   },

#   {
#     -- Theme inspired by Atom
#     'navarasu/onedark.nvim',
#     priority = 1000,
#     config = function()
#       vim.cmd.colorscheme 'onedark'
#     end,
#   },

#   {
#     -- Set lualine as statusline
#     'nvim-lualine/lualine.nvim',
#     -- See `:help lualine.txt`
#     opts = {
#       options = {
#         icons_enabled = false,
#         theme = 'onedark',
#         component_separators = '|',
#         section_separators = '',
#       },
#     },
#   },

#   {
#     -- Enable `lukas-reineke/indent-blankline.nvim`
#     -- See `:help indent_blankline.txt`
#     opts = {
#       char = '┊',
#       show_trailing_blankline_indent = false,
#     },
#   },

#   -- "gc" to comment visual regions/lines
#   { 'numToStr/Comment.nvim', opts = {} },

#   -- Fuzzy Finder (files, lsp, etc)
#   { 'nvim-telescope/telescope.nvim', branch = '0.1.x', dependencies = { 'nvim-lua/plenary.nvim' } },

#   -- Fuzzy Finder Algorithm which requires local dependencies to be built.
#   -- Only load if `make` is available. Make sure you have the system
#   -- requirements installed.
#   {
#     'nvim-telescope/telescope-fzf-native.nvim',
#     -- NOTE: If you are having trouble with this installation,
#     --       refer to the README for telescope-fzf-native for more instructions.
#     build = 'make',
#     cond = function()
#       return vim.fn.executable 'make' == 1
#     end,
#   },

#   {
#     -- Highlight, edit, and navigate code
#     'nvim-treesitter/nvim-treesitter',
#     dependencies = {
#       'nvim-treesitter/nvim-treesitter-textobjects',
#     },
#     build = ':TSUpdate',
#   },

#   -- NOTE: Next Step on Your Neovim Journey: Add/Configure additional "plugins" for kickstart
#   --       These are some example plugins that I've included in the kickstart repository.
#   --       Uncomment any of the lines below to enable them.
#   -- require 'kickstart.plugins.autoformat',
#   -- require 'kickstart.plugins.debug',

#   -- NOTE: The import below can automatically add your own plugins, configuration, etc from `lua/custom/plugins/*.lua`
#   --    You can use this folder to prevent any conflicts with this init.lua if you're interested in keeping
#   --    up-to-date with whatever is in the kickstart repo.
#   --    Uncomment the following line and add your plugins to `lua/custom/plugins/*.lua` to get going.
#   --
#   --    For additional information see: https://github.com/folke/lazy.nvim#-structuring-your-plugins
#   -- { import = 'custom.plugins' },
# }, {})

# -- [[ Basic Keymaps ]]

# -- Keymaps for better default experience
# -- See `:help vim.keymap.set()`
# vim.keymap.set({ 'n', 'v' }, '<Space>', '<Nop>', { silent = true })

# -- Remap for dealing with word wrap
# vim.keymap.set('n', 'k', "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
# vim.keymap.set('n', 'j', "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })

# -- [[ Highlight on yank ]]
# -- See `:help vim.highlight.on_yank()`
# local highlight_group = vim.api.nvim_create_augroup('YankHighlight', { clear = true })
# vim.api.nvim_create_autocmd('TextYankPost', {
#   callback = function()
#     vim.highlight.on_yank()
#   end,
#   group = highlight_group,
#   pattern = '*',
# })

# -- [[ Configure Telescope ]]
# -- See `:help telescope` and `:help telescope.setup()`
# require('telescope').setup {
#   defaults = {
#     mappings = {
#       i = {
#         ['<C-u>'] = false,
#         ['<C-d>'] = false,
#       },
#     },
#   },
# }

# -- Enable telescope fzf native, if installed
# -- [[ Configure Treesitter ]]
# -- See `:help nvim-treesitter`
# require('nvim-treesitter.configs').setup {
#   -- Add languages to be installed here that you want installed for treesitter
#   ensure_installed = { 'c', 'cpp', 'go', 'lua', 'python', 'rust', 'tsx', 'typescript', 'vimdoc', 'vim' },

#   -- Autoinstall languages that are not installed. Defaults to false (but you can change for yourself!)
#   auto_install = false,

#   highlight = { enable = true },
#   indent = { enable = true },
#   incremental_selection = {
#     enable = true,
#     keymaps = {
#       init_selection = '<c-space>',
#       node_incremental = '<c-space>',
#       scope_incremental = '<c-s>',
#       node_decremental = '<M-space>',
#     },
#   },
#   textobjects = {
#     select = {
#       enable = true,
#       lookahead = true, -- Automatically jump forward to textobj, similar to targets.vim
#       keymaps = {
#         -- You can use the capture groups defined in textobjects.scm
#         ['aa'] = '@parameter.outer',
#         ['ia'] = '@parameter.inner',
#         ['af'] = '@function.outer',
#         ['if'] = '@function.inner',
#         ['ac'] = '@class.outer',
#         ['ic'] = '@class.inner',
#       },
#     },
#     move = {
#       enable = true,
#       set_jumps = true, -- whether to set jumps in the jumplist
#       goto_next_start = {
#         [']m'] = '@function.outer',
#         [']]'] = '@class.outer',
#       },
#       goto_next_end = {
#         [']M'] = '@function.outer',
#         [']['] = '@class.outer',
#       },
#       goto_previous_start = {
#         ['[m'] = '@function.outer',
#         ['[['] = '@class.outer',
#       },
#       goto_previous_end = {
#         ['[M'] = '@function.outer',
#         ['[]'] = '@class.outer',
#       },
#     },
#     swap = {
#       enable = true,
#       swap_next = {
#         ['<Leader>a'] = '@parameter.inner',
#       },
#       swap_previous = {
#         ['<Leader>A'] = '@parameter.inner',
#       },
#     },
#   },
# }

# -- Diagnostic keymaps
# vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, { desc = 'Go to previous diagnostic message' })
# vim.keymap.set('n', ']d', vim.diagnostic.goto_next, { desc = 'Go to next diagnostic message' })
# vim.keymap.set('n', '<Leader>e', vim.diagnostic.open_float, { desc = 'Open floating diagnostic message' })
# vim.keymap.set('n', '<Leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostics list' })

# -- [[ Configure LSP ]]
# --  This function gets run when an LSP connects to a particular buffer.
# local on_attach = function(_, bufnr)
#   -- NOTE: Remember that lua is a real programming language, and as such it is possible
#   -- to define small helper and utility functions so you don't have to repeat yourself
#   -- many times.
#   --
#   -- In this case, we create a function that lets us more easily define mappings specific
#   -- for LSP related items. It sets the mode, buffer and description for us each time.
#   local nmap = function(keys, func, desc)
#     if desc then
#       desc = 'LSP: ' .. desc
#     end

#     vim.keymap.set('n', keys, func, { buffer = bufnr, desc = desc })
#   end

#   nmap('<Leader>rn', vim.lsp.buf.rename, '[R]e[n]ame')
#   nmap('<Leader>ca', vim.lsp.buf.code_action, '[C]ode [A]ction')

#   nmap('gd', vim.lsp.buf.definition, '[G]oto [D]efinition')
#   nmap('gr', require('telescope.builtin').lsp_references, '[G]oto [R]eferences')
#   nmap('gI', vim.lsp.buf.implementation, '[G]oto [I]mplementation')
#   nmap('<Leader>D', vim.lsp.buf.type_definition, 'Type [D]efinition')
#   nmap('<Leader>ds', require('telescope.builtin').lsp_document_symbols, '[D]ocument [S]ymbols')
#   nmap('<Leader>ws', require('telescope.builtin').lsp_dynamic_workspace_symbols, '[W]orkspace [S]ymbols')

#   -- See `:help K` for why this keymap
#   nmap('K', vim.lsp.buf.hover, 'Hover Documentation')
#   nmap('<C-k>', vim.lsp.buf.signature_help, 'Signature Documentation')

#   -- Lesser used LSP functionality
#   nmap('gD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')
#   nmap('<Leader>wa', vim.lsp.buf.add_workspace_folder, '[W]orkspace [A]dd Folder')
#   nmap('<Leader>wr', vim.lsp.buf.remove_workspace_folder, '[W]orkspace [R]emove Folder')
#   nmap('<Leader>wl', function()
#     print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
#   end, '[W]orkspace [L]ist Folders')

#   -- Create a command `:Format` local to the LSP buffer
#   vim.api.nvim_buf_create_user_command(bufnr, 'Format', function(_)
#     vim.lsp.buf.format()
#   end, { desc = 'Format current buffer with LSP' })
# end

# -- Enable the following language servers
# --  Feel free to add/remove any LSPs that you want here. They will automatically be installed.
# --
# --  Add any additional override configuration in the following tables. They will be passed to
# --  the `settings` field of the server config. You must look up that documentation yourself.
# --
# --  If you want to override the default filetypes that your language server will attach to you can
# --  define the property 'filetypes' to the map in question.
# local servers = {
#   -- clangd = {},
#   -- gopls = {},
#   -- pyright = {},
#   -- rust_analyzer = {},
#   -- tsserver = {},
#   -- html = { filetypes = { 'html', 'twig', 'hbs'} },

#   lua_ls = {
#     Lua = {
#       workspace = { checkThirdParty = false },
#       telemetry = { enable = false },
#     },
#   },
# }

# -- Setup neovim lua configuration
# require('neodev').setup()

# -- nvim-cmp supports additional completion capabilities, so broadcast that to servers
# local capabilities = vim.lsp.protocol.make_client_capabilities()
# capabilities = require('cmp_nvim_lsp').default_capabilities(capabilities)

# -- Ensure the servers above are installed
# local mason_lspconfig = require 'mason-lspconfig'

# mason_lspconfig.setup {
#   ensure_installed = vim.tbl_keys(servers),
# }

# mason_lspconfig.setup_handlers {
#   function(server_name)
#     require('lspconfig')[server_name].setup {
#       capabilities = capabilities,
#       on_attach = on_attach,
#       settings = servers[server_name],
#       filetypes = (servers[server_name] or {}).filetypes,
#     }
#   end
# }

# -- [[ Configure nvim-cmp ]]
# -- See `:help cmp`
# local cmp = require 'cmp'
# local luasnip = require 'luasnip'
# require('luasnip.loaders.from_vscode').lazy_load()
# luasnip.config.setup {}

# cmp.setup {
#   snippet = {
#     expand = function(args)
#       luasnip.lsp_expand(args.body)
#     end,
#   },
#   mapping = cmp.mapping.preset.insert {
#     ['<C-n>'] = cmp.mapping.select_next_item(),
#     ['<C-p>'] = cmp.mapping.select_prev_item(),
#     ['<C-d>'] = cmp.mapping.scroll_docs(-4),
#     ['<C-f>'] = cmp.mapping.scroll_docs(4),
#     ['<C-Space>'] = cmp.mapping.complete {},
#     ['<CR>'] = cmp.mapping.confirm {
#       behavior = cmp.ConfirmBehavior.Replace,
#       select = true,
#     },
#     ['<Tab>'] = cmp.mapping(function(fallback)
#       if cmp.visible() then
#         cmp.select_next_item()
#       elseif luasnip.expand_or_locally_jumpable() then
#         luasnip.expand_or_jump()
#       else
#         fallback()
#       end
#     end, { 'i', 's' }),
#     ['<S-Tab>'] = cmp.mapping(function(fallback)
#       if cmp.visible() then
#         cmp.select_prev_item()
#       elseif luasnip.locally_jumpable(-1) then
#         luasnip.jump(-1)
#       else
#         fallback()
#       end
#     end, { 'i', 's' }),
#   },
#   sources = {
#     { name = 'nvim_lsp' },
#     { name = 'luasnip' },
#   },
# }
