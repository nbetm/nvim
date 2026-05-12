-- Git blame in the editor — two flavors.
--   `M.popup`  - one-shot floating window with the commit that last touched
--                the current line. Rendered as a tiny markdown buffer with
--                `conceallevel=2`, so `[sha](url)` displays as just the SHA
--                with the link concealed. Press `gx` on a link to open it.
--                Press the bound key again while the popup is open to enter
--                it (then scroll, yank, etc; `<C-w>q` to close).
--   `M.toggle` - toggle persistent inline virtual text. While on, every line
--                shows " <author> · <relative> · <subject>" in navy at EOL.
--                Refreshes ~250ms after the cursor settles.
--
-- Both shell out to `git log -1 -L <line>,<line>:<file>` so they show the
-- commit that introduced the current state of the line, not the latest commit
-- that touched the file.

local M = {}

-- ─── Glyph + host detection ────────────────────────────────────────────────

-- nf-md-source_commit. Built from codepoint so the source stays ASCII-safe
-- and survives any transport stripping multibyte glyphs.
local GLYPH = vim.fn.nr2char(0xf0717)

-- Unit separator: never appears in commit text, safe to use as a field
-- delimiter inside git's `--format=...` template.
local US = "\x1f"
-- Record separator: marks the end of the formatted block so we can split off
-- the per-line diff that `git log -L` appends after.
local RS = "\x1e"

-- Normalize a remote URL into { host = "github"|"gitlab"|"bitbucket"|"other",
-- base = "https://host/owner/repo" }. Host detection drives the URL
-- conventions for commit / PR links in the popup.
local function host_info(remote_url)
  if not remote_url or remote_url == "" then return { host = "other" } end
  local s = remote_url:gsub("^%w+://[^/@]*@?", ""):gsub("^git@", "")
  s = s:gsub(":", "/", 1)
  s = (s:gsub("%.git/?$", ""))

  local host
  if s:match("^github%.com/") then
    host = "github"
  elseif s:match("gitlab") then
    host = "gitlab"
  elseif s:match("^bitbucket%.org/") then
    host = "bitbucket"
  else
    host = "other"
  end
  return { host = host, base = "https://" .. s }
end

local function commit_url(info, sha)
  if info.host == "github" then return info.base .. "/commit/" .. sha end
  if info.host == "gitlab" then return info.base .. "/-/commit/" .. sha end
  if info.host == "bitbucket" then return info.base .. "/commits/" .. sha end
  return nil
end

local function pr_url(info, num)
  if info.host == "github" then return info.base .. "/pull/" .. num end
  if info.host == "gitlab" then return info.base .. "/-/merge_requests/" .. num end
  if info.host == "bitbucket" then return info.base .. "/pull-requests/" .. num end
  return nil
end

-- Per-buffer cache of resolved host_info for the buffer's repo.
local repo_cache = {}

local function repo_for(buf)
  local cached = repo_cache[buf]
  if cached then return cached end
  local file = vim.api.nvim_buf_get_name(buf)
  if file == "" then return nil end
  local res = vim
    .system({ "git", "remote", "get-url", "origin" }, { text = true, cwd = vim.fs.dirname(file) })
    :wait(1500)
  local remote = (res and res.code == 0) and (res.stdout or ""):gsub("\n$", "") or ""
  local info = host_info(remote)
  repo_cache[buf] = info
  return info
end

-- Parse `(#NNN)` at end of subject (GitHub squash-merge convention).
local function parse_pr(subject) return subject and subject:match("%(#(%d+)%)%s*$") end

local MONTHS = { "Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec" }
local function pretty_date(iso)
  local y, mo, d = iso:match("(%d+)-(%d+)-(%d+)")
  if not y then return iso end
  return string.format("%s %d, %s", MONTHS[tonumber(mo)], tonumber(d), y)
end

-- ─── Popup ──────────────────────────────────────────────────────────────────

local popup_win = nil

