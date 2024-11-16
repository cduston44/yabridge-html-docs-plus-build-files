#!/bin/bash

# Slackware build script for yabridge

# Copyright 2024 Martin Bångens Sweden
# All rights reserved.
#
# Redistribution and use of this script, with or without modification, is
# permitted provided that the following conditions are met:
#
# 1. Redistributions of this script must retain the above copyright
#    notice, this list of conditions and the following disclaimer.
#
#  THIS SOFTWARE IS PROVIDED BY THE AUTHOR "AS IS" AND ANY EXPRESS OR IMPLIED
#  WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
#  MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.  IN NO
#  EVENT SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
#  SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
#  PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS;
#  OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
#  WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR
#  OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
#  ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

# Function to show help
usage() {
    echo "Usage: $0 [--tag TAG | --hash COMMIT_HASH]"
    echo "  --tag TAG           Fetch the specified tag (default if no option is provided)"
    echo "  --hash COMMIT_HASH  Fetch the repository at a specific commit hash"
    echo "  -h, --help          Show this help message"
    echo ""
    echo "Note:"
    echo "  If you encounter the following error:"
    echo "  'AttributeError: module 'emoji' has no attribute 'EMOJI_ALIAS_UNICODE_ENGLISH',"
    echo "  please install the 'emoji' version 1.7.0 by running:"
    echo "  'pip install emoji==1.7.0'"
    echo ""
    exit 1
}

# Check for help option
if [[ "$1" == "-h" || "$1" == "--help" ]]; then
    usage
fi

# Parse command line arguments
TAG=""
HASH=""
while [[ $# -gt 0 ]]; do
    case "$1" in
        --tag)
            TAG="$2"
            shift 2
            ;;
        --hash)
            HASH="$2"
            shift 2
            ;;
        *)
            echo "Unknown option: $1"
            usage
            ;;
    esac
done

# Default to using the tag if neither tag nor hash is provided
if [[ -z "$TAG" && -z "$HASH" ]]; then
    echo "No tag or hash provided. Using the tag argument." >&2
    usage
fi

# Determine which URL to download based on the provided argument
if [[ -n "$TAG" ]]; then
    DOWNLOAD_URL="https://github.com/robbert-vdh/yabridge/archive/refs/tags/$TAG.tar.gz"
elif [[ -n "$HASH" ]]; then
    DOWNLOAD_URL="https://github.com/robbert-vdh/yabridge/archive/$HASH.tar.gz"
else
    echo "Error: You must specify either a tag or a commit hash." >&2
    usage
fi

# Generate tar and dir names
if [[ -n "$TAG" ]]; then
    DIR_NAME="yabridge-$TAG"
    TAR_NAME="$TAG.tar.gz"
elif [[ -n "$HASH" ]]; then
    DIR_NAME="yabridge-$HASH"
    TAR_NAME="$HASH.tar.gz"
fi

# No globals in source files only functions
# shellcheck source=updater/common.sh
. updater/common.sh
# shellcheck source=updater/downloader.sh
. updater/downloader.sh
# shellcheck source=updater/html.sh
. updater/html.sh
# shellcheck source=updater/vst3sdk.sh
. updater/vst3sdk.sh
# shellcheck source=updater/cargo.sh
. updater/cargo.sh

# Start the update process
cd "$(dirname "$0")" || exit 1; CWD=$(pwd)

cd "$CWD/updater/tmp/" || exit 1
downloadSource "$TAR_NAME" "$DIR_NAME" "$DOWNLOAD_URL"
cd "$DIR_NAME" || exit 1
updateHtml
updateVendor

# change to vst3sdk repo
cd .. || exit 1
updateVst3sdk

