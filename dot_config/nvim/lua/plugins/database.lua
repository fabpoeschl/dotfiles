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

      -- :DBConnect -c <context> -n <namespace> -d <database> [-s <secret>] [-k <key>] [-u <user>] [-p <remote-port>]
      vim.api.nvim_create_user_command("DBConnect", function(opts)
        local args = opts.fargs
        local context, namespace, database, secret, secret_key, user, port_override

        local i = 1
        while i <= #args do
          local flag = args[i]
          local val = args[i + 1]
          if flag == "-c" or flag == "--context" then context = val
          elseif flag == "-n" or flag == "--namespace" then namespace = val
          elseif flag == "-d" or flag == "--database" then database = val
          elseif flag == "-s" or flag == "--secret" then secret = val
          elseif flag == "-k" or flag == "--key" then secret_key = val
          elseif flag == "-u" or flag == "--user" then user = val
          elseif flag == "-p" or flag == "--port" then port_override = val
          else
            vim.notify("DBConnect: unknown flag " .. flag, vim.log.levels.ERROR)
            return
          end
          i = i + 2
        end

        -- Prompt for required args if not provided
        context = context or vim.fn.input("Context: ")
        namespace = namespace or vim.fn.input("Namespace: ")
        database = database or vim.fn.input("Database name: ")

        if context == "" or namespace == "" or database == "" then
          vim.notify("DBConnect: context, namespace, and database are required", vim.log.levels.ERROR)
          return
        end

        -- Defaults
        secret = secret or database
        secret_key = secret_key or "password"
        user = user or "postgres"

        -- Detect remote port from database name (or use override)
        local db_lower = database:lower()
        local remote_port
        if port_override then
          remote_port = tonumber(port_override)
        elseif db_lower:match("postgres") or db_lower:match("pgsql") or db_lower:match("pg") then
          remote_port = 5432
        elseif db_lower:match("mysql") or db_lower:match("maria") then
          remote_port = 3306
        elseif db_lower:match("redis") then
          remote_port = 6379
        elseif db_lower:match("mongo") then
          remote_port = 27017
        else
          remote_port = 5432
        end
        local local_port = tostring(remote_port)

        local conn_name = context .. "/" .. namespace .. "/" .. database

        -- Check if already connected
        if active_connections[conn_name] then
          vim.notify("DBConnect: already connected to " .. conn_name, vim.log.levels.WARN)
          return
        end

        -- Find the pod
        local pod_cmd = string.format(
          "kubectl --context %s -n %s get pods -o jsonpath='{.items[*].metadata.name}'",
          vim.fn.shellescape(context),
          vim.fn.shellescape(namespace)
        )
        local pod_output = vim.fn.system(pod_cmd)
        local pod
        for name in pod_output:gmatch("%S+") do
          if name:match(database) then
            pod = name
            break
          end
        end

        if not pod then
          vim.notify("DBConnect: no pod matching '" .. database .. "' found", vim.log.levels.ERROR)
          return
        end

        vim.notify("DBConnect: found pod " .. pod)

        -- Fetch password from secret
        local secret_cmd = string.format(
          "kubectl --context %s -n %s get secret %s -o jsonpath='{.data.%s}' | base64 -d",
          vim.fn.shellescape(context),
          vim.fn.shellescape(namespace),
          vim.fn.shellescape(secret),
          secret_key
        )
        local password = vim.fn.system(secret_cmd):gsub("%s+$", "")

        if vim.v.shell_error ~= 0 or password == "" then
          vim.notify("DBConnect: failed to fetch password from secret '" .. secret .. "'", vim.log.levels.ERROR)
          return
        end

        -- Start port-forward as a background job
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
        local scheme = "postgres"
        if db_lower:match("mysql") or db_lower:match("maria") then scheme = "mysql"
        elseif db_lower:match("redis") then scheme = "redis"
        elseif db_lower:match("mongo") then scheme = "mongodb"
        end

        local encoded_password = password:gsub("([^%w%-%.%_%~])", function(c)
          return string.format("%%%02X", string.byte(c))
        end)

        local url = string.format("%s://%s:%s@localhost:%s/%s",
          scheme, user, encoded_password, local_port, database)

        -- Register in vim.g.dbs for dadbod-ui
        local dbs = vim.g.dbs or {}
        dbs[conn_name] = url
        vim.g.dbs = dbs

        active_connections[conn_name] = { job_id = job_id, port = local_port }

        vim.notify(string.format(
          "DBConnect: connected to %s (localhost:%s) — use :DBUI to browse",
          conn_name, local_port
        ))
      end, {
        nargs = "*",
        desc = "Connect to a remote database (port-forward + dadbod)",
      })

      -- :DBDisconnect [name] — stop port-forward and remove connection
      vim.api.nvim_create_user_command("DBDisconnect", function(opts)
        local name = opts.args

        if name == "" then
          -- List active connections and let user pick
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
