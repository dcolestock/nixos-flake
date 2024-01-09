-- ------------- --
-- Neovim Config --
-- ------------- --

-- ------------- --
--   Settings    --
-- ------------- --
vim.g.mapleader = " "
vim.g.maplocalleader = " "
vim.o.undofile = true

-- Behavior --
vim.o.tabstop = 2
vim.o.shiftwidth = 2
vim.o.expandtab = true
vim.o.breakindent = true
vim.o.confirm = true
vim.o.startofline = true
vim.o.smartcase = true
vim.o.ignorecase = true
vim.o.timeout = true
vim.o.timeoutlen = 300
vim.o.updatetime = 250
vim.o.completeopt = "menuone,noselect"
vim.o.clipboard = "unnamedplus"

-- Mouse --
vim.o.mouse = "a"
vim.o.mousefocus = true
vim.o.mousemodel = "extend"

-- Apperance --
vim.wo.number = true
vim.o.wrap = true
vim.o.termguicolors = true
vim.cmd.colorscheme("onedark")
vim.o.list = true
vim.opt.listchars = { tab = "├─", trail = "·", nbsp = "⎵" }
vim.o.showmode = true
vim.o.laststatus = 3
vim.wo.signcolumn = "yes"

-- ------------- --
-- Autocommands  --
-- ------------- --
vim.api.nvim_create_autocmd("TextYankPost", {
  group = vim.api.nvim_create_augroup("highlight_yank", {}),
  desc = "Hightlight selection on yank",
  pattern = "*",
  callback = function()
    vim.highlight.on_yank { higroup = "IncSearch", timeout = 150 }
  end,
})

if vim.version.cmp(vim.version(), { 0, 10, 0 }) >= 0 then
  local osc52 = require('vim.ui.clipboard.osc52')
  vim.g.clipboard = {
    name = 'OSC 52',
    copy = {
      ['+'] = osc52.copy('+'),
      ['*'] = osc52.copy('*'),
    },
    paste = {
      ['+'] = osc52.paste('+'),
      ['*'] = osc52.paste('*'),
    },
  }
end

-- ------------- --
--    Keymaps    --
-- ------------- --
vim.keymap.set('n', ',v', '<Cmd>edit $MYVIMRC<CR>', {desc = "edit config file"})
vim.keymap.set('n', ',,', '<C-^>', {desc = "Swap to Recent Buffer" })

local toggle_visuals_settings
local function toggle_visuals()
  if vim.wo.number or vim.o.relativenumber then
    toggle_visuals_settings = {
      number = vim.o.number,
      relativenumber = vim.o.relativenumber,
      list = vim.o.list,
      signcolumn = vim.o.signcolumn,
      miniindent = vim.b.miniindentscope_disable
    }
    vim.o.number = false
    vim.o.relativenumber = false
    vim.o.list = false
    vim.o.signcolumn = "no"
    vim.b.miniindentscope_disable = true
  else
    vim.o.number = toggle_visuals_settings["number"]
    vim.o.relativenumber = toggle_visuals_settings["relativenumber"]
    vim.o.list = toggle_visuals_settings["list"]
    vim.o.signcolumn = toggle_visuals_settings["signcolumn"]
    vim.b.miniindentscope_disable = toggle_visuals_settings["miniindent"]
  end
end
vim.keymap.set('n', '<F2>', toggle_visuals, {noremap = true, silent = true, desc = "Toggle Decorations"} )
vim.keymap.set('n', '<CR>', '<Cmd>nohlsearch<CR><CR>', { desc = "Clear Search" })
vim.keymap.set('n', 'ZS', 'ZQ', { desc = "Force Quit" })

