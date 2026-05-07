# CLAUDE.md

> Ignore: claude --resume 34adef2a-22c7-47bb-89b7-09b9fb717e64

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

Personal Neovim config based on the **MiniMax** starter template, lives at `~/.config/nvim/`. Centered on `mini.nvim` (a library of modules, not a single plugin).

## Tooling

- **Format Lua:** `stylua .` (config in `.stylua.toml`).
- **Plugin manager:** built-in `vim.pack` (requires Neovim 0.12+). State in `nvim-pack-lock.json`.
- **Update plugins (from inside Neovim):** `:lua vim.pack.update()` then `:write` to confirm.
- **Update treesitter parsers:** `:TSUpdate` (runs automatically via `on_packchanged` hook when `nvim-treesitter` itself updates).
- **Health checks:** `:checkhealth vim.lsp vim.treesitter nvim-treesitter provider`.
- **Lua LS workspace:** known globals declared in `.luarc.json`.

## Architecture

### Load order

`init.lua` runs first, then everything in `plugin/` is auto-sourced **alphabetically** — the numeric prefixes (`10_`, `20_`, `30_`, etc.) are load order. `after/` files load after plugins.

```
init.lua                entry; defines _G.Config, installs mini.nvim
plugin/10_options.lua   builtin options + diagnostics config
plugin/20_keymaps.lua   leader mappings + Config.leader_group_clues
plugin/30_mini.lua      all mini.nvim module setup
plugin/40_plugins.lua   non-mini plugins (treesitter, lspconfig, conform, friendly-snippets)
plugin/50_filetypes.lua filetype detection rules
lua/<name>.lua          personal helpers required from plugin/ files
after/ftplugin/*.lua    per-filetype config
after/lsp/*.lua         LSP server configs (consumed by vim.lsp.config/enable)
after/snippets/*.json   higher-priority snippet files
snippets/global.json    always-loaded global snippets
colors/*.lua            colorschemes
```

### Staged loading

`init.lua` exposes `_G.Config` with helpers wrapped in `mini.misc.safely` (so one failure doesn't cascade): `now`, `later`, `now_if_args`, `on_event`, `on_filetype`, `new_autocmd`, `on_packchanged`. See `init.lua` for what each does.

### Leader mappings

Leader is `<Space>`. Two-key convention: first key is the semantic group, second is the action. Lowercase second key = narrow scope (current buffer / file dir / cwd), uppercase = broad scope (workspace / all). Mirrors Vim's `gd` (local) vs `gD` (global) split. Example: `<Leader>ps` document LSP symbols, `<Leader>pS` workspace LSP symbols. New groups need an entry in `Config.leader_group_clues` (`plugin/20_keymaps.lua`) so `mini.clue` shows hints.

### Subsystems

- **LSP servers:** per-server config in `after/lsp/<name>.lua`, enabled via `vim.lsp.enable` in `plugin/40_plugins.lua`.
- **Formatters:** `conform.setup({ formatters_by_ft })` in `plugin/40_plugins.lua`. Trigger with `<Leader>lf`. Format-on-save is allowlisted in the same call.
- **Snippets:** loaded in `plugin/30_mini.lua` from `snippets/global.json`, `after/snippets/<lang>.json`, and `friendly-snippets`. Expand with `<C-j>` in Insert.

## Working in this config

### Principles

- **Read mini docs first.** Before customizing a mini module, try `:h MiniXxx.config` (knobs), then `-examples` (working setups), then `-overview` (concepts). When help is ambiguous, source is canonical. Many problems have a documented mini-native lever — don't write a workaround when there's a knob.
- **Investigate at the right layer.** If filtering noise from a server (LSP progress, diagnostics), check whether the upstream layer can be told to stop emitting first — LSP `capabilities`, server `settings`, server CLI flags. Root-cause beats post-arrival filtering.

### Where to look

`<pack>` = `~/.local/share/nvim/site/pack/core/opt/`.

- **Mini knobs / source:** `:h MiniXxx.config`, `:h MiniXxx-examples`, `:h MiniXxx-overview`. Source at `<pack>/mini.nvim/lua/mini/<module>.lua`.
- **nvim-lspconfig server defaults:** `<pack>/nvim-lspconfig/lsp/<server>.lua` (cmd, filetypes, default capabilities, root markers).
- **Conform formatters:** `<pack>/conform.nvim/lua/conform/formatters/<name>.lua` (binary, args, stdin handling).
- **Neovim built-ins:** `:h vim.lsp`, `:h vim.diagnostic`, `:h vim.treesitter`, `:h options`, `:h vim.keymap.set`.
- **Live state inspection:** `:checkhealth <subsystem>`, `:LspInfo`, `:verbose nmap <key>`, `:lua print(vim.inspect(...))`.
- **Headless probes:** `nvim --headless +'lua ...' +qa!`. For `later()`-deferred setup, wrap in `vim.defer_fn(..., 200)` so callbacks fire before quit.
- **Plugin repo state:** `gh api repos/<owner>/<repo>` for archive status, recent commits.
- **`.notes/`:** prior configs (Helix, the previous nvim attempt, theme spec) and gitignored upstream copies for grep-able lookup.

## Editing conventions

- Many existing files have long heredoc-style comment blocks that serve as inline tutorials. These are load-bearing documentation, not noise — don't strip them on cleanup.
- `.notes/` is gitignored. Holds reference copies of upstream configs and working scratch (notes, cheat-sheets). Not tracked.
