#!/bin/bash

set -e
set -u

GIT_HASH=$(git rev-parse --short HEAD)
GIT_BRANCH=$(git rev-parse --abbrev-ref HEAD)

cat <<-EOF
#define YMGitCommitHash @"$GIT_HASH"
#define YMGitBranchName @"$GIT_BRANCH"
EOF
