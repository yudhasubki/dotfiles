local overrides = require("custom.configs.overrides")

---@type NvPluginSpec[]
local plugins = {

  -- Override plugin definition options
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      -- format & linting
      {
        "nvimtools/none-ls.nvim",
        dependencies = { "nvim-lua/plenary.nvim" },
        ft = "go",
        config = function()
          require("custom.configs.null-ls")
        end,
      },
    },
    config = function()
      require("custom.configs.lspconfig")
    end,
  },

  -- override plugin configs
  {
    "williamboman/mason.nvim",
    opts = overrides.mason,
  },

  {
  "nvim-treesitter/nvim-treesitter",
  build = ":TSUpdate",
},

  {
    "nvim-tree/nvim-tree.lua",
    opts = overrides.nvimtree,
  },

  -- Install a plugin
  {
    "max397574/better-escape.nvim",
    event = "InsertEnter",
    config = function()
      require("better_escape").setup()
    end,
  },

  -- Copilot
  {
    "zbirenbaum/copilot.lua",
    cmd = "Copilot",
    event = "InsertEnter",
    config = function()
      require("copilot").setup({})
    end,
  },

  -- Gopher: Go productivity (struct tags, impl interface, test gen)
  {
    "olexsmir/gopher.nvim",
    ft = "go",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
    },
    build = function()
      vim.cmd [[silent! GoInstallDeps]]
    end,
    opts = {},
  },

  -- Avante (AI panel)
  {
    "yetone/avante.nvim",
    event = "VeryLazy",
    build = "make",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "MunifTanjim/nui.nvim",
      "nvim-tree/nvim-web-devicons",
      "zbirenbaum/copilot.lua",
    },
    opts = {
      -- Default provider
      provider = "copilot",

      -- Provider configs
      providers = {
        copilot = {
          model = "gpt-4o",
          timeout = 30000,
          extra_request_body = {
            temperature = 0,
            max_completion_tokens = 8192,
          },
        },
        claude = {
          api_key_name = "ANTHROPIC_API_KEY",
          model = "claude-sonnet-4-20250514",
          timeout = 30000,
          extra_request_body = {
            temperature = 0,
            max_tokens = 8192,
          },
        },
      },

      windows = {
        position = "right",
        width = 40,
      },
    },
  },
}

return plugins
