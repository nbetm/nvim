-- Line-anchored code notes. Drop annotations on file:line pairs while
-- exploring or refactoring; browse / walk-through / yank via mini.pick.
--
-- See docs/superpowers/specs/2026-05-11-codenotes-design.md for design rationale.

local M = {}

-- ─── Storage helpers ────────────────────────────────────────────────────────

-- Resolve the git repo root for a buffer or cwd. Falls back to the current
-- working directory (NOT start_path) when not in a git repo — this keeps
-- the XDG bucket key stable across `M.create` calls within a session.
local function repo_root(start_path)
  start_path = start_path or vim.fn.getcwd()
  local res = vim.system({ "git", "rev-parse", "--show-toplevel" }, { text = true, cwd = start_path }):wait(1500)
  if res and res.code == 0 and res.stdout and res.stdout ~= "" then return (res.stdout:gsub("\n$", "")) end
  return vim.fn.getcwd()
end

-- Where do the notes for this root live? Always XDG-bucketed by sha256 of
-- the resolved repo root path. Clones at different filesystem paths get
-- separate buckets; branches share within a clone.
local function store_path(root)
  local xdg_dir = vim.fn.stdpath("data") .. "/codenotes"
  vim.fn.mkdir(xdg_dir, "p")
  return xdg_dir .. "/" .. vim.fn.sha256(root):sub(1, 12) .. ".json"
end

-- Read a store. Missing file or malformed JSON both yield an empty store.
local function load(path)
  local ok_read, content = pcall(vim.fn.readfile, path)
  if not ok_read or not content or #content == 0 then return { notes = {} } end
  local ok_decode, decoded = pcall(vim.json.decode, table.concat(content, "\n"))
  if not ok_decode or type(decoded) ~= "table" or type(decoded.notes) ~= "table" then
    vim.notify("codenotes: malformed store at " .. path .. ", treating as empty", vim.log.levels.WARN)
    return { notes = {} }
  end
  return decoded
end

-- Generate a stable per-note id: <epoch-ms>-<random4>. Sortable, unique
-- enough for this use case (single-user, infrequent creates).
local function new_id() return string.format("%d-%04x", math.floor(vim.uv.hrtime() / 1e6), math.random(0, 0xFFFF)) end

-- Atomically write a store. Writes to `.tmp`, then renames.
local function save(path, store)
  vim.fn.mkdir(vim.fn.fnamemodify(path, ":h"), "p")
  local tmp = path .. ".tmp"
  local encoded = vim.json.encode(store)
  if vim.fn.writefile({ encoded }, tmp) ~= 0 then
    vim.notify("codenotes: failed to write " .. tmp, vim.log.levels.ERROR)
    return
  end
  local ok, err = os.rename(tmp, path)
  if not ok then vim.notify("codenotes: rename failed: " .. (err or "?"), vim.log.levels.ERROR) end
end

-- ─── Rendering state ────────────────────────────────────────────────────────

-- One namespace for all codenote extmarks. Created in M.setup().
local ns

-- Map of buffer → { [extmark_id] = note_id, ... }
-- Lets actions (delete) find a note from the extmark or vice versa.
local buf_to_marks = {}

-- Sign glyph + highlight per spec.
-- nf-md-lightbulb (U+F0335), built from its codepoint at runtime so the
-- source stays ASCII-only (grep-safe; survives editors that strip glyphs).
local SIGN_TEXT = vim.fn.nr2char(0xf0335)
local SIGN_HL = "CodenoteSign"

