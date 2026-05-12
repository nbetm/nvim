-- ┌─────────────────┐
-- │ Custom mappings │
-- └─────────────────┘
--
-- This file contains definitions of custom general and Leader mappings.
--
-- Heads up: 'mini.basics' ships defaults that don't appear here — `gy`/`gp`
-- (yank/paste system clipboard), `gO`/`go` (empty line above/below), `<C-s>`
-- (save + leave Insert), `\h`/`\w`/`\s`/`\b`/`\c`/`\l`/`\n`/`\r` toggles.
-- Cross-check with `:verbose nmap <key>` before adding new mappings; easy to
-- clobber. See `:h MiniBasics.config.mappings`.

-- General mappings ===========================================================

-- Use this section to add custom general mappings. See `:h vim.keymap.set()`.

-- An example helper to create a Normal mode mapping
local nmap = function(lhs, rhs, desc)
  -- See `:h vim.keymap.set()`
  vim.keymap.set("n", lhs, rhs, { desc = desc })
end

-- Paste linewise before/after current line
-- Usage: `yiw` to yank a word and `]p` to put it on the next line.
nmap("[p", '<Cmd>exe "iput! " . v:register<CR>', "Paste Above")
nmap("]p", '<Cmd>exe "iput "  . v:register<CR>', "Paste Below")

-- `<Esc>` clears the current search highlight. `\h` from mini.basics still
-- toggles `'hlsearch'` globally if you want it off persistently.
nmap("<Esc>", "<Cmd>noh<CR>", "Clear search highlight")

