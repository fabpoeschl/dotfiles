 # Add an existing submodule to the git repository'
 function git-add-submodule() {
   if [[ -v $url ]]; then
      echo Error: URL variable name already used.
      return 1
   fi 

   pushd $1
   if [[ -d .git ]]; then
     export url=`git remote get-url origin`
   fi
   popd
   if [[ -v URL ]]; then
      echo git submodule add $url $1
      git submodule add $url $1
   else
     echo The target folder is not a git directory.
   fi
 }
