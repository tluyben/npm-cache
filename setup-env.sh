#!/bin/bash

# Setup script for Local NPM Cache Registry
# Source this file to configure your shell environment

echo "Configuring NPM to use local registry..."

# Check if the server is running
if ! curl -s http://localhost:4873 > /dev/null 2>&1; then
    echo "WARNING: Local registry server doesn't appear to be running!"
    echo "Start it with: ./npm-cache/serve"
    echo ""
fi

# Set environment variable
export NPM_CONFIG_REGISTRY=http://localhost:4873/

echo "✓ NPM_CONFIG_REGISTRY set to http://localhost:4873/"
echo ""
echo "Current registry: $(npm config get registry)"
echo ""
echo "To make this persistent, run:"
echo "  npm config set registry http://localhost:4873/"
echo ""
echo "To revert to default NPM registry:"
echo "  unset NPM_CONFIG_REGISTRY"
echo "  npm config delete registry"
