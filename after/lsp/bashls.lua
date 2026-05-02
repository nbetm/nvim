-- Tell bash-language-server to drive its diagnostics through `shellcheck`,
-- matching the Helix setup.
return {
  settings = {
    bashIde = {
      shellcheckPath = "shellcheck",
    },
  },
}
