#!/usr/bin/env bash

rootbranch="develop"

# ===========================================
# Method declarations
# ===========================================

# Generate proper tag name with our versioning scheme
# $arg1 | branch name
# $arg2 | version
# $arg3 | parent tag
get_tag_name() {

    gtn_tag=""

    # If root, return the standard version -> (v0.1)
    if [ $1 == $rootbranch ]; then
        echo "v0.$2"
    else
        # if we have a parent tag -> (v0.1-CID-3333)
        if [ "$3" != "" ]; then
            gtn_tag="$3-$1"
        else
            gtn_tag="$1" # this should not happen
        fi

        # Apply version -> (v0.1-CID-3333-1)
        if [ ${gtn_tag} ]; then
            gtn_tag="$gtn_tag-$2"
            echo $gtn_tag
        fi
    fi
}

# Tag all commits in a branch with version numbers
# $arg1 | branch name
tag_branch() {
    echo "Tagging branch [$1]"

    # Get an array of commits belonging to the target branch
    commits=$(git log --walk-reflogs $1 --pretty=format:"%h" --no-patch); commits=($commits) # convert string -> array
    version=1
    parenttag=""

    # If it's not the root branch, get the parent commit's tag - we'll use it as a prefix
    if [ "$1" != "$rootbranch" ]; then
        parenttag=$(git tag --points-at ${commits[${#commits[@]}-1]})
    fi

    # Iterate through the commits, and tag them
    for ((i=${#commits[@]}-1; i>=0; i--)); do
        tag=""
        tag=$(git tag --points-at ${commits[$i]})

        if [ -z ${tag} ]; then
            echo "existing tag not found - proceeding with tagging"
            tag=$(get_tag_name $1 ${version} ${parenttag})
            git tag -a ${tag} -m "auto-generated" ${commits[$i]}
        else
            echo "Commit has been tagged already - ${tag} - ${commits[$i]}"
        fi
        version=$((version + 1))
    done
}

# ===========================================
# Tagging script
# ===========================================

# Run on main branch
tag_branch $rootbranch

# Run on all other branches, except root
branches=$(git for-each-ref --format='%(refname:short)' refs/heads); branchlist=($branches) # convert string -> array
for ((cnt=0; cnt<${#branchlist[@]}-1; cnt++)); do
    if [ "${branchlist[$cnt]}" != "$rootbranch" ]; then
        tag_branch ${branchlist[$cnt]}
    fi
done
