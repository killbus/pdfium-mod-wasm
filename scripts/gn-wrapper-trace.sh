#!/usr/bin/env bash
# Wrapper trace script - wraps gn to show call stack
set -x
export PS4='+(${BASH_SOURCE}:${LINENO}): ${FUNCNAME[0]:+${FUNCNAME[0]}(): }'

echo "[GN TRACE] Called with args: $@" >&2
echo "[GN TRACE] PWD: $PWD" >&2
echo "[GN TRACE] SHLVL: $SHLVL" >&2
echo "[GN TRACE] Calling real gn..." >&2

# Call real gn
exec /opt/depot-tools/gn.real "$@"
