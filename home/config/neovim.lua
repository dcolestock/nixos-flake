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
vim.o.conceallevel = 2

-- Mouse --
vim.o.mouse = "a"
vim.o.mousefocus = true
vim.o.mousemodel = "extend"

-- Appearance --
vim.wo.number = true
vim.o.wrap = true
vim.o.termguicolors = true
vim.cmd.colorscheme("onedark")
vim.o.list = true
vim.opt.listchars = { tab = "├─", trail = "·", nbsp = "⎵" }
vim.o.showmode = true
vim.o.laststatus = 3
vim.wo.signcolumn = "yes"
vim.opt.clipboard = 'unnamed,unnamedplus'

-- ------------- --
-- Autocommands  --
-- ------------- --
vim.api.nvim_create_autocmd("TextYankPost", {
  desc = "Highlight selection on yank",
  group = vim.api.nvim_create_augroup("highlight_yank", {}),
  pattern = "*",
  callback = function()
    vim.highlight.on_yank({ higroup = "IncSearch", timeout = 150 })
  end,
})

-- if vim.version.cmp(vim.version(), { 0, 10, 0 }) >= 0 then
--   local osc52 = require("vim.ui.clipboard.osc52")
--   vim.g.clipboard = {
--     name = "OSC 52",
--     copy = {
--       ["+"] = osc52.copy("+"),
--       ["*"] = osc52.copy("*"),
--     },
--     paste = {
--       ["+"] = osc52.paste("+"),
--       ["*"] = osc52.paste("*"),
--     },
--   }
-- end

-- vim.api.nvim_create_autocmd({ "BufWritePre" }, {
--   desc = "mkdir if folder doesn't exist",
--   pattern = "*",
--   callback = function()
--     local function auto_mkdir(dir, force)
--       if not dir or string.len(dir) == 0 then
--         return
--       end
--       local stats = vim.uv.fs_stat(dir)
--       local is_directory = (stats and stats.type == "directory") or false
--       if string.match(dir, "^%w%+://") or is_directory or string.match(dir, "^suda:") then
--         return
--       end
--       if not force then
--         vim.fn.inputsave()
--         local result = vim.fn.input(string.format('"%s" does not exist. Create? [y/N]', dir), "")
--         if string.len(result) == 0 then
--           print("Canceled")
--           return
--         end
--         vim.fn.inputrestore()
--       end
--       vim.fn.mkdir(dir, "p")
--     end
--     auto_mkdir(vim.fn.expand("<afile>:p:h"), vim.v.cmdbang)
--   end,
--   once = false,
-- })

vim.api.nvim_create_autocmd("FileType", {
  group = myCommandGroup,
  desc = "Set commentstring for devicetree files",
  pattern = "dts",
  callback = function()
    vim.opt_local.commentstring = "// %s"
  end,
})

