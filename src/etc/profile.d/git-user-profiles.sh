#!/bin/bash
## git-profile-init - Select and initialize a git profile.
## Author: Kevin C. Krinke <kevin@krinke.ca>
## Copyright: GPLv2

# Present a whiptail menu, listing all profiles
# When the user selects a profile, export the env accordingly
# This script is intended to be sourced from ~/.bashrc as opposed
# to being ran directly as a normal command.

ENABLE_ON_BASH_LOGIN=0
[ -f /etc/default/git-user-profiles ] && source /etc/default/git-user-profiles
if [ $ENABLE_ON_BASH_LOGIN -eq 1 ]
then
    GUP_TMP_FILE="/tmp/gup-init.$$"
    # If there is a global profiles directory, do yes; else, no.

    if [ -d "${GIT_USER_PROFILES_PATH}" ]
    then
        menu_list=""
        for profile in $(/bin/ls -1 "${GIT_USER_PROFILES_PATH}" | sort -r)
        do
            menu_list="${profile} '' ${menu_list}"
        done
        whiptail --menu --noitem --clear "Select a GIT profile:" 20 40 10 ${menu_list} 2> "${GUP_TMP_FILE}"
        if [ $? -eq 0 ]
        then
            selected_profile=$(cat "${GUP_TMP_FILE}")
            echo "Selected GIT Profile: ${selected_profile}"
            export GUP_USER_NAME=""
            export GUP_USER_EMAIL=""
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
            fi
        else
            echo "Git profile selection was aborted."
        fi
        /bin/rm -f "${GUP_TMP_FILE}"
    fi
fi
