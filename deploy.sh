#!/bin/bash

echo -e "\033[0;32mDeploying updates to GitHub...\033[0m"

# Build the project into an empty /public
# -c wipes old contents except .git (the submodule repo)
rm -rf public/*
hugo

# Go To Public folder
cd public

# Ensure we’re on the right branch
git checkout master

# Stage all changes, including deletions
git add -A

# Commit changes
msg="rebuilding site $(date)"
if [ $# -eq 1 ]
then 
  msg="$1"
fi
git commit -m "$msg" || echo "No changes to commit"

# Push to website repo
git push origin master

# Come Back up to the Project Root
cd ..
