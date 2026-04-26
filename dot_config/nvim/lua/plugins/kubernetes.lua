-- Kubernetes pod connection tools (no external plugin needed)
-- Registers :PodConnect command and <leader>k keymaps

local k8s = require("util.k8s")

-- Parse flags from fargs, return opts and remaining positional args
local function parse_args(fargs)
  local parsed = {}
  local rest = {}
  local flags = {
    ["-c"] = "context",   ["--context"]     = "context",
    ["-n"] = "namespace", ["--namespace"]    = "namespace",
    ["-a"] = "app",       ["--application"]  = "app",
  }
  local i = 1
  while i <= #fargs do
    local flag = fargs[i]
    local field = flags[flag]
    if field then
      if i + 1 > #fargs then
        vim.notify("PodConnect: " .. flag .. " requires a value", vim.log.levels.ERROR)
        return nil
      end
      parsed[field] = fargs[i + 1]
      i = i + 2
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
  return parsed, rest
end

-- Fill any unset `parsed` fields from vim.g.podconnect_presets[name].
local function apply_preset(parsed, name)
  local presets = vim.g.podconnect_presets
  if not presets or not presets[name] then
    vim.notify("PodConnect: unknown preset '" .. name .. "'", vim.log.levels.ERROR)
    return false
  end
  for k, v in pairs(presets[name]) do
    if parsed[k] == nil then parsed[k] = v end
  end
  return true
end

-- :PodConnect [<preset>] [-c <ctx>] [-n <ns>] [-a <app>] [shell|logs|forward <ports>...]
vim.api.nvim_create_user_command("PodConnect", function(cmd_opts)
  if vim.fn.executable("kubectl") == 0 then
    vim.notify("PodConnect: kubectl is not installed or not in PATH", vim.log.levels.ERROR)
    return
  end

  local parsed, rest = parse_args(cmd_opts.fargs)
  if not parsed then return end

  -- Bare invocation with presets defined: pop a picker, then re-invoke.
  if #cmd_opts.fargs == 0
      and vim.g.podconnect_presets and next(vim.g.podconnect_presets) then
    vim.ui.select(vim.tbl_keys(vim.g.podconnect_presets), { prompt = "PodConnect:" }, function(choice)
      if choice then vim.cmd({ cmd = "PodConnect", args = { choice } }) end
    end)
    return
  end

  -- If the first positional matches a preset key, consume it as a preset
  -- (anything else is the action: shell / logs / forward).
  if rest[1] and vim.g.podconnect_presets and vim.g.podconnect_presets[rest[1]] then
    if not apply_preset(parsed, rest[1]) then return end
    table.remove(rest, 1)
  end

  -- Defaults (vim.g.*) are intended to be set per project via .nvim.lua.
  parsed.context = parsed.context or vim.g.k8s_context or vim.fn.input("Context: ")
  parsed.namespace = parsed.namespace or vim.g.k8s_namespace or vim.fn.input("Namespace: ")
  parsed.app = parsed.app or vim.g.podconnect_application or vim.fn.input("Application: ")

  if parsed.context == "" or parsed.namespace == "" or parsed.app == "" then
    vim.notify("PodConnect: context, namespace, and application are required", vim.log.levels.ERROR)
    return
  end

  local action = rest[1] or "shell"

  k8s.find_pod(parsed.context, parsed.namespace, parsed.app, function(pod, err)
    if not pod then
      vim.notify("PodConnect: " .. err, vim.log.levels.ERROR)
      return
    end

    vim.notify("PodConnect: found pod " .. pod)

    local ctx = vim.fn.shellescape(parsed.context)
    local ns = vim.fn.shellescape(parsed.namespace)
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
        table.insert(port_args, vim.fn.shellescape(rest[i]))
      end
      if #port_args == 0 then
        local mapping = vim.fn.input("Port mapping (local:remote): ")
        if mapping == "" then return end
        table.insert(port_args, vim.fn.shellescape(mapping))
      end
      local fwd_cmd = string.format(
        "kubectl --context %s -n %s port-forward %s %s",
        ctx, ns, p, table.concat(port_args, " ")
      )
      vim.cmd("botright split | terminal " .. fwd_cmd)

    else
      vim.notify("PodConnect: unknown action '" .. action .. "' (use shell, logs, or forward)", vim.log.levels.ERROR)
    end
  end)
end, {
  nargs = "*",
  desc = "Connect to a remote application pod",
  complete = function(arglead)
    local candidates = { "shell", "logs", "forward" }
    if vim.g.podconnect_presets then
      for k in pairs(vim.g.podconnect_presets) do
        table.insert(candidates, k)
      end
    end
    return vim.tbl_filter(
      function(c) return vim.startswith(c, arglead) end,
      candidates
    )
  end,
})

vim.keymap.set("n", "<leader>ks", "<cmd>PodConnect shell<CR>", { desc = "Shell into pod" })
vim.keymap.set("n", "<leader>kl", "<cmd>PodConnect logs<CR>", { desc = "Tail pod logs" })
vim.keymap.set("n", "<leader>kf", "<cmd>PodConnect forward<CR>", { desc = "Port-forward pod" })

-- Return empty table so lazy.nvim doesn't complain
return {}
