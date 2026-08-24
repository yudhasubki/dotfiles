local M = {}

local minimum_version = { 22, 13, 0 }

local function parse_version(output)
  local major, minor, patch = (output or ""):match("v?(%d+)%.(%d+)%.(%d+)")
  if not major then
    return nil
  end

  return { tonumber(major), tonumber(minor), tonumber(patch) }
end

local function version_is_supported(version)
  for index = 1, 3 do
    if version[index] ~= minimum_version[index] then
      return version[index] > minimum_version[index]
    end
  end

  return true
end

local function node_version(command)
  local started, process = pcall(vim.system, { command, "--version" }, { text = true })
  if not started then
    return nil
  end

  local completed, result = pcall(function()
    return process:wait(2000)
  end)
  if not completed or not result or result.code ~= 0 then
    return nil
  end

  return parse_version(result.stdout)
end

local function add_candidate(candidates, seen, command)
  if not command or command == "" or vim.fn.executable(command) ~= 1 then
    return
  end

  local resolved = vim.uv.fs_realpath(command) or command
  local key = vim.fn.has("win32") == 1 and resolved:lower() or resolved
  if seen[key] then
    return
  end

  seen[key] = true
  table.insert(candidates, command)
end

function M.resolve_node()
  local override = vim.env.COPILOT_NODE_COMMAND
  if override and override ~= "" and vim.fn.executable(override) == 1 then
    local version = node_version(override)
    if version and version_is_supported(version) then
      return override, version
    end
  end

  local candidates, seen = {}, {}
  add_candidate(candidates, seen, vim.fn.exepath("node"))

  local is_windows = vim.fn.has("win32") == 1
  local separator = is_windows and ";" or ":"
  local executable = is_windows and "node.exe" or "node"
  local path = vim.env.PATH or vim.env.Path or ""

  for directory in vim.gsplit(path, separator, { plain = true, trimempty = true }) do
    directory = directory:gsub('^"(.*)"$', "%1")
    add_candidate(candidates, seen, vim.fs.joinpath(directory, executable))
  end

  if not is_windows then
    add_candidate(candidates, seen, vim.fn.exepath("nodejs"))
  end

  for _, command in ipairs(candidates) do
    local version = node_version(command)
    if version and version_is_supported(version) then
      return command, version
    end
  end
end

function M.setup()
  local node = M.resolve_node()
  if not node then
    vim.notify_once(
      "Copilot disabled: Node.js >= 22.13 was not found. Set COPILOT_NODE_COMMAND to a compatible binary.",
      vim.log.levels.WARN,
      { title = "Copilot" }
    )
    return
  end

  require("copilot").setup({
    copilot_node_command = node,
  })
end

M.setup()

return M
