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

# Generate html file from md files
# patch them and move to ../../../html/
generateNew () {
    patch_file="$1.md"
    patch="../../patches/$1.html.patch"
    python3 -m gh_md_to_html "$patch_file" || exit 1
    patch -p1 -F5 --verbose < "$patch" || exit 1

    file_from="$1.html"
    file_to="../../../html/$file_from"
    checkFile "$file_from" "$file_to"
}

# Update README and other documents
# You can add other md files here
# also add a patch for them in ../../patches/
updateHtml () {
    echo "Generate README.html from README.md"
    generateNew README

    echo "Generate CHANGELOG.html from CHANGELOG.md"
    generateNew CHANGELOG

    echo "Generate ROADMAP.html from ROADMAP.md"
    generateNew ROADMAP

    echo "Generate architecture.html from docs/architecture.md"
    cp -v docs/architecture.md .
    generateNew architecture

    echo "Generate README-yabridgectl.html from tools/yabridgectl/README.md"
    cp -v tools/yabridgectl/README.md README-yabridgectl.md
    generateNew README-yabridgectl

    from="github-markdown-css/github-css.css"
    to="../../../html/files/github-css.css"
    checkFile "$from" "$to"

    from="images/screenshot.png"
    to="../../../html/files/screenshot.png"
    checkFile "$from" "$to"
}
