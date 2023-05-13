#!/bin/bash
# use the script like update.sh 5.0.5

cd "$(dirname "$0")" || exit 1; CWD=$(pwd)
wget -c -T 20 https://github.com/robbert-vdh/yabridge/archive/refs/tags/"$1".tar.gz
rm -fr yabridge-"$1"
tar xf "$1".tar.gz || exit 1
cd yabridge-"$1" || exit 1
checkAndPassHTML () {
    # make sure we see the same diff as on github
    (echo "diff $1.html ../html/$1.html"; diff "$1".html ../html/"$1".html) | less
    echo ""
    echo "Move new file over old? (y/N)"
    read -r ANS
    if [ "$ANS" == "y" ] || [ "$ANS" == "Y" ]; then
        echo "mv $1.html ../html/$1.html"
        mv "$1".html ../html/"$1".html || exit 1
    fi
}

generateNew () {
python3 -m gh_md_to_html "$1".md
cat ../patches/"$1".html.patch | patch -p1 --verbose || exit 1
checkAndPassHTML "$1"
}

# If you get an error from the README.md file
#
# pip uninstall emoji
# pip install emoji==1.7.0
echo -e "README.md\n"
generateNew README
echo -e "CHANGELOG.md\n"
generateNew CHANGELOG
echo -e "ROADMAP.md\n"
generateNew ROADMAP
echo -e "docs/architecture.md\n"
cp docs/architecture.md .
generateNew architecture
echo -e "tools/yabridgectl/README.md\n"
cp tools/yabridgectl/README.md README-yabridgectl.md
generateNew README-yabridgectl

cd tools/yabridgectl || exit 1
cargo vendor
# make sure cargo vendor output config.toml like this

# [source.crates-io]
# replace-with = "vendored-sources"
#
# [source."git+https://github.com/nicokoch/reflink?rev=e8d93b465f5d9ad340cd052b64bbc77b8ee107e2"]
# git = "https://github.com/nicokoch/reflink"
# rev = "e8d93b465f5d9ad340cd052b64bbc77b8ee107e2"
# replace-with = "vendored-sources"
#
# [source.vendored-sources]
# directory = "vendor"

# notice, we need to change https://github.com/nicokoch/reflink so cargo wont try to download from github.com

# -[source."git+https://github.com/nicokoch/reflink?rev=e8d93b465f5d9ad340cd052b64bbc77b8ee107e2"]
# +[source."https://github.com/nicokoch/reflink"]

(echo "diff vendor ../../../cargo/vendor"; diff -qr vendor ../../../cargo/vendor; echo ""; diff -r vendor ../../../cargo/vendor) | less
echo ""
echo "Move new vendor directory to replace old? (y/N)"
read -r ANS
if [ "$ANS" == "y" ] || [ "$ANS" == "Y" ]; then
    echo "rm -fr ../../../cargo/vendor"
    echo "mv vendor ../../../cargo/vendor"
    rm -fr ../../../cargo/vendor
    mv vendor ../../../cargo/vendor || exit 1
fi
cd $CWD
rm -fr "$1".tar.gz*
rm -fr yabridge-"$1"
