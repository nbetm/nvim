-- Mirror Helix: keep diagnostics scoped to open files for performance on large
-- repos. Other settings (line length, etc.) live in `pyproject.toml` so the
-- editor and CI agree on rules.
return {
  settings = {
    python = {
      analysis = {
        diagnosticMode = "openFilesOnly",
      },
    },
  },
}
