-- Same binary as `dockerls` (Docker Inc.'s server speaks both protocols).
-- Overrides the nvim-lspconfig default of `docker-compose-langserver`.
return {
  cmd = { "docker-language-server", "start", "--stdio" },
}
