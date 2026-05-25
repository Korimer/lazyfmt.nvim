local M = {}

local nix_cmd = nil
function M.detect_nix()
  nix_cmd = "nix-shell -p"
end

local datadir = nil
function M.create_data_dir()
  datadir = vim.fn.stdpath("data") .. "/lazyfmt"
  if vim.fn.isdirectory(datadir) == 0 then
    vim.fn.mkdir(datadir, "p")
  end
end

function M.write_shortcut(pkgname)
  local filepath = datadir .. "/" .. pkgname
  local shortcut, err = io.open(filepath, "w")

  if not shortcut then
    vim.notify("LazyFmt Error: Could not open file " .. filepath .. " - " .. tostring(err), vim.log.levels.ERROR)
    return
  end

  shortcut:write("#!/usr/bin/env bash\n" .. nix_cmd .. " " .. pkgname .. ' --run ' .. [[\"\$@\""]])
  shortcut:close()

  os.execute("chmod +x " .. filepath)
  vim.notify("Created Nix shortcut for " .. pkgname, vim.log.levels.INFO)
end

function M.setup()
  M.detect_nix()
  M.create_data_dir()

  vim.api.nvim_create_user_command(
    'LazyLink',
    function(opts)
      if opts.args == "" then
        vim.notify("LazyLink requires a package name", vim.log.levels.WARN)
        return
      end
      M.write_shortcut(opts.args)
    end,
    {
      nargs = 1,
      desc = "Create a Nix shortcut for a specified package",
    }
  )
end

return M