-- Place signs for any notes in the store that match this buffer's relative path.
local function place_signs(buf)
  if not ns then return end
  if vim.bo[buf].buftype ~= "" then return end -- skip help/qf/terminal/prompt/nofile
  local abs_path = vim.api.nvim_buf_get_name(buf)
  if abs_path == "" then return end
  local root = repo_root(vim.fn.fnamemodify(abs_path, ":h"))
  if not vim.startswith(abs_path, root .. "/") then return end
  local rel_path = abs_path:sub(#root + 2)
  local store = load(store_path(root))

  -- Find matching notes first; if none, no need to clear and rebuild.
  local matching = {}
  for _, note in ipairs(store.notes) do
    if note.path == rel_path then table.insert(matching, note) end
  end
  if #matching == 0 and (not buf_to_marks[buf] or vim.tbl_isempty(buf_to_marks[buf])) then return end

  buf_to_marks[buf] = buf_to_marks[buf] or {}
  -- Clear existing marks for this buffer to avoid duplicates on re-render.
  for mark_id, _ in pairs(buf_to_marks[buf]) do
    pcall(vim.api.nvim_buf_del_extmark, buf, ns, mark_id)
  end
  buf_to_marks[buf] = {}

  for _, note in ipairs(matching) do
    local line_idx = math.max(0, note.line - 1) -- 0-indexed for extmark
    local ok, mark_id = pcall(vim.api.nvim_buf_set_extmark, buf, ns, line_idx, 0, {
      sign_text = SIGN_TEXT,
      sign_hl_group = SIGN_HL,
      invalidate = true,
    })
    if ok then buf_to_marks[buf][mark_id] = note.id end
  end
end

-- Read current extmark positions for this buffer and persist them to the
-- store. Invalid marks (anchor line was fully deleted) are GC'd from both
-- the store and the in-memory buf_to_marks. Returns true if anything changed.
local function sync_positions(buf)
  local marks = buf_to_marks[buf]
  if not marks or vim.tbl_isempty(marks) then return false end
  local abs_path = vim.api.nvim_buf_get_name(buf)
  if abs_path == "" then return false end
  local root = repo_root(vim.fn.fnamemodify(abs_path, ":h"))
  local path = store_path(root)
  local store = load(path)

  local by_id = {}
  for _, note in ipairs(store.notes) do
    by_id[note.id] = note
  end

  local line_count = vim.api.nvim_buf_line_count(buf)
  local to_remove = {} -- set of note ids to GC
  local changed = false

  for mark_id, note_id in pairs(marks) do
    local note = by_id[note_id]
    if note then
      local pos = vim.api.nvim_buf_get_extmark_by_id(buf, ns, mark_id, { details = true })
      if pos and pos[3] and pos[3].invalid then
        to_remove[note_id] = true
        pcall(vim.api.nvim_buf_del_extmark, buf, ns, mark_id)
        marks[mark_id] = nil
        changed = true
      elseif pos and pos[1] then
        local new_line = math.min(pos[1] + 1, line_count)
        if note.line ~= new_line then
          note.line = new_line
          changed = true
        end
      end
    end
  end

  if next(to_remove) then
    local kept = {}
    for _, note in ipairs(store.notes) do
      if not to_remove[note.id] then table.insert(kept, note) end
    end
    store.notes = kept
  end
  if changed then save(path, store) end
  return changed
end

-- ─── Picker actions ─────────────────────────────────────────────────────────

local function jump_to(item)
  if not item or type(item) ~= "table" then return end
  vim.schedule(function()
    vim.cmd("edit " .. vim.fn.fnameescape(item.path))
    local ok = pcall(vim.api.nvim_win_set_cursor, 0, { item.lnum, 0 })
    if ok then vim.cmd("normal! zz") end
  end)
end

-- Remove the currently-matched note from the store and any open buffer's
-- extmark, then refresh the picker items in place. Picker stays open so
-- multiple notes can be deleted without reopening.
--
-- `store_p` is bound at picker-open time so we delete from the store the
-- picker was opened against, not whatever the current buffer happens to be.
local function delete_action(store_p)
  local item = MiniPick.get_picker_matches().current
  if not item then return end

  local store = load(store_p)
  local new_notes = {}
  for _, note in ipairs(store.notes) do
    if note.id ~= item.note_id then table.insert(new_notes, note) end
  end
  store.notes = new_notes
  save(store_p, store)

  -- Clear extmark(s) in any open buffer. Skip + clean stale bufnrs.
  for b, marks in pairs(buf_to_marks) do
    if not vim.api.nvim_buf_is_valid(b) then
      buf_to_marks[b] = nil
    else
      for mark_id, note_id in pairs(marks) do
        if note_id == item.note_id then
          pcall(vim.api.nvim_buf_del_extmark, b, ns, mark_id)
          buf_to_marks[b][mark_id] = nil
        end
      end
    end
  end

  -- Refresh picker items: drop the deleted item from the current list.
  local refreshed = {}
  for _, it in ipairs(MiniPick.get_picker_items()) do
    if it.note_id ~= item.note_id then table.insert(refreshed, it) end
  end
  MiniPick.set_picker_items(refreshed)
  vim.notify("codenotes: deleted", vim.log.levels.INFO)
end

-- Send currently visible (filtered) picker items to the qf list and open it.
-- Closes the picker.
local function send_to_qf_action()
  local matches = MiniPick.get_picker_matches()
  local items = matches.all or MiniPick.get_picker_items() or {}
  if #items == 0 then return end

  local qf_list = {}
  for _, it in ipairs(items) do
    table.insert(qf_list, {
      filename = it.path,
      lnum = it.lnum,
      col = 1,
      text = it.content,
    })
  end
  vim.fn.setqflist(qf_list, "r")
  MiniPick.stop()
  vim.schedule(function() vim.cmd("copen") end)
end

-- Format currently visible items as 'path:line  content' lines and write to
-- the + register. Closes the picker.
local function yank_action()
  local matches = MiniPick.get_picker_matches()
  local items = matches.all or MiniPick.get_picker_items() or {}
  if #items == 0 then return end

  local lines = {}
  for _, it in ipairs(items) do
    table.insert(lines, string.format("%s:%d  %s", it.path, it.lnum, it.content))
  end
  vim.fn.setreg("+", table.concat(lines, "\n"), "V")
  MiniPick.stop()
  vim.notify(string.format("codenotes: yanked %d notes", #items), vim.log.levels.INFO)
end

-- ─── Public API ─────────────────────────────────────────────────────────────

M.setup = function()
  ns = vim.api.nvim_create_namespace("codenotes")
  local group = vim.api.nvim_create_augroup("codenotes", { clear = true })
  vim.api.nvim_create_autocmd("BufReadPost", {
    group = group,
    callback = function(args) place_signs(args.buf) end,
    desc = "codenotes: place signs from store on buffer open",
  })
  vim.api.nvim_create_autocmd("BufWritePost", {
    group = group,
    callback = function(args) sync_positions(args.buf) end,
    desc = "codenotes: persist extmark positions on save",
  })
  vim.api.nvim_create_autocmd("BufDelete", {
    group = group,
    callback = function(args)
      sync_positions(args.buf)
      buf_to_marks[args.buf] = nil
    end,
    desc = "codenotes: final sync + cleanup on buffer delete",
  })
end

M.create = function()
  local buf = vim.api.nvim_get_current_buf()
  local abs_path = vim.api.nvim_buf_get_name(buf)
  if abs_path == "" then
    vim.notify("codenotes: no file in current buffer", vim.log.levels.WARN)
    return
  end
  local line = vim.fn.line(".")
  local root = repo_root(vim.fn.fnamemodify(abs_path, ":h"))
  if not vim.startswith(abs_path, root .. "/") then
    vim.notify("codenotes: file is outside the repo root " .. root, vim.log.levels.WARN)
    return
  end
  local rel_path = abs_path:sub(#root + 2)
  local path = store_path(root)
  local store = load(path)

  -- Is there already a note on this file:line? If so, edit it instead of stacking.
  local existing
  for _, note in ipairs(store.notes) do
    if note.path == rel_path and note.line == line then
      existing = note
      break
    end
  end

  local prompt = existing and "Edit note: " or "Code note: "
  local default = existing and existing.content or ""

  vim.ui.input({ prompt = prompt, default = default }, function(input)
    if not input then return end
    local trimmed = vim.trim(input)
    if trimmed == "" then return end

    if existing then
      existing.content = trimmed
      save(path, store)
      vim.notify("codenotes: updated", vim.log.levels.INFO)
      return
    end

    local note = {
      id = new_id(),
      path = rel_path,
      line = line,
      content = trimmed,
      created = os.date("!%Y-%m-%dT%H:%M:%SZ"),
    }
    table.insert(store.notes, note)
    save(path, store)

    if ns then
      local ok, mark_id = pcall(vim.api.nvim_buf_set_extmark, buf, ns, line - 1, 0, {
        sign_text = SIGN_TEXT,
        sign_hl_group = SIGN_HL,
        invalidate = true,
      })
      if ok then
        buf_to_marks[buf] = buf_to_marks[buf] or {}
        buf_to_marks[buf][mark_id] = note.id
      end
    end
    vim.notify("codenotes: saved", vim.log.levels.INFO)
  end)
end

M.delete_at_cursor = function()
  local buf = vim.api.nvim_get_current_buf()
  local abs_path = vim.api.nvim_buf_get_name(buf)
  if abs_path == "" then
    vim.notify("codenotes: no file in current buffer", vim.log.levels.WARN)
    return
  end
  local line = vim.fn.line(".")
  local root = repo_root(vim.fn.fnamemodify(abs_path, ":h"))
  if not vim.startswith(abs_path, root .. "/") then return end
  local rel_path = abs_path:sub(#root + 2)
  local path = store_path(root)
  local store = load(path)

  local target_id
  local kept = {}
  for _, note in ipairs(store.notes) do
    if note.path == rel_path and note.line == line then
      target_id = note.id
    else
      table.insert(kept, note)
    end
  end

  if not target_id then
    vim.notify("codenotes: no note on this line", vim.log.levels.INFO)
    return
  end

  store.notes = kept
  save(path, store)

  -- Clear the extmark in any open buffer with this note.
  if ns then
    for b, marks in pairs(buf_to_marks) do
      if vim.api.nvim_buf_is_valid(b) then
        for mark_id, note_id in pairs(marks) do
          if note_id == target_id then
            pcall(vim.api.nvim_buf_del_extmark, b, ns, mark_id)
            marks[mark_id] = nil
          end
        end
      else
        buf_to_marks[b] = nil
      end
    end
  end

  vim.notify("codenotes: deleted", vim.log.levels.INFO)
end

M.pick = function()
  local buf = vim.api.nvim_get_current_buf()
  local abs_path = vim.api.nvim_buf_get_name(buf)
  local start = abs_path ~= "" and vim.fn.fnamemodify(abs_path, ":h") or vim.fn.getcwd()
  local root = repo_root(start)
  local path = store_path(root)
  local store = load(path)

  if #store.notes == 0 then
    vim.notify("codenotes: no notes in this repo", vim.log.levels.INFO)
    return
  end

  -- Build picker items. Sort by path then line for predictable ordering.
  local items = {}
  for _, note in ipairs(store.notes) do
    table.insert(items, {
      text = string.format("%s:%d  %s", note.path, note.line, note.content),
      path = root .. "/" .. note.path,
      lnum = note.line,
      content = note.content,
      note_id = note.id,
    })
  end
  table.sort(items, function(a, b)
    if a.path == b.path then return a.lnum < b.lnum end
    return a.path < b.path
  end)

  local store_name = path:match("^.+/(.+)$") or path
  MiniPick.start({
    source = {
      items = items,
      name = "Code notes (" .. store_name .. ")",
      choose = jump_to,
      show = function(buf_id, items_to_show, query)
        MiniPick.default_show(buf_id, items_to_show, query, { show_icons = true })
      end,
    },
    mappings = {
      delete = { char = "<C-d>", func = function() delete_action(path) end },
      send_to_qf = { char = "<C-q>", func = send_to_qf_action },
      yank = { char = "<C-y>", func = yank_action },
    },
  })
end

return M
