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

# Vendor dependencies in tools/yabridgectl
updateVendor () {
    cd tools/yabridgectl || exit 1
    cargo vendor > config.toml || exit 1
    # This sed will remove the git reference so it will stay an offline build
    # for Slackware 15 it will find reflink in the vendor directory
    # if its just "https://github.com/nicokoch/reflink"
    sed -i 's|git+\(https://github.com/nicokoch/reflink\).*|\1"]|' config.toml

    src="vendor"
    target="../../../../../cargo/vendor"
    checkDir "$src" "$target"

    src="config.toml"
    target="../../../../../cargo/CARGO_HOME/config.toml"
    checkFile "$src" "$target"

    cd ../../ || exit 1
}
