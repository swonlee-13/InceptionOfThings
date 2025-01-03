#!/bin/bash

# Define the file path
FILE="./deployment.yaml"

# Check if the file contains v1 or v2 and replace accordingly
if grep -q 'wil42/playground:v1' $FILE; then
  sed -i '' 's/wil42\/playground:v1/wil42\/playground:v2/g' $FILE
  NEW_VERSION="v2"
elif grep -q 'wil42/playground:v2' $FILE; then
  sed -i '' 's/wil42\/playground:v2/wil42\/playground:v1/g' $FILE
  NEW_VERSION="v1"
else
    echo "Error: Image version not found in the file"
    exit 1
fi

# Add the changes to git
git add $FILE

# Commit the changes
git commit -m "Update playground image to $NEW_VERSION"

# Push the changes
git push "git@github.com:Alixmixx/deploy_amuller_42.git"
