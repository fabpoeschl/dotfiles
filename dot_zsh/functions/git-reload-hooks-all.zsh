# Reload all git hooks
function git-reload-hooks-all() {
	git submodule foreach --recursive 'rm -f $(git rev-parse --git-dir)/hooks/*;git init'
}
