-- ------------- --
-- Neovim Config --
-- ------------- --
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Backups --
vim.o.backupdir = vim.fn.expand("~/.nvim/backup//")
vim.o.writebackup = true
vim.o.backup = true
vim.o.directory = vim.fn.expand("~/.nvim/swap//")
vim.o.swapfile = true
vim.o.undodir = vim.fn.expand("~/.nvim/undo//")
vim.o.undofile = true

-- Behavior --
vim.o.tabstop = 2
vim.o.shiftwidth = 2
vim.o.expandtab = true
vim.wo.number = true
vim.o.wrap = true
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
vim.o.termguicolors = true
vim.cmd.colorscheme("gruvbox")
vim.o.list = true
vim.opt.listchars = { tab = "├─", trail = "·", nbsp = "⎵" }
vim.o.showmode = true
vim.o.laststatus = 3
vim.wo.signcolumn = "yes"

-- Highlight on yank --
vim.api.nvim_create_autocmd("TextYankPost", {
  group = vim.api.nvim_create_augroup("highlight_yank", {}),
  desc = "Hightlight selection on yank",
  pattern = "*",
  callback = function()
    vim.highlight.on_yank { higroup = "IncSearch", timeout = 150 }
  end,
})
