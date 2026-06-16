-- tflint config (runs as a language server via `tflint --langserver`).
-- Source: https://github.com/terraform-linters/tflint

return {
  -- Same as terraform-ls (./terraformls.lua).
  root_dir = function(bufnr, on_dir)
    local name = vim.api.nvim_buf_get_name(bufnr)
    if name == "" or name:find("://", 1, true) then return end
    on_dir(vim.fs.root(bufnr, { ".terraform", ".git", ".tflint.hcl" }) or vim.fs.dirname(name))
  end,
  on_attach = function(client) client.server_capabilities.semanticTokensProvider = nil end,
}
