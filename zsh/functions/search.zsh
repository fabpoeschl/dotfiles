# Search for files by name
# Case-insensitive and allows partial search
# If on Mac OS X, will prompt to open the file if there is a single result
function search() {
  results=`find . -iname "*$1*"`
  echo $results
  if command_exists open; then
    resultLength=`echo $results | wc -l | sed -e "s/^[ \t]*//"`
    if [ $resultLength -eq 1 ]; then
      while true; do
        echo "One result found! Open it? (y/n)?"
        read yn
        case $yn in
          [Yy]* ) open $results; break;;
          [Nn]* ) break;;
          * ) echo "Please answer (Y/y)es or (N/n)o.";;
        esac
      done
    fi
  fi
}
