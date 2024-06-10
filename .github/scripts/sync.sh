#!/bin/bash

# Define your GitHub Personal Access Token
GITHUB_TOKEN="YOUR_PERSONAL_ACCESS_TOKEN"

REPOS=(
    "https://github.com/geimob/joseimob.git"
)

TEMP_DIR=$(mktemp -d)

update_repo() {
    REPO_URL=$1
    REPO_NAME=$(basename $REPO_URL .git)

    git clone $REPO_URL $TEMP_DIR/$REPO_NAME
    
    cd $TEMP_DIR/$REPO_NAME
    
    git config credential.helper store
    echo "https://$GITHUB_TOKEN:x-oauth-basic" > ~/.git-credentials
    
    git remote add template https://github.com/geimob/geimob-regular.git
    
    git fetch template
    
    git merge template/main -m "Update from template"
    
    git push origin main
    
    cd -
}

for REPO in "${REPOS[@]}"; do
    update_repo $REPO
done

# Clean up temporary directory
rm -rf $TEMP_DIR
