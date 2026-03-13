return {
  {
    "fabpoeschl/kubernetes.nvim",
    virtual = true,
    name = "kubernetes-commands",
    keys = {
      { "<leader>ks", "<cmd>PodConnect shell<CR>", desc = "Shell into pod" },
      { "<leader>kl", "<cmd>PodConnect logs<CR>", desc = "Tail pod logs" },
      { "<leader>kf", "<cmd>PodConnect forward<CR>", desc = "Port-forward pod" },
    },
    config = function()
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

        local ctx = vim.fn.shellescape(opts.context)
        local ns = vim.fn.shellescape(opts.namespace)
        local p = vim.fn.shellescape(pod)

        if action == "shell" then
          local shell_cmd = string.format(
            "kubectl --context %s -n %s exec -it %s -- bash 2>/dev/null || kubectl --context %s -n %s exec -it %s -- sh",
            ctx, ns, p, ctx, ns, p
          )
          vim.cmd("botright split | terminal " .. shell_cmd)

        elseif action == "logs" then
          local logs_cmd = string.format("kubectl --context %s -n %s logs -f %s", ctx, ns, p)
          vim.cmd("botright split | terminal " .. logs_cmd)

        elseif action == "forward" then
          local port_args = {}
          for i = 2, #rest do
            table.insert(port_args, rest[i])
          end
          if #port_args == 0 then
            local mapping = vim.fn.input("Port mapping (local:remote): ")
            if mapping == "" then return end
            table.insert(port_args, mapping)
          end
          local fwd_cmd = string.format(
            "kubectl --context %s -n %s port-forward %s %s",
            ctx, ns, p, table.concat(port_args, " ")
          )
          vim.cmd("botright split | terminal " .. fwd_cmd)

        else
          vim.notify("PodConnect: unknown action '" .. action .. "' (use shell, logs, or forward)", vim.log.levels.ERROR)
        end
      end, {
        nargs = "*",
        desc = "Connect to a remote application pod",
      })
    end,
  },
}
