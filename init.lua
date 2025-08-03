-- Bootstrap 'mini.nvim' manually in a way that it gets managed by 'mini.deps'
local mini_path = vim.fn.stdpath("data") .. "/site/pack/deps/start/mini.nvim"
if not vim.loop.fs_stat(mini_path) then
  vim.cmd("echo 'Installing `mini.nvim`' | redraw")
  local clone_cmd = { "git", "clone", "--filter=blob:none", "https://github.com/echasnovski/mini.nvim", mini_path }
  vim.fn.system(clone_cmd)
  vim.cmd("packadd mini.nvim | helptags ALL")
  vim.cmd("echo 'Installed `mini.nvim`' | redraw")
end

-- Set up 'mini.deps' immediately to have its `now()` and `later()` helpers
require("mini.deps").setup()

-- Define main config table to be able to use it in scripts
_G.Config = {}

vim.g.mapleader = " "

require("mini.ai").setup() -- a/i textobjects
require("mini.align").setup() -- aligning
require("mini.bracketed").setup() -- unimpaired bindings with TS
require("mini.comment").setup() -- TS-wise comments
require("mini.icons").setup() -- icons
require("mini.jump").setup() -- fFtT work past a line
require("mini.pairs").setup() -- pair brackets
require("mini.statusline").setup() -- statusline
require("mini.notify").setup() -- notifications
require("mini.completion").setup() -- autocompletion and signature help
require("mini.git").setup()
require("mini.diff").setup()
require("mini.files").setup()

local miniclue = require("mini.clue")
miniclue.setup({
  triggers = {
    -- Leader triggers
    { mode = "n", keys = "<Leader>" },
    { mode = "x", keys = "<Leader>" },

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
