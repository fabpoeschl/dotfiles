# Packs $2-$n into $1 depending on $1's extension
# Found at <http://pastebin.com/CTra4QTF>
function compress() {
  if [[ $# -lt 2 ]]; then
    echo -e "\n$0() usage:"
    echo -e "\t$0 archive_file_name file1 file2 ... fileN"
    echo -e "\tcreates archive of files 1-N\n"
  else
    DEST=$1
    shift
    case $DEST in
      *.tar.bz2) tar -cvjf $DEST "$@" ;;
      *.tar.gz)  tar -cvzf $DEST "$@" ;;
      *.zip)     zip -r $DEST "$@" ;;
      *)         echo "Unknown file type - $DEST" ;;
    esac
  fi
}
