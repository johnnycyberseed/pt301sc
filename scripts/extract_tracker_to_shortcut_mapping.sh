#!/usr/bin/env bash

# If SHORTCUT_API_TOKEN is not set, exit
if [ -z "$SHORTCUT_API_TOKEN" ]; then
  echo "Error: SHORTCUT_API_TOKEN environment variable is not set"
  cat <<EOF

  This script uses the Shortcut API to fetch stories.
  To do so, it needs a Shortcut API token from an account with access to those stories.

  Please set SHORTCUT_API_TOKEN to your Shortcut API token
  You can get it from https://app.shortcut.com/settings/account/api-tokens

  For your convenience, if you save your token in a 1Password API Credential item named "shortcut-api-token",
  You can set the SHORTCUT_API_TOKEN environment variable by running:

    $ source scripts/set_shortcut_token.bash

  Example:

    $ export SHORTCUT_API_TOKEN=<your-api-token>
    $ ./scripts/extract_tracker_to_shortcut_mapping.sh

EOF
  exit 1
fi

# Fetch all stories from Shortcut
#   (since we're querying for all of the possible workflow states, this should get all stories)
stories=$(
  curl -X POST \
    -H "Content-Type: application/json" \
    -H "Shortcut-Token: ${SHORTCUT_API_TOKEN}" \
    -L "https://api.app.shortcut.com/api/v3/stories/search" \
    -d '{"workflow_state_types": ["backlog", "done", "started", "unstarted"]}'
)

# Extract the URLs from the stories JSON.
# => [{shortcut_url: "", tracker_url: ""}, ... ]
#
# Assumes that every Shortcut story's first "external link" is the Pivotal Tracker URL.
# - this is true if you imported your Tracker stories via https://github.com/useshortcut/api-cookbook/tree/main/pivotal-import
urls=$(echo "${stories}" | jq 'map({shortcut_url: .app_url, tracker_url: .external_links[0]})')

# Transform into the format expected by the pt301sc application.
# => { "(trackerid)": "(shortcuturl)", ... }
trackerid_to_shortcuturl=$(echo "${urls}" \
  | jq '. | map({(.tracker_url | capture("(?<id>[0-9]+)$").id): (.shortcut_url)}) | add '
)

echo "${trackerid_to_shortcuturl}"
