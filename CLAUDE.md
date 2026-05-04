# CLAUDE.md

> Ignore: claude --resume 34adef2a-22c7-47bb-89b7-09b9fb717e64

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

Personal Neovim config based on the **MiniMax** starter template. Centered on `mini.nvim` (a library of modules, not a single plugin). Lives at `~/.config/vmini/` and is intended to be loaded via `NVIM_APPNAME=vmini nvim` rather than as the default config.

## Tooling

- **Format Lua:** `stylua .` (config in `.stylua.toml`: 2-space, 120 cols, Unix, `AutoPreferDouble`).
- **Plugin manager:** built-in `vim.pack` (requires Neovim 0.12+). State in `nvim-pack-lock.json`.
- **Update plugins (from inside Neovim):** `:lua vim.pack.update()` then `:write` to confirm.
- **Update treesitter parsers:** `:TSUpdate` (runs automatically via `on_packchanged` hook when `nvim-treesitter` itself updates).
- **Health checks:** `:checkhealth vim.lsp vim.treesitter nvim-treesitter`.
- **Lua LS workspace:** `.luarc.json` declares `vim` as a global and disables third-party checks.

## Architecture

### Load order

`init.lua` runs first, then everything in `plugin/` is auto-sourced **alphabetically** — the numeric prefixes (`10_`, `20_`, `30_`, `40_`) are load order. `after/` files load after plugins.

```
init.lua              entry; defines _G.Config, installs mini.nvim
plugin/10_options.lua builtin options + diagnostics config
plugin/20_keymaps.lua leader mappings + Config.leader_group_clues
plugin/30_mini.lua    all mini.nvim module setup
plugin/40_plugins.lua non-mini plugins (treesitter, lspconfig, conform, friendly-snippets)
after/ftplugin/*.lua  per-filetype config
after/lsp/*.lua       LSP server configs (consumed by vim.lsp.config/enable)
after/snippets/*.json higher-priority snippet files
snippets/global.json  always-loaded global snippets
```

### `_G.Config` helpers (defined in `init.lua`)

All plugin files assume this global exists:

- `Config.now(f)` — run immediately during startup. Use for colorscheme, statusline, tabline, dashboard.
- `Config.later(f)` — defer past first draw. Default for everything non-critical.
- `Config.now_if_args(f)` — `now` when `nvim <file>`, else `later`. Use for things needed when a file is opened at startup (completion, LSP, treesitter, `mini.files`).
- `Config.on_event(ev, f)` / `Config.on_filetype(ft, f)` — lazier variants.
- `Config.new_autocmd(event, pattern, callback, desc)` — autocmd in the `custom-config` augroup.
- `Config.on_packchanged(name, kinds, cb, desc)` — hook into `vim.pack` update/install events (see `40_plugins.lua` for the `:TSUpdate` example).

All wrap `mini.misc.safely` so a failure in one setup block doesn't break startup.

### Leader mapping convention

Leader is `<Space>`. Mappings are **two-key**: first key is the semantic group, second is the action. Uppercase second key = local/buffer variant of lowercase global action (e.g., `<Leader>fs` workspace LSP symbols, `<Leader>fS` document symbols).

**When adding a new leader group,** add an entry to `Config.leader_group_clues` in `plugin/20_keymaps.lua` — `mini.clue` reads this table to show hints. Existing groups: `b` Buffer, `e` Explore/Edit, `f` Find, `g` Git, `l` Language, `m` Map, `o` Other, `s` Session, `t` Terminal, `v` Visits.

### Adding an LSP server

1. Create `after/lsp/<server>.lua` returning a config table (see `after/lsp/lua_ls.lua` for the shape — `on_attach`, `settings`, etc.).
2. Uncomment and extend the `vim.lsp.enable({...})` call in `plugin/40_plugins.lua`.

`mini.completion` advertises its capabilities globally via `vim.lsp.config('*', { capabilities = ... })` in `30_mini.lua`, so per-server configs don't need to repeat that.

### Formatter config

Formatters are configured in `plugin/40_plugins.lua` under `conform.setup({ formatters_by_ft = { ... } })`. `lsp_format = 'fallback'` means LSP formatting is used if no formatter is registered for the filetype. Trigger with `<Leader>lf`.

### Snippets

Three sources, loaded in `plugin/30_mini.lua`:
1. `snippets/global.json` — always available.
2. `after/snippets/<lang>.json` — per-language overrides.
3. `friendly-snippets` plugin — via `gen_loader.from_lang()`.

Expand with `<C-j>` in Insert mode.

## Editing conventions

- The `stylua: ignore start` / `ignore end` blocks in `10_options.lua` and `20_keymaps.lua` are **intentionally manually aligned** for readability. Preserve alignment when editing, or remove the ignore comments to autoformat.
- Many existing files have long heredoc-style comment blocks that serve as inline tutorials for the user. These are load-bearing documentation, not noise — don't strip them on cleanup.
- `.notes/` is gitignored and contains reference copies of upstream configs (mini.nvim, echasnovski-nvim, catppuccin, etc.) for lookup. Don't treat it as project code.
