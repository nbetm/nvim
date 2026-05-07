-- nvim-lspconfig defaults to `filetypes = { "yaml", "yaml.docker-compose",
-- "yaml.gitlab", "yaml.helm-values" }`. The compound types trip
-- `:checkhealth vim.lsp` (filename != filetype) without adding behavior:
-- yamlls already attaches to any compound `yaml.x` via the `yaml` parent.
--
-- Schemas: each entry maps a SchemaStore URL to one or more glob patterns.
-- yamlls fetches the schema on demand and caches it.
-- Browse the full catalog at https://www.schemastore.org/json/.
return {
  filetypes = { "yaml" },
  settings = {
    yaml = {
      keyOrdering = false, -- Don't lint key order; YAML maps are unordered.
      schemas = {
        ["https://json.schemastore.org/github-workflow.json"] = ".github/workflows/*.{yml,yaml}",
        ["https://json.schemastore.org/github-action.json"] = ".github/action.{yml,yaml}",
        ["https://json.schemastore.org/dependabot-2.0.json"] = ".github/dependabot.{yml,yaml}",
        ["https://json.schemastore.org/pre-commit-config.json"] = ".pre-commit-config.{yml,yaml}",
        ["https://json.schemastore.org/gitlab-ci.json"] = "*gitlab-ci*.{yml,yaml}",
        ["https://www.gh-dash.dev/schema.json"] = "**/gh-dash/config.{yml,yaml}",
      },
    },
  },
}
