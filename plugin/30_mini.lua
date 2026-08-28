-- ┌────────────────────┐
-- │ MINI configuration │
-- └────────────────────┘
--
-- Setup for every 'mini.nvim' module. The plugin itself is added in 'init.lua'.
-- Knobs are at `:h MiniXxx.config`, concepts at `:h mini.nvim-general-principles`.

-- To minimize the time until first screen draw, modules are enabled in two steps:
-- - Step one enables everything that is needed for first draw with `now()`.
--   Sometimes needed only if Neovim is started as `nvim -- path/to/file`.
-- - Everything else is delayed until the first draw with `later()`.
local now, now_if_args, later = Config.now, Config.now_if_args, Config.later

-- Step one ===================================================================
-- Color scheme. Applied here (in `now()`) so the rest of the immediate setup
-- (statusline, tabline, etc.) derives highlights from it.
--
-- `nord-deep` lives in 'colors/nord-deep.lua' (vendored, no plugin install).
-- Set `vim.g.nord_deep_transparent = 1` before this block to drop the bg.
--
-- Other built-in alternatives (mini.hues-based, ship with mini.nvim):
--   miniwinter, minispring, minisummer, miniautumn, randomhue
now(function() vim.cmd("colorscheme nord-deep") end)

-- Common configuration presets. The defaults it ships are listed in the
-- "Heads up" block at the top of 'plugin/20_keymaps.lua'.
--
-- See also:
-- - `:h MiniBasics.config.options` - list of adjusted options
-- - `:h MiniBasics.config.mappings` - list of created mappings
-- - `:h MiniBasics.config.autocommands` - list of created autocommands
now(function()
  require("mini.basics").setup({
    -- Manage options in 'plugin/10_options.lua' for didactic purposes
    options = { basic = false },
    mappings = {
      -- Create `<C-hjkl>` mappings for window navigation
      windows = true,
      -- Create `<M-hjkl>` mappings for navigation in Insert and Command modes
      move_with_alt = true,
    },
    autocommands = {
      basic = true,
      -- We set `relativenumber = true` globally. The default visual-mode
      -- toggle would briefly clear relnum on mode exit and fight that.
      relnum_in_visual_mode = false,
    },
  })
end)

-- Icon provider. Used by 'mini.pick', 'mini.files', 'mini.statusline', others.
now(function()
  -- Set up to not prefer extension-based icon for some extensions
  local ext3_blocklist = { scm = true, txt = true, yml = true }
  local ext4_blocklist = { json = true, yaml = true }
  -- Override LSP-kind highlights so symbol pickers (mini.extra `Pick lsp`) and
  -- the completion popup's kind icons render in the same colors as source-code
  -- syntax. Without this, mini.icons assigns its own colors per kind (e.g.,
  -- Class → magenta, Field → yellow), which diverges from how the colorscheme
  -- paints those tokens in actual code.
  --
  -- Mapping rule: each LSP kind links to the same highlight group that source
  -- code uses for that token. Functions stay cyan, types stay aqua, etc.
  local lsp_kind_hl = {
    array = { hl = "@variable" },
    boolean = { hl = "Boolean" },
    class = { hl = "Type" },
    color = { hl = "Constant" },
    constant = { hl = "Constant" },
    constructor = { hl = "@constructor" },
    enum = { hl = "Type" },
    enummember = { hl = "@constant" },
    event = { hl = "Special" },
    field = { hl = "@field" },
    file = { hl = "Directory" },
    folder = { hl = "Directory" },
    ["function"] = { hl = "Function" },
    interface = { hl = "Type" },
    key = { hl = "@property" },
    keyword = { hl = "Keyword" },
    method = { hl = "Function" },
    module = { hl = "@module" },
    namespace = { hl = "@namespace" },
    null = { hl = "@constant.builtin" },
    number = { hl = "Number" },
    object = { hl = "@variable" },
    operator = { hl = "Operator" },
    package = { hl = "@module" },
    property = { hl = "@property" },
    reference = { hl = "@variable" },
    snippet = { hl = "@string.special" },
    string = { hl = "String" },
    struct = { hl = "Type" },
    text = { hl = "@text" },
    typeparameter = { hl = "@type.definition" },
    unit = { hl = "@constant" },
    value = { hl = "@variable" },
    variable = { hl = "@variable" },
  }
  require("mini.icons").setup({
    use_file_extension = function(ext, _) return not (ext3_blocklist[ext:sub(-3)] or ext4_blocklist[ext:sub(-4)]) end,
    lsp = lsp_kind_hl,
  })

  -- Mock 'nvim-tree/nvim-web-devicons' for plugins without 'mini.icons' support.
  -- Not needed for 'mini.nvim' or MiniMax, but might be useful for others.
  later(MiniIcons.mock_nvim_web_devicons)

  -- Add LSP kind icons. Useful for 'mini.completion'.
  later(MiniIcons.tweak_lsp_kind)
end)

