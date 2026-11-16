#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

cleanup() { echo 'Cleaning temporary assets...'; }
trap cleanup EXIT
