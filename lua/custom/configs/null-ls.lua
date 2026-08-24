local null_ls = require("null-ls")
local go = require("custom.go")

local sources = {
  -- Imports first; gopls applies gofumpt as the second, explicit formatting
  -- pass in custom/init.lua.
  null_ls.builtins.formatting.goimports,
  -- Keep the expensive aggregate lint out of the typing loop. This builtin
  -- publishes diagnostics only after a save.
  null_ls.builtins.diagnostics.golangci_lint.with({
    timeout = 120000,
    -- golangci-lint invokes `go list ./...`, which is invalid outside a Go
    -- module. Never fall back to Neovim's cwd for standalone Go files.
    cwd = function(params)
      return go.module_root(params.bufname)
    end,
    runtime_condition = function(params)
      return go.module_root(params.bufname) ~= nil
    end,
  }),
}

null_ls.setup({
  debug = false,
  sources = sources,
})
