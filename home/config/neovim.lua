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


-- ------------- --
--    Keymaps    --
-- ------------- --
vim.keymap.set('n', ',v', '<Cmd>edit $MYVIMRC<CR>')
vim.keymap.set('n', ',,', '<C-^>') 

local toggle_visuals_settings
local function toggle_visuals()
  if vim.wo.number or vim.o.relativenumber then
    toggle_visuals_settings = {
      number = vim.o.number,
      relativenumber = vim.o.relativenumber,
      list = vim.o.list,
      signcolumn = vim.o.signcolumn,
    }
    vim.o.number = false
    vim.o.relativenumber = false
    vim.o.list = false
    vim.o.signcolumn = "no"
  else
    vim.o.number = toggle_visuals_settings["number"]
    vim.o.relativenumber = toggle_visuals_settings["relativenumber"]
    vim.o.list = toggle_visuals_settings["list"]
    vim.o.signcolumn = toggle_visuals_settings["signcolumn"]
  end
end
vim.keymap.set('n', '<F2>', toggle_visuals, {noremap = true, silent = true} )
vim.keymap.set('n', '<CR>', '<Cmd>nohlsearch<CR>')

vim.keymap.set({ 'n', 'v' }, '<Space>', '<Nop>', { silent = true })
vim.keymap.set('n', '<leader>k', '<Nop>', { desc = 'testfolder' })
vim.keymap.set('n', '<leader>kk', '<Cmd>nohlsearch<CR>', { desc = 'test2' })

-- Remap for dealing with word wrap
vim.keymap.set('n', 'k', "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
vim.keymap.set('n', 'j', "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })
