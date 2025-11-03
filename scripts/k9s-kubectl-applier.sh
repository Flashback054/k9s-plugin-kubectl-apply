#!/bin/bash

set -e

# Get variables from k9s env
CONTEXT="$1"
KUBECONFIG_FILE="$2"

# Create tmp file
tmpfile=$(mktemp /tmp/k9s-apply-XXXXXX).yaml
# Cleanup tmp file at the end
trap "rm -f '$tmpfile'" EXIT

# Record checksum before editing
orig_sum=$(sha256sum "$tmpfile" | awk '{print $1}')

# Open the editor
${EDITOR:-vim} "$tmpfile"

# Check if user wrote anything (file not empty)
if [ ! -s "$tmpfile" ]; then
	echo "Empty yaml"
	exit 0
fi

# Compare checksum before and after editing
new_sum=$(sha256sum "$tmpfile" | awk '{print $1}')

if [ "$orig_sum" = "$new_sum" ]; then
	echo "Yaml not changed"
	exit 0
fi

# Apply using the same kubeconfig and context as k9s.
kubectl --kubeconfig "$KUBECONFIG_FILE" --context "$CONTEXT" apply -f "$tmpfile" --warnings-as-errors