M.popup = function()
  if popup_win and vim.api.nvim_win_is_valid(popup_win) then
    vim.api.nvim_set_current_win(popup_win)
    return
  end
  local buf = vim.api.nvim_get_current_buf()
  local line = vim.fn.line(".")
  local file = vim.fn.expand("%:p")
  if file == "" or vim.fn.filereadable(file) == 0 then
    vim.notify("blame: no file", vim.log.levels.WARN)
    return
  end
  local fmt = table.concat({ "%H", "%h", "%an", "%as", "%s", "%b" }, US) .. RS
  local res = vim
    .system({
      "git",
      "log",
      "-1",
      "--format=" .. fmt,
      "-L",
      string.format("%d,%d:%s", line, line, file),
    }, { text = true, cwd = vim.fs.dirname(file) })
    :wait(2000)
  if not res or res.code ~= 0 or not res.stdout or res.stdout == "" then
    vim.notify("blame: untracked or no history", vim.log.levels.WARN)
    return
  end
  -- Split off the per-line diff appended after the formatted block.
  local block = vim.split(res.stdout, RS, { plain = true })[1] or ""
  local parts = vim.split(block, US, { plain = true })
  if #parts < 5 then
    vim.notify("blame: parse error", vim.log.levels.WARN)
    return
  end
  local full_sha, short_sha, author, date, subject = parts[1], parts[2], parts[3], parts[4], parts[5]
  local body = (parts[6] or ""):gsub("^\n", ""):gsub("\n+$", "")

  local info = repo_for(buf) or { host = "other" }
  local curl = commit_url(info, full_sha)
  local sha_link = curl and string.format("[%s](%s)", short_sha, curl) or short_sha

  local pr_num = parse_pr(subject)
  local subject_clean = pr_num and (subject:gsub("%s*%(#%d+%)%s*$", "")) or subject
  local pr_tail = ""
  if pr_num then
    local purl = pr_url(info, pr_num)
    pr_tail = purl and string.format(" ([#%s](%s))", pr_num, purl) or string.format(" (#%s)", pr_num)
  end

  local lines = {
    string.format("%s · %s", author, pretty_date(date)),
    "",
    string.format("%s %s%s", sha_link, subject_clean, pr_tail),
  }
  if body ~= "" then
    table.insert(lines, "")
    for _, l in ipairs(vim.split(body, "\n", { plain = true })) do
      table.insert(lines, l)
    end
  end

  local _, winid = vim.lsp.util.open_floating_preview(lines, "markdown", {
    border = "single",
    focus = false,
    max_height = 20,
  })
  popup_win = winid
  if winid and vim.api.nvim_win_is_valid(winid) then
    vim.wo[winid].conceallevel = 2
    vim.wo[winid].concealcursor = "n"
  end
end

-- ─── Inline (toggle) ────────────────────────────────────────────────────────

local ns = vim.api.nvim_create_namespace("inline-blame")
local group = vim.api.nvim_create_augroup("inline-blame", {})
local enabled = false
local saved_updatetime = nil

local clear = function() vim.api.nvim_buf_clear_namespace(0, ns, 0, -1) end

local show = function()
  local buf = vim.api.nvim_get_current_buf()
  local line = vim.fn.line(".")
  local file = vim.fn.expand("%:p")
  if file == "" or vim.fn.filereadable(file) == 0 then return end
  local fmt = table.concat({ "%an", "%ar", "%s" }, US)
  vim.system({
    "git",
    "log",
    "-1",
    "--format=" .. fmt,
    "-L",
    string.format("%d,%d:%s", line, line, file),
  }, { text = true, cwd = vim.fs.dirname(file) }, function(res)
    if res.code ~= 0 or not res.stdout then return end
    local first = vim.split(res.stdout, "\n", { plain = true })[1] or ""
    if first == "" then return end
    local parts = vim.split(first, US, { plain = true })
    if #parts < 3 then return end
    local author, relative, subject = parts[1], parts[2], parts[3]
    subject = subject:gsub("%s*%(#%d+%)%s*$", "")
    local text = string.format("  %s %s · %s · %s", GLYPH, author, relative, subject)
    vim.schedule(function()
      if not enabled then return end
      if vim.api.nvim_get_current_buf() ~= buf then return end
      if vim.fn.line(".") ~= line then return end
      vim.api.nvim_buf_set_extmark(buf, ns, line - 1, 0, {
        virt_text = { { text, "BlameInline" } },
        virt_text_pos = "eol",
        hl_mode = "combine",
      })
    end)
  end)
end

M.toggle = function()
  enabled = not enabled
  vim.api.nvim_clear_autocmds({ group = group })
  if not enabled then
    clear()
    if saved_updatetime then
      vim.o.updatetime = saved_updatetime
      saved_updatetime = nil
    end
    return
  end
  saved_updatetime = vim.o.updatetime
  vim.o.updatetime = 250
  vim.api.nvim_create_autocmd({ "CursorMoved", "InsertEnter", "BufLeave" }, {
    group = group,
    callback = clear,
  })
  vim.api.nvim_create_autocmd("CursorHold", {
    group = group,
    callback = show,
  })
  show()
end

return M
