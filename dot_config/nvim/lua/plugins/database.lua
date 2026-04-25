-- Database connection tools (port-forward + dadbod integration)
-- Registers :DBConnect and :DBDisconnect commands
--
-- Credentials are fetched via an external script set in DBCONNECT_CREDENTIALS_CMD.
-- The script receives flags: -n <namespace> -d <database> -c <context>
-- and should print to stdout: either "password" (1 line) or "username\npassword" (2 lines).
-- Extra output before credentials (e.g. env switching messages) is ignored.
--
-- Example:
--   export DBCONNECT_CREDENTIALS_CMD="scripts/db-credentials.sh"

-- Extract resource name: StatefulSet (name-ordinal) or Deployment (name-hash-hash)
local function resource_name(pod_name)
  local ss = pod_name:match("^(.+)%-[0-9]+$")
  if ss then return ss end
  return pod_name:match("^(.+)%-[a-z0-9]+%-[a-z0-9]+$")
end

local active_connections = {}

local function parse_flags(fargs)
  local opts = {}
  local flags = {
    ["-c"] = "context",    ["--context"]    = "context",
    ["-n"] = "namespace",  ["--namespace"]  = "namespace",
    ["-d"] = "database",   ["--database"]   = "database",
    ["-u"] = "user",       ["--user"]       = "user",
    ["-p"] = "port",       ["--port"]       = "port",
    ["-l"] = "local_port", ["--local-port"] = "local_port",
    ["-b"] = "dbname",     ["--dbname"]     = "dbname",
  }
  local i = 1
  while i <= #fargs do
    local flag = fargs[i]
    local field = flags[flag]
    if field then
      if i + 1 > #fargs then
        vim.notify("DBConnect: " .. flag .. " requires a value", vim.log.levels.ERROR)
        return nil
      end
      opts[field] = fargs[i + 1]
      i = i + 2
    else
      vim.notify("DBConnect: unknown flag " .. flag, vim.log.levels.ERROR)
      return nil
    end
  end
  return opts
end

local function detect_db_type(database)
  local db_lower = database:lower()
  if db_lower:match("mysql") or db_lower:match("maria") then
    return "mysql", 3306
  elseif db_lower:match("redis") then
    return "redis", 6379
  elseif db_lower:match("mongo") then
    return "mongodb", 27017
  else
    return "postgres", 5432
  end
end

