local M = {}

M.treesitter = {
  ensure_installed = {
    "vim",
    "lua",
    "html",
    "css",
    "javascript",
    "typescript",
    "tsx",
    "go",
    "gomod",
    "gosum",
    "gowork",
    "c",
    "markdown",
    "markdown_inline",
  },
  indent = {
    enable = true,
  },
}

M.mason = {
  ensure_installed = {
    -- lua stuff
    "lua-language-server",
    "stylua",

    -- web dev stuff
    "css-lsp",
    "html-lsp",
    "typescript-language-server",
    "deno",
    "prettier",

    "gopls",
    "goimports",

    -- c/cpp stuff
    "clangd",
    "clang-format",
  },
}

-- git support in nvimtree
local function nvimtree_on_attach(bufnr)
  local api = require("nvim-tree.api")

  local function warn_no_node()
    vim.notify("No file or folder under cursor", vim.log.levels.WARN, { title = "NvimTree" })
  end

  api.config.mappings.default_on_attach(bufnr)

  vim.keymap.set("n", "s", function()
    local node = api.tree.get_node_under_cursor()
    if not node then
      warn_no_node()
      return
    end

    api.node.open.edit(node)
  end, {
    buffer = bufnr,
    desc = "NvimTree: Open File",
    noremap = true,
    silent = true,
    nowait = true,
  })
end

M.nvimtree = {
  on_attach = nvimtree_on_attach,

  git = {
    enable = true,
  },

  diagnostics = {
    enable = true,
    show_on_dirs = true,
    show_on_open_dirs = true,
    severity = {
      min = vim.diagnostic.severity.WARN,
      max = vim.diagnostic.severity.ERROR,
    },
  },

  renderer = {
    highlight_git = true,
    highlight_diagnostics = "name",
    icons = {
      diagnostics_placement = "before",
      show = {
        git = true,
        diagnostics = true,
      },
    },
  },
}

return M
