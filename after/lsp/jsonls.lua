-- jsonls comes with built-in schema awareness via VSCode's catalog, but the
-- coverage there is uneven. Adding explicit schemas for the configs we
-- actually touch keeps validation reliable across machines.
--
-- Schemas: each entry maps one or more glob patterns to a SchemaStore URL.
-- jsonls fetches and caches them on demand.
-- Browse the full catalog at https://www.schemastore.org/json/.
return {
  settings = {
    json = {
      validate = { enable = true },
      schemas = {
        {
          fileMatch = { ".prettierrc", ".prettierrc.json" },
          url = "https://json.schemastore.org/prettierrc.json",
        },
        {
          fileMatch = { ".markdownlint.json", ".markdownlint.jsonc" },
          url = "https://json.schemastore.org/markdownlint.json",
        },
        {
          fileMatch = { "package.json" },
          url = "https://json.schemastore.org/package.json",
        },
        {
          fileMatch = { "tsconfig*.json" },
          url = "https://json.schemastore.org/tsconfig.json",
        },
        {
          fileMatch = { ".eslintrc", ".eslintrc.json" },
          url = "https://json.schemastore.org/eslintrc.json",
        },
      },
    },
  },
}
