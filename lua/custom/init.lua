local autocmd = vim.api.nvim_create_autocmd


autocmd("BufWritePre", {
  pattern = "*.go",
  callback = function ()
    vim.lsp.buf.format{async = false}
  end,
})

autocmd("LspAttach", {
  callback = function(args)
    vim.schedule(function()
      local opts = { buffer = args.buf }
      vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
      vim.keymap.set("n", "gD", vim.lsp.buf.declaration, opts)
      vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)
      vim.keymap.set("n", "gi", vim.lsp.buf.implementation, opts)
      vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
      vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
      vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts)
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

-- ── Avante Model Picker ─────────────────────────────────────────
vim.keymap.set("n", "<leader>am", function()
  vim.ui.select(
    {
      "gpt-4o",
      "gpt-4.1",
      "claude-sonnet-4-20250514",
      "claude-3.5-sonnet",
      "gemini-2.5-pro",
      "o3-mini",
    },
    { prompt = "Select Model:" },
    function(choice)
      if choice then
        require("avante.config").override({
          providers = {
            copilot = { model = choice },
          },
        })
        vim.notify("Model: " .. choice)
      end
    end
  )
end, { silent = true })