-- Notifications provider, upper right corner. `<Leader>l` shows the history.
-- See `:h MiniNotify.config`.
now(function()
  -- winblend 0: mini defaults the notify float to 25 (translucent). Keep it
  -- opaque so it reads as a distinct surface like every other float.
  require("mini.notify").setup({ window = { winblend = 0 } })
  -- Quiet INFO/DEBUG/TRACE so daily noise reads as plain text. ERROR/WARN
  -- keep their Diagnostic* tint to flag actual attention.
  vim.notify = MiniNotify.make_notify({
    INFO = { hl_group = "MiniNotifyNormal" },
    DEBUG = { hl_group = "MiniNotifyNormal" },
    TRACE = { hl_group = "MiniNotifyNormal" },
  })
end)

-- Session management, a thin wrapper around `:h mksession`.
-- Mapped under the `<Leader>o` group in 'plugin/20_keymaps.lua'.
now(function() require("mini.sessions").setup() end)

-- Start screen, currently disabled. Neovim opens straight into an empty buffer.
-- Re-enable by uncommenting below. The colorscheme keeps the MiniStarter*
-- highlights, so flipping back needs no color work.
-- See `:h MiniStarter-example-config`, `:h MiniStarter-lifecycle`.
-- now(function() require("mini.starter").setup() end)

-- Statusline. Sets `:h 'statusline'`. Sections run mode, developer info (git,
-- diff, diagnostics, LSP), filename, file info, then location and search count.
-- See `:h MiniStatusline-example-content` for the default `content.active`.
now(function()
  local MiniStatusline = require("mini.statusline")
  -- Default content, but with the filename centered. An extra `%=` before it
  -- balances the space on both sides.
  MiniStatusline.setup({
    content = {
      active = function()
        local mode, mode_hl = MiniStatusline.section_mode({ trunc_width = 120 })
        local git = MiniStatusline.section_git({ trunc_width = 40 })
        local diff = MiniStatusline.section_diff({ trunc_width = 75 })
        local diagnostics = MiniStatusline.section_diagnostics({ trunc_width = 75 })
        local lsp = MiniStatusline.section_lsp({ trunc_width = 75 })
        local filename = MiniStatusline.section_filename({ trunc_width = 140 })
        local fileinfo = MiniStatusline.section_fileinfo({ trunc_width = 120 })
        local location = MiniStatusline.section_location({ trunc_width = 75 })
        local search = MiniStatusline.section_searchcount({ trunc_width = 75 })

        return MiniStatusline.combine_groups({
          { hl = mode_hl, strings = { mode } },
          { hl = "MiniStatuslineDevinfo", strings = { git, diff, diagnostics, lsp } },
          "%=", -- center the filename
          "%<",
          { hl = "MiniStatuslineFilename", strings = { filename } },
          "%=",
          { hl = "MiniStatuslineFileinfo", strings = { fileinfo } },
          { hl = mode_hl, strings = { search, location } },
        })
      end,
    },
  })
end)

