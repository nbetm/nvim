-- terraform-ls config.
-- Source: https://github.com/hashicorp/terraform-ls

return {
  -- Never attach to non-file buffers (octo:// PR-review diffs, etc.).
  -- terraform-ls panics on a non-file URI via `MustParseURI`.
  root_dir = function(bufnr, on_dir)
    local name = vim.api.nvim_buf_get_name(bufnr)
    if name == "" or name:find("://", 1, true) then return end
    on_dir(vim.fs.root(bufnr, { ".terraform", ".git" }) or vim.fs.dirname(name))
  end,
  -- Treesitter does the highlighting, so drop the semantic-token layer.
  -- It adds an open-flicker and goes stale after an external reload.
  on_attach = function(client) client.server_capabilities.semanticTokensProvider = nil end,
}
