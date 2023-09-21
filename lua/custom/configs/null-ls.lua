local null_ls = require "null-ls"
local augroup = vim.api.nvim_create_augroup("LspFormatting", {})


local sources = {
--   null_ls.builtins.formatting.gofumpt,
--   null_ls.builtins.formatting.goimports_reviser,
--   null_ls.builtins.formatting.golines,
  
  null_ls.builtins.formatting.stylua,

  null_ls.builtins.formatting.goimports,
}

null_ls.setup{
  debug = true,
  sources = sources,
}
