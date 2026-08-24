local lsp_defaults = require("plugins.configs.lspconfig")
local go = require("custom.go")

-- Mason prepends its bin directory to PATH, but Go tools installed with
-- `go install` are intentionally kept current in GOBIN/GOPATH. Resolve that
-- location through `go env` so custom paths and Windows are handled too.

vim.lsp.config("gopls", {
  on_attach = lsp_defaults.on_attach,
  capabilities = lsp_defaults.capabilities,
  cmd = { go.resolve_tool("gopls") },
  filetypes = { "go", "gomod", "gowork", "gotmpl" },
  -- Prefer a go.work root over a nested go.mod, then fall back to the Git
  -- worktree root. Native root markers are evaluated in priority order.
  root_markers = { "go.work", "go.mod", ".git" },
  settings = {
    gopls = {
      completeUnimported = true,
      completeFunctionCalls = true,
      usePlaceholders = true,
      gofumpt = true,
      vulncheck = "Imports",
      -- Keep all workspace packages diagnosed while editing. This lets a
      -- change in one file surface errors in dependent files immediately.
      expandWorkspaceToModule = true,
      diagnosticsDelay = "500ms",
      codelenses = {
        generate = true,
        regenerate_cgo = true,
        run_govulncheck = true,
        tidy = true,
        upgrade_dependency = true,
        vendor = true,
      },
      analyses = {
        unusedparams = true,
        unreachable = true,
        unusedwrite = true,
        shadow = true,
        nilness = true,
        useany = true,
      },
      hints = {
        assignVariableTypes = true,
        compositeLiteralFields = true,
        constantValues = true,
        functionTypeParameters = true,
        parameterNames = true,
        rangeVariableTypes = true,
      },
    },
  },
})

vim.lsp.enable("gopls")
