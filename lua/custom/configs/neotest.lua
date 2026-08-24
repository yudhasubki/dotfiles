require("neotest").setup({
  adapters = {
    require("neotest-golang")({
      runner = "gotestsum",
      go_test_args = { "-v", "-race", "-count=1" },
    }),
  },
  diagnostic = {
    enabled = true,
    severity = vim.diagnostic.severity.ERROR,
  },
  output = {
    enabled = true,
    open_on_run = true,
  },
  quickfix = {
    enabled = true,
    open = false,
  },
  status = {
    enabled = true,
    signs = true,
    virtual_text = true,
  },
})
