-- Kubernetes helpers shared by plugins/kubernetes.lua and plugins/database.lua.

local M = {}

-- Map a pod's top-level ownerReference to the workload name a user types.
-- Pods owned by a ReplicaSet trace back to a Deployment whose name is the RS
-- name minus the trailing pod-template-hash (lowercase alphanumeric).
local function workload_name(kind, owner)
  if not kind or owner == nil or owner == "" then return nil end
  if kind == "ReplicaSet" then
    return owner:match("^(.+)%-[a-z0-9]+$")
  end
  return owner
end

-- Find a running pod whose top-level workload matches `workload`.
-- callback(pod_name, err): pod_name is nil on error.
function M.find_pod(context, namespace, workload, callback)
  vim.system(
    { "kubectl", "--context", context, "-n", namespace,
      "get", "pods", "--field-selector=status.phase=Running",
      "-o", 'jsonpath={range .items[*]}{.metadata.name}{"\t"}'
        .. '{.metadata.ownerReferences[0].kind}{"\t"}'
        .. '{.metadata.ownerReferences[0].name}{"\n"}{end}' },
    {},
    vim.schedule_wrap(function(result)
      if result.code ~= 0 then
        callback(nil, result.stderr ~= "" and result.stderr or "kubectl failed")
        return
      end
      for line in result.stdout:gmatch("[^\r\n]+") do
        local pod, kind, owner = line:match("^([^\t]+)\t([^\t]*)\t([^\t]*)$")
        if pod and workload_name(kind, owner) == workload then
          callback(pod, nil)
          return
        end
      end
      callback(nil, "no running pod for workload '" .. workload .. "'")
    end)
  )
end

return M
