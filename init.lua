-- Personal Neovim config built around mini.nvim, based on the MiniMax starter.
-- README.md has the file layout. CLAUDE.md has the tooling notes.

-- ┌────────────────┐
-- │ Plugin manager │
-- └────────────────┘
--
-- `vim.pack` is Neovim's built-in plugin manager. `vim.pack.add()` loads a
-- plugin after making sure it is installed from source. Installed state is
-- recorded in the 'nvim-pack-lock.json' lockfile.
--
-- See also:
-- - `:h vim.pack-examples` - how to use it
-- - `:h vim.pack-lockfile` - lockfile info
-- - `:h vim.pack-events` - available events and plugin hooks examples
-- - `:h vim.pack.update()` - more details about confirmation step

-- Passes data between scripts. Reachable as both `_G.Config` and `Config`.
_G.Config = {}

-- 'mini.nvim' powers most of this config. See 'plugin/30_mini.lua' for how.
-- Loaded here so 'mini.misc' is available for the loading helpers below.
vim.pack.add({ "https://github.com/nvim-mini/mini.nvim" })

-- Loading helpers. Each wraps its callback in `MiniMisc.safely` so one failure
-- doesn't cascade.
-- - `now` - run immediately. Colorscheme, statusline, tabline.
-- - `later` - run after the first draw. Anything not needed at startup.
-- - `now_if_args` - `now` when started as `nvim -- path/to/file`, else `later`.
-- - `on_event` - run once on the first matching event, e.g. `InsertEnter`.
-- - `on_filetype` - run once on the first matching filetype, e.g. `lua`.
--
-- See also: `:h MiniMisc.safely()`, 'plugin/30_mini.lua', 'plugin/40_plugins.lua'
local misc = require("mini.misc")
Config.now = function(f) misc.safely("now", f) end
Config.later = function(f) misc.safely("later", f) end
Config.now_if_args = vim.fn.argc(-1) > 0 and Config.now or Config.later
Config.on_event = function(ev, f) misc.safely("event:" .. ev, f) end
Config.on_filetype = function(ft, f) misc.safely("filetype:" .. ft, f) end

-- Custom autocommand group, plus a helper to add to it.
-- See `:h autocommand`, `:h nvim_create_augroup()`, `:h nvim_create_autocmd()`.
local gr = vim.api.nvim_create_augroup("custom-config", {})
Config.new_autocmd = function(event, pattern, callback, desc)
  local opts = { group = gr, pattern = pattern, callback = callback, desc = desc }
  vim.api.nvim_create_autocmd(event, opts)
end

-- `vim.pack.add()` hook helper. Plugin data is passed to the callback.
-- See `:h vim.pack-events`, and 'plugin/40_plugins.lua' for a use.
Config.on_packchanged = function(plugin_name, kinds, callback, desc)
  local f = function(ev)
    local name, kind = ev.data.spec.name, ev.data.kind
    if not (name == plugin_name and vim.tbl_contains(kinds, kind)) then return end
    if not ev.data.active then vim.cmd.packadd(plugin_name) end
    callback(ev.data)
  end
  Config.new_autocmd("PackChanged", "*", f, desc)
end
