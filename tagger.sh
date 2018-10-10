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

# remove all git tags
# git tag | xargs git tag -d

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

    #echo "get_tag_name called with $@"
    gtn_tag=""

    if [ $1 == $rootbranch ]; then
        echo "v0.$2"
    else
        gtn_tag="$3-$1"

        if [ ${gtn_tag} ]; then
            gtn_tag="$gtn_tag-$2"
            echo $gtn_tag
        fi
    fi
}


# Tag all commits in a branch with version numbers
# $arg1 -> branch name
tag_branch() {
    echo "Tagging branch [$1]"
    commits=$(git log --walk-reflogs $1 --pretty=format:"%h" --no-patch);
    echo "commits: $commits"
    commits=($commits)
    version=1
    parenttag=""

    if [ "$1" != "$rootbranch" ]; then
        parenttag=$(git describe --tags ${commits[${#commits[@]}-1]})
        echo "parenttag=$parenttag"
    fi

    for ((i=${#commits[@]}-1; i>=0; i--)); do

        echo "tagging commit ${commits[$i]}"
        tag=""
        echo "for-tag: $tag"
        echo "running: git describe --tags ${commits[$i]}"
        tag=$(git describe --tags ${commits[$i]})
        echo "for-tag-after-describe: $tag"

        if [ -z ${tag} ]; then
            echo "existing tag not found - proceeding with tagging"
            echo "running: get_tag_name $1 ${version} ${parenttag}"
            tag=$(get_tag_name $1 ${version} ${parenttag})
            echo "tag=$tag"
            echo "running: git tag -a ${tag} -m 'auto-generated' ${commits[$i]}"
            git tag -a ${tag} -m "auto-generated" ${commits[$i]}
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

#for ((i=${#branchlist[@]}-1; i>=0; i--)); do
#    if [ "${branchlist[$i]}" != "$rootbranch" ]; then
#    echo "calling tag_branch with branchname ${branchlist[$i]}"
#        tag_branch ${branchlist[$i]}
#    fi
#done