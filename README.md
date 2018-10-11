# taggr

Automated git commit tagging with custom versioning scheme

## Helpers
### list commit hashes from a branch - newest first!
    git log --walk-reflogs {branch name} --pretty=format:"%h" --no-patch

### show branch names only
    git for-each-ref --format='%(refname:short)' refs/heads

### list tags of a specific commit (with hash)
    git tag --points-at {hash}

### create tag for a specific commit
    git tag -a {tag text} -m {tag message} {hash}

### remove all git tags
    git tag | xargs git tag -d

## Algorithm (pseudo code)

 1. List all commits from {root-branch}
 2. Iterate through the commit hashes, and tag them with `v0.{version}` (in reverse)
 3. List all branches from repo, and exclude `{root-branch}`
 4. Iterate through them and:
	 - List all commits (in reverse)
	 - Get the tag of the _first_ commit (that belongs to the parent branch)
	 - Tag the rest with `{first-commit-tag}-{branch-name}-{version}` (in reverse)