-- Tabline. Sets `:h 'tabline'` to list buffers in creation order at the top.
-- Navigate with `[b` and `]b`.
now(function() require("mini.tabline").setup() end)

-- Step one or two ============================================================
-- Load now if Neovim is started like `nvim -- path/to/file`, otherwise - later.
-- This ensures a correct behavior for files opened during startup.

-- Completion and signature help. Async two-stage autocompletion: attached LSP
-- servers first, built-in keyword completion as the fallback. Snippet candidates
-- come from 'mini.snippets', set up further down this file.
--
-- `<Tab>` / `<S-Tab>` navigate the popup (wired in 'mini.keymap' below).
-- See `:h MiniCompletion` for the full interaction model.
now_if_args(function()
  -- Customize post-processing of LSP responses for a better user experience.
  -- Don't show 'Text' suggestions (usually noisy) and show snippets last.
  local process_items_opts = { kind_priority = { Text = -1, Snippet = 99 } }
  local process_items = function(items, base)
    return MiniCompletion.default_process_items(items, base, process_items_opts)
  end
  require("mini.completion").setup({
    lsp_completion = {
      -- Without this config autocompletion is set up through `:h 'completefunc'`.
      -- Although not needed, setting up through `:h 'omnifunc'` is cleaner
      -- (sets up only when needed) and makes it possible to use `<C-u>`.
      source_func = "omnifunc",
      auto_setup = false,
      process_items = process_items,
    },
  })

  -- Set 'omnifunc' for LSP completion only when needed.
  local on_attach = function(ev) vim.bo[ev.buf].omnifunc = "v:lua.MiniCompletion.completefunc_lsp" end
  Config.new_autocmd("LspAttach", nil, on_attach, "Set 'omnifunc'")

  -- Advertise to servers that Neovim now supports certain set of completion and
  -- signature features through 'mini.completion'.
  vim.lsp.config("*", { capabilities = MiniCompletion.get_lsp_capabilities() })
end)

-- File system explorer in Miller columns. Manipulate files by editing the
-- buffer text, then press `=` to synchronize. `g?` lists the mappings.
-- `<Leader>e` opens at the current file's directory, `<Leader>E` at cwd.
--
-- See also:
-- - `:h MiniFiles-navigation`
-- - `:h MiniFiles-manipulation`
-- - `:h MiniFiles-examples`
now_if_args(function()
  -- Enable directory/file preview with wider panes for readability.
  require("mini.files").setup({
    -- Match mini.pick: <Esc> closes the explorer (default is `q`).
    -- <CR> opens a file and closes the explorer (default key for that is `L`).
    mappings = { close = "<Esc>", go_in_plus = "<CR>" },
    windows = {
      preview = true,
      width_focus = 50,
      width_nofocus = 15,
      width_preview = 80,
    },
  })

  -- Add common bookmarks for every explorer. Example usage inside explorer:
  -- - `'c` to navigate into your config directory
  -- - `g?` to see available bookmarks
  local add_marks = function()
    MiniFiles.set_bookmark("c", vim.fn.stdpath("config"), { desc = "Config" })
    local vimpack_plugins = vim.fn.stdpath("data") .. "/site/pack/core/opt"
    MiniFiles.set_bookmark("p", vimpack_plugins, { desc = "Plugins" })
    MiniFiles.set_bookmark("w", vim.fn.getcwd, { desc = "Working directory" })
  end
  Config.new_autocmd("User", "MiniFilesExplorerOpen", add_marks, "Add bookmarks")
end)

