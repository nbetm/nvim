-- Drive bash-language-server diagnostics through `shellcheck`.
return {
  settings = {
    bashIde = {
      shellcheckPath = "shellcheck",
    },
  },
}
