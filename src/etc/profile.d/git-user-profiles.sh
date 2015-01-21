#!/bin/bash
## git-profile-init - Select and initialize a git profile.
## Author: Kevin C. Krinke <kevin@krinke.ca>
## Copyright: GPLv2

# Present a whiptail menu, listing all profiles
# When the user selects a profile, export the env accordingly
# This script is intended to be sourced from ~/.bashrc as opposed
# to being ran directly as a normal command.

GUP_TMP_FILE="/tmp/gup-init.$$"
ENABLE_ON_BASH_LOGIN=0
[ -f /etc/default/git-user-profiles ] && source /etc/default/git-user-profiles
if [ $ENABLE_ON_BASH_LOGIN -eq 1 ]
then
    # If there is a global profiles directory, do yes; else, no.
    if [ -d "${GIT_USER_PROFILES_PATH}" ]
    then
        menu_list=""
        for profile in $(/bin/ls -1 "${GIT_USER_PROFILES_PATH}" | sort -r)
        do
            menu_list="${profile} '' ${menu_list}"
        done
        whiptail --menu --noitem --clear "Select a GIT profile:" 12 40 5 ${menu_list} 2> "${GUP_TMP_FILE}"
        if [ $? -eq 0 ]
        then
            selected_profile=$(cat "${GUP_TMP_FILE}")
            echo "Selected GIT Profile: ${selected_profile}"
            export GUP_CURRENT=""
            export GUP_USER_NAME=""
            export GUP_USER_EMAIL=""
            export GUP_USER_SKEY=""
            source "${GIT_USER_PROFILES_PATH}/${selected_profile}"
            if [ -n "${GUP_USER_NAME}" -a -n "${GUP_USER_EMAIL}" ]
            then
                export GUP_ENV_EXISTS=1
            else
                export GUP_ENV_EXISTS=0
            fi
            if [ $GUP_ENV_EXISTS -eq 0 ]
            then
                echo "Failed to source GIT User Profiles environment variables!" 1>&2
            else
                export GUP_CURRENT="${selected_profile}"
            fi
        else
            echo "Git profile selection was aborted."
        fi
    fi
fi
/bin/rm -f "${GUP_TMP_FILE}"
# Simple alias to re-source this profile in an existing session regardless if
# it's enabled on bash login or not.
alias git-user-profiles-select='source /etc/profile.d/git-user-profiles.sh'
