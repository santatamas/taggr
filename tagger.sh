#!/usr/bin/env bash

rootbranch="master"

# list commit hashes from a branch - newest first!
# git log --walk-reflogs master --pretty=format:"%h" --no-patch

# show branch names only
# git for-each-ref --format='%(refname:short)' refs/heads

# list tags of a specific commit (with hash)
# git describe --tags 6dddc48

# create tag for a specific commit
# git tag -a v1.2 9fceb02

# -----------------------------------------

# Algorithm proposal
# - list all commits from {root-branch} - DONE
# - iterate through the hashes, and tag them with v0.{version} (in reverse) - DONE

# - list all branches, and exclude {root-branch}
# - iterate through them and:
#   - list all commits
#   - get the tag of the _first_ commit in history
#   - tag the rest with {first-commit-tag}-{branch-name}-{version} (in reverse)

# Implementation
rc=$(git log --walk-reflogs master --pretty=format:"%h" --no-patch)
rootcommits=($rc) # I don't know why we need this at all, but this will result in an array of lines

# echo ${#rootcommits[@]}
# echo "---- Listing commits from ${rootbranch} ----"

version=1
for ((i=${#rootcommits[@]}-1; i>=0; i--)); do
  #git tag -a -m "auto-generated" v0.${version} ${rootcommits[$i]}
  currenttags=$(git describe --tags ${rootcommits[$i]})

  if [ -z ${currenttags} ]; then
    git tag -a -m "auto-generated" v0.${version} ${rootcommits[$i]}
  else
    echo "Commit has been tagged already - ${currenttags} - ${rootcommits[$i]}"
  fi
  version=$((version + 1))
done