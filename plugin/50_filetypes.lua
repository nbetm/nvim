-- ┌────────────────────────┐
-- │ Custom filetype rules  │
-- └────────────────────────┘
--
-- Compound filetypes (`yaml.foo`) let language servers like
-- `docker_compose_language_service` and `ansiblels` activate only on the
-- subset of YAML that's actually relevant. nvim doesn't auto-detect these,
-- so we register the patterns here. Plain `yaml` is still claimed by
-- `yamlls` for everything else.

vim.filetype.add({
  filename = {
    ["docker-compose.yml"] = "yaml.docker-compose",
    ["docker-compose.yaml"] = "yaml.docker-compose",
    ["compose.yml"] = "yaml.docker-compose",
    ["compose.yaml"] = "yaml.docker-compose",
  },
  pattern = {
    -- Ansible: typical playbook/role/inventory paths. `vim.filetype.add`
    -- patterns are anchored with implicit `^` and `$` and use Lua patterns.
    [".*/playbooks/.*%.ya?ml"] = "yaml.ansible",
    [".*/roles/.*/tasks/.*%.ya?ml"] = "yaml.ansible",
    [".*/roles/.*/handlers/.*%.ya?ml"] = "yaml.ansible",
    [".*/roles/.*/vars/.*%.ya?ml"] = "yaml.ansible",
    [".*/roles/.*/defaults/.*%.ya?ml"] = "yaml.ansible",
    [".*/roles/.*/meta/.*%.ya?ml"] = "yaml.ansible",
    [".*/inventory/.*%.ya?ml"] = "yaml.ansible",
    [".*/group_vars/.*%.ya?ml"] = "yaml.ansible",
    [".*/host_vars/.*%.ya?ml"] = "yaml.ansible",
  },
})
