# Reload git hooks
function git-reload-hooks() {
   rm -f (git rev-parse --git-dir)/hooks/*
   git init
 }
