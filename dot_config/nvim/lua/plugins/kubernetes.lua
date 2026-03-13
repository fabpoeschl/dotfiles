return {
  {
    "nvim-lua/plenary.nvim",
    lazy = true,
  },

  {
    "fabpoeschl/kubernetes.nvim",
    virtual = true,
    name = "kubernetes-commands",
    dependencies = { "nvim-lua/plenary.nvim" },
    keys = {
      { "<leader>ks", "<cmd>PodConnect shell<CR>", desc = "Shell into pod" },
      { "<leader>kl", "<cmd>PodConnect logs<CR>", desc = "Tail pod logs" },
      { "<leader>kf", "<cmd>PodConnect forward<CR>", desc = "Port-forward pod" },
      { "<leader>kd", "<cmd>PodDisconnect<CR>", desc = "Stop pod port-forward" },
    },
    config = function()
      -- Track active port-forward jobs: { name = { job_id, ports } }
      local active_forwards = {}

      -- Find a running pod by name substring
      local function find_pod(context, namespace, app)
        local cmd = string.format(
          "kubectl --context %s -n %s get pods --field-selector=status.phase=Running -o jsonpath='{.items[*].metadata.name}'",
          vim.fn.shellescape(context),
          vim.fn.shellescape(namespace)
        )
        local output = vim.fn.system(cmd)
        if vim.v.shell_error ~= 0 then
          return nil
        end
        for name in output:gmatch("%S+") do
          if name:match(app) then
            return name
          end
        end
        return nil
      end

      -- Parse flags from fargs, return remaining positional args
      local function parse_args(fargs)
        local opts = {}
        local rest = {}
        local i = 1
        while i <= #fargs do
          local flag = fargs[i]
          if flag == "-c" or flag == "--context" then opts.context = fargs[i + 1]; i = i + 2
          elseif flag == "-n" or flag == "--namespace" then opts.namespace = fargs[i + 1]; i = i + 2
          elseif flag == "-a" or flag == "--application" then opts.app = fargs[i + 1]; i = i + 2
          elseif flag:sub(1, 1) == "-" then
            vim.notify("PodConnect: unknown flag " .. flag, vim.log.levels.ERROR)
            return nil
          else
            -- Rest are positional (action + action args)
            for j = i, #fargs do
              table.insert(rest, fargs[j])
            end
            break
          end
        end
        return opts, rest
      end

      -- :PodConnect -c <context> -n <namespace> -a <app> [shell|logs|forward <port:port> ...]
      vim.api.nvim_create_user_command("PodConnect", function(cmd_opts)
        local opts, rest = parse_args(cmd_opts.fargs)
        if not opts then return end

        opts.context = opts.context or vim.fn.input("Context: ")
        opts.namespace = opts.namespace or vim.fn.input("Namespace: ")
        opts.app = opts.app or vim.fn.input("Application: ")

        if opts.context == "" or opts.namespace == "" or opts.app == "" then
          vim.notify("PodConnect: context, namespace, and application are required", vim.log.levels.ERROR)
          return
        end

        local action = rest[1] or "shell"

        local pod = find_pod(opts.context, opts.namespace, opts.app)
        if not pod then
          vim.notify("PodConnect: no running pod matching '" .. opts.app .. "'", vim.log.levels.ERROR)
          return
        end

        vim.notify("PodConnect: found pod " .. pod)
        local conn_name = opts.context .. "/" .. opts.namespace .. "/" .. opts.app

        if action == "shell" then
          -- Open a terminal with an interactive shell
          local shell_cmd = string.format(
            "kubectl --context %s -n %s exec -it %s -- bash 2>/dev/null || kubectl --context %s -n %s exec -it %s -- sh",
            vim.fn.shellescape(opts.context), vim.fn.shellescape(opts.namespace), vim.fn.shellescape(pod),
            vim.fn.shellescape(opts.context), vim.fn.shellescape(opts.namespace), vim.fn.shellescape(pod)
          )
          vim.cmd("botright split | terminal " .. shell_cmd)

        elseif action == "logs" then
          -- Open a terminal tailing logs
          local logs_cmd = string.format(
            "kubectl --context %s -n %s logs -f %s",
            vim.fn.shellescape(opts.context), vim.fn.shellescape(opts.namespace), vim.fn.shellescape(pod)
          )
          vim.cmd("botright split | terminal " .. logs_cmd)

        elseif action == "forward" then
          -- Port-forward as a background job
          local port_args = {}
          for i = 2, #rest do
            table.insert(port_args, rest[i])
          end

          if #port_args == 0 then
            local mapping = vim.fn.input("Port mapping (local:remote): ")
            if mapping == "" then return end
            table.insert(port_args, mapping)
          end

          if active_forwards[conn_name] then
            vim.notify("PodConnect: already forwarding for " .. conn_name .. " — use :PodDisconnect first", vim.log.levels.WARN)
            return
          end

          local pf_cmd = { "kubectl", "--context", opts.context, "-n", opts.namespace, "port-forward", pod }
          for _, p in ipairs(port_args) do
            table.insert(pf_cmd, p)
          end

          local job_id = vim.fn.jobstart(pf_cmd, {
            on_stderr = function(_, data)
              local msg = table.concat(data, "\n"):gsub("%s+$", "")
              if msg ~= "" then
                vim.notify("PodConnect [" .. conn_name .. "]: " .. msg, vim.log.levels.WARN)
              end
            end,
            on_exit = function(_, code)
              active_forwards[conn_name] = nil
              if code ~= 0 then
                vim.notify("PodConnect: port-forward exited (code " .. code .. ")", vim.log.levels.WARN)
              end
            end,
          })

          if job_id <= 0 then
            vim.notify("PodConnect: failed to start port-forward", vim.log.levels.ERROR)
            return
          end

          active_forwards[conn_name] = { job_id = job_id, ports = port_args }
          vim.notify(string.format("PodConnect: forwarding %s (%s)", conn_name, table.concat(port_args, ", ")))

        else
          vim.notify("PodConnect: unknown action '" .. action .. "' (use shell, logs, or forward)", vim.log.levels.ERROR)
        end
      end, {
        nargs = "*",
        desc = "Connect to a remote application pod",
      })

      -- :PodDisconnect [name] — stop a port-forward
      vim.api.nvim_create_user_command("PodDisconnect", function(cmd_opts)
        local name = cmd_opts.args

        if name == "" then
          local names = vim.tbl_keys(active_forwards)
          if #names == 0 then
            vim.notify("PodDisconnect: no active port-forwards", vim.log.levels.INFO)
            return
          end
          vim.ui.select(names, { prompt = "Disconnect:" }, function(choice)
            if choice then
              vim.cmd("PodDisconnect " .. choice)
            end
          end)
          return
        end

        local conn = active_forwards[name]
        if not conn then
          vim.notify("PodDisconnect: no active forward '" .. name .. "'", vim.log.levels.ERROR)
          return
        end

        vim.fn.jobstop(conn.job_id)
        active_forwards[name] = nil
        vim.notify("PodDisconnect: stopped " .. name)
      end, {
        nargs = "?",
        desc = "Stop a pod port-forward",
      })
    end,
  },
}
