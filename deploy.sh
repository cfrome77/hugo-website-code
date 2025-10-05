#!/bin/bash

echo -e "\033[0;32mDeploying updates to GitHub...\033[0m"

# Initialize and update the public submodule if needed
if [ ! -d "public/.git" ]; then
    echo "Initializing and updating public submodule..."
    git submodule update --init --recursive
else
    echo "Updating public submodule..."
    git submodule update --recursive
fi

# Go to public folder
cd public || { echo "Failed to cd into public"; exit 1; }

# Ensure we’re on the correct branch and discard any local changes
git fetch origin
git checkout master || git checkout -B master origin/master
git reset --hard origin/master

# Return to project root to build site
cd .. || { echo "Failed to return to project root"; exit 1; }

# Clean the public folder except .git
echo "Cleaning public folder..."
find public -mindepth 1 ! -name '.git' -exec rm -rf {} +

# Build the Hugo site into public/
echo "Building site with Hugo..."
hugo --environment production

# Go back to public folder to commit changes
cd public || { echo "Failed to cd into public"; exit 1; }

# Stage all changes, including deletions
git add -A

# Commit changes
msg="rebuilding site $(date)"
if [ $# -eq 1 ]; then 
  msg="$1"
fi
git commit -m "$msg" || echo "No changes to commit"

# Push to GitHub
git push origin master || echo "Push failed"

# Return to project root
cd ..
echo -e "\033[0;32mDeployment complete!\033[0m"

# Update submodule reference
git add public
git commit -m "$msg (Submodule Reference Update)" || echo "No submodule reference change to commit"
git push origin master
