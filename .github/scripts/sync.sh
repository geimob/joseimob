#!/bin/bash

REPOS=(
    "https://x-access-token:${GITHUB_TOKEN}@github.com/geimob/joseimob.git"
)

TEMP_DIR=$(mktemp -d)

update_repo() {
    REPO_URL=$1
    REPO_NAME=$(basename $REPO_URL .git)
    
    git clone $REPO_URL $TEMP_DIR/$REPO_NAME
    
    cd $TEMP_DIR/$REPO_NAME
    
    git remote add template https://x-access-token:${GITHUB_TOKEN}@github.com/geimob/geimob-regular.git
    
    git fetch template
    
    git merge template/main -m "Update from template"
    
    git push origin main
    
    cd -
}

for REPO in "${REPOS[@]}"; do
    update_repo $REPO
done

rm -rf $TEMP_DIR
