#!/bin/bash

# Script to generate self-signed SSL certificates for development
# Usage: ./scripts/generate_cert.sh

CERT_DIR="priv/cert"

# Create directory if it doesn't exist
mkdir -p $CERT_DIR

# Generate self-signed certificate valid for 365 days
openssl req -new -newkey rsa:4096 -days 365 -nodes -x509 \
  -subj "/C=US/ST=State/L=City/O=Organization/CN=localhost" \
  -keyout $CERT_DIR/key.pem \
  -out $CERT_DIR/cert.pem

echo "Self-signed certificate generated successfully!"
echo "Key file: $CERT_DIR/key.pem"
echo "Certificate file: $CERT_DIR/cert.pem" 