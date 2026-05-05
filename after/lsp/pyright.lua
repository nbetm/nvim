-- Mirror Helix: keep diagnostics scoped to open files for performance on large
-- repos. Other settings (line length, etc.) live in `pyproject.toml` so the
-- editor and CI agree on rules.
--
-- `workDoneProgress = false` opts out of `$/progress` notifications so pyright
-- stops reporting 0-100% on every analyze. All other channels (diagnostics,
-- hover, completion, etc.) are unaffected.
return {
  capabilities = {
    window = { workDoneProgress = false },
  },
  settings = {
    python = {
      analysis = {
        diagnosticMode = "openFilesOnly",
      },
    },
  },
}
