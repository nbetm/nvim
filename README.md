# nvim

Personal [Neovim] config built around [mini.nvim].

## Requirements

- [Neovim] 0.12+ (uses `vim.pack`, `vim.lsp.config`)
- [Git]
- _(Optional, recommended)_ [ripgrep] for the grep pickers.
- _(Optional, recommended)_ [`nvim-treesitter` build deps] (C compiler + `tree-sitter` CLI).
- _(Optional, recommended)_ Terminal emulator (or GUI) with [true color] and [Nerd Font icon][nerd font] support.
  No need for a full Nerd Font; [`NerdFontsSymbolsOnly`] as a fallback is usually enough.
  [Ghostty] and [Kitty] already ship with Nerd Font symbols built in.

## Try it out

Clone into an isolated config so it won't touch your normal setup:

```sh
git clone https://github.com/nbetm/nvim ~/.config/nvim-nbetm
```

Launch under a namespaced app name:

```sh
NVIM_APPNAME=nvim-nbetm nvim
```

`NVIM_APPNAME` reroutes Neovim's config, data, state, and cache dirs to their `nvim-nbetm` counterparts.
Fully isolated from your default Neovim.
See `:h NVIM_APPNAME`.

First launch bootstraps `mini.nvim` and queues treesitter parser installs in the background.
Give it a few seconds, then `:checkhealth` to verify.

To remove everything:

```sh
rm -rf ~/.config/nvim-nbetm \
    ~/.local/share/nvim-nbetm \
    ~/.local/state/nvim-nbetm \
    ~/.cache/nvim-nbetm
```

## What's inside

**Base:** [mini.nvim].
A library of small modules (pickers, statusline, completion, sessions, comment, ai textobjects, etc).
Setup lives in `plugin/30_mini.lua`.
Other plugins kept to a minimum: [`nvim-treesitter`], [`nvim-lspconfig`], [`conform.nvim`], [`friendly-snippets`], and [`octo.nvim`] for GitHub PR review workflows.

**Plugin manager:** Neovim 0.12+'s built-in [`vim.pack`].

**In-house modules** under `lua/`:

- [`blame.lua`](lua/blame.lua): git blame two ways.
  Popup with concealed markdown links to the commit and PR pages, plus toggleable inline virtual text.
- [`codenotes.lua`](lua/codenotes.lua): line-anchored personal notes.
  Drop a lightbulb on any line, browse via [mini.pick], persist per-repo.
  Inspired by @thornycrackers's [`qfnotes.lua`] and rewritten for the [mini.nvim] stack.
- [`notes.lua`](lua/notes.lua): picker over the project's gitignored `.notes/` directory.
- [`git_files.lua`](lua/git_files.lua): modified, staged, and untracked file picker.

**Colorscheme:** `nord-deep`, vendored at [`colors/nord-deep.lua`](colors/nord-deep.lua).
An arctic, north-bluish color palette taken to deeper depths.
Full palette spec at [nbetm/nix-config docs/nord-deep.md].

**Keymap cheatsheet:** [`docs/keymap-cheatsheet.html`](docs/keymap-cheatsheet.html).

## Structure

Plugin files load alphabetically.
The numeric prefixes encode load order:

```plain
init.lua                # entrypoint
plugin/10_options.lua   # options + diagnostics config
plugin/20_keymaps.lua   # leader mappings + clue groups
plugin/30_mini.lua      # mini.nvim module setup
plugin/40_plugins.lua   # non-mini plugins
plugin/50_filetypes.lua # filetype detection
lua/                    # in-house helpers
after/ftplugin/         # per-filetype config
after/lsp/              # LSP server configs
```

[ghostty]: https://ghostty.org/
[git]: https://git-scm.com/
[kitty]: https://sw.kovidgoyal.net/kitty/
[mini.nvim]: https://github.com/nvim-mini/mini.nvim
[mini.pick]: https://github.com/nvim-mini/mini.nvim/blob/main/readmes/mini-pick.md
[nbetm/nix-config docs/nord-deep.md]: https://github.com/nbetm/nix-config/blob/main/docs/nord-deep.md
[neovim]: https://neovim.io/
[nerd font]: https://www.nerdfonts.com/
[ripgrep]: https://github.com/BurntSushi/ripgrep#installation
[true color]: https://github.com/termstandard/colors#truecolor-support-in-output-devices
[`conform.nvim`]: https://github.com/stevearc/conform.nvim
[`friendly-snippets`]: https://github.com/rafamadriz/friendly-snippets
[`nerdfontssymbolsonly`]: https://github.com/ryanoasis/nerd-fonts/releases/latest
[`nvim-lspconfig`]: https://github.com/neovim/nvim-lspconfig
[`nvim-treesitter`]: https://github.com/nvim-treesitter/nvim-treesitter
[`nvim-treesitter` build deps]: https://github.com/nvim-treesitter/nvim-treesitter/tree/main?tab=readme-ov-file#requirements
[`octo.nvim`]: https://github.com/pwntester/octo.nvim
[`qfnotes.lua`]: https://github.com/thornycrackers/nix-config/blob/master/src/nvim/lua/qfnotes.lua
[`vim.pack`]: https://neovim.io/doc/user/lua.html#vim.pack
