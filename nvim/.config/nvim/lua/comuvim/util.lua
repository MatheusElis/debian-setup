local M = {}

M.is_windows = vim.fn.has("win32") == 1
M.is_linux = vim.fn.has("unix") == 1
M.is_wsl = (function()
  if vim.fn.has("wsl") == 1 then
    return true
  end
  local output = vim.fn.system("uname -r")
  return output:lower():find("microsoft") ~= nil
end)()
M.is_mac = vim.fn.has("macunix") == 1

return M
