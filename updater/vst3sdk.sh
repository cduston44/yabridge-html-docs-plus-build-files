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

# No globals in source files only functions
# No globals here
# shellcheck source=updater/common.sh
. common.sh

vst3sdkDownloader () {
    rm -rf vst3sdk
    if ! git clone https://github.com/robbert-vdh/vst3sdk.git; then
        echo "Git clone failed"
        exit 1
    fi

    cd vst3sdk || exit 1
    git submodule update --init --recursive || exit 1
    git submodule status || exit 1

    rm -rf .git .gitmodules index.html \
        CHANGES.md README.md \
        VST3_License_Agreement.pdf \
        VST3_Usage_Guidelines.pdf

}

updateVst3sdk () {
    vst3sdkDownloader
    cd .. || exit 1
    checkDir "vst3sdk" "../../vst3sdk"
}
