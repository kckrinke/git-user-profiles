#!/bin/bash
next_ver=""

function revert_build () {
    read -p "Press <ENTER> to revert, <CTRL+c> to abort." JUNK
    git reset $(git log HEAD~1 | head -1 | awk {'print $2'})
    git diff debian/changelog | patch -R -p1
    git tag -d $(git tag | sort -V -r | head -1)
    git clean -f -d
    return 0
}

# if the first cli argument is ZERO characters (-z)
if [ -z "$1" ]
then
    cat - <<EOF
################################################################
# Rebuilding package for the existing codebase checkout.
#
# This uses the same debian package changelog and version number
# even though the actual code may have changed. If you want to
# build a specific version, please do a "git checkout <tag>"
# where <tag> is the named tag of the prior build.
#
# Specify a tag name in order to tag and build a new version.
# ie: ./$(basename "$0") v1.2.3
################################################################

EOF
    read -p "Press <ENTER> to continue, <CTRL+c> to stop." JUNK
else
    # first argument is not blank, check...
    case "$1" in
        "--revert") revert_build; exit $?;;
        *)
            # Everything else is assumed to be a vN.N.N format
            # version tag.
            cat - <<EOF
################################################################
# Building new package ${1}.
#
# This generates the debian/changelog from git commit history,
# commits the changelog update and tags the release. From there
# we try to actually build the package. If the package fails,
# the build script will try to revert the changelog and tag
# commit.
#
################################################################

EOF
            read -p "Press <ENTER> to continue, <CTRL+c> to stop." JUNK
            # actually do the changelog/tagging steps
            next_tag="$1"
            last_tag=$(git tag | sort -V -r | egrep -v "^${next_tag}\s*\$" | head -1)
            next_ver=$(echo "${next_tag}" | perl -pe 's/^v//')
            echo "Updating debian changelog... v${next_ver}"
            git-dch --ignore-branch --full --spawn-editor=snapshot \
                    --git-author --release --since ${last_tag} \
                    --new-version ${next_ver}
            if [ -z "${GUP_USER_SKEY}" ]
            then
                git commit -a -m "Debian version bump to: ${next_ver}"
                git tag "${next_tag}"
            else
                git commit -a --signoff --gpg-sign="${GUP_USER_SKEY}" \
                    -m "Debian version bump to: ${next_ver}"
                git tag -u "${GUP_USER_SKEY}" \
                    -m "Debian version bump to: ${next_ver}" \
                    "${next_tag}"
            fi
            ;;
    esac
fi

build_rv=254
if [ -z "${GUP_USER_SKEY}" ]
then
    echo "Building debian package..."
    dpkg-buildpackage -rfakeroot -tc -us -uc
    build_rv=$?
else
    read -p "Press <ENTER> to start packaging, <CTRL+c> to stop." JUNK
    echo "Building signed debian package..."
    dpkg-buildpackage \
        -rfakeroot -tc -us \
        -k"${GUP_USER_SKEY}"
    build_rv=$?
fi
if [ ${build_rv} -ne 0 -a -n "${next_ver}" ]
then
    cat - <<EOF
################################################################
#
# The build failed. Going to try to revert the packaging
# changes (such as git tags, debian/changelog, etc).
#
# The following is a listing of existing tags:
#  $(git tag | sort -V -r | perl -pe 's/\s+$/, /g;' | sed -e 's/, $//')
#
################################################################

EOF
    revert_build
else
    # get the next_ver if it's not already there
    [ -z "${next_ver}" ] && \
        next_ver=$(git tag | sort -V -r | head -1 | sed -e 's/^v//')
    echo "Process complete, packages..."
    ls -1 ../*${next_ver}*deb
fi
