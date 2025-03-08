#!/usr/bin/env bash

# fetch all stories from Shortcut
stories=$(
  curl -X POST \
    -H "Content-Type: application/json" \
    -H "Shortcut-Token: $SHORTCUT_API_TOKEN" \
    -L "https://api.app.shortcut.com/api/v3/stories/search" \
    -d '{"workflow_state_types": ["backlog", "done", "started", "unstarted"]}'
)

# => [{shortcut_url: "", tracker_url: ""}, ... ]
urls=$(echo "${stories}" | jq 'map({shortcut_url: .app_url, tracker_url: .external_links[0]})')

# => { "(trackerid)": "(shortcuturl)", ... }
trackerid_to_shortcuturl=$(echo "${urls}" \
  | jq '. | map({(.tracker_url | capture("(?<id>[0-9]+)$").id): (.shortcut_url)}) | add '
)

echo "${trackerid_to_shortcuturl}"