-- Remap for dealing with word wrap
vim.keymap.set('n', 'k', "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
vim.keymap.set('n', 'j', "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })

-- vim.keymap.set('n', '<Leader>l', '<Nop>', { desc = 'LSP' })
-- vim.keymap.set('n', '<Leader>lf',  function() vim.lsp.buf.format { async = true } end, { desc = "Format" })
-- vim.keymap.set('n', '<Leader>ld',  vim.lsp.buf.definition, { desc = "Definition" })
-- vim.keymap.set('n', '<Leader>lt',  vim.lsp.buf.type_definition, { desc = "Definition" })
-- vim.keymap.set('n', '<Leader>lD',  vim.lsp.buf.declaration, { desc = "Declaration" })
-- vim.keymap.set('n', '<Leader>li',  vim.lsp.buf.implementation, { desc = "Implementation" })
-- vim.keymap.set('n', '<Leader>lr',  vim.lsp.buf.rename, { desc = "Rename" })
-- vim.keymap.set('n', '<Leader>lR',  vim.lsp.buf.references, { desc = "References" })
-- vim.keymap.set('n', '<Leader>l ',  vim.lsp.buf.hover, { desc = "Hover" })
-- vim.keymap.set({'n', 'v'}, '<Leader>la',  vim.lsp.buf.code_action, { desc = "Code Action" })
-- vim.keymap.set('n', '<Leader>ls',  vim.lsp.buf.signature_help, { desc = "Signature Help" })
-- vim.keymap.set('n', '[d',  vim.diagnostic.goto_prev, { desc = "[Diag] Goto Prev" })
-- vim.keymap.set('n', ']d',  vim.diagnostic.goto_next, { desc = "[Diag] Goto Next" })
-- vim.keymap.set('n', '<Leader>lpf',  vim.diagnostic.open_float, { desc = "Open Float" })
-- vim.keymap.set('n', '<Leader>lps',  vim.diagnostic.setloclist, { desc = "Set Loc List" })
--

vim.keymap.set('n', '<space>e', vim.diagnostic.open_float, { desc = "Open Float" })
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, { desc = "[Diag] Next" })
vim.keymap.set('n', ']d', vim.diagnostic.goto_next, { desc = "[Diag] Prev" })
vim.keymap.set('n', '<space>q', vim.diagnostic.setloclist, { desc = "Set Loc List" })


vim.api.nvim_create_autocmd('LspAttach', {
  group = vim.api.nvim_create_augroup('UserLspConfig', {}),
  callback = function(ev)
    -- Enable completion triggered by <c-x><c-o>
    vim.bo[ev.buf].omnifunc = 'v:lua.vim.lsp.omnifunc'

    -- Buffer local mappings.
    vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, { buffer = ev.buf, desc = "Declaration" })
    vim.keymap.set('n', 'gd', vim.lsp.buf.definition, { buffer = ev.buf, desc = "Definition" })
    vim.keymap.set('n', 'K', vim.lsp.buf.hover, { buffer = ev.buf, desc = "Hover" })
    vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, { buffer = ev.buf, desc = "Implementation" })
    vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, { buffer = ev.buf, desc = "Signature Help" })
    vim.keymap.set('n', '<space>wa', vim.lsp.buf.add_workspace_folder, { buffer = ev.buf, desc = "Add Workspace Folder" })
    vim.keymap.set('n', '<space>wr', vim.lsp.buf.remove_workspace_folder, { buffer = ev.buf, desc = "Remove Workspace Folder" })
    vim.keymap.set('n', '<space>wl', function()
      print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
    end, { buffer = ev.buf, desc = "List Workspace Folders" })
    vim.keymap.set('n', '<space>D', vim.lsp.buf.type_definition, { buffer = ev.buf, desc = "Type Definition" })
    vim.keymap.set('n', '<space>lr', vim.lsp.buf.rename, { buffer = ev.buf, desc = "Rename" })
    vim.keymap.set({ 'n', 'v' }, '<space>ca', vim.lsp.buf.code_action, { buffer = ev.buf, desc = "Code Action" })
    vim.keymap.set('n', 'gr', vim.lsp.buf.references, { buffer = ev.buf, desc = "References" })
    vim.keymap.set('n', '<space>lf', function() vim.lsp.buf.format { async = true } end, { buffer = ev.buf, desc = "Format" })
  end,
})


vim.keymap.set('v', 'p',  "\"_dP", { desc = "Paste Without Yanking" })
vim.keymap.set('v', ",'",  "<C-v>I'<Esc>gv$A',<ESC>gvgJ$r<Cmd>keeppatterns s/\\(.\\{-\\},\\)\\{10\\}/&\r/g<CR>", { desc = "Comma Separate and Quote List" })

vim.keymap.set('n', '<Leader>c', "<Cmd>bdelete<CR>", { desc = "Close Buffer" })
vim.keymap.set('n', '<Leader>C', "<Cmd>bdelete!<CR>", { desc = "Force Close Buffer" })




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
          --
