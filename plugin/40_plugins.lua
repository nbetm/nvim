-- ┌─────────────────────────┐
-- │ Plugins outside of MINI │
-- └─────────────────────────┘
--
-- This file contains installation and configuration of plugins outside of MINI.
-- They significantly improve user experience in a way not yet possible with MINI.
-- These are mostly plugins that provide programming language specific behavior.
--
-- Use this file to install and configure other such plugins.

-- Make concise helpers for installing/adding plugins in two stages
local add = vim.pack.add
local now_if_args, later = Config.now_if_args, Config.later

-- Tree-sitter ================================================================

-- Tree-sitter is a tool for fast incremental parsing. It converts text into
-- a hierarchical structure (called tree) that can be used to implement advanced
-- and/or more precise actions: syntax highlighting, textobjects, indent, etc.
--
-- Tree-sitter support is built into Neovim (see `:h treesitter`). However, it
-- requires two extra pieces that don't come with Neovim directly:
-- - Language parsers: programs that convert text into trees. Some are built-in
--   (like for Lua), 'nvim-treesitter' provides many others.
--   NOTE: It requires third party software to build and install parsers.
--   See the link for more info in "Requirements" section of the MiniMax README.
-- - Query files: definitions of how to extract information from trees in
--   a useful manner (see `:h treesitter-query`). 'nvim-treesitter' also provides
--   these, while 'nvim-treesitter-textobjects' provides the ones for Neovim
--   textobjects (see `:h text-objects`, `:h MiniAi.gen_spec.treesitter()`).
--
-- Add these plugins now if file (and not 'mini.starter') is shown after startup.
--
-- Troubleshooting:
-- - Run `:checkhealth vim.treesitter nvim-treesitter` to see potential issues.
-- - In case of errors related to queries for Neovim bundled parsers (like `lua`,
--   `vimdoc`, `markdown`, etc.), manually install them via 'nvim-treesitter'
--   with `:TSInstall <language>`. Be sure to have necessary system dependencies
--   (see MiniMax README section for software requirements).
now_if_args(function()
  -- Define hook to update tree-sitter parsers after plugin is updated
  local ts_update = function() vim.cmd("TSUpdate") end
  Config.on_packchanged("nvim-treesitter", { "update" }, ts_update, ":TSUpdate")

  add({
    "https://github.com/nvim-treesitter/nvim-treesitter",
    "https://github.com/nvim-treesitter/nvim-treesitter-textobjects",
  })

  -- Define languages which will have parsers installed and auto enabled.
  -- Restart Neovim once after editing; wait for installation before opening files.
  -- See `:=require('nvim-treesitter').get_available()` for the full list.
  local languages = {
    -- Built-in to Neovim 0.12 (listed for completeness; install is a no-op):
    "c",
    "lua",
    "markdown",
    "markdown_inline",
    "query",
    "vim",
    "vimdoc",
    -- Daily-driver languages
    "bash",
    "make",
    "python",
    "rust",
    "go",
    "json",
    "yaml",
    "toml",
    "ini",
    "nix",
    "dockerfile",
    "hcl",
    -- Templating / data
    "jinja",
    "jinja_inline",
    -- Web stack. `html` doubles as the markdown injection target
    -- for inline `<tag>`s in .md files; `css` and `javascript` then
    -- inject from `<style>` and `<script>` blocks inside html.
    "html",
    "css",
    "javascript",
    "typescript",
    -- Diff / SCM helpers
    "diff",
    "git_config",
    "git_rebase",
    "gitcommit",
    "gitignore",
    "regex",
  }
  local isnt_installed = function(lang) return #vim.api.nvim_get_runtime_file("parser/" .. lang .. ".*", false) == 0 end
  local to_install = vim.tbl_filter(isnt_installed, languages)
  if #to_install > 0 then require("nvim-treesitter").install(to_install) end

  -- Route compound filetypes to base grammars. Without this, opening (e.g.)
  -- a docker-compose file (filetype `yaml.docker-compose`) wouldn't start
  -- tree-sitter because no `yaml.docker-compose` parser exists. The base
  -- `yaml` grammar handles them all.
  vim.treesitter.language.register("yaml", {
    "yaml.docker-compose",
    "yaml.ansible",
    "yaml.gitlab",
    "yaml.helm-values",
  })
  vim.treesitter.language.register("markdown", { "markdown.mdx" })

  -- Enable tree-sitter after opening a file for a target language
  local filetypes = {}
  for _, lang in ipairs(languages) do
    for _, ft in ipairs(vim.treesitter.language.get_filetypes(lang)) do
      table.insert(filetypes, ft)
    end
  end
  local ts_start = function(ev) vim.treesitter.start(ev.buf) end
  Config.new_autocmd("FileType", filetypes, ts_start, "Start tree-sitter")
end)

-- Language servers ===========================================================

