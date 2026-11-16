#!/usr/bin/env bash
# Automated git bisect runner
git bisect start HEAD v1.0.0
git bisect run npm test
