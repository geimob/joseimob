#!/bin/bash

# Define the repositories to update
REPOS=(
    "https://x-access-token:${AUTH_TOKEN}@github.com/geimob/joseimob.git"
)

# Create a temporary directory for cloning
TEMP_DIR=$(mktemp -d)

# Cleanup function to remove the temporary directory
cleanup() {
    rm -rf $TEMP_DIR
}

# Trap any errors to ensure cleanup
trap cleanup EXIT

# Function to update repository from the template
update_repo() {
    REPO_URL=$1
    REPO_NAME=$(basename $REPO_URL .git)
    
    echo "Cloning repository $REPO_NAME"
    git clone $REPO_URL $TEMP_DIR/$REPO_NAME || { echo "Failed to clone $REPO_NAME"; exit 1; }
    
    cd $TEMP_DIR/$REPO_NAME || { echo "Failed to enter repository directory"; exit 1; }
    
    echo "Adding template remote"
    git remote add template "https://x-access-token:${AUTH_TOKEN}@github.com/geimob/geimob-regular.git" || { echo "Failed to add template remote"; exit 1; }
    
    echo "Fetching template repository"
    git fetch template || { echo "Failed to fetch template"; exit 1; }
    
    echo "Merging template/main into main"
    git merge template/main --allow-unrelated-histories -m "Update from template" || {
        echo "Merge conflict detected. Attempting to resolve automatically."
        
        # Resolve conflicts by accepting the incoming changes
        for file in $(git diff --name-only --diff-filter=U); do
            echo "Resolving conflict in $file by accepting incoming changes"
            git checkout --theirs $file
            git add $file
        done
        
        git commit -m "Resolved merge conflicts by accepting incoming changes" || {
            echo "Automatic conflict resolution failed. Manual intervention required."
            exit 1
        }
    }
    
    echo "Pushing changes to origin"
    git push origin main || { echo "Failed to push changes to origin"; exit 1; }
    
    cd - || { echo "Failed to return to previous directory"; exit 1; }
}

# Update each repository in the list
for REPO in "${REPOS[@]}"; do
    update_repo $REPO
done
