# Kubernetes helpers sourced by remote-db-connect and remote-pod-connect.

# Find a running pod whose top-level workload (Deployment / StatefulSet /
# DaemonSet / Job) matches the given name.
#
# Usage: pod=$(k8s_find_pod CONTEXT NAMESPACE WORKLOAD)
# Prints the pod name on stdout, or nothing if no match.
k8s_find_pod() {
  local ctx="$1" ns="$2" workload="$3"
  kubectl --context "$ctx" -n "$ns" get pods \
    --field-selector=status.phase=Running \
    -o 'jsonpath={range .items[*]}{.metadata.name}{"\t"}{.metadata.ownerReferences[0].kind}{"\t"}{.metadata.ownerReferences[0].name}{"\n"}{end}' \
  | awk -F'\t' -v target="$workload" '
      {
        pod = $1; kind = $2; owner = $3
        if (kind == "ReplicaSet") { sub(/-[a-z0-9]+$/, "", owner) }
        if (owner == target) { print pod; exit }
      }'
}
