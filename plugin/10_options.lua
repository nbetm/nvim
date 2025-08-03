-- Leader key -----------------------------------------------------------------
vim.g.mapleader = " "

-- General --------------------------------------------------------------------
vim.o.mouse = "nvi" -- Enable mouse in normal, visual, insert modes (exclude command-line)
vim.o.mousescroll = "ver:3,hor:6" -- Default mouse scroll speeds
vim.o.switchbuf = "uselast" -- Use last accessed window for buffer switching
vim.o.undofile = true -- Enable persistent undo

vim.cmd("filetype plugin indent on") -- Enable all filetype plugins

-- Limit what is stored in Shared Data file
--  - Remember marks for last 100 files
--  - Save max 50 lines of registers
--  - Skip items larger than 10KB
--  - Save 1000 command-line history entries
--  - Save 100 search patterns
--  - Save 100 input-line history entries
--  - Disable hlsearch when loading
vim.o.shada = "'100,<50,s10,:1000,/100,@100,h"

-- UI -------------------------------------------------------------------------
vim.o.breakindent = true -- Indent wrapped lines to match line start
vim.o.textwidth = 80 -- Primary line length target
vim.o.colorcolumn = "80,120" -- Show both 80 (ideal) and 120 (max) columns
vim.o.cursorline = true -- Highlight current line
vim.o.linebreak = true -- Wrap at word boundaries
vim.o.list = true -- Show whitespace characters
vim.o.number = true -- Show line numbers
vim.o.pumheight = 15 -- Reasonable popup menu height
vim.o.ruler = true -- Show cursor position
vim.o.shortmess = "CFOSWaco" -- Reduce verbose messages (includes "Scanning...")
vim.o.showmode = false -- Let statusline handle mode display
vim.o.signcolumn = "yes" -- Always show sign column
vim.o.splitbelow = true -- New horizontal splits below
vim.o.splitright = true -- New vertical splits right
vim.o.wrap = false -- No line wrapping

-- Special characters (ASCII-safe, practical)
vim.o.fillchars = "eob: ,fold:-,vert:│,foldopen:-,foldclose:+"
vim.o.listchars = "tab:> ,trail:·,extends:>,precedes:<,nbsp:+"
vim.o.cursorlineopt = "screenline,number" -- Show cursor line only screen line when wrapped
vim.o.breakindentopt = "list:-1" -- Add padding for lists when 'wrap' is on

-- nvim 0.11.x
vim.o.splitkeep = "screen" -- Reduce scroll during window split
vim.o.termguicolors = true -- Enable gui colors
vim.o.completeopt = "menuone,noselect,fuzzy" -- Fuzzy completion
vim.o.winborder = "single" -- Single-line borders (modern, clean)

-- Editing --------------------------------------------------------------------
vim.o.autoindent = true -- Use auto indent
vim.o.expandtab = true -- Convert tabs to spaces
vim.o.formatoptions = "crqnl1j" -- Auto-wrap comments + other improvements
vim.o.ignorecase = true -- Ignore case when searching
vim.o.incsearch = true -- Show search results while typing
vim.o.infercase = true -- Infer letter cases for completion
vim.o.smartcase = true -- Case-sensitive if uppercase in pattern
vim.o.smartindent = true -- Make indenting smart
vim.o.shiftwidth = 4 -- Default 4-space indentation
vim.o.tabstop = 4 -- Tab display width
vim.o.softtabstop = 4 -- Backspace deletes 4 spaces
vim.o.virtualedit = "block" -- Allow cursor past end of line in visual block

-- List formatting pattern for gw command
vim.o.formatlistpat = [[^\s*[0-9\-\+\*]\+[\.\)]*\s\+]]
vim.o.complete = ".,w,b,kspell" -- Include spell checking in completion sources

-- Folds ----------------------------------------------------------------------
vim.o.foldmethod = "expr" -- Use expression folding
vim.o.foldexpr = "v:lua.vim.treesitter.foldexpr()" -- TreeSitter-based folding
vim.o.foldlevel = 99 -- Start with all folds open
vim.o.foldlevelstart = 99 -- Open all folds on file open
vim.o.foldnestmax = 10 -- Reasonable nesting limit
vim.o.foldtext = "" -- Use underlying text (nvim 0.10+)

-- Custom autocommands --------------------------------------------------------
local augroup = vim.api.nvim_create_augroup("CustomSettings", {})
vim.api.nvim_create_autocmd("FileType", {
  group = augroup,
  callback = function()
    -- Keep comment auto-wrap (c) but remove problematic options
    vim.cmd("setlocal formatoptions-=o formatoptions-=t")
    -- Ensure we have our desired options
    vim.cmd("setlocal formatoptions+=crqnl1j")
  end,
  desc = "Ensure proper formatoptions with comment wrapping",
})

-- Diagnostics ----------------------------------------------------------------
local diagnostic_opts = {
  -- Define how diagnostic entries should be shown
  signs = { priority = 9999, severity = { min = "WARN", max = "ERROR" } },
  underline = { severity = { min = "HINT", max = "ERROR" } },
  virtual_lines = false,
  virtual_text = { current_line = true, severity = { min = "ERROR", max = "ERROR" } },

  -- Don't update diagnostics when typing
  update_in_insert = false,
}

-- Use `later()` to avoid sourcing `vim.diagnostic` on startup
MiniDeps.later(function() vim.diagnostic.config(diagnostic_opts) end)

-- Spelling -------------------------------------------------------------------
vim.o.spelllang = "en" -- English spell checking
vim.o.spelloptions = "camel" -- Treat camelCase as separate words
