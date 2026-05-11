-- Pick files that are modified, staged, or untracked in the current git repo.
-- Uses `git status --porcelain` so the list covers everything you've touched
-- since the last commit, regardless of stage state. Equivalent to the set you
-- see in `git status`'s "Changes" / "Untracked" sections.
--
-- Ignored files (`.gitignore`-matched) are excluded.
-- Deleted files are excluded too — they can't be opened from the picker.

local M = {}

local function repo_root()
  local res = vim.system({ "git", "rev-parse", "--show-toplevel" }, { text = true }):wait(1500)
  if not res or res.code ~= 0 then return nil end
  return (res.stdout or ""):gsub("\n$", "")
end

M.changed = function()
  local root = repo_root()
  if not root or root == "" then
    vim.notify("not in a git repo", vim.log.levels.WARN)
    return
  end
  local res = vim.system({ "git", "status", "--porcelain" }, { text = true, cwd = root }):wait(2000)
  if not res or res.code ~= 0 then
    vim.notify("git status failed", vim.log.levels.WARN)
    return
  end

  local files = {}
  for line in vim.gsplit(res.stdout or "", "\n") do
    if line ~= "" then
      local status = line:sub(1, 2)
      local path = line:sub(4)
      -- Porcelain renames render as `R  old -> new` — pick the new path.
      local arrow = path:find(" %-> ")
      if arrow then path = path:sub(arrow + 4) end
      -- Skip deleted (can't open) and ignored (rare here, but defensive).
      local is_deleted = status:match("^.D$") or status:match("^D.$")
      local is_ignored = status == "!!"
      if not is_deleted and not is_ignored then table.insert(files, root .. "/" .. path) end
    end
  end

  if #files == 0 then
    vim.notify("no changed files", vim.log.levels.INFO)
    return
  end

  MiniPick.start({
    source = {
      items = files,
      name = "Changed files",
      cwd = root,
      -- Show mini.icons prefix per row, same as `Pick files`.
      show = function(buf_id, items_to_show, query)
        MiniPick.default_show(buf_id, items_to_show, query, { show_icons = true })
      end,
    },
  })
end

return M
