#!/bin/bash
# Define the path to the GPG encrypted file
VAULT_FILE="$HOME/.vault_pass.gpg"

# Check if the file exists
if [ ! -f "$VAULT_FILE" ]; then
  echo "Error: Encrypted vault file not found at $VAULT_FILE" >&2
  echo "Run this to create it: echo 'your_password' | gpg --symmetric --output $VAULT_FILE" >&2
  exit 1
fi

# Decrypt the content on the fly
# --quiet: Don't print GPG version info
# --batch: Don't ask interactive questions
# --use-agent: Try to use the GPG agent (cached passphrase) so you don't type it every time
gpg --quiet --batch --use-agent --decrypt "$VAULT_FILE"