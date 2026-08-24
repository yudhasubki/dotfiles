local lsp_defaults = require("plugins.configs.lspconfig")

vim.lsp.config("gopls", {
  on_attach = lsp_defaults.on_attach,
  capabilities = lsp_defaults.capabilities,
  cmd = { "gopls" },
  filetypes = { "go", "gomod", "gowork", "gotmpl" },
  -- Prefer a go.work root over a nested go.mod, then fall back to the Git
  -- worktree root. Native root markers are evaluated in priority order.
  root_markers = { "go.work", "go.mod", ".git" },
  settings = {
    gopls = {
      completeUnimported = true,
      usePlaceholders = true,
      -- Keep all workspace packages diagnosed while editing. This lets a
      -- change in one file surface errors in dependent files immediately.
      expandWorkspaceToModule = true,
      diagnosticsDelay = "500ms",
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

-- if you just want default config for the servers then put them in a table
-- local servers = { "html", "cssls", "tsserver", "clangd" }

-- for _, lsp in ipairs(servers) do
--  lspconfig[lsp].setup {
--    on_attach = on_attach,
--    capabilities = capabilities,
-- }
-- end

-- 
-- lspconfig.pyright.setup { blabla}
