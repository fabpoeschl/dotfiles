# Start docker dependencies
function start-docker-dependencies() {
  podman machine start
  podman-compose up
}
