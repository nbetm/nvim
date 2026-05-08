-- Pick files from a `.notes/` directory adjacent to the current project.
-- The default picker (`<Leader>f` / `Pick files`) uses ripgrep with gitignore
-- enabled, so `.notes/` (which is gitignored) is invisible. This module
-- searches `.notes/` explicitly with `rg --no-ignore`, walking upward from
-- the current buffer's directory to find the nearest one.

local M = {}

local function find_notes_dir()
  local start = vim.fn.expand("%:p:h")
  if start == "" then start = vim.fn.getcwd() end
  return vim.fs.find(".notes", { type = "directory", upward = true, path = start })[1]
end

M.pick = function()
  local notes_dir = find_notes_dir()
  if not notes_dir then
    vim.notify(".notes/ not found above " .. vim.fn.getcwd(), vim.log.levels.WARN)
    return
  end
  -- `--no-ignore` to bypass parent .gitignore that excludes `.notes/`.
  -- `--hidden` so dotfiles inside the notes dir show up. `!.git` excludes
  -- any nested git repo metadata in case the notes dir contains one.
  local files = vim.fn.systemlist({
    "rg",
    "--files",
    "--no-ignore",
    "--hidden",
    "--glob",
    "!.git",
    "--",
    notes_dir,
  })
  if vim.v.shell_error ~= 0 or #files == 0 then
    vim.notify(".notes/ exists but is empty: " .. notes_dir, vim.log.levels.INFO)
    return
  end
  MiniPick.start({
    source = {
      items = files,
      name = "Notes (" .. vim.fn.fnamemodify(notes_dir, ":~") .. ")",
    },
  })
end

return M
