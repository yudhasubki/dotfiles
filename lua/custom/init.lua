local autocmd = vim.api.nvim_create_autocmd


autocmd("BufWritePre", {
  pattern = "*.go",
  callback = function ()
    vim.lsp.buf.format{async = false}
  end,
})
-- Auto resize panes when resizing nvim window
-- autocmd("VimResized", {
--   pattern = "*",
--   command = "tabdo wincmd =",
-- })
