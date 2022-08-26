# Search shell history
function hgrep() {
  history 1 | grep $1
}