-- Fetch credentials via external script.
-- Returns (username, password) via callback. Username may be nil.
local function get_credentials(opts, callback)
  local cmd = vim.env.DBCONNECT_CREDENTIALS_CMD
  if not cmd then
    local password = vim.fn.inputsecret("Password: ")
    if password == "" then
      vim.notify("DBConnect: password is required", vim.log.levels.ERROR)
      return
    end
    callback(nil, password)
    return
  end

  vim.system(
    { cmd, "-n", opts.namespace, "-d", opts.database, "-c", opts.context },
    { cwd = vim.fn.getcwd() },
    vim.schedule_wrap(function(result)
      if result.code ~= 0 then
        vim.notify("DBConnect: credentials script failed (code=" .. result.code .. ")\n"
          .. (result.stderr or ""), vim.log.levels.ERROR)
        return
      end
      local lines = {}
      for line in result.stdout:gmatch("[^\r\n]+") do
        lines[#lines + 1] = line
      end
      if #lines == 0 then
        vim.notify("DBConnect: credentials script returned empty output", vim.log.levels.ERROR)
        return
      end
      local password = lines[#lines]
      local username = #lines >= 2 and lines[#lines - 1] or nil
      callback(username, password)
    end)
  )
end

local function encode_password(password)
  vim.cmd("silent! runtime autoload/db/url.vim")
  local ok, result = pcall(function()
    return vim.fn["db#url#encode"](password)
  end)
  if ok then return result end
  return password:gsub("([^%w%-%.%_%~])", function(c)
    return string.format("%%%02X", string.byte(c))
  end)
end

-- :DBConnect -c <ctx> -n <ns> -d <db> [-u <user>] [-p <port>] [-l <local-port>] [-b <dbname>]
vim.api.nvim_create_user_command("DBConnect", function(cmd_opts)
  if vim.fn.executable("kubectl") == 0 then
    vim.notify("DBConnect: kubectl not in PATH", vim.log.levels.ERROR)
    return
  end

  local opts = parse_flags(cmd_opts.fargs)
  if not opts then return end

  opts.context = opts.context or vim.fn.input("Context: ")
  opts.namespace = opts.namespace or vim.fn.input("Namespace: ")
  opts.database = opts.database or vim.fn.input("Database pod name: ")

  if opts.context == "" or opts.namespace == "" or opts.database == "" then
    vim.notify("DBConnect: context, namespace, and database are required", vim.log.levels.ERROR)
    return
  end

  local scheme, default_port = detect_db_type(opts.database)
  local remote_port = opts.port and tonumber(opts.port) or default_port
  local local_port = opts.local_port or tostring(remote_port)
  local dbname = opts.dbname or opts.database
  local conn_name = opts.context .. "/" .. opts.namespace .. "/" .. opts.database

  if active_connections[conn_name] then
    vim.notify("DBConnect: already connected to " .. conn_name, vim.log.levels.WARN)
    return
  end

  -- Step 1: Find the pod
  vim.system(
    { "kubectl", "--context", opts.context, "-n", opts.namespace,
      "get", "pods", "--field-selector=status.phase=Running",
      "-o", "jsonpath={.items[*].metadata.name}" },
    {},
    vim.schedule_wrap(function(pod_result)
      if pod_result.code ~= 0 then
        vim.notify("DBConnect: kubectl failed: " .. (pod_result.stderr or ""), vim.log.levels.ERROR)
        return
      end

      local pod
      for name in pod_result.stdout:gmatch("%S+") do
        if resource_name(name) == opts.database then
          pod = name
          break
        end
      end

      if not pod then
        vim.notify("DBConnect: no running pod matching '" .. opts.database .. "'", vim.log.levels.ERROR)
        return
      end

      -- Step 2: Get credentials
      get_credentials(opts, function(script_user, password)
        -- User priority: -u flag > script output > DBCONNECT_USER env > "postgres"
        opts.user = opts.user or script_user or vim.env.DBCONNECT_USER or "postgres"

        -- Step 3: Start port-forward
        local job_id = vim.fn.jobstart({
          "kubectl", "--context", opts.context, "-n", opts.namespace,
          "port-forward", pod, local_port .. ":" .. tostring(remote_port),
        }, {
          on_stderr = function(_, data)
            local msg = table.concat(data, "\n"):gsub("%s+$", "")
            if msg ~= "" then
              vim.notify("DBConnect [" .. conn_name .. "]: " .. msg, vim.log.levels.WARN)
            end
          end,
          on_exit = function(_, code)
            active_connections[conn_name] = nil
            if code ~= 0 then
              vim.notify("DBConnect: port-forward exited (code " .. code .. ")", vim.log.levels.WARN)
            end
          end,
        })

        if job_id <= 0 then
          vim.notify("DBConnect: failed to start port-forward", vim.log.levels.ERROR)
          return
        end

        -- Step 4: Register connection with dadbod
        local url = string.format("%s://%s:%s@localhost:%s/%s",
          scheme, opts.user, encode_password(password), local_port, dbname)

        local dbs = vim.g.dbs or {}
        dbs[conn_name] = url
        vim.g.dbs = dbs

        active_connections[conn_name] = { job_id = job_id, port = local_port, scheme = scheme }

        vim.notify(string.format(
          "DBConnect: %s (localhost:%s, user=%s, db=%s) — :DBUI to browse",
          conn_name, local_port, opts.user, dbname))
      end)
    end)
  )
end, {
  nargs = "*",
  desc = "Connect to a remote database (port-forward + dadbod)",
})

-- :DBDisconnect [name] — stop port-forward and remove connection
vim.api.nvim_create_user_command("DBDisconnect", function(cmd_opts)
  local name = cmd_opts.args

  if name == "" then
    local names = vim.tbl_keys(active_connections)
    if #names == 0 then
      vim.notify("DBDisconnect: no active connections", vim.log.levels.INFO)
      return
    end
    vim.ui.select(names, { prompt = "Disconnect:" }, function(choice)
      if choice then
        vim.cmd("DBDisconnect " .. choice)
      end
    end)
    return
  end

  local conn = active_connections[name]
  if not conn then
    vim.notify("DBDisconnect: no active connection '" .. name .. "'", vim.log.levels.ERROR)
    return
  end

  vim.fn.jobstop(conn.job_id)
  active_connections[name] = nil

  local dbs = vim.g.dbs or {}
  dbs[name] = nil
  vim.g.dbs = dbs

  vim.notify("DBDisconnect: disconnected from " .. name)
end, {
  nargs = "?",
  desc = "Disconnect a remote database",
})

vim.keymap.set("n", "<leader>dc", "<cmd>DBConnect<CR>", { desc = "Connect to remote DB" })
vim.keymap.set("n", "<leader>dd", "<cmd>DBDisconnect<CR>", { desc = "Disconnect remote DB" })

return {
  {
    "tpope/vim-dadbod",
    cmd = "DB",
  },
  {
    "kristijanhusak/vim-dadbod-ui",
    dependencies = { "tpope/vim-dadbod" },
    cmd = { "DBUI", "DBUIToggle", "DBUIAddConnection" },
    keys = {
      { "<leader>du", "<cmd>DBUIToggle<CR>", desc = "Toggle DB UI" },
      { "<leader>da", "<cmd>DBUIAddConnection<CR>", desc = "Add DB connection" },
    },
    init = function()
      vim.g.db_ui_use_nerd_fonts = 1
      vim.g.db_ui_save_location = vim.fn.stdpath("data") .. "/db_ui"
    end,
  },
  {
    "kristijanhusak/vim-dadbod-completion",
    dependencies = { "tpope/vim-dadbod", "hrsh7th/nvim-cmp" },
    ft = { "sql", "mysql", "plsql" },
    config = function()
      local cmp = require("cmp")
      cmp.setup.filetype({ "sql", "mysql", "plsql" }, {
        sources = cmp.config.sources({
          { name = "vim-dadbod-completion" },
        }, {
          { name = "buffer" },
        }),
      })
    end,
  },
}
