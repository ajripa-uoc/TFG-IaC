#!/bin/bash

# Script to create an IAM user with access keys and attach a specified policy

# Variables
USERNAME="tfg-user"             # Name of the IAM user to be created
POLICY="tfg_policy"             # Name of the IAM policy to be attached
CREDENTIALS_FILE="$HOME/${USERNAME}_credentials.json" # Path to save the access keys

# Create a new IAM user
echo "Creating IAM user: $USERNAME"
aws iam create-user --user-name "$USERNAME"

# Generate access keys for the new user and save to a secure file
echo "Creating access keys for $USERNAME and saving to $CREDENTIALS_FILE"
aws iam create-access-key --user-name "$USERNAME" > "$CREDENTIALS_FILE"

# Create the IAM policy using a policy document file (tfg-policy.json must exist)
echo "Creating policy: $POLICY"
aws iam create-policy --policy-name "$POLICY" --policy-document file://$POLICY.json

# Attach the created policy to the new user
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
echo "Attaching policy $POLICY to user $USERNAME"
aws iam attach-user-policy --policy-arn arn:aws:iam::$ACCOUNT_ID:policy/$POLICY --user-name "$USERNAME"

# Output location of the credentials
echo "Access keys for user $USERNAME have been created and saved to $CREDENTIALS_FILE"
