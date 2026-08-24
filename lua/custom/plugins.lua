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
      require("custom.configs.copilot")
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

  -- Fast Go test feedback with nearest/file/package runs and DAP hand-off.
  {
    "nvim-neotest/neotest",
    ft = "go",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-neotest/nvim-nio",
      "antoinemadec/FixCursorHold.nvim",
      {
        "fredrikaverpil/neotest-golang",
        version = "*",
      },
    },
    keys = {
      { "<leader>tn", function() require("neotest").run.run() end, desc = "Test: Nearest" },
      { "<leader>tf", function() require("neotest").run.run(vim.fn.expand("%")) end, desc = "Test: File" },
      {
        "<leader>ta",
        function()
          local root = require("custom.go").require_module_root("run all tests")
          if not root then
            return
          end
          require("neotest").run.run(root)
        end,
        desc = "Test: All",
      },
      { "<leader>tl", function() require("neotest").run.run_last() end, desc = "Test: Last" },
      { "<leader>tD", function() require("neotest").run.run({ strategy = "dap" }) end, desc = "Test: Debug Nearest" },
      { "<leader>ts", function() require("neotest").summary.toggle() end, desc = "Test: Summary" },
      { "<leader>to", function() require("neotest").output.open({ enter = true }) end, desc = "Test: Output" },
      { "<leader>tp", function() require("neotest").output_panel.toggle() end, desc = "Test: Output Panel" },
      { "<leader>tS", function() require("neotest").run.stop() end, desc = "Test: Stop" },
    },
    config = function()
      require("custom.configs.neotest")
    end,
  },

  -- Delve-backed Go debugging with scopes, watches and inline values.
  {
    "mfussenegger/nvim-dap",
    ft = "go",
    dependencies = {
      "leoluz/nvim-dap-go",
      {
        "rcarriga/nvim-dap-ui",
        dependencies = { "nvim-neotest/nvim-nio" },
      },
      "theHamsta/nvim-dap-virtual-text",
    },
    keys = {
      { "<F5>", function() require("dap").continue() end, desc = "Debug: Continue" },
      { "<F10>", function() require("dap").step_over() end, desc = "Debug: Step Over" },
      { "<F11>", function() require("dap").step_into() end, desc = "Debug: Step Into" },
      { "<F12>", function() require("dap").step_out() end, desc = "Debug: Step Out" },
      { "<leader>db", function() require("dap").toggle_breakpoint() end, desc = "Debug: Breakpoint" },
      { "<leader>dB", function() require("dap").set_breakpoint(vim.fn.input("Condition: ")) end, desc = "Debug: Conditional Breakpoint" },
      { "<leader>du", function() require("dapui").toggle() end, desc = "Debug: Toggle UI" },
      { "<leader>dr", function() require("dap").repl.toggle() end, desc = "Debug: REPL" },
      { "<leader>dl", function() require("dap").run_last() end, desc = "Debug: Run Last" },
      { "<leader>dx", function() require("dap").terminate() end, desc = "Debug: Terminate" },
    },
    config = function()
      require("custom.configs.dap")
    end,
  },

  -- Render Go coverprofiles in the gutter and as a summary popup.
  {
    "andythigpen/nvim-coverage",
    version = "*",
    ft = "go",
    dependencies = { "nvim-lua/plenary.nvim" },
    keys = {
      { "<leader>tc", function() require("custom.configs.coverage").run() end, desc = "Test: Run with Coverage" },
      { "<leader>tC", function() require("coverage").summary() end, desc = "Test: Coverage Summary" },
      { "<leader>tv", function() require("coverage").toggle() end, desc = "Test: Toggle Coverage" },
    },
    config = function()
      require("custom.configs.coverage").setup()
    end,
  },

}

return plugins