-- ------------- --
--  Treesitter   --
-- ------------- --
local nix_embedded_lua = vim.treesitter.query.parse(
  "nix",
  [[
  (binding_set
    (binding
      attrpath: (attrpath) @_typename (#eq? @_typename "type")
      expression: (_
                    (string_fragment) @_typevalue (#eq? @_typevalue "lua")))
    (binding
      attrpath: (attrpath) @_configname (#eq? @_configname "config")
      expression: (_
                    (string_fragment) @lua)
      )
    )
  ]]
)

local python_embedded_sql = vim.treesitter.query.parse(
  "python",
  [[
  (assignment
    left: (identifier) @_varname
    (#match? @_varname "query$")
    right: (string (string_content) @sql)
    (#match? @sql "^[\n \t\s]*([sS](elect|ELECT)|[iI](nsert|NSERT)|[uU](pdate|PDATE)|[cC](reate|REATE)|[dD](elete|ELETE)|[aA](lter|LTER)|[dD](rop|ROP))[\n \t\s]+")
  )
  (call
    function: [
      (attribute attribute: (identifier) @_funcname)
      (identifier) @_funcname]
    (#match? @_funcname "^(runquery|read_sql|execute)$")
    arguments: (argument_list . (string (string_content) @sql))
  )
]]
)

local get_root = function(bufnr)
  local parser = vim.treesitter.get_parser(bufnr, "nix", {})
  local tree = parser:parse()[1]
  return tree:root()
end

-- ------------- --
--    Keymaps    --
-- ------------- --
vim.keymap.set("n", ",v", "<Cmd>edit $MYVIMRC<CR>", { desc = "edit config file" })
vim.keymap.set("n", ",,", "<C-^>", { desc = "Swap to Recent Buffer" })

vim.keymap.set("i", "<F9>", "<ESC>yy`]a=<C-R>=<C-R>0<CR><CR>", { desc = "calculate line" })
vim.keymap.set("n", "<leader>=", "yy`]a=<C-R>=<C-R>0<CR><ESC>", { desc = "calculate line" })
vim.keymap.set("v", "<leader>=", "y`]a=<C-R>=<C-R>0<CR><ESC>", { desc = "calculate selection" })

-- Only yank the line if it's not empty
local function smart_dd()
  if vim.api.nvim_get_current_line():match("^%s*$") then
    return '"_dd'
  else
    return "dd"
  end
end
vim.keymap.set("n", "dd", smart_dd, { desc = "Smart dd", noremap = true, expr = true })

-- Repeat or execute macro on each selected line
vim.keymap.set("x", ".", ":norm .<CR>", { desc = "Repeat for each selected line" })
vim.keymap.set("x", "@", ":norm @q<CR>", { desc = "Macro q for each selected line" })

-- Non-LSP rename
vim.keymap.set("v", "<leader>lr", '"hy:%s/<C-r>h/<C-r>h/gc<left><left><left>', { desc = "Rename selected text" })
vim.keymap.set(
  "n",
  "<leader>lr",
  ":%s/\\<<C-r><C-w>\\>/<C-r><C-w>/gcI<Left><Left><Left><Left>",
  { desc = "Rename current word" }
)

local toggle_visuals_settings
local function toggle_visuals()
  if vim.wo.number or vim.o.relativenumber then
    toggle_visuals_settings = {
      number = vim.o.number,
      relativenumber = vim.o.relativenumber,
      list = vim.o.list,
      signcolumn = vim.o.signcolumn,
      miniindent = vim.b.miniindentscope_disable,
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
vim.keymap.set("n", "<F2>", toggle_visuals, { noremap = true, silent = true, desc = "Toggle Decorations" })
vim.keymap.set("n", "<CR>", "<Cmd>nohlsearch<CR><CR>", { desc = "Clear Search" })
vim.keymap.set("n", "ZS", "ZQ", { desc = "Force Quit" })

-- Remap for dealing with word wrap
vim.keymap.set("n", "k", "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
vim.keymap.set("n", "j", "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })

vim.keymap.set("n", "<C-J>", "<C-W><C-J>")
vim.keymap.set("n", "<C-H>", "<C-W><C-H>")
vim.keymap.set("n", "<C-K>", "<C-W><C-K>")
vim.keymap.set("n", "<C-L>", "<C-W><C-L>")

-- getcharstr -- For wordle functions

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

vim.keymap.set("n", "<space>e", vim.diagnostic.open_float, { desc = "Open Float" })
-- vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, { desc = "[Diag] Next" }) -- default in nvim 0.10
-- vim.keymap.set("n", "]d", vim.diagnostic.goto_next, { desc = "[Diag] Prev" }) -- default in nvim 0.10
vim.keymap.set("n", "<space>q", vim.diagnostic.setloclist, { desc = "Set Loc List" })

vim.keymap.set("n", "<space>lf", function()
  require("conform").format({ async = true })
end, { desc = "[Conform] Format" })
vim.api.nvim_create_user_command("Format", function(args)
  local range = nil
  if args.count ~= -1 then
    local end_line = vim.api.nvim_buf_get_lines(0, args.line2 - 1, args.line2, true)[1]
    range = {
      start = { args.line1, 0 },
      ["end"] = { args.line2, end_line:len() },
    }
  end
  require("conform").format({ async = true, lsp_fallback = true, range = range })
end, { range = true })
vim.keymap.set("v", "<space>lf", "<Cmd>Format<CR>", { desc = "[Conform] Format" })

vim.keymap.set({ "n", "v" }, "<space>lc", vim.lsp.buf.code_action, { desc = "C̶o̶d̶e̶ A̶c̶t̶i̶o̶n̶" })
vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("UserLspConfig", {}),
  callback = function(ev)
    local client = vim.lsp.get_client_by_id(ev.data.client_id)
    -- Enable completion triggered by <c-x><c-o>
    vim.api.nvim_buf_set_option(ev.buf, "omnifunc", "v:lua.vim.lsp.omnifunc")

    -- Buffer local mappings.
    vim.keymap.set("n", "gD", vim.lsp.buf.declaration, { buffer = ev.buf, desc = "Declaration" })
    vim.keymap.set("n", "gd", vim.lsp.buf.definition, { buffer = ev.buf, desc = "Definition" })
    vim.keymap.set("n", "<space>D", vim.lsp.buf.type_definition, { buffer = ev.buf, desc = "Type Definition" })
    -- vim.keymap.set("n", "K", vim.lsp.buf.hover, { buffer = ev.buf, desc = "Hover" }) -- default in nvim 0.10
    vim.keymap.set("n", "gi", vim.lsp.buf.implementation, { buffer = ev.buf, desc = "Implementation" })
    vim.keymap.set("n", "<C-k>", vim.lsp.buf.signature_help, { buffer = ev.buf, desc = "Signature Help" })
    -- vim.keymap.set("n", "<space>wa", vim.lsp.buf.add_workspace_folder, { buffer = ev.buf, desc = "Add Workspace Folder" })
    -- vim.keymap.set("n", "<space>wr", vim.lsp.buf.remove_workspace_folder, { buffer = ev.buf, desc = "Remove Workspace Folder" })
    -- vim.keymap.set("n", "<space>wl", function() print(vim.inspect(vim.lsp.buf.list_workspace_folders())) end, { buffer = ev.buf, desc = "List Workspace Folders" })
    if client.server_capabilities.renameProvider then
      vim.keymap.set("n", "<space>lr", vim.lsp.buf.rename, { buffer = ev.buf, desc = "[LSP] Rename" })
    end
    if client.server_capabilities.codeActionProvider then
      vim.keymap.set({ "n", "v" }, "<space>lc", vim.lsp.buf.code_action, { buffer = ev.buf, desc = "Code Action" })
    end
    vim.keymap.set("n", "gr", vim.lsp.buf.references, { buffer = ev.buf, desc = "References" })
    vim.keymap.set("n", "<Leader>lF", function()
      vim.lsp.buf.format({ async = true })
    end, { desc = "[LSP] Format" })

    -- if vim.lsp.inlay_hint then
    --   vim.lsp.inlay_hint(ev.buf, true)
    -- end
  end,
})

vim.keymap.set("v", "p", '"_dP', { desc = "Paste Without Yanking" })
vim.keymap.set(
  "v",
  ",'",
  "<C-v>I'<Esc>gv$A',<ESC>gvgJ$r<Cmd>keeppatterns s/\\(.\\{-\\},\\)\\{10\\}/&\r/g<CR>",
  { desc = "Comma Separate and Quote List" }
)

vim.keymap.set(
  "n",
  ",o",
  "I•<Esc>ml\"lyy:keeppatterns s/[^_]//g<CR>:keeppatterns s/_/<C-r>l\\r/g<CR>J'lV<Esc>f_r#jf_r#jf_r#jf_r#jf_r#v'<:keeppatterns s/•//<CR>gv:s/#/"
)
vim.keymap.set("v", ",a", ":source<CR>", { desc = "Source Vimscript" })
vim.keymap.set("v", ",o", ":lua<CR>", { desc = "Source Lua" })

vim.keymap.set("n", "<Leader>c", "<Cmd>bdelete<CR>", { desc = "Close Buffer" })
vim.keymap.set("n", "<Leader>C", "<Cmd>bdelete!<CR>", { desc = "Force Close Buffer" })

-- lvim.keys.normal_mode[",<Tab>"] = "<Cmd>tabNext<CR>"
-- lvim.keys.normal_mode[",<S-Tab>"] = "<Cmd>tabprevious<CR>"
-- -- lvim.keys.insert_mode["<Up>"] = "<Esc><Up>"
-- -- lvim.keys.insert_mode["<Down>"] = "<Esc><Down>"
-- lvim.builtin.which_key.mappings["x"] = {
--   "<Cmd>new | setlocal ft=python bt=nofile bh=hide noswapfile nu | file Scratch<CR>", "Scratch"
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

-- ZMK related files
vim.filetype.add({
  extension = {
    keymap = "dts",
    overlay = "dts",
  },
  pattern = {
    [".*_defconfig"] = "kconfig",
    [".*/zmk%-config/.*%.conf"] = "kconfig", -- Careful to not include all .conf files
  },
})

-- Help.lua from https://www.reddit.com/r/neovim/comments/1cj3s7s/changing_how_the_help_files_are_shown/l2eczru/

--[[
local ns = vim.api.nvim_create_namespace("filetype.help")

local function ts_query_get_ranges(parser, root, query_string)
  local line_range = {}
  local query = vim.treesitter.query.parse(parser:lang(), query_string)
  for _, matches, _ in query:iter_matches(root, 0) do
    for _, match in ipairs(matches) do
      local start, _, _, stop, _, _ = unpack(vim.treesitter.get_range(match))
      if start ~= stop then table.insert(line_range, ({ start, stop })) end
    end
  end
  return line_range
end

local function get_header_ranges(parser, root)
  local header_ranges = ts_query_get_ranges(parser, root, string.format('(line . [(h1) (h2) (h3)]) @v', type))

  -- If last line of buffer is present in ranges, you remove that range
  -- This is because, modeline is parsed as a heading in older vimdocs
  header_ranges = vim.tbl_filter(function(range)
    return range[2] ~= vim.api.nvim_buf_line_count(0)
  end, header_ranges)


  -- We combine header_ranges & tag ranges only when they overlap
  local tag_ranges = ts_query_get_ranges(parser, root,
    '((line . [(h1) (h2) (h3)]) . (line . (tag)+ . "\\n"?)* @v)')
  for i, header_range in ipairs(header_ranges) do -- Yes O(n^2), I don't really care.
    for _, tag_range in ipairs(tag_ranges) do
      if header_range[1] < tag_range[1]           -- header starts first
          and header_range[2] + 1 >= tag_range[1] -- header end is farther or equal than tag start
          and header_range[2] < tag_range[2] then -- header end is less than tag end
        header_ranges[i][2] = tag_range[2]
      elseif tag_range[1] < header_range[1]       -- tag starts first
          and tag_range[2] + 1 >= header_range[1] -- tag end is farther or equal than header start
          and tag_range[2] < header_range[2] then -- tag end is less than header end
        header_ranges[i][1] = tag_range[1]
      end
    end
  end

  return header_ranges
end

local function extmark_render_box(ranges, hl)
  for _, range in ipairs(ranges) do
    local start, stop = unpack(range)
    local lines = vim.api.nvim_buf_get_lines(0, start, stop, true)
    local max_line_width = vim.iter(lines):fold(0, function(acc, line)
      return math.max(acc, vim.fn.strdisplaywidth(line) + 2)
    end)

    -- If dashes are already present above line, we reuse that line for top border
    local dashes_above = lines[1]:match("^-*$") or lines[1]:match("^=*$")
    local border_top = "╭" .. ("─"):rep(max_line_width) .. "╮"
    if dashes_above then
      vim.api.nvim_buf_set_extmark(0, ns, start, 0, {
        virt_text = { { border_top, hl } },
        virt_text_pos = "overlay",
      })
    else
      vim.api.nvim_buf_set_extmark(0, ns, start, 0, {
        virt_lines = { { { border_top, hl } } },
        virt_lines_above = true,
      })
    end

    -- Render bottom border
    local border_bottom = "╰" .. ("─"):rep(max_line_width) .. "╯"
    vim.api.nvim_buf_set_extmark(0, ns, stop, 0, {
      virt_lines = { { { border_bottom, hl } } },
      virt_lines_above = true,
    })

    -- Render left and right border
    for i = start, stop - 1 do
      if i ~= start or not dashes_above then
        vim.api.nvim_buf_set_extmark(0, ns, i, 0, {
          virt_text = { { "│ ", hl } },
          virt_text_pos = "inline",
        })
        vim.api.nvim_buf_set_extmark(0, ns, i, 0, {
          virt_text = { { "│", hl } },
          virt_text_win_col = max_line_width + 1,
        })
      end
    end
  end
end

vim.api.nvim_create_autocmd("FileType", {
  group = vim.api.nvim_create_augroup("filetype.help", {}),
  pattern = "help",
  callback = function()
    local parser = vim.treesitter.get_parser()
    local tree = parser:parse(true)
    local root = tree[1]:root()

    local code_ranges = ts_query_get_ranges(parser, root, "(code) @v")
    local header_ranges = get_header_ranges(parser, root)

    vim.api.nvim_buf_clear_namespace(0, ns, 0, -1)
    extmark_render_box(code_ranges, "Comment")
    extmark_render_box(header_ranges, "Identifier")
  end
})]]