-- Miscellaneous helpers. `\z` zooms the current buffer, `<C-w>0` resizes a
-- window to its editable width. The globals exposed below are debug aids, e.g.
-- `:lua put(stat_summary(bench_time(f, 100)))` times `f` over 100 runs.
now_if_args(function()
  -- Expose useful debug/benchmark helpers as global names: `put`, `put_text`,
  -- `stat_summary` (e.g. `=put(stat_summary(...))`), and `bench_time`.
  require("mini.misc").setup({
    make_global = { "put", "put_text", "stat_summary", "bench_time" },
  })

  -- Change current working directory based on the current file path. It
  -- searches up the file tree until the first root marker ('.git' or 'Makefile')
  -- and sets their parent directory as a current directory.
  -- This is helpful when simultaneously dealing with files from several projects.
  MiniMisc.setup_auto_root()

  -- Restore latest cursor position on file open
  MiniMisc.setup_restore_cursor()

  -- Synchronize terminal emulator background with Neovim's background to remove
  -- possibly different color padding around Neovim instance
  MiniMisc.setup_termbg_sync()
end)

-- Step two ===================================================================

-- Extra 'mini.nvim' functionality.
--
-- See also:
-- - `:h MiniExtra.pickers` - pickers. Most are mapped in `<Leader>p` group.
--   Calling `setup()` makes 'mini.pick' respect 'mini.extra' pickers.
-- - `:h MiniExtra.gen_ai_spec` - 'mini.ai' textobject specifications
-- - `:h MiniExtra.gen_highlighter` - 'mini.hipatterns' highlighters
later(function() require("mini.extra").setup() end)

-- Extend and create a/i textobjects (`:h a(`, `:h a'`, and more), plus "next"
-- and "last" variants that search forward and backward from the cursor.
--
-- See also:
-- - `:h MiniAi-builtin-textobjects`
-- - `:h MiniAi-textobject-specification`
later(function()
  local ai = require("mini.ai")
  ai.setup({
    -- 'mini.ai' can be extended with custom textobjects
    custom_textobjects = {
      -- Make `aB` / `iB` act on around/inside whole *b*uffer
      B = MiniExtra.gen_ai_spec.buffer(),
      -- For more complicated textobjects that require structural awareness,
      -- use tree-sitter. This example makes `aF`/`iF` mean around/inside function
      -- definition (not call). See `:h MiniAi.gen_spec.treesitter()` for details.
      F = ai.gen_spec.treesitter({ a = "@function.outer", i = "@function.inner" }),
    },

    -- Default mimics built-in search: cover the cursor first, then look right.
    -- "cover" drops the look-right half, so a textobject either covers the
    -- cursor or you ask for it by name with `an`/`in` or `al`/`il`.
    search_method = "cover",
  })
end)

-- Align text. `ga` is the operator (`gaip,` aligns a paragraph by comma), `gA`
-- starts the interactive version. See `:h MiniAlign-example`.
later(function() require("mini.align").setup() end)

-- Animate cursor movement, scroll, and window open/close/resize.
-- Left off: the effects are a matter of taste, and scroll and resize have
-- side effects (see `:h mini.animate`). Uncomment to enable.
-- later(function() require('mini.animate').setup() end)

-- Go forward/backward with square brackets over buffers, diagnostics, quickfix
-- entries, and more. Lowercase steps one, uppercase jumps to the end (`]b` next
-- buffer, `[Q` first quickfix entry). See `:h MiniBracketed` for every target.
later(function() require("mini.bracketed").setup() end)

-- Remove buffers without disturbing the window layout.
-- Mapped under the `<Leader>B` group in 'plugin/20_keymaps.lua'.
later(function() require("mini.bufremove").setup() end)

