local dap = require("dap")
local dapui = require("dapui")

local dlv = vim.fn.exepath("dlv")
if dlv == "" then
  dlv = "dlv"
end

require("dap-go").setup({
  delve = {
    path = dlv,
    initialize_timeout_sec = 20,
    port = "${port}",
  },
})

require("nvim-dap-virtual-text").setup({
  commented = true,
  all_references = true,
})

dapui.setup({
  controls = { enabled = true },
  floating = { border = "rounded" },
})

dap.listeners.before.attach.go_dap_ui = function()
  dapui.open()
end
dap.listeners.before.launch.go_dap_ui = function()
  dapui.open()
end
dap.listeners.before.event_terminated.go_dap_ui = function()
  dapui.close()
end
dap.listeners.before.event_exited.go_dap_ui = function()
  dapui.close()
end

vim.fn.sign_define("DapBreakpoint", { text = "●", texthl = "DiagnosticError" })
vim.fn.sign_define("DapBreakpointCondition", { text = "◆", texthl = "DiagnosticWarn" })
vim.fn.sign_define("DapStopped", { text = "▶", texthl = "DiagnosticInfo", linehl = "Visual" })
