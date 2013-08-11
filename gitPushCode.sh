# Push the code to remote repo.

BRANCH_NAME=$(git symbolic-ref -q HEAD)
BRANCH_NAME=${BRANCH_NAME##refs/heads/}
BRANCH_NAME=${BRANCH_NAME:-HEAD}

# Replace the 'origin' and 'acquia' with your repo alias(es).
git push origin $BRANCH_NAME
git push acquia $BRANCH_NAME
