#!/bin/bash
case "$(uname -s)" in
	Darwin*) ./install-packages-macos.sh;; 
	Linux*)  ./install-packages-linux.sh;;
	*)       echo "Unknown OS. Aborting installation";;
esac

./create-symlinks.sh
