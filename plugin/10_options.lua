-- ┌──────────────────────────┐
-- │ Built-in Neovim behavior │
-- └──────────────────────────┘
--
-- This file defines Neovim's built-in behavior. The goal is to improve overall
-- usability in a way that works best with MINI.
--
-- Here `vim.o.xxx = value` sets default value of option `xxx` to `value`.
-- See `:h 'xxx'` (replace `xxx` with actual option name).
--
-- Option values can be customized on a per buffer or window basis.
-- See 'after/ftplugin/' for common example.
--
-- Notes:
-- - Some options (like `:h 'exrc'`) need to be set before this file is sourced.
--   Set them directly at the bottom of the 'init.lua' file.

-- General ====================================================================
vim.g.mapleader = " " -- Use `<Space>` as <Leader> key

vim.o.mouse = "a" -- Enable mouse
vim.o.mousescroll = "ver:3,hor:6" -- Customize mouse scroll
vim.o.switchbuf = "usetab" -- Use already opened buffers when switching
vim.o.undofile = true -- Enable persistent undo

vim.o.shada = "'100,<50,s10,:1000,/100,@100,h" -- Limit ShaDa file (for startup)

-- Route the system clipboard through OSC 52 instead of xclip/wl-copy. Works
-- uniformly: locally with/without tmux, and over SSH. Combined with tmux's
-- `set-clipboard on`, yanks populate the tmux paste buffer too. See the
-- `TextYankPost` autocmd below for the yank-only mirror that drives this.
local osc52 = require("vim.ui.clipboard.osc52")
vim.g.clipboard = {
  name = "osc52",
  copy = { ["+"] = osc52.copy("+"), ["*"] = osc52.copy("*") },
  paste = { ["+"] = osc52.paste("+"), ["*"] = osc52.paste("*") },
}

-- Enable all filetype plugins and syntax (if not enabled, for better startup)
vim.cmd("filetype plugin indent on")
if vim.fn.exists("syntax_on") ~= 1 then vim.cmd("syntax enable") end

-- UI =========================================================================
vim.o.breakindent = true -- Indent wrapped lines to match line start
vim.o.breakindentopt = "list:-1" -- Add padding for lists (if 'wrap' is set)
vim.o.colorcolumn = "+1" -- Draw column on the right of maximum width
vim.o.cursorline = true -- Enable current line highlighting
vim.o.linebreak = true -- Wrap lines at 'breakat' (if 'wrap' is set)
vim.o.list = true -- Show helpful text indicators
vim.o.number = true -- Show line numbers
vim.o.relativenumber = true -- Show line numbers relative to current line
vim.o.pumborder = "single" -- Use border in popup menu
vim.o.pumheight = 10 -- Make popup menu smaller
vim.o.pummaxwidth = 100 -- Make popup menu not too wide
vim.o.ruler = false -- Don't show cursor coordinates
vim.o.shortmess = "CFOSWaco" -- Disable some built-in completion messages
vim.o.showmode = false -- Don't show mode in command line
vim.o.signcolumn = "yes" -- Always show signcolumn (less flicker)
vim.o.splitbelow = true -- Horizontal splits will be below
vim.o.splitkeep = "screen" -- Reduce scroll during window split
vim.o.splitright = true -- Vertical splits will be to the right
vim.o.winborder = "single" -- Use border in floating windows
vim.o.wrap = false -- Don't visually wrap lines (toggle with \w)

vim.o.cursorlineopt = "screenline,number" -- Show cursor line per screen line

-- Special UI symbols. More is set via 'mini.basics' later.
vim.o.fillchars = "eob: ,fold:╌"
vim.o.listchars = "extends:…,nbsp:␣,precedes:…,tab:> ,trail:·"

-- Folds (see `:h fold-commands`, `:h zM`, `:h zR`, `:h zA`, `:h zj`)
-- Tree-sitter expression folding is accurate where a parser is installed and
-- gracefully no-ops elsewhere. `foldlevel*=99` keeps everything open by default;
-- close folds explicitly with `zM`, open with `zR`.
vim.o.foldexpr = "v:lua.vim.treesitter.foldexpr()"
vim.o.foldmethod = "expr"
vim.o.foldlevel = 99
vim.o.foldlevelstart = 99
vim.o.foldnestmax = 10
vim.o.foldtext = ""

