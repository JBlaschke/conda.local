#!/usr/bin/env bash

#
# Remove stuff from PATH
# cf: https://unix.stackexchange.com/a/291611
#

__path_remove() {
  # Delete path by parts so we can never accidentally remove sub paths
  PATH=${PATH//":$1:"/":"} # delete any instances in the middle
  PATH=${PATH/#"$1:"/} # delete any instance at the beginning
  PATH=${PATH/%":$1"/} # delete any instance in the at the end
}

__path_remove $PATHSTR
