-- Git blame in the editor — two flavors.
--   `M.popup`  - one-shot floating window with the commit that last touched
--                the current line. Press the bound key again while it's open
--                to enter the popup (then `yiw` the hash, `<C-w>q` to close).
--   `M.toggle` - toggle persistent inline virtual text. While on, every line
--                shows "<author>, <relative date>  <subject>" at end-of-line.
--                Refreshes ~250ms after the cursor settles.
--
-- Both shell out to `git log -1 -L <line>,<line>:<file>` so they show the
-- commit that introduced the current state of the line, not the latest commit
-- that touched the file.

local M = {}

-- ─── Popup ──────────────────────────────────────────────────────────────────

local popup_win = nil

M.popup = function()
  -- If the popup from the previous press is still open, jump into it.
  if popup_win and vim.api.nvim_win_is_valid(popup_win) then
    vim.api.nvim_set_current_win(popup_win)
    return
  end
  local line = vim.fn.line(".")
  local file = vim.fn.expand("%:p")
  if file == "" or vim.fn.filereadable(file) == 0 then
    vim.notify("blame: no file", vim.log.levels.WARN)
    return
  end
  local res = vim
    .system({
      "git",
      "log",
      "-1",
      "--format=%h %s%n%an, %ar",
      "-L",
      string.format("%d,%d:%s", line, line, file),
    }, { text = true, cwd = vim.fs.dirname(file) })
    :wait(2000)
  if not res or res.code ~= 0 then
    vim.notify("blame: untracked or no history", vim.log.levels.WARN)
    return
  end
  local out = vim.split(res.stdout or "", "\n")
  local _, winid = vim.lsp.util.open_floating_preview({ out[1] or "", out[2] or "" }, "", {
    border = "single",
    focus = false,
  })
  popup_win = winid
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
  vim.system({
    "git",
    "log",
    "-1",
    "--format=%an, %ar  %s",
    "-L",
    string.format("%d,%d:%s", line, line, file),
  }, { text = true, cwd = vim.fs.dirname(file) }, function(res)
    if res.code ~= 0 or not res.stdout then return end
    local first = vim.split(res.stdout, "\n")[1] or ""
    if first == "" then return end
    vim.schedule(function()
      -- Bail if the cursor moved while git was running.
      if not enabled then return end
      if vim.api.nvim_get_current_buf() ~= buf then return end
      if vim.fn.line(".") ~= line then return end
      vim.api.nvim_buf_set_extmark(buf, ns, line - 1, 0, {
        virt_text = { { "  " .. first, "Comment" } },
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
    -- Restore previous `updatetime` so other CursorHold-driven behavior is
    -- back to the user's normal cadence.
    if saved_updatetime then
      vim.o.updatetime = saved_updatetime
      saved_updatetime = nil
    end
    return
  end
  -- Default `'updatetime'` is 4000ms; CursorHold would only fire after 4s of
  -- idle, which feels broken for inline blame. Drop it to 250ms while active.
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
