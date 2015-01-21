#!/bin/bash

if [ -z "$1" ]
then

    echo "Rebuilding existing package. Specify a v0.0.0 version in order to tag and build a new version."
    
else

    next_tag="$1"
    last_tag=$(git tag | sort -V -r | egrep -v "^${next_tag}\s\$" | head -1)
    next_ver=$(echo "${next_tag}" | perl -pe 's/^v//')
    echo "Updating debian changelog... v${next_ver}"
    git-dch --ignore-branch --full --spawn-editor=snapshot --git-author --release --since ${last_tag} --new-version ${next_ver}
    git commit -a -m "Debian version bump to: ${next_ver}"
    git tag "${next_tag}"
    echo "Don't forget to \"git push origin --tags\""

fi

echo "Building debian package..."
dpkg-buildpackage -rfakeroot -tc -us -uc
echo "Process complete. Check ../ for the packages."
