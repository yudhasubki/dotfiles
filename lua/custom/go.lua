local M = {}

local go_bin_resolved = false
local go_bin

local function resolve_go_bin()
  if go_bin_resolved then
    return go_bin
  end

  go_bin_resolved = true

  local go_command = vim.fn.exepath("go")
  if go_command == "" then
    return nil
  end

  local started, process = pcall(vim.system, {
    go_command,
    "env",
    "-json",
    "GOBIN",
    "GOPATH",
  }, { text = true })
  if not started then
    return nil
  end

  local completed, result = pcall(function()
    return process:wait(2000)
  end)
  if not completed or not result or result.code ~= 0 then
    return nil
  end

  local decoded, environment = pcall(vim.json.decode, result.stdout or "")
  if not decoded or type(environment) ~= "table" then
    return nil
  end

  if environment.GOBIN and environment.GOBIN ~= "" then
    go_bin = environment.GOBIN
    return go_bin
  end

  local is_windows = vim.fn.has("win32") == 1
  local separator = is_windows and ";" or ":"
  for path in vim.gsplit(environment.GOPATH or "", separator, { plain = true, trimempty = true }) do
    go_bin = vim.fs.joinpath(path, "bin")
    return go_bin
  end
end

function M.resolve_tool(name)
  local executable = vim.fn.has("win32") == 1 and (name .. ".exe") or name
  local directory = resolve_go_bin()

  if directory then
    local candidate = vim.fs.joinpath(directory, executable)
    if vim.fn.executable(candidate) == 1 then
      return candidate
    end
  end

  local from_path = vim.fn.exepath(name)
  return from_path ~= "" and from_path or name
end

function M.module_root(source)
  local path
  if type(source) == "number" then
    path = vim.api.nvim_buf_get_name(source)
  else
    path = source or vim.api.nvim_buf_get_name(0)
  end

  if path == "" then
    return nil
  end

  return vim.fs.root(path, "go.mod")
end

function M.require_module_root(action)
  local root = M.module_root(0)
  if root then
    return root
  end

  vim.notify(
    ("Cannot %s: no go.mod found for the current buffer"):format(action),
    vim.log.levels.WARN,
    { title = "Go" }
  )
end

return M