-- Language Server Protocol (LSP) is a set of conventions that power creation of
-- language specific tools. It requires two parts:
-- - Server - program that performs language specific computations.
-- - Client - program that asks server for computations and shows results.
--
-- Here Neovim itself is a client (see `:h vim.lsp`). Language servers need to
-- be installed separately based on your OS, CLI tools, and preferences.
-- See note about 'mason.nvim' at the bottom of the file.
--
-- Neovim's team collects commonly used configurations for most language servers
-- inside 'neovim/nvim-lspconfig' plugin.
--
-- Add it now if file (and not 'mini.starter') is shown after startup.
--
-- Troubleshooting:
-- - Run `:checkhealth vim.lsp` to see potential issues.
now_if_args(function()
  add({ "https://github.com/neovim/nvim-lspconfig" })

  -- Enable language servers via 'nvim-lspconfig' rules.
  -- Per-server config (when needed) lives in 'after/lsp/<name>.lua'.
  -- Each server's CLI binary must be available on PATH (install via Nix etc.).
  vim.lsp.enable({
    -- Lua
    "lua_ls",
    -- Python
    "pyright",
    "ruff",
    -- Shell
    "bashls",
    -- Data / config
    "jsonls",
    "yamlls",
    "taplo",
    -- Markup
    "marksman",
    -- Nix
    "nixd",
    -- Containers
    "dockerls",
    "docker_compose_language_service",
    -- Templates
    "jinja_lsp",
    -- Ansible (activates on ansible-flavored YAML)
    "ansiblels",
  })
end)

-- Formatting =================================================================

-- Programs dedicated to text formatting (a.k.a. formatters) are very useful.
-- Neovim has built-in tools for text formatting (see `:h gq` and `:h 'formatprg'`).
-- They can be used to configure external programs, but it might become tedious.
--
-- The 'stevearc/conform.nvim' plugin is a good and maintained solution for easier
-- formatting setup.
later(function()
  add({ "https://github.com/stevearc/conform.nvim" })

  -- See also:
  -- - `:h Conform`
  -- - `:h conform-options`
  -- - `:h conform-formatters`
  -- Filetypes that get formatted on save. Other filetypes still format on
  -- demand via `<Leader>lf`. Adding here is the only switch needed.
  local format_on_save_fts = {
    bash = true,
    hcl = true,
    markdown = true,
    python = true,
    sh = true,
    terraform = true,
  }

  require("conform").setup({
    default_format_opts = {
      -- Allow formatting from LSP server if no dedicated formatter is available
      lsp_format = "fallback",
    },
    -- Map of filetype to formatters. CLI binaries must be on PATH.
    -- Python's ruff formatter reads `pyproject.toml` for line-length / rules.
    formatters_by_ft = {
      lua = { "stylua" },
      python = { "ruff_format" },
      sh = { "shfmt" },
      bash = { "shfmt" },
      json = { "prettier" },
      jsonc = { "prettier" },
      yaml = { "yamlfmt" },
      toml = { "taplo" },
      markdown = { "mdformat" },
      nix = { "nixfmt" },
      dockerfile = { "dockerfmt" },
      terraform = { "terraform_fmt" },
      hcl = { "terraform_fmt" },
    },
    formatters = {
      -- 4-space indent, indent switch cases (override shfmt's tab default).
      shfmt = { prepend_args = { "-i", "4", "-ci" } },
    },
    format_on_save = function(bufnr)
      if format_on_save_fts[vim.bo[bufnr].filetype] then return { timeout_ms = 1000, lsp_format = "fallback" } end
    end,
  })
end)

-- Snippets ===================================================================

-- Although 'mini.snippets' provides functionality to manage snippet files, it
-- deliberately doesn't come with those.
--
-- The 'rafamadriz/friendly-snippets' is currently the largest collection of
-- snippet files. They are organized in 'snippets/' directory (mostly) per language.
-- 'mini.snippets' is designed to work with it as seamlessly as possible.
-- See `:h MiniSnippets.gen_loader.from_lang()`.
later(function() add({ "https://github.com/rafamadriz/friendly-snippets" }) end)

-- GitHub PR review ===========================================================

-- 'octo.nvim' brings the GitHub PR review workflow into Neovim: open a PR,
-- navigate the diff, leave inline comments, submit a multi-comment review.
-- Used here as a review-only tool — PR browsing/management lives in `gh-dash`.
--
-- Typical flow:
-- - `gh pr checkout <num>` (or pick from gh-dash) to switch branches
-- - `:Octo pr edit` to open the PR for the current branch
-- - `:Octo review start` to enter the review session
-- - Navigate diff with built-in keymaps; `<Space>ca` leaves an inline comment
-- - `:Octo review submit` to send the review
--
-- See also:
-- - `:h octo` and `:Octo` (top-level command discovery)
-- - https://github.com/pwntester/octo.nvim#commands for the full list
later(function()
  add({
    "https://github.com/nvim-lua/plenary.nvim",
    "https://github.com/pwntester/octo.nvim",
  })
  require("octo").setup({
    -- `default` uses `vim.ui.select`, which is already routed to mini.pick
    -- (see plugin/30_mini.lua). Avoids pulling in telescope/fzf-lua/snacks
    -- just for this plugin's pickers.
    picker = "default",
  })
end)

-- Honorable mentions =========================================================

-- 'mason-org/mason.nvim' (a.k.a. "Mason") is a great tool (package manager) for
-- installing external language servers, formatters, and linters. It provides
-- a unified interface for installing, updating, and deleting such programs.
--
-- The caveat is that these programs will be set up to be mostly used inside Neovim.
-- If you need them to work elsewhere, consider using other package managers.
--
-- You can use it like so:
-- now_if_args(function()
--   add({ 'https://github.com/mason-org/mason.nvim' })
--   require('mason').setup()
-- end)

-- Color scheme: see 'plugin/30_mini.lua' (`everforest` is installed and applied
-- there alongside the early `now()` setup so statusline highlights derive from
-- it). Switch by editing that block.
