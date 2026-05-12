# CLAUDE.md

This file provides guidance to Claude Code when working with code in this repository.
See @README.md for project overview.

## Project Overview

Personal Neovim config built around `mini.nvim`.
Based on the **MiniMax** starter template.

## Tooling

- **Format Lua:** `stylua .` (config in `.stylua.toml`).
- **Plugin manager:** built-in `vim.pack`.
  State in `nvim-pack-lock.json`.
  Update from inside Neovim with `:lua vim.pack.update()` then `:write` to confirm.
- **Update treesitter parsers:** `:TSUpdate` (runs automatically via `on_packchanged` hook when `nvim-treesitter` itself updates).
- **Health checks:** `:checkhealth vim.lsp vim.treesitter nvim-treesitter provider`.
- **Lua LS workspace:** globals declared in `.luarc.json`.

## Staged loading

`init.lua` exposes `_G.Config` with helpers wrapped in `mini.misc.safely` (so one failure doesn't cascade): `now`, `later`, `now_if_args`, `on_event`, `on_filetype`, `new_autocmd`, `on_packchanged`.
See `init.lua` for what each does.

## Leader mappings

Leader is `<Space>`.
Two-key convention: first key is the semantic group, second is the action.
Lowercase second key = narrow scope (current buffer / file dir / cwd), uppercase = broad scope (workspace / all).
Mirrors Vim's `gd` vs `gD` split.
Example: `<Leader>s` document LSP symbols, `<Leader>S` workspace LSP symbols.
New groups need an entry in `Config.leader_group_clues` (`plugin/20_keymaps.lua`) so `mini.clue` shows hints.

## Subsystems

- **LSP servers:** per-server config in `after/lsp/<name>.lua`, enabled via `vim.lsp.enable` in `plugin/40_plugins.lua`.
- **Formatters:** `conform.setup({ formatters_by_ft })` in `plugin/40_plugins.lua`.
  Trigger with `<Leader>cf`.
  Format-on-save is allowlisted in the same call.
- **Snippets:** loaded in `plugin/30_mini.lua` from `snippets/global.json`, `after/snippets/<lang>.json`, and `friendly-snippets`.
  Expand with `<C-j>` in Insert.

## Principles

- **Read mini docs first.** Before customizing a mini module, try `:h MiniXxx.config` (knobs), then `-examples` (working setups), then `-overview` (concepts).
  When help is ambiguous, source is canonical.
  Many problems have a documented mini-native lever; don't write a workaround when there's a knob.
- **Investigate at the right layer.** If filtering noise from a server (LSP progress, diagnostics), check whether the upstream layer can be told to stop emitting first: LSP `capabilities`, server `settings`, server CLI flags.
  Root-cause beats post-arrival filtering.

## Where to look

`<pack>` = `~/.local/share/nvim/site/pack/core/opt/`.

- **Mini knobs / source:** `:h MiniXxx.config`, `:h MiniXxx-examples`, `:h MiniXxx-overview`.
  Source at `<pack>/mini.nvim/lua/mini/<module>.lua`.
- **nvim-lspconfig server defaults:** `<pack>/nvim-lspconfig/lsp/<server>.lua` (cmd, filetypes, default capabilities, root markers).
- **Conform formatters:** `<pack>/conform.nvim/lua/conform/formatters/<name>.lua` (binary, args, stdin handling).
- **Neovim built-ins:** `:h vim.lsp`, `:h vim.diagnostic`, `:h vim.treesitter`, `:h options`, `:h vim.keymap.set`.
- **Live state inspection:** `:checkhealth <subsystem>`, `:LspInfo`, `:verbose nmap <key>`, `:lua print(vim.inspect(...))`.
- **Headless probes:** `nvim --headless +'lua ...' +qa!`.
  For `later()`-deferred setup, wrap in `vim.defer_fn(..., 200)` so callbacks fire before quit.
- **Plugin repo state:** `gh api repos/<owner>/<repo>` for archive status, recent commits.
- **`.notes/`:** gitignored scratch directory.
  Reference copies of upstream configs, working notes, plans.

## Editing conventions

Many existing files have long heredoc-style comment blocks that serve as inline tutorials.
These are load-bearing documentation, not noise; don't strip them on cleanup.
