#!/bin/bash
# Fresh install or update - both are handled by update.sh
cd "$(dirname "$0")"
exec ./update.sh
