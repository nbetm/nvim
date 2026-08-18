-- markdown-oxide: Obsidian-compatible PKM language server.
-- Source: https://github.com/Feel-ix-343/markdown-oxide
--
-- Settings live in TOML, not here: `~/.config/moxide/settings.toml` globally,
-- layered under `~/seton/.moxide.toml` for the notes vault.

-- The notes vault. Everything PKM-flavoured is scoped to it, because oxide
-- roots on `.git` and so treats every code repo as a vault of its own.
local vault = vim.fs.normalize("~/seton")

return {
  -- Neovim defaults this to `false`. markdown-oxide needs it for the "create
  -- unresolved file" code action and for resolving completions in files it
  -- has not indexed yet.
  capabilities = {
    workspace = {
      didChangeWatchedFiles = { dynamicRegistration = true },
    },
  },
  -- Replaces the daily-note commands nvim-lspconfig attaches to every client.
  -- Unscoped, `:LspToday` in a code repo writes a dated note to the repo root;
  -- daily notes only mean something in the vault.
  on_attach = function(client, bufnr)
    if vim.fs.normalize(client.root_dir or "") ~= vault then return end
    for _, cmd in ipairs({ "today", "tomorrow", "yesterday" }) do
      local name = "Lsp" .. cmd:gsub("^%l", string.upper)
      local jump = function()
        local params = { title = ("Markdown-Oxide-%s"):format(cmd), command = "jump", arguments = { cmd } }
        client:exec_cmd(params, { bufnr = bufnr })
      end
      vim.api.nvim_buf_create_user_command(bufnr, name, jump, { desc = ("Open %s daily note"):format(cmd) })
    end
  end,
}
