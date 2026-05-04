-- nvim-lspconfig defaults to `filetypes = { "yaml", "yaml.docker-compose",
-- "yaml.gitlab", "yaml.helm-values" }`. The compound types trip
-- `:checkhealth vim.lsp` (filename != filetype) without adding behavior:
-- yamlls already attaches to any compound `yaml.x` via the `yaml` parent.
-- Schemas (kubernetes, github-actions, etc.) are configured separately.
return {
  filetypes = { "yaml" },
}