-- Editing ====================================================================
vim.o.autoindent = true -- Use auto indent
vim.o.expandtab = true -- Convert tabs to spaces
vim.o.fixendofline = true -- Add a trailing newline on write if missing (default)
vim.o.formatoptions = "rqnl1j" -- Improve comment editing
vim.o.ignorecase = true -- Ignore case during search
vim.o.incsearch = true -- Show search matches while typing
vim.o.infercase = true -- Infer case in built-in completion
vim.o.shiftwidth = 2 -- Use this number of spaces for indentation
vim.o.smartcase = true -- Respect case if search pattern has upper case
vim.o.smartindent = true -- Make indenting smart
vim.o.spelloptions = "camel" -- Treat camelCase word parts as separate words
vim.o.tabstop = 2 -- Show tab as this number of spaces
vim.o.virtualedit = "block" -- Allow going past end of line in blockwise mode

-- Note: 'iskeyword' kept at default (`@,48-57,_,192-255`) — adding `-` quietly
-- changes built-in word motions (`*`, `diw`) and surprises in shell/markdown.

-- Pattern for a start of numbered list (used in `gw`). This reads as
-- "Start of list item is: at least one special character (digit, -, +, *)
-- possibly followed by punctuation (. or `)`) followed by at least one space".
vim.o.formatlistpat = [[^\s*[0-9\-\+\*]\+[\.\)]*\s\+]]

-- Built-in completion
vim.o.complete = ".,w,b,kspell" -- Use less sources
vim.o.completeopt = "menuone,noselect,fuzzy,nosort" -- Use custom behavior
vim.o.completetimeout = 100 -- Limit sources delay

-- Autocommands ===============================================================

-- Don't auto-wrap comments and don't insert comment leader after hitting 'o'.
-- Do on `FileType` to always override these changes from filetype plugins.
local f = function() vim.cmd("setlocal formatoptions-=c formatoptions-=o") end
Config.new_autocmd("FileType", nil, f, "Proper 'formatoptions'")

-- Mirror yanks (only) to the system clipboard. Keeps `clipboard=""` so `dd`/`dw`
-- don't clobber `+`, while still letting yanked text paste in tmux/browser/other
-- nvim instances. Use `gp`/`gP` from mini.basics to read `+` back in.
local mirror_yank = function()
  if vim.v.event.operator == "y" then vim.fn.setreg("+", vim.fn.getreg('"'), vim.fn.getregtype('"')) end
end
Config.new_autocmd("TextYankPost", nil, mirror_yank, "Mirror yanks to clipboard")

-- Strip trailing whitespace on save. Skip `markdown`: two trailing spaces are
-- a hard line break there, stripping silently would corrupt formatting.
-- For format-on-save filetypes (python, bash, etc.) the formatter handles
-- this anyway; the autocmd is a no-op there but keeps the rule global.
local trim_trailing_ws = function()
  if vim.bo.filetype == "markdown" then return end
  local pos = vim.api.nvim_win_get_cursor(0)
  vim.cmd([[silent! keepjumps keeppatterns %s/\s\+$//]])
  pcall(vim.api.nvim_win_set_cursor, 0, pos)
end
Config.new_autocmd("BufWritePre", "*", trim_trailing_ws, "Strip trailing whitespace")

-- There are other autocommands created by 'mini.basics'. See 'plugin/30_mini.lua'.

-- Diagnostics ================================================================

-- Neovim has built-in support for showing diagnostic messages. This configures
-- a more conservative display while still being useful.
-- See `:h vim.diagnostic` and `:h vim.diagnostic.config()`.
local diagnostic_opts = {
  -- Show signs on top of any other sign, but only for warnings and errors
  signs = { priority = 9999, severity = { min = "WARN", max = "ERROR" } },

  -- Show all diagnostics as underline (for their messages type `<Leader>ld`)
  underline = { severity = { min = "HINT", max = "ERROR" } },

  -- Show details inline for the current line at WARN+ severity. See
  -- `<Leader>ld` for the full popup with all severities.
  virtual_lines = false,
  virtual_text = {
    current_line = true,
    severity = { min = "WARN", max = "ERROR" },
  },

  -- Don't update diagnostics when typing
  update_in_insert = false,
}

-- Use `later()` to avoid sourcing `vim.diagnostic` on startup
Config.later(function() vim.diagnostic.config(diagnostic_opts) end)
