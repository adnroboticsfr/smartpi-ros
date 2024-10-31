#!/bin/bash

# arguments: $RELEASE $LINUXFAMILY $BOARD $BUILD_DESKTOP
#
# This is the image customization script

# NOTE: It is copied to /tmp directory inside the image
# and executed there inside chroot environment
# so don't reference any files that are not already installed

# NOTE: If you want to transfer files between chroot and host
# userpatches/overlay directory on host is bind-mounted to /tmp/overlay in chroot
# The sd card's root path is accessible via $SDCARD variable.

# shellcheck enable=requires-variable-braces
# shellcheck disable=SC2034

RELEASE=$1
LINUXFAMILY=$2
BOARD=$3
BUILD_DESKTOP=$4

Main() {
    #case "${BOARD}" in
        #smartpad)
            #rotateConsole
            #rotateScreen
            #rotateTouch
            #disableDPMS
            #if [[ "${BUILD_DESKTOP}" = "yes" ]]; then
                #patchLightdm
                #copyOnboardConf
                #patchOnboardAutostart
                #installScreensaverSetup
            #fi
            #;;
    #esac

    # Ajout des commandes apt update et installation des dépendances
    sudo apt update
    sudo apt upgrade -y
    #sudo apt install -y \
        #ros-desktop-full-python-dev
}



Main "$@"
