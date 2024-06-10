#!/bin/bash

REPOS=(
    "https://x-access-token:${AUTH_TOKEN}@github.com/geimob/joseimob.git"
)

TEMP_DIR=$(mktemp -d)

# Cleanup function to remove the temporary directory
cleanup() {
    rm -rf $TEMP_DIR
}

# Trap any errors to ensure cleanup
trap cleanup EXIT

update_repo() {
    REPO_URL=$1
    REPO_NAME=$(basename $REPO_URL .git)
    
    git clone $REPO_URL $TEMP_DIR/$REPO_NAME
    
    cd $TEMP_DIR/$REPO_NAME
    
    git remote add template "https://x-access-token:${AUTH_TOKEN}@github.com/geimob/geimob-regular.git"
    
    git fetch template
    
    git merge template/main --allow-unrelated-histories -m "Update from template" || {
        echo "Merge conflict detected. Attempting to resolve automatically."
        
        git merge --strategy-option theirs template/main -m "Update from template with automatic conflict resolution" || {
            echo "Automatic conflict resolution failed. Manual intervention required."
            exit 1
        }
    }
    
    git push origin main
    
    cd -
}

for REPO in "${REPOS[@]}"; do
    update_repo $REPO
done
