local M = {}

local nix_cmd = nil
function M.detect_nix()
  nix_cmd = "nix-shell -p"
end

local datadir = nil
function M.create_data_dir()
  datadir = vim.fn.stdpath("data") .. "/lazyfmt"
  os.execute("mkdir " .. datadir)
end

function M.write_shortcut(pkgname)
  if datadir == nil then M.create_data_dir() end
  if nix_cmd == nil then M.detect_nix() end
  local shortcut = io.open(datadir .. "/" .. pkgname, "w")
  shortcut.write(
    "#!/usr/bin/env bash\n" .. nix_cmd .. " " .. pkgname .. " --run " .. [[\"\$@\""]]
  )
end

return M