-- LSP navigation under `g*`. Falls back to the original built-in `gX` when no
-- LSP client is attached to the current buffer (so opening a plain text file
-- still gets you `gd`'s "go to local declaration", etc.).
local lsp_or_builtin = function(lsp_fn, builtin_keys)
  return function()
    if next(vim.lsp.get_clients({ bufnr = 0 })) ~= nil then
      lsp_fn()
    else
      vim.cmd("normal! " .. builtin_keys)
    end
  end
end

nmap("gd", lsp_or_builtin(vim.lsp.buf.definition, "gd"), "Goto definition (LSP)")
nmap("gD", lsp_or_builtin(vim.lsp.buf.declaration, "gD"), "Goto declaration (LSP)")
nmap("gI", lsp_or_builtin(vim.lsp.buf.implementation, "gI"), "Goto implementation (LSP)")
-- `K` (hover) is already wired by Neovim 0.10+ when an LSP attaches.

-- Many general mappings are created by 'mini.basics'. See 'plugin/30_mini.lua'

-- Leader mappings ============================================================

-- Neovim has the concept of a Leader key (see `:h <Leader>`). It is a configurable
-- key that is primarily used for "workflow" mappings (opposed to text editing).
-- Like "open file explorer", "create scratch buffer", "pick from buffers".
--
-- In 'plugin/10_options.lua' <Leader> is set to <Space>, i.e. press <Space>
-- whenever there is a suggestion to press <Leader>.
--
-- This config uses a "two key Leader mappings" approach: first key describes
-- semantic group, second key executes an action. Both keys are usually chosen
-- to create some kind of mnemonic.
-- Example: `<Leader>p` groups picker actions; `<Leader>pb` - pick buffer.
-- Use this section to add Leader mappings in a structural manner.
--
-- Usually if there are narrow and broad kinds of actions, lowercase second key
-- denotes narrow (current buffer / file dir / cwd) and uppercase - broad
-- (workspace / all). Mirrors Vim's own `gd` (local) vs `gD` (global) split.
-- Example: `<Leader>ps` / `<Leader>pS` - document / workspace LSP symbols.
--
-- Many of the mappings use 'mini.nvim' modules set up in 'plugin/30_mini.lua'.

-- Create a global table with information about Leader groups in certain modes.
-- This is used to provide 'mini.clue' with extra clues.
-- Add an entry if you create a new group.
Config.leader_group_clues = {
  { mode = "n", keys = "<Leader>B", desc = "+Buffer" },
  { mode = "n", keys = "<Leader>p", desc = "+Picker" },
  { mode = "n", keys = "<Leader>G", desc = "+Git" },
  { mode = "n", keys = "<Leader>c", desc = "+Code" },
  { mode = "n", keys = "<Leader>O", desc = "+Other" },
  { mode = "n", keys = "<Leader>o", desc = "+Session" },
  { mode = "n", keys = "<Leader>v", desc = "+Visits" },

  { mode = "x", keys = "<Leader>G", desc = "+Git" },
  { mode = "x", keys = "<Leader>c", desc = "+Code" },
}

-- Helpers for a more concise `<Leader>` mappings.
-- Most of the mappings use `<Cmd>...<CR>` string as a right hand side (RHS) in
-- an attempt to be more concise yet descriptive. See `:h <Cmd>`.
-- This approach also doesn't require the underlying commands/functions to exist
-- during mapping creation: a "lazy loading" approach to improve startup time.
local nmap_leader = function(suffix, rhs, desc) vim.keymap.set("n", "<Leader>" .. suffix, rhs, { desc = desc }) end
local xmap_leader = function(suffix, rhs, desc) vim.keymap.set("x", "<Leader>" .. suffix, rhs, { desc = desc }) end

-- Direct leader actions (no group). Quick shortcuts for the heavy hitters.
-- `<Leader>q` mirrors `<Leader>bd` — closes the current buffer (keeps splits
-- intact); `<Leader>Q` quits Neovim entirely.
local explore_at_file = "<Cmd>lua MiniFiles.open(vim.api.nvim_buf_get_name(0))<CR>"

-- Smart close, in priority order:
--   1. In a quickfix window -> `:cclose`.
--   2. In a location-list window -> `:lclose`.
--   3. In a help window -> `:helpclose`.
--   4. Last listed buffer -> `:quitall` (E162 still protects unsaved work).
--   5. Otherwise -> MiniBufremove.delete() (protects unsaved work via E37).
local smart_close = function()
  local wintype = vim.fn.win_gettype(0)
  if wintype == "quickfix" then return vim.cmd("cclose") end
  if wintype == "loclist" then return vim.cmd("lclose") end
  if vim.bo.buftype == "help" then return vim.cmd("helpclose") end

  local buf = vim.api.nvim_get_current_buf()
  local listed = vim.tbl_filter(function(b) return vim.bo[b].buflisted end, vim.api.nvim_list_bufs())
  if #listed == 1 and listed[1] == buf then
    vim.cmd("quitall")
    return
  end
  MiniBufremove.delete()
end

-- Git blame helpers (popup + inline toggle). Implementation lives in
-- `lua/blame.lua` to keep this file focused on keymap registration.
local blame = require("blame")
local notes = require("notes")
local git_files = require("git_files")
local codenotes = require("codenotes")

-- Picker shortcuts shared between root direct mappings and the +Picker group.
local pick_workspace_symbols_live = '<Cmd>Pick lsp scope="workspace_symbol_live"<CR>'

nmap_leader("a", "ggVG", "Select all")
nmap_leader("e", explore_at_file, "Explorer file dir")
nmap_leader("E", "<Cmd>lua MiniFiles.open()<CR>", "Explorer cwd")
nmap_leader("b", "<Cmd>Pick buffers<CR>", "Buffers")
nmap_leader("g", git_files.changed, "Changed files")
nmap_leader("f", "<Cmd>Pick files<CR>", "Files")
nmap_leader("N", notes.pick, "Project notes")
nmap_leader("n", codenotes.pick, "Code notes")
nmap_leader("m", codenotes.create, "New / edit note at cursor")
nmap_leader("M", codenotes.delete_at_cursor, "Delete note at cursor")
nmap_leader("s", '<Cmd>Pick lsp scope="document_symbol"<CR>', "Symbols buffer")
nmap_leader("S", pick_workspace_symbols_live, "Symbols workspace")
nmap_leader("d", '<Cmd>Pick diagnostic scope="current"<CR>', "Diagnostic buffer")
nmap_leader("D", '<Cmd>Pick diagnostic scope="all"<CR>', "Diagnostic workspace")
nmap_leader("r", "<Cmd>Pick resume<CR>", "Resume")
nmap_leader("w", "<Cmd>write<CR>", "Write")
nmap_leader("W", "<Cmd>wall<CR>", "Write all")
nmap_leader("q", smart_close, "Close")
nmap_leader("Q", "<Cmd>quitall<CR>", "Quit all")
nmap_leader("/", "<Cmd>Pick grep_live<CR>", "Grep")
nmap_leader("?", "<Cmd>Pick commands<CR>", "Commands")

-- B is for 'Buffer' (capital so lowercase `b` is free for the buffer picker
-- root shortcut). Common usage:
-- - `<Leader>Bs` - create scratch (temporary) buffer
-- - `<Leader>Ba` - navigate to the alternative buffer
-- - `<Leader>Bw` - wipeout (fully delete) current buffer
local new_scratch_buffer = function() vim.api.nvim_win_set_buf(0, vim.api.nvim_create_buf(true, true)) end

nmap_leader("Ba", "<Cmd>b#<CR>", "Alternate")
nmap_leader("Bd", "<Cmd>lua MiniBufremove.delete()<CR>", "Delete")
nmap_leader("BD", "<Cmd>lua MiniBufremove.delete(0, true)<CR>", "Delete!")
nmap_leader("Bs", new_scratch_buffer, "Scratch")
nmap_leader("Bw", "<Cmd>lua MiniBufremove.wipeout()<CR>", "Wipeout")
nmap_leader("BW", "<Cmd>lua MiniBufremove.wipeout(0, true)<CR>", "Wipeout!")

-- p is for 'Picker'. Common usage:
-- - `<Leader>f`  - find files (root shortcut)
-- - `<Leader>/`  - grep inside files (root shortcut)
-- - `<Leader>pb` - buffers
-- - `<Leader>ph` - help tag
-- - `<Leader>pr` - resume latest picker
-- - `<Leader>pv` - all visited paths; requires 'mini.visits'
--
-- All these use 'mini.pick'. See `:h MiniPick-overview` for an overview.

nmap_leader("p/", '<Cmd>Pick history scope="/"<CR>', '"/" history')
nmap_leader("p:", '<Cmd>Pick history scope=":"<CR>', '":" history')
nmap_leader("pb", "<Cmd>Pick buffers<CR>", "Buffers")
nmap_leader("pc", '<Cmd>Pick git_commits path="%"<CR>', "Commits buffer")
nmap_leader("pC", "<Cmd>Pick git_commits<CR>", "Commits all")
nmap_leader("pd", '<Cmd>Pick diagnostic scope="current"<CR>', "Diagnostic buffer")
nmap_leader("pD", '<Cmd>Pick diagnostic scope="all"<CR>', "Diagnostic workspace")
nmap_leader("pf", "<Cmd>Pick files<CR>", "Files")
nmap_leader("pg", '<Cmd>Pick git_hunks path="%"<CR>', "Git hunks buffer")
nmap_leader("pG", "<Cmd>Pick git_hunks<CR>", "Git hunks all")
nmap_leader("ph", "<Cmd>Pick help<CR>", "Help tags")
nmap_leader("pH", "<Cmd>Pick hl_groups<CR>", "Highlight groups")
nmap_leader("pl", '<Cmd>Pick buf_lines scope="current"<CR>', "Lines buffer")
nmap_leader("pL", '<Cmd>Pick buf_lines scope="all"<CR>', "Lines all")
nmap_leader("pn", codenotes.pick, "Code notes")
nmap_leader("pN", notes.pick, "Project notes")
nmap_leader("pr", "<Cmd>Pick resume<CR>", "Resume")
nmap_leader("pR", '<Cmd>Pick lsp scope="references"<CR>', "References")
nmap_leader("ps", '<Cmd>Pick lsp scope="document_symbol"<CR>', "Symbols buffer")
nmap_leader("pS", pick_workspace_symbols_live, "Symbols workspace")
nmap_leader("pv", "<Cmd>Pick visit_paths<CR>", "Visit paths cwd")
nmap_leader("pV", '<Cmd>Pick visit_paths cwd=""<CR>', "Visit paths all")

-- G is for 'Git' (capital so lowercase `g` is free for the changed-files
-- picker root shortcut). Common usage:
-- - `<Leader>g`  - pick a modified/staged/untracked file (root shortcut)
-- - `<Leader>Gb` - quick blame popup for the current line
-- - `<Leader>Gs` - show information at cursor (mini.git, opens a buffer)
-- - `<Leader>Go` - toggle 'mini.diff' overlay to show in-buffer unstaged changes
-- - `<Leader>Gd` - show unstaged changes as a patch in separate tabpage
-- - `<Leader>GL` - show Git log of current file (workspace scope)
-- - `\b`         - toggle inline-blame virtual text per line
local git_log_cmd = [[Git log --pretty=format:\%h\ \%as\ │\ \%s --topo-order]]
local git_log_buf_cmd = git_log_cmd .. " --follow -- %"

nmap_leader("Ga", "<Cmd>Git diff --cached -- %<CR>", "Added diff buffer")
nmap_leader("GA", "<Cmd>Git diff --cached<CR>", "Added diff all")
nmap_leader("Gc", "<Cmd>Git commit<CR>", "Commit")
nmap_leader("GC", "<Cmd>Git commit --amend<CR>", "Commit amend")
nmap_leader("Gd", "<Cmd>Git diff -- %<CR>", "Diff buffer")
nmap_leader("GD", "<Cmd>Git diff<CR>", "Diff all")
nmap_leader("Gl", "<Cmd>" .. git_log_buf_cmd .. "<CR>", "Log buffer")
nmap_leader("GL", "<Cmd>" .. git_log_cmd .. "<CR>", "Log all")
nmap_leader("Go", "<Cmd>lua MiniDiff.toggle_overlay()<CR>", "Toggle overlay")
nmap_leader("Gb", blame.popup, "Blame popup")
nmap_leader("Gs", "<Cmd>lua MiniGit.show_at_cursor()<CR>", "Show at cursor")

xmap_leader("Gs", "<Cmd>lua MiniGit.show_at_cursor()<CR>", "Show at selection")

-- Inline blame toggle (overrides mini.basics' `\b` = background toggle).
vim.keymap.set("n", "\\b", blame.toggle, { desc = "Toggle inline blame" })

-- c is for 'Code'. Spans LSP actions, comment toggle, and note pickers.
-- Common usage:
-- - `<Leader>cd` - show more diagnostic details in a floating window
-- - `<Leader>cr` - perform rename via LSP
-- - `<Leader>cs` - navigate to source definition of symbol under cursor
-- - `<Leader>cc` - toggle comment on current line / visual selection
-- - `<Leader>cm` / `cM` - new-or-edit / delete code note at cursor (mirrors `<Leader>m` / `M`)
-- - `<Leader>cn` / `cN` - code notes / project notes picker (mirrors `<Leader>n` / `N`)
--
-- NOTE: most LSP mappings represent a more structured way of replacing built-in
-- LSP mappings (like `:h gra` and others). This is needed because `gr` is mapped
-- by an "replace" operator in 'mini.operators' (which is more commonly used).
local function comment_visual()
  local s = math.min(vim.fn.line("v"), vim.fn.line("."))
  local e = math.max(vim.fn.line("v"), vim.fn.line("."))
  MiniComment.toggle_lines(s, e)
end

nmap_leader("ca", "<Cmd>lua vim.lsp.buf.code_action()<CR>", "Actions")
nmap_leader("cc", "<Cmd>lua MiniComment.toggle_lines(vim.fn.line('.'), vim.fn.line('.'))<CR>", "Comment toggle")
nmap_leader("cd", "<Cmd>lua vim.diagnostic.open_float()<CR>", "Diagnostic popup")
nmap_leader("cf", '<Cmd>lua require("conform").format()<CR>', "Format")
nmap_leader("ch", "<Cmd>lua vim.lsp.buf.hover()<CR>", "Hover")
nmap_leader("ci", "<Cmd>lua vim.lsp.buf.implementation()<CR>", "Implementation")
nmap_leader("cl", "<Cmd>lua vim.lsp.codelens.run()<CR>", "Lens")
nmap_leader("cm", codenotes.create, "New / edit note at cursor")
nmap_leader("cM", codenotes.delete_at_cursor, "Delete note at cursor")
nmap_leader("cn", codenotes.pick, "Code notes")
nmap_leader("cN", notes.pick, "Project notes")
nmap_leader("cr", "<Cmd>lua vim.lsp.buf.rename()<CR>", "Rename")
nmap_leader("cR", "<Cmd>lua vim.lsp.buf.references()<CR>", "References")
nmap_leader("cs", "<Cmd>lua vim.lsp.buf.definition()<CR>", "Source definition")
nmap_leader("ct", "<Cmd>lua vim.lsp.buf.type_definition()<CR>", "Type definition")

xmap_leader("cc", comment_visual, "Comment toggle")
xmap_leader("cf", '<Cmd>lua require("conform").format()<CR>', "Format selection")

-- O is for 'Other'. Grab-bag of utility actions (capital O so the lowercase
-- `o` is free for the more frequent Session group below).
local toggle_quickfix = function() vim.cmd(vim.fn.getqflist({ winid = true }).winid ~= 0 and "cclose" or "copen") end
local toggle_loclist = function() vim.cmd(vim.fn.getloclist(0, { winid = true }).winid ~= 0 and "lclose" or "lopen") end
-- - `<Leader>Oz` - toggle between "zoomed" and regular view of current buffer
nmap_leader("On", "<Cmd>lua MiniNotify.show_history()<CR>", "Notifications")
nmap_leader("Oq", toggle_quickfix, "Quickfix toggle")
nmap_leader("OQ", toggle_loclist, "Location toggle")
nmap_leader("Or", "<Cmd>lua MiniMisc.resize_window()<CR>", "Resize to default width")
nmap_leader("Ot", "<Cmd>lua MiniTrailspace.trim()<CR>", "Trim trailspace")
nmap_leader("Oz", "<Cmd>lua MiniMisc.zoom()<CR>", "Zoom toggle")

-- o is for 'Session' (sessions are the most-used `o*` action; Other lives at
-- `O*` above). Common usage:
-- - `<Leader>on` - start new session
-- - `<Leader>or` - read previously started session
-- - `<Leader>oR` - restart Neovim preserving current session
local session_new = 'vim.ui.input({ prompt = "Session name: " }, MiniSessions.write)'

nmap_leader("od", '<Cmd>lua MiniSessions.select("delete")<CR>', "Delete")
nmap_leader("on", "<Cmd>lua " .. session_new .. "<CR>", "New")
nmap_leader("or", '<Cmd>lua MiniSessions.select("read")<CR>', "Read")
nmap_leader("oR", "<Cmd>lua MiniSessions.restart()<CR>", "Restart")
nmap_leader("ow", "<Cmd>lua MiniSessions.write()<CR>", "Write current")

-- v is for 'Visits'. Common usage:
-- - `<Leader>vv` - add    "core" label to current file.
-- - `<Leader>vV` - remove "core" label to current file.
-- - `<Leader>vc` - pick among all files with "core" label.
local make_pick_core = function(cwd, desc)
  return function()
    local sort_latest = MiniVisits.gen_sort.default({ recency_weight = 1 })
    local local_opts = { cwd = cwd, filter = "core", sort = sort_latest }
    MiniExtra.pickers.visit_paths(local_opts, { source = { name = desc } })
  end
end

nmap_leader("vc", make_pick_core(nil, "Core visits cwd"), "Core visits cwd")
nmap_leader("vC", make_pick_core("", "Core visits all"), "Core visits all")
nmap_leader("vv", '<Cmd>lua MiniVisits.add_label("core")<CR>', 'Add "core" label')
nmap_leader("vV", '<Cmd>lua MiniVisits.remove_label("core")<CR>', 'Remove "core" label')
nmap_leader("vl", "<Cmd>lua MiniVisits.add_label()<CR>", "Add label")
nmap_leader("vL", "<Cmd>lua MiniVisits.remove_label()<CR>", "Remove label")
