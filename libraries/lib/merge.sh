#!/usr/bin/env bash
#
# Combine per-architecture static libraries into a single universal (fat) .a.
#
# The vendored libraries in this directory were produced by building each
# dependency (libtransmission, openssl, curl, libevent, ...) separately per
# architecture and then merging the slices with `lipo`. This helper automates
# that final merge step.
#
# Usage:
#   ./merge.sh <lib-name> <arch-dir-1> <arch-dir-2> [<arch-dir-n> ...]
#
# Example (merge a device build and an x86_64 build of libtransmission):
#   ./merge.sh transmission ./build/arm64/lib ./build/x86_64/lib
#
# Produces ./lib<lib-name>.a in the current directory. Input libraries are
# left untouched.
set -euo pipefail

if [ "$#" -lt 3 ]; then
  echo "usage: $0 <lib-name> <arch-dir-1> <arch-dir-2> [<arch-dir-n> ...]" >&2
  exit 1
fi

name="$1"
shift

inputs=()
for dir in "$@"; do
  inputs+=("${dir%/}/lib${name}.a")
done

lipo -create "${inputs[@]}" -output "./lib${name}.a"
echo "created ./lib${name}.a"
