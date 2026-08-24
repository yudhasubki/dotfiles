local autocmd = vim.api.nvim_create_autocmd

local function has_lsp_client(bufnr, client_name)
  return #vim.lsp.get_clients({ bufnr = bufnr, name = client_name }) > 0
end

local function format_go(bufnr)
  local function format_with(client_name)
    if not has_lsp_client(bufnr, client_name) then
      return
    end

    vim.lsp.buf.format({
      async = false,
      bufnr = bufnr,
      timeout_ms = 5000,
      filter = function(client)
        return client.name == client_name
      end,
    })
  end

  -- Keep the order explicit: goimports owns imports, then gopls applies
  -- gofumpt. Filtering prevents multiple LSP clients racing on save.
  format_with("null-ls")
  format_with("gopls")
end

autocmd("BufWritePre", {
  pattern = "*.go",
  callback = function(args)
    format_go(args.buf)
  end,
})

autocmd("LspAttach", {
  callback = function(args)
    vim.schedule(function()
      if not vim.api.nvim_buf_is_valid(args.buf) then
        return
      end

      local client = vim.lsp.get_client_by_id(args.data.client_id)
      if not client then
        return
      end

      local opts = { buffer = args.buf, silent = true }
      vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
      vim.keymap.set("n", "gD", vim.lsp.buf.declaration, opts)
      vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)
      vim.keymap.set("n", "gi", vim.lsp.buf.implementation, opts)
      vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
      vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
      vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts)

      if client.name ~= "gopls" then
        return
      end

      if client:supports_method("textDocument/inlayHint") then
        vim.lsp.inlay_hint.enable(true, { bufnr = args.buf })
        vim.keymap.set("n", "<leader>lh", function()
          local enabled = vim.lsp.inlay_hint.is_enabled({ bufnr = args.buf })
          vim.lsp.inlay_hint.enable(not enabled, { bufnr = args.buf })
        end, vim.tbl_extend("force", opts, { desc = "LSP: Toggle Inlay Hints" }))
      end

      if client:supports_method("textDocument/codeLens") then
        vim.lsp.codelens.enable(true, { bufnr = args.buf, client_id = client.id })
        vim.keymap.set("n", "<leader>lc", vim.lsp.codelens.run,
          vim.tbl_extend("force", opts, { desc = "LSP: Run Code Lens" }))
      end
    end)
  end,
})

autocmd("VimEnter", {
  callback = function(data)
    local directory = vim.fn.isdirectory(data.file) == 1
    if directory then
      vim.cmd.cd(data.file)
      -- nvim-tree is lazy-loaded; use the command to trigger proper loading
      vim.cmd("NvimTreeToggle")
    end
  end,
})

vim.keymap.set("n", "<leader>fd", "<cmd>Telescope diagnostics<CR>", {
  desc = "Find: Workspace Diagnostics",
  silent = true,
})
vim.keymap.set("n", "<leader>fD", "<cmd>Telescope diagnostics bufnr=0<CR>", {
  desc = "Find: Buffer Diagnostics",
  silent = true,
})

-- ── Inline Diagnostics: show errors on the code line ────────────
vim.diagnostic.config({
  signs = {
    text = {
      [vim.diagnostic.severity.ERROR] = "",
      [vim.diagnostic.severity.WARN]  = "",
      [vim.diagnostic.severity.HINT]  = "󰌵",
      [vim.diagnostic.severity.INFO]  = "",
    },
  },
  -- Show error message next to the code (right side of the line)
  virtual_text = {
    prefix = "●",
    spacing = 2,
    source = "if_many",
  },
  -- Underline the problematic code
  underline = true,
  -- Don't update diagnostics while typing
  update_in_insert = false,
  -- Show errors before warnings
  severity_sort = true,
  -- Floating window when you hover on error
  float = {
    focusable = true,
    style = "minimal",
    border = "rounded",
    source = "always",
    header = "",
    prefix = "",
  },
})
