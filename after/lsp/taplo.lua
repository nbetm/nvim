-- Pin schema validation on. It is already the default in taplo 0.10.
return {
  settings = {
    evenBetterToml = {
      schema = {
        enabled = true,
      },
    },
  },
}
