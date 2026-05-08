-- Use Docker Inc.'s `docker-language-server` (same binary used by
-- `docker_compose_language_service`). nvim-lspconfig defaults to the older
-- `docker-langserver` (npm) which we don't have installed.
return {
  cmd = { "docker-language-server", "start", "--stdio" },
}
