#!/bin/bash

#
# Make archive of LOU data directories and publish it to the root of LOU site.
#
# Author: Volodymyr M. Lisivka <vlisivka@gmail.com>

renice +19 -p $$ >/dev/null

# Treat unset variables as an error when substituting.
set -u

# Exit immediately if a command exits with a non-zero status.
set -e

APP="`basename "$0"`"

#
# Settings
#

# Path to base directory where YaBB data files are located
LOU_DATA_DIR="/var/www/vhosts/linux.org.ua/var/yabb-2.1"

# Store to archive these directories only
LOU_DIRS_TO_ARCHIVE=( Boards Messages )

# Name of target archive
LOU_TARGET_ARCHIVE_NAME="lou-yabb-archive.tar.gz"

# Store target archvie to that directory
LOU_TARGET_ARCHIVE_DIR="/var/www/vhosts/linux.org.ua/htdocs"

# URL to target archive
LOU_TARGET_ARCHIVE_URL="/$LOU_TARGET_ARCHIVE_NAME"

# Path to temporary directory
TMPDIR="${TMPDIR:=/tmp}"

#
# Subroutines
#

error() { 
  echo "[$APP:${BASH_LINENO[0]}] ERROR: $@" >&2 
} 
	

#
# Main code
#

# Create uncompressed archive. It can be used by zsync to download more efficiently in some cases
tar -c -C "$LOU_DATA_DIR" -f "$TMPDIR/${LOU_TARGET_ARCHIVE_NAME%.gz}" "${LOU_DIRS_TO_ARCHIVE[@]}" || {
  error "Cannot create targ archive \"$TMPDIR/${LOU_TARGET_ARCHIVE_NAME%.gz}\"."
  exit 1
}

# Create .zsync file and .gz archive file
zsyncmake -z -b 2048 -u "$LOU_TARGET_ARCHIVE_URL" "$TMPDIR/${LOU_TARGET_ARCHIVE_NAME%.gz}" -o "$TMPDIR/$LOU_TARGET_ARCHIVE_NAME.zsync" || {
  error "Cannot create .zsync file for \"$TMPDIR/${LOU_TARGET_ARCHIVE_NAME%.gz}\" file."
  exit 1
}

# Move generated files over old ones
mv --target-directory="$LOU_TARGET_ARCHIVE_DIR/" --force "$TMPDIR/${LOU_TARGET_ARCHIVE_NAME%.gz}"* || {
  error "Cannot move \"$TMPDIR/${LOU_TARGET_ARCHIVE_NAME%.gz}*\" files to \"$LOU_TARGET_ARCHIVE_DIR/\" directory."
  exit 1
}

exit 0
