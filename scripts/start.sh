#!/bin/bash
# Enable xtrace to show commands as they're executed
set -x

# Ensure there is an SSL certificate (to service HTTPS requests)
[ -f "priv/cert/cert.pem" ] && [ -f "priv/cert/key.pem" ] || ./scripts/generate_cert.sh

# Start the application
mix run --no-halt 