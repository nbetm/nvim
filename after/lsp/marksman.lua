-- Drop `markdown.mdx` from the default filetypes — we don't author MDX, and
-- the compound type trips `:checkhealth vim.lsp` without adding value.
return {
  filetypes = { "markdown" },
}
