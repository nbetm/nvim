-- Pick files from a `.notes/` directory adjacent to the current project.
-- The default picker (`<Leader>f` / `Pick files`) uses ripgrep with gitignore
-- enabled, so `.notes/` (which is gitignored) is invisible. This module
-- searches `.notes/` explicitly with `rg --no-ignore`, walking upward from
-- the working directory to find the nearest one.

local M = {}

local function find_notes_dir()
  return vim.fs.find(".notes", { type = "directory", upward = true, path = vim.fn.getcwd() })[1]
end

M.pick = function()
  local notes_dir = find_notes_dir()
  if not notes_dir then
    vim.notify(".notes/ not found above " .. vim.fn.getcwd(), vim.log.levels.WARN)
    return
  end
  -- `--no-ignore` to bypass parent .gitignore that excludes `.notes/`.
  -- `--hidden` so dotfiles inside the notes dir show up. `--follow` traverses
  -- symlinks so notes linked into `.notes/` from elsewhere show up.
  -- `!.git` excludes any nested git repo metadata.
  local files = vim.fn.systemlist({
    "rg",
    "--files",
    "--no-ignore",
    "--hidden",
    "--follow",
    "--glob",
    "!.git",
    "--",
    notes_dir,
  })
  -- Gate on `#files` only, not the exit code. With `--follow`, rg exits 2 on
  -- non-fatal warnings (e.g. a dangling symlink in the notes tree) yet still
  -- lists every valid file on stdout, so a bad exit code is not "empty".
  if #files == 0 then
    vim.notify(".notes/ exists but is empty: " .. notes_dir, vim.log.levels.INFO)
    return
  end
  MiniPick.start({
    source = {
      items = files,
      name = "Notes (" .. vim.fn.fnamemodify(notes_dir, ":~") .. ")",
      -- Show mini.icons prefix per row, same as `Pick files`.
      show = function(buf_id, items_to_show, query)
        MiniPick.default_show(buf_id, items_to_show, query, { show_icons = true })
      end,
    },
  })
end

return M
