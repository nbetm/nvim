-- Same binary as `dockerls` (Docker Inc.'s server speaks both protocols).
-- Overrides the nvim-lspconfig default of `docker-compose-langserver`.
--
-- Map our compound filetype `yaml.docker-compose` to the languageId the
-- binary expects (`dockercompose`, the VS Code convention). Without this
-- mapping the server doesn't recognize the languageId, falls back to
-- Dockerfile parsing, and reports errors like "unknown instructions:
-- x-common-env" on YAML anchors / extension fields.
return {
  cmd = { "docker-language-server", "start", "--stdio" },
  get_language_id = function(_, ft)
    if ft == "yaml.docker-compose" then return "dockercompose" end
    return ft
  end,
}
