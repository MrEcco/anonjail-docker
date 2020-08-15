#!/bin/bash
# set -x
set -e

# Remove default gateways
/usr/local/bin/strict.py

# Add new default gateway
DEFAULT_GATEWAY=${DEFAULT_GATEWAY:-169.254.1.4}
ip ro add 0.0.0.0/0 via ${DEFAULT_GATEWAY}

exec $@