-- Show next-key clues in a bottom right window. Triggers are opt-in, listed
-- below. `<BS>` steps back through the key sequence. Deliberately inert in
-- special buffers (mini.files and friends) so it won't shadow their mappings.
--
-- See also:
-- - `:h MiniClue-examples`
-- - `:h MiniClue.ensure_buf_triggers()`
-- - `:h MiniClue.set_mapping_desc()`
later(function()
  local miniclue = require("mini.clue")
  miniclue.setup({
    -- Define which clues to show. By default shows only clues for custom mappings
    -- (uses `desc` field from the mapping, which takes precedence over a custom clue).
    clues = {
      -- This is defined in 'plugin/20_keymaps.lua' with Leader group descriptions
      Config.leader_group_clues,
      miniclue.gen_clues.builtin_completion(),
      miniclue.gen_clues.g(),
      miniclue.gen_clues.marks(),
      miniclue.gen_clues.registers(),
      miniclue.gen_clues.square_brackets(),
      -- Submode for window resize: after `<C-w>+`, bare `+`/`-` keep resizing
      -- until `<Esc>` or any key outside the submode.
      miniclue.gen_clues.windows({ submode_resize = true }),
      miniclue.gen_clues.z(),
    },
    -- Explicitly opt-in for set of common keys to trigger clue window
    triggers = {
      { mode = { "n", "x" }, keys = "<Leader>" }, -- Leader triggers
      { mode = "n", keys = "\\" }, -- mini.basics
      { mode = { "n", "x" }, keys = "[" }, -- mini.bracketed
      { mode = { "n", "x" }, keys = "]" },
      { mode = "i", keys = "<C-x>" }, -- Built-in completion
      { mode = { "n", "x" }, keys = "g" }, -- `g` key
      { mode = { "n", "x" }, keys = "'" }, -- Marks
      { mode = { "n", "x" }, keys = "`" },
      { mode = { "n", "x" }, keys = '"' }, -- Registers
      { mode = { "i", "c" }, keys = "<C-r>" },
      { mode = "n", keys = "<C-w>" }, -- Window commands
      { mode = { "n", "x" }, keys = "s" }, -- `s` key (mini.surround, etc.)
      { mode = { "n", "x" }, keys = "z" }, -- `z` key
    },
    -- Show the clue popup faster than the default ~1000ms.
    -- Wider config so descriptions don't truncate on busier groups.
    window = { delay = 500, config = { width = 60 } },
  })
end)

-- Command line tweaks. Improves command line editing with:
-- - Autocompletion. Basically an automated `:h cmdline-completion`.
-- - Autocorrection of words as-you-type. Like `:W`->`:w`, `:lau`->`:lua`, etc.
-- - Autopeek command range (like line number at the start) as-you-type.
later(function() require("mini.cmdline").setup() end)

-- Tweak and save any color scheme, plus color space conversion helpers.
-- Left off: not needed day to day. Uncomment to enable, then see
-- `:h MiniColors.interactive()` and `:h MiniColors-recipes`.
-- later(function() require('mini.colors').setup() end)

-- Comment lines with `gc`, inferring structure from `:h 'commentstring'`.
-- Neovim's built-in `:h commenting` is based on this module. Enabled anyway
-- for the extra customization it exposes.
later(function() require("mini.comment").setup() end)

-- Autohighlight word under cursor with a customizable delay.
-- Word boundaries are defined based on `:h 'iskeyword'` option.
later(function() require("mini.cursorword").setup() end)

-- Diff hunks against a reference, by default the Git index. Feeds the developer
-- section of 'mini.statusline'. `gh` applies a hunk, `gH` resets one, `\o`
-- toggles the overlay.
--
-- See also:
-- - `:h MiniDiff-overview`
-- - `:h MiniDiff.gen_source`
later(function()
  require("mini.diff").setup({
    -- Use `g/G` as the hunk-navigation suffix (instead of the default `h/H`).
    -- Trade-offs:
    -- - Pro: hand alternation on a split keyboard (right pinky `[]`, left
    --   index `g`) is faster than the same-hand `h` sequence.
    -- - Pro: `g` for "git hunk" is a defensible mnemonic.
    -- - Con: diverges from upstream mini.diff docs (which use `h/H`).
    mappings = {
      goto_first = "[G",
      goto_prev = "[g",
      goto_next = "]g",
      goto_last = "]G",
    },
    -- Use 'sign' for the style instead of `vim.go.number and 'number'`
    -- view = {
    --   style = "sign",
    -- },
  })
end)

