# IAM User Creation Script

This script automates the creation of an IAM user with access keys and attaches a specified policy in AWS.

## Prerequisites

- AWS CLI installed and configured.
- A JSON policy file named `tfg-policy.json` should exist in the same directory as the script.

## Script Details

- **Username**: `tfg-user` (modifiable in the script).
- **Policy**: `tfg_policy` (modifiable in the script).
- **Credentials File**: Saves generated access keys in `$HOME/tfg-user_credentials.json`.

## Usage

1. Clone or download this script.
2. Make the script executable:
   ```bash
   chmod +x create_user.sh
3. Run the script:
   ```bash
   ./create_user.sh
