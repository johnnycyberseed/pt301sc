#!/bin/bash
# Enable xtrace to show commands as they're executed
set -x

# Ensure dependencies are installed
mix deps.get

# Ensure there is an SSL certificate (to service HTTPS requests)
[ -f "priv/cert/cert.pem" ] && [ -f "priv/cert/key.pem" ] || ./scripts/generate_cert.sh

# Start the application
PT301SC_HTTP_PORT=80 PT301SC_HTTPS_PORT=443 mix run --no-halt 