-- Git helpers wired into Neovim's state, not a full client. `:Git <cmd>` runs a
-- command in a buffer. Mapped under the `<Leader>g` group in 'plugin/20_keymaps.lua'.
--
-- See also:
-- - `:h :Git`
-- - `:h MiniGit.show_at_cursor()`
later(function() require("mini.git").setup() end)

-- Highlight patterns in text: `TODO`/`NOTE` words and hex color codes.
-- `:Pick hipatterns` picks among all matches. See `:h MiniHipatterns-examples`.
later(function()
  local hipatterns = require("mini.hipatterns")
  local hi_words = MiniExtra.gen_highlighter.words
  hipatterns.setup({
    highlighters = {
      -- Highlight a fixed set of common words. Will be highlighted in any place,
      -- not like "only in comments".
      fixme = hi_words({ "FIXME" }, "MiniHipatternsFixme"),
      warn = hi_words({ "WARN" }, "MiniHipatternsWarn"),
      todo = hi_words({ "TODO" }, "MiniHipatternsTodo"),
      note = hi_words({ "NOTE" }, "MiniHipatternsNote"),

      -- Highlight hex color string (#aabbcc) with that color as a background
      hex_color = hipatterns.gen_highlighter.hex_color(),
    },
  })
end)

-- Draw the indent scope at the cursor as a vertical line, with `ai`/`ii`
-- textobjects and `[i`/`]i` motions to its top and bottom.
later(function()
  require("mini.indentscope").setup({
    -- Near-instant scope draw (5ms steps). Keeps the line useful without the
    -- ease-out feeling laggy on big files.
    draw = { animation = function() return 5 end },
  })
end)

-- Smarter `fFtT` (see `:h f`): works across lines, highlights every match, and
-- repeats without needing `;`.
later(function() require("mini.jump").setup() end)

-- Jump anywhere on screen by typing labels. `<CR>` labels every spot, then each
-- typed label character narrows the set until one target is left.
-- See `:h MiniJump2d.gen_spotter` for the available spotters.
later(function()
  local jump2d = require("mini.jump2d")
  jump2d.setup({
    -- Spot only word starts (non-space, non-punctuation runs). Less visual
    -- noise than the default "every character" spotter.
    spotter = jump2d.gen_spotter.pattern("[^%s%p]+"),
    -- Home-row labels.
    labels = "asdfghjkl;",
    -- Dim non-target text and show 2 steps of label-trail ahead.
    view = { dim = true, n_steps_ahead = 2 },
  })
  -- Free-form single-character jump (press `sj`, then a char, then a label).
  vim.keymap.set(
    { "n", "x", "o" },
    "sj",
    function() MiniJump2d.start(MiniJump2d.builtin_opts.single_character) end,
    { desc = "Jump to char (jump2d)" }
  )
end)

-- Special key mappings. Multi-step actions fall through a list of conditions
-- until one matches. Combos fire an extra action when a key sequence is typed
-- fast enough, without delaying the individual keys.
--
-- See also:
-- - `:h MiniKeymap.map_multistep()`
-- - `:h MiniKeymap.map_combo()`
later(function()
  require("mini.keymap").setup()
  -- Navigate 'mini.completion' menu with `<Tab>` /  `<S-Tab>`
  MiniKeymap.map_multistep("i", "<Tab>", { "pmenu_next" })
  MiniKeymap.map_multistep("i", "<S-Tab>", { "pmenu_prev" })
  -- On `<CR>` try to accept current completion item, fall back to accounting
  -- for pairs from 'mini.pairs'
  MiniKeymap.map_multistep("i", "<CR>", { "pmenu_accept", "minipairs_cr" })
  -- On `<BS>` just try to account for pairs from 'mini.pairs'
  MiniKeymap.map_multistep("i", "<BS>", { "minipairs_bs" })
end)

-- Search navigation tweaks (in `later()` so we win against any plugin that
-- maps n/N during startup):
--  1. Append `zv` so `*`/`#`/`n`/`N` open enough folds to land on the match.
--  2. (n/N) Always mean forward/backward regardless of last search direction.
--     Vim's default has `n` repeat in the search direction. After `?foo` it
--     goes backwards. `v:searchforward` is 1 after `/`/`*`, 0 after `?`/`#`.
later(function()
  vim.keymap.set("n", "*", "*zv")
  vim.keymap.set("n", "#", "#zv")
  vim.keymap.set(
    { "n", "x" },
    "n",
    function() return (vim.v.searchforward == 1 and "n" or "N") .. "zv" end,
    { expr = true, desc = "Next search (forward)" }
  )
  vim.keymap.set(
    { "n", "x" },
    "N",
    function() return (vim.v.searchforward == 1 and "N" or "n") .. "zv" end,
    { expr = true, desc = "Prev search (backward)" }
  )
end)

-- Move lines and selections with `<M-hjkl>`. In Normal mode `<M-j>`/`<M-k>`
-- move the line and `<M-h>`/`<M-l>` change its indent.
later(function()
  -- `reindent_linewise = false` keeps the original indentation when moving
  -- whole lines with `<M-j>`/`<M-k>`. Avoids surprise auto-reindent.
  require("mini.move").setup({ options = { reindent_linewise = false } })
end)

-- Text edit operators: `gr` replace, `gm` duplicate, `gs` sort, `gx` exchange,
-- `g=` evaluate as Lua. Each works as an operator, on the current line when the
-- second character is repeated, and on a visual selection.
--
-- See also:
-- - `:h MiniOperators-overview`
later(function()
  require("mini.operators").setup()

  -- Create mappings for swapping adjacent arguments. Notes:
  -- - Relies on `a` argument textobject from 'mini.ai'.
  -- - It is not 100% reliable, but mostly works.
  -- - It overrides `:h (` and `:h )`.
  -- Explanation: `gx`-`ia`-`gx`-`ila` <=> exchange current and last argument
  -- Usage: when on `a` in `(aa, bb)` press `)` followed by `(`.
  vim.keymap.set("n", "(", "gxiagxila", { remap = true, desc = "Swap arg left" })
  vim.keymap.set("n", ")", "gxiagxina", { remap = true, desc = "Swap arg right" })
end)

-- Autopairs. Typing an opening character inserts the pair, and typing a closing
-- one steps over it. `<C-v>(` inserts a literal `(` when the guess is wrong.
later(function()
  -- Create pairs not only in Insert, but also in Command line mode
  require("mini.pairs").setup({ modes = { command = true } })
end)

-- Fuzzy picker over anything, started with `:Pick <name>`. `<Tab>` previews an
-- item, `<S-Tab>` shows picker info, `<CR>` chooses, `<Esc>` closes. Mapped
-- under the `<Leader>p` group in 'plugin/20_keymaps.lua'.
--
-- See also:
-- - `:h MiniPick-overview`
-- - `:h MiniPick.builtin` and `:h MiniExtra.pickers` - available pickers
later(function()
  require("mini.pick").setup({
    window = { prompt_prefix = "❱ " },
  })
  -- Route generic UI selectors (LSP code actions, etc.) through mini.pick.
  vim.ui.select = MiniPick.ui_select
end)

-- Manage and expand snippets. Sources, in load order:
-- - 'snippets/global.json' - available in any buffer
-- - 'after/snippets/<lang>.json' - per-language, e.g. 'after/snippets/lua.json'
-- - 'friendly-snippets' - the collection added in 'plugin/40_plugins.lua'
--
-- `<C-j>` in Insert expands the prefix before the cursor, or opens a picker when
-- the prefix is partial. Inside a session `<C-l>` / `<C-h>` move between
-- tabstops and `<C-c>` ends it.
--
-- See also:
-- - `:h MiniSnippets-session`
-- - `:h MiniSnippets.gen_loader`
later(function()
  -- Define language patterns to work better with 'friendly-snippets'
  local latex_patterns = { "latex/**/*.json", "**/latex.json" }
  local lang_patterns = {
    tex = latex_patterns,
    plaintex = latex_patterns,
    -- Recognize special injected language of markdown tree-sitter parser
    markdown_inline = { "markdown.json" },
  }

  local snippets = require("mini.snippets")
  local config_path = vim.fn.stdpath("config")
  snippets.setup({
    snippets = {
      -- Always load 'snippets/global.json' from config directory
      snippets.gen_loader.from_file(config_path .. "/snippets/global.json"),
      -- Load from 'snippets/' directory of plugins, like 'friendly-snippets'
      snippets.gen_loader.from_lang({ lang_patterns = lang_patterns }),
    },
  })

  -- Expose snippets as completion candidates via an in-process LSP server.
  -- Without this, snippets only expand via the explicit `<C-j>` mapping. With
  -- it, they show up inline (kind=Snippet, sorted last by `kind_priority`).
  MiniSnippets.start_lsp_server()
end)

-- `gS` toggles bracketed arguments between one line and one per line. Finds
-- arguments with Lua patterns, so it works inside comments and strings but is
-- less accurate than a tree-sitter approach. See `:h MiniSplitjoin.gen_hook`.
later(function() require("mini.splitjoin").setup() end)

-- Surround actions under the `s` prefix: `sa` add, `sd` delete, `sr` replace,
-- `sf` find, `sh` highlight. Searches only the surrounding covering the cursor,
-- with `n`/`l` variants to reach forward or backward like 'mini.ai'.
--
-- See also:
-- - `:h MiniSurround-builtin-surroundings`
-- - `:h MiniSurround-surrounding-specification`
later(function()
  require("mini.surround").setup()
  -- Disable bare `s` (built-in substitute char, and `cl` does the same) so the
  -- `s*` prefix used by mini.surround (`sa`/`sd`/`sr`/...) feels clean.
  vim.keymap.set({ "n", "x" }, "s", "<Nop>")
end)

-- Highlight trailing whitespace, pausing in Insert mode to cut noise while
-- typing. `<Leader>cT` trims the buffer.
later(function() require("mini.trailspace").setup() end)

-- Track file system visits on disk and reuse them in frecency order. Paths can
-- carry labels, and this config uses a "core" label as a per-project shortlist.
-- Mapped under the `<Leader>v` group in 'plugin/20_keymaps.lua'.
--
-- See also:
-- - `:h MiniVisits-overview`
-- - `:h MiniVisits-examples`
later(function() require("mini.visits").setup() end)

-- Personal codenotes plugin.
later(function() require("codenotes").setup() end)

-- `\` toggle customizations (runs after mini.basics):
-- - Drop toggles I don't use (cursorline/column, line numbers).
-- - Rewrite the surviving descs to drop mini.basics' "'option'" single-quotes.
-- - Add `\I` for LSP inlay-hints toggle (lowercase `\i` is ignorecase).
later(function()
  for _, key in ipairs({ "\\C", "\\c", "\\n", "\\r" }) do
    pcall(vim.keymap.del, "n", key)
  end

  local descs = {
    ["\\i"] = "Toggle ignorecase",
    ["\\l"] = "Toggle listchars",
    ["\\s"] = "Toggle spell",
    ["\\w"] = "Toggle wrap",
  }
  for key, label in pairs(descs) do
    local existing = vim.fn.maparg(key, "n", false, true)
    local rhs = existing and (existing.callback or existing.rhs)
    if rhs and rhs ~= "" then vim.keymap.set("n", key, rhs, { desc = label, silent = true }) end
  end

  vim.keymap.set(
    "n",
    "\\I",
    function() vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled()) end,
    { desc = "Toggle inlay hints" }
  )
end)
