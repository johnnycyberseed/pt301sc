#!/bin/bash

# Colors for better output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Default mode is to add the block
REMOVE_MODE=false

# Process command-line arguments
while [[ "$#" -gt 0 ]]; do
  case $1 in
    --rm) REMOVE_MODE=true ;;
    *) echo -e "${RED}Unknown parameter: $1${NC}"; exit 1 ;;
  esac
  shift
done

# Function to display a confirmation prompt
confirm() {
  local prompt=$1
  local response
  
  echo -en "${YELLOW}$prompt [y/N]:${NC} "
  read response
  
  if [[ "$response" =~ ^[Yy]$ ]]; then
    return 0
  else
    return 1
  fi
}

# Function to check if a command exists
command_exists() {
  command -v "$1" >/dev/null 2>&1
}

# Main script starts here
HOSTS_FILE="/etc/hosts"
TEMP_HOSTS="/tmp/hosts.new"
BACKUP_HOSTS="/tmp/hosts.backup.$(date +%Y%m%d%H%M%S)"

# Create a backup
cp "$HOSTS_FILE" "$BACKUP_HOSTS"
echo -e "${GREEN}✓ Created backup at $BACKUP_HOSTS${NC}"

# Create a temporary copy to edit
cp "$HOSTS_FILE" "$TEMP_HOSTS"

# Check if the PT301SC block already exists
if grep -q "BEGIN: PT301SC" "$HOSTS_FILE"; then
  if [ "$REMOVE_MODE" = true ]; then
    echo -e "${GREEN}Found PT301SC block in $HOSTS_FILE - preparing to remove it${NC}"
    # Remove existing block
    sed -i '' '/# ==- BEGIN: PT301SC -==/,/# ==- END: PT301SC -==/d' "$TEMP_HOSTS"
  else
    echo -e "${YELLOW}Warning: PT301SC block already exists in $HOSTS_FILE${NC}"
    if confirm "Would you like to remove the existing block and add a fresh one?"; then
      # Remove existing block
      sed -i '' '/# ==- BEGIN: PT301SC -==/,/# ==- END: PT301SC -==/d' "$TEMP_HOSTS"
      echo -e "${GREEN}✓ Removed existing PT301SC block${NC}"
    else
      echo -e "${YELLOW}Exiting without making changes.${NC}"
      echo -e "${GREEN}Tip: You can remove the existing block by running:${NC}"
      echo -e "${GREEN}   sudo $0 --rm${NC}"
      exit 0
    fi
  fi
else
  if [ "$REMOVE_MODE" = true ]; then
    echo -e "${YELLOW}No PT301SC block found in $HOSTS_FILE. Nothing to remove.${NC}"
    exit 0
  fi
fi

# Add the new block to the temporary file (only if not in remove mode)
if [ "$REMOVE_MODE" = false ]; then
  cat << EOF >> "$TEMP_HOSTS"
# ==- BEGIN: PT301SC -==
127.0.0.1  www.pivotaltracker.com
# ==- END: PT301SC -==
EOF
fi

# Show diff - use colordiff if available
echo -e "${GREEN}Here's the difference between your current hosts file and the proposed change:${NC}"
if command_exists colordiff; then
  colordiff -u "$HOSTS_FILE" "$TEMP_HOSTS"
else
  diff -u "$HOSTS_FILE" "$TEMP_HOSTS"
fi

# Prepare confirmation message based on mode
if [ "$REMOVE_MODE" = true ]; then
  CONFIRM_MSG="Do you want to remove the PT301SC routing from your hosts file?"
  SUCCESS_MSG="✓ PT301SC routing has been removed from your hosts file"
else
  CONFIRM_MSG="Do you want to apply these changes to your hosts file?"
  SUCCESS_MSG="✓ Your hosts file now routes www.pivotaltracker.com to localhost (127.0.0.1)"
fi

# Ask for confirmation
if confirm "$CONFIRM_MSG"; then
  # Apply changes
  echo "Applying the change on your $HOSTS_FILE (sudo required)..."
  if sudo cp "$TEMP_HOSTS" "$HOSTS_FILE"; then
    echo -e "${GREEN}✓ Changes applied successfully!${NC}"
    echo -e "${GREEN}$SUCCESS_MSG${NC}"
  else
    echo -e "${RED}Error: Failed to apply changes. Did the sudo succeed?${NC}"
  fi
else
  echo -e "${YELLOW}Operation cancelled. No changes were made to your hosts file.${NC}"
fi

# Clean up
rm "$TEMP_HOSTS"
echo -e "${GREEN}✓ Temporary files cleaned up${NC}"
echo -e "${GREEN}✓ Original backup preserved at $BACKUP_HOSTS${NC}" 