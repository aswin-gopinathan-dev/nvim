local M = {}

local uname = vim.loop.os_uname().sysname

M.is_win = uname == "Windows_NT"
M.is_linux = uname == "Linux"
M.sep = M.is_win and "\\" or "/"

function M.join(...)
  return table.concat({ ... }, M.sep)
end

function M.exists(path)
  return path ~= nil and path ~= "" and vim.uv.fs_stat(path) ~= nil
end

function M.executable(path)
  return vim.fn.executable(path) == 1
end

function M.cwd()
  return vim.fn.getcwd()
end

function M.normalize(path)
  if not path or path == "" then
    return path
  end

  if M.is_win then
    return path:gsub("/", "\\")
  end

  return path:gsub("\\", "/")
end

function M.get_venv_python(workspace)
  workspace = workspace or M.cwd()

  if M.is_win then
    return M.join(workspace, ".venv", "Scripts", "python.exe")
  end

  return M.join(workspace, ".venv", "bin", "python")
end

function M.get_build_dir(workspace)
  workspace = workspace or M.cwd()
  return M.join(workspace, "out", "Debug")
end

function M.get_build_dirs(workspace)
  workspace = workspace or M.cwd()

  return {
    M.join(workspace, "out", "Debug"),
    M.join(workspace, "build"),
    M.join(workspace, "build", "Debug"),
    M.join(workspace, "cmake-build-debug"),
  }
end

function M.get_executable_ext()
  return M.is_win and ".exe" or ""
end

function M.get_shell()
  if M.is_win then
    if M.executable("pwsh") then
      return "pwsh"
    end
    return "powershell"
  end

  if M.executable("bash") then
    return "bash"
  end

  if M.executable("zsh") then
    return "zsh"
  end

  return vim.o.shell
end

function M.get_shell_cmd()
  if M.is_win then
    if M.executable("pwsh") then
      return "pwsh -NoLogo -NoProfile"
    end
    return "powershell -NoLogo -NoProfile"
  end

  if M.executable("bash") then
    return "bash"
  end

  if M.executable("zsh") then
    return "zsh"
  end

  return vim.o.shell
end

function M.get_mason_package_path(...)
  return M.join(vim.fn.stdpath("data"), "mason", "packages", ...)
end

function M.get_codelldb_path(user_path)
  -- 1. explicit user override
  if M.exists(user_path) then
    return user_path
  end

  -- 2. Mason-installed adapter
  local adapter_dir = M.get_mason_package_path("codelldb", "extension", "adapter")

  if M.is_win then
    local mason_path = M.join(adapter_dir, "codelldb.exe")
    if M.exists(mason_path) then
      return mason_path
    end

    local mason_alt = M.join(adapter_dir, "codelldb")
    if M.exists(mason_alt) then
      return mason_alt
    end
  else
    local mason_path = M.join(adapter_dir, "codelldb")
    if M.exists(mason_path) then
      return mason_path
    end

    local mason_alt = M.join(adapter_dir, "codelldb-x86_64-linux")
    if M.exists(mason_alt) then
      return mason_alt
    end
  end

  -- 3. system PATH fallback
  if M.executable("codelldb") then
    return "codelldb"
  end

  -- 4. not found
  return nil
end

function M.resolve(path, base)
  if not path or path == "" then
    return path
  end

  base = base or M.cwd()

  -- absolute path
  if path:match("^/") or path:match("^%a:[/\\]") then
    return M.normalize(path)
  end

  return M.normalize(M.join(base, path))
end


function M.get_config_file()
  local base_dir = vim.fn.fnamemodify(debug.getinfo(1, "S").source:sub(2), ":h")
  local filename = M.is_win and "config-windows.toml" or "config-linux.toml"
  return M.join(base_dir, filename)
end


function M.read_config()
  local file = M.get_config_file()

  if not M.exists(file) then
    vim.notify("Config file not found: " .. file, vim.log.levels.ERROR)
    return nil
  end

  local ok, toml = pcall(require, "toml")
  if not ok then
    vim.notify("toml.nvim not available", vim.log.levels.ERROR)
    return nil
  end

  local ok_parse, data = pcall(toml.parse_file, file)
  if not ok_parse then
    vim.notify("Failed to parse TOML: " .. file, vim.log.levels.ERROR)
    return nil
  end

  return data
end

local function find_project_root()
return vim.fs.root(0, {
  "project.toml",
  "entrypoint.py",
  "Cargo.toml",
  ".git",
}) or vim.fn.getcwd()
end

function M.get_project_file()
return M.join(find_project_root(), "project.toml")
end

function M.read_project()
local file = M.get_project_file()

if not M.exists(file) then
  vim.notify("project.toml not found in project root", vim.log.levels.ERROR)
  return nil
end

local ok, toml = pcall(require, "toml")
if not ok then
  vim.notify("toml.nvim not available", vim.log.levels.ERROR)
  return nil
end

local ok_parse, data = pcall(toml.parse_file, file)
if not ok_parse then
  vim.notify("Failed to parse project.toml", vim.log.levels.ERROR)
  return nil
end

return data
end

function M.get_active_target()
  local cfg = M.read_project()
  if not cfg then
    return nil
  end

  local active = cfg.active_target

  if not active then
    vim.notify("active_target not set in config", vim.log.levels.ERROR)
    return nil
  end

  return cfg, active
end

return M
