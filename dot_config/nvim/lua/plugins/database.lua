return {
  -- Database client
  {
    "tpope/vim-dadbod",
    cmd = "DB",
  },

  -- Database UI (drawer with tables, saved queries, etc.)
  {
    "kristijanhusak/vim-dadbod-ui",
    dependencies = { "tpope/vim-dadbod" },
    cmd = { "DBUI", "DBUIToggle", "DBUIAddConnection" },
    keys = {
      { "<leader>du", "<cmd>DBUIToggle<CR>", desc = "Toggle DB UI" },
      { "<leader>da", "<cmd>DBUIAddConnection<CR>", desc = "Add DB connection" },
      { "<leader>dc", "<cmd>DBConnect<CR>", desc = "Connect to remote DB" },
      { "<leader>dd", "<cmd>DBDisconnect<CR>", desc = "Disconnect remote DB" },
    },
    init = function()
      vim.g.db_ui_use_nerd_fonts = 1
      vim.g.db_ui_save_location = vim.fn.stdpath("data") .. "/db_ui"
    end,
    config = function()
      -- Track active port-forward jobs: { name = { job_id, local_port } }
      local active_connections = {}

      -- Parse flags, return opts table
      local function parse_flags(fargs)
        local opts = {}
        local flags = {
          ["-c"] = "context",   ["--context"]   = "context",
          ["-n"] = "namespace", ["--namespace"]  = "namespace",
          ["-d"] = "database",  ["--database"]   = "database",
          ["-s"] = "secret",    ["--secret"]     = "secret",
          ["-k"] = "key",       ["--key"]        = "key",
          ["-u"] = "user",      ["--user"]       = "user",
          ["-p"] = "port",      ["--port"]       = "port",
          ["-b"] = "dbname",    ["--dbname"]     = "dbname",
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

      -- Detect DB scheme and default port from database name
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

      -- :DBConnect -c <ctx> -n <ns> -d <db> [-s <secret>] [-k <key>] [-u <user>] [-p <port>] [-b <dbname>]
      vim.api.nvim_create_user_command("DBConnect", function(cmd_opts)
        if vim.fn.executable("kubectl") == 0 then
          vim.notify("DBConnect: kubectl is not installed or not in PATH", vim.log.levels.ERROR)
          return
        end

        local opts = parse_flags(cmd_opts.fargs)
        if not opts then return end

        -- Prompt for required args if not provided
        opts.context = opts.context or vim.fn.input("Context: ")
        opts.namespace = opts.namespace or vim.fn.input("Namespace: ")
        opts.database = opts.database or vim.fn.input("Database pod name: ")

        if opts.context == "" or opts.namespace == "" or opts.database == "" then
          vim.notify("DBConnect: context, namespace, and database are required", vim.log.levels.ERROR)
          return
        end

        -- Defaults
        local secret = opts.secret or opts.database
        local secret_key = opts.key or "password"
        local user = opts.user or "postgres"
        local scheme, default_port = detect_db_type(opts.database)
        local remote_port = opts.port and tonumber(opts.port) or default_port
        local local_port = tostring(remote_port)
        local dbname = opts.dbname or opts.database

        local conn_name = opts.context .. "/" .. opts.namespace .. "/" .. opts.database

        -- Check if already connected
        if active_connections[conn_name] then
          vim.notify("DBConnect: already connected to " .. conn_name, vim.log.levels.WARN)
          return
        end

        -- Run kubectl commands asynchronously to avoid blocking the UI
        local context = opts.context
        local namespace = opts.namespace
        local database = opts.database

        -- Step 1: Find the pod
        vim.system(
          { "kubectl", "--context", context, "-n", namespace,
            "get", "pods", "--field-selector=status.phase=Running",
            "-o", "jsonpath={.items[*].metadata.name}" },
          {},
          vim.schedule_wrap(function(pod_result)
            if pod_result.code ~= 0 then
              vim.notify("DBConnect: kubectl get pods failed: " .. (pod_result.stderr or ""), vim.log.levels.ERROR)
              return
            end

            local pod
            for name in pod_result.stdout:gmatch("%S+") do
              if name:find(database, 1, true) then
                pod = name
                break
              end
            end

            if not pod then
              vim.notify("DBConnect: no running pod matching '" .. database .. "'", vim.log.levels.ERROR)
              return
            end

            vim.notify("DBConnect: found pod " .. pod)

            -- Step 2: Fetch password from secret
            vim.system(
              { "kubectl", "--context", context, "-n", namespace,
                "get", "secret", secret,
                "-o", "jsonpath={.data." .. secret_key .. "}" },
              {},
              vim.schedule_wrap(function(secret_result)
                if secret_result.code ~= 0 then
                  vim.notify("DBConnect: failed to fetch secret '" .. secret .. "': " .. (secret_result.stderr or ""), vim.log.levels.ERROR)
                  return
                end

                -- Decode base64
                vim.system(
                  { "base64", "-d" },
                  { stdin = secret_result.stdout },
                  vim.schedule_wrap(function(decode_result)
                    if decode_result.code ~= 0 then
                      vim.notify("DBConnect: failed to decode secret", vim.log.levels.ERROR)
                      return
                    end

                    local password = decode_result.stdout:gsub("%s+$", "")
                    if password == "" then
                      vim.notify("DBConnect: secret key '" .. secret_key .. "' is empty", vim.log.levels.ERROR)
                      return
                    end

                    -- Step 3: Start port-forward as a background job
                    local pf_cmd = {
                      "kubectl", "--context", context, "-n", namespace,
                      "port-forward", pod, local_port .. ":" .. tostring(remote_port),
                    }

                    local job_id = vim.fn.jobstart(pf_cmd, {
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

                    -- Build connection URL and register with dadbod
                    local encoded_password = password:gsub("([^%w%-%.%_%~])", function(c)
                      return string.format("%%%02X", string.byte(c))
                    end)

                    local url = string.format("%s://%s:%s@localhost:%s/%s",
                      scheme, user, encoded_password, local_port, dbname)

                    local dbs = vim.g.dbs or {}
                    dbs[conn_name] = url
                    vim.g.dbs = dbs

                    active_connections[conn_name] = { job_id = job_id, port = local_port }

                    vim.notify(string.format(
                      "DBConnect: connected to %s (localhost:%s) — use :DBUI to browse",
                      conn_name, local_port
                    ))
                  end)
                )
              end)
            )
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
    end,
  },

  -- Autocompletion for SQL via nvim-cmp
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
