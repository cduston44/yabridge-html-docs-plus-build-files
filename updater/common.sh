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

# Run the diff command with the first argument as the new file
# and the second argument as the old file
# Capture the exit status of the diff command
# Check the exit status
diffFile() {
    echo "diff $1 $2"

    if [[ ! -f $2 ]]; then
        return 0
    fi

    diff "$1" "$2"
    status=$?

    if [ $status -eq 0 ]; then
        return 0  # Files are identical
    elif [ $status -eq 1 ]; then
        return 1  # Files differ
    else
        echo "An error occurred with diff" >&2
        exit 1
    fi
}


# Ask to move the file specified in the first argument
# and move it to the second argument if the user confirms
moveNewFile () {
    echo ""
    echo "Move new file over old? (y/N)"

    read -r ANS

    if [ "$ANS" == "y" ] || [ "$ANS" == "Y" ]; then
        install -vD "$1" "$2" || exit 1
    fi
}


# Compare the directories specified in the first and second arguments
# first argument is the new file second is the old 
# using diff -qr for a quick comparison
# Capture the exit status
# If the directories differ, show the detailed differences with diff -r
diffDir() {
    echo "diff $1 $2"

    if [[ ! -f $2 ]]; then
        return 0
    fi

    diff -qr "$1" "$2"
    status=$?

    if [ $status -eq 0 ]; then
        return 0  # Directories are identical
    elif [ $status -eq 1 ]; then
        echo ""
        diff -r "$1" "$2"
        return 1  # Directories differ
    else
        echo "An error occurred with diff" >&2
        exit 1
    fi
}


# Ask to move the new directory specified in the first argument
# to replace the old directory specified in the second argument
# Remove the old directory before moving the new one
moveNewDir () {
    echo ""
    echo "Move new vendor directory to replace old? (y/N)"
    read -r ANS
    if [ "$ANS" == "y" ] || [ "$ANS" == "Y" ]; then
        rm -vfr "$2"
        install -vD "$1" "$2" || exit 1
    fi
}


# This check if target do differ or don't exist
# before asking to move the file or just force
# move it while creating the missing directories
checkDir () {
    if ! diffDir "$1" "$2"; then
        moveNewDir "$1" "$2"
    else
        mkdir -p "$2"
        mv "$1"/* "$2"
    fi
}


checkFile () {
    if ! diffFile "$1" "$2"; then
        moveNewFile "$1" "$2"
    else
        install -vD "$1" "$2" || exit 1
    fi
}
