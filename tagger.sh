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

# $arg1 -> branch name
# $arg2 -> version
# $arg3 -> parent tag
get_tag_name() {

    if [ $1 == $rootbranch ]; then
        echo "v0.$2"
    else
        tag="$3-$1"

        if [ ${tag} ]; then
            tag="$tag-$2"
            echo $tag
        fi
    fi
}


# Tag all commits in a branch with version numbers
# $arg1 -> branch name
tag_branch() {
    echo "Tagging branch [$1]"
    commits=$(git log --walk-reflogs $1 --pretty=format:"%h" --no-patch); commits=($commits)
    version=1
    parenttag=""

    if [ "$1" != "$rootbranch" ]; then
        parenttag=$(git describe --tags ${commits[${#commits[@]}-1]})
    fi

    for ((i=${#commits[@]}-1; i>=0; i--)); do
        tag=$(git describe --tags ${commits[$i]})

        if [ -z ${tag} ]; then
            tag=get_tag_name $1 ${version} ${parenttag}
            git tag -a -m "auto-generated" ${tag} ${commits[$i]}
        else
            echo "Commit has been tagged already - ${tag} - ${commits[$i]}"
        fi
        version=$((version + 1))
    done
}

tag_branch $rootbranch

# ================ Tagging child branches =================
branches=$(git for-each-ref --format='%(refname:short)' refs/heads)
branchlist=($branches)

for ((i=${#branchlist[@]}-1; i>=0; i--)); do
    if [ ${branchlist[$i]} != $rootbranch ]; then
        tag_branch ${branchlist[$i]}
    fi
done