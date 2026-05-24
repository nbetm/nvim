-- Open a command in a centered floating terminal. The terminal buffer is
-- wiped automatically when the process exits, so launching a TUI (lazygit,
-- jjui, htop) and quitting it returns to the previous window cleanly.
--
-- Usage:
--   require("floatterm").open("lazygit")
--   require("floatterm").open("jjui", { width = 0.7, height = 0.8 })
--
-- `width`/`height` are ratios of the editor's columns/lines. Width defaults
-- to 0.9; height to 0.85 so the statusline and cmdline stay visible above
-- and below the float.

local M = {}

M.open = function(cmd, opts)
  opts = opts or {}
  local w_ratio = opts.width or 0.9
  local h_ratio = opts.height or 0.85

  local w = math.floor(vim.o.columns * w_ratio)
  local h = math.floor(vim.o.lines * h_ratio)

  -- Border that blends with the editor canvas: chrome fg on base bg.
  -- Derived each call so a colorscheme swap stays consistent.
  vim.api.nvim_set_hl(0, "FloattermBorder", {
    fg = vim.api.nvim_get_hl(0, { name = "LineNr" }).fg,
    bg = vim.api.nvim_get_hl(0, { name = "Normal" }).bg,
  })

  local buf = vim.api.nvim_create_buf(false, true)
  local win = vim.api.nvim_open_win(buf, true, {
    relative = "editor",
    width = w,
    height = h,
    col = math.floor((vim.o.columns - w) / 2),
    row = math.floor((vim.o.lines - h) / 2),
    style = "minimal",
    border = "single",
  })
  -- TUIs feel like a screen takeover, so match the editor's `Normal` bg
  -- (base) instead of `NormalFloat` (surface), and use a border whose own
  -- bg matches that base too (otherwise FloatBorder's surface bg shows as
  -- a band around the float).
  vim.wo[win].winhighlight = "NormalFloat:Normal,FloatBorder:FloattermBorder"

  vim.fn.jobstart(cmd, {
    term = true,
    on_exit = function()
      if vim.api.nvim_buf_is_valid(buf) then vim.api.nvim_buf_delete(buf, { force = true }) end
    end,
  })
  vim.cmd("startinsert")
end

return M
