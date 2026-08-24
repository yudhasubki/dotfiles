local M = {}
local go = require("custom.go")

local function coverage_file(root)
  local directory = vim.fs.joinpath(vim.fn.stdpath("cache"), "go-coverage")
  local filename = vim.fn.sha256(root):sub(1, 16) .. ".out"
  return vim.fs.joinpath(directory, filename), directory
end

function M.setup()
  local profile = coverage_file(go.module_root(0) or vim.uv.cwd())
  require("coverage").setup({
    auto_reload = true,
    summary = {
      min_coverage = 80.0,
    },
    lang = {
      go = {
        coverage_file = profile,
      },
    },
  })
end

function M.run()
  local root = go.require_module_root("run coverage")
  if not root then
    return
  end

  local profile, profile_directory = coverage_file(root)
  vim.fn.mkdir(profile_directory, "p")

  vim.notify("Running Go tests with race detection and coverage…", vim.log.levels.INFO)
  vim.system({
    "gotestsum",
    "--format=standard-verbose",
    "--",
    "-race",
    "-count=1",
    "-coverprofile=" .. profile,
    "./...",
  }, { cwd = root, text = true }, function(result)
    vim.schedule(function()
      if result.code ~= 0 then
        local message = vim.trim(result.stderr ~= "" and result.stderr or result.stdout or "")
        if #message > 4000 then
          message = message:sub(-4000)
        end
        if message == "" then
          message = "Go coverage run failed"
        end
        vim.notify(message, vim.log.levels.ERROR)
        return
      end

      -- Refresh the absolute profile path when switching between worktrees in
      -- the same Neovim session, then immediately place coverage signs.
      require("coverage").setup({
        auto_reload = true,
        summary = { min_coverage = 80.0 },
        lang = { go = { coverage_file = profile } },
      })
      require("coverage").load(true)
      vim.notify("Coverage loaded (kept outside the Git worktree)", vim.log.levels.INFO)
    end)
  end)
end

return M
