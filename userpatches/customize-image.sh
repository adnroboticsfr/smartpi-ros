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
    # Ajout des commandes apt update et installation des dépendances
    sudo apt update && sudo apt upgrade -y
    sudo apt install -y curl gnupg2 lsb-release catkin v4l-utils libv4l-dev python3-cv-bridge python3-smbus
    sudo apt install gstreamer1.0-plugins-base gstreamer1.0-plugins-good gstreamer1.0-plugins-bad gstreamer1.0-plugins-ugly
    sudo apt install -y ros-desktop-full-python-dev
    sudo apt install -y python3-rosinstall python3-rosinstall-generator python3-wstool build-essential
    sudo apt install python3-rosdep2 rosbash ros-shape-msgs ros-geometry-msgs ros-cmake-modules ros-image-publisher \
                ros-perception-lisp-dev ros-desktop-full-lisp-dev ros2-test-interface-files ros-image-proc \
                ros-mk ros-roscpp-msg ros-image-view ros-std-msgs ros-topic-tools-srvs ros-environment ros-core-lisp-dev \
                ros-std-srvs ros-trajectory-msgs rospack-tools ros-nav-msgs ros-base-dev ros-robot-dev rosegarden \
                ros-perception-python-dev ros-viz rosout ros-perception ros-simulators-dev \
                ros-core-rosbuild-dev ros-simulators-python-dev rosbuild ros-message-generation ros-core ros-stereo-msgs \
                ros-stereo-image-proc ros-image-rotate ros-robot-state-publisher ros-visualization-msgs ros-move-base-msgs \
                ros-pcl-msgs ros-opencv-apps ros-desktop-dev ros-robot-lisp-dev ros-base-lisp-dev ros-map-msgs \
                ros-actionlib-msgs ros-rosgraph-msgs rosdiagnostic ros-desktop-full-python-dev ros-sensor-msgs ros-robot \
                roslang ros-simulators-lisp-dev ros-diagnostic-msgs ros-robot-python-dev ros-viz-dev \
                ros-core-dev roslisp ros-tf2-msgs ros-desktop-lisp-dev ros-perception-dev ros-camera-calibration
    sudo apt install libpcl-ros*
    # Ajout SmartPI-GPIO
    sudo apt update 
    sudo apt-get install -y python3-dev python3-pip libjpeg-dev zlib1g-dev libtiff-dev
    sudo mv /usr/lib/python3.11/EXTERNALLY-MANAGED /usr/lib/python3.11/EXTERNALLY-MANAGED.old
    git clone https://github.com/ADNroboticsfr/smartpi-gpio.git
    cd smartpi-gpio
    sudo python3 setup.py sdist bdist_wheel
    sudo pip3 install dist/smartpi_gpio-1.0.0-py3-none-any.whl
    cd ~/catkin_ws/src
    catkin_init_workspace
    git clone https://github.com/ros/geometry2.git
    git clone https://github.com/ros/media_export
    git clone https://github.com/adnroboticsfr/USB-Camera-Node-ROS.git
    if [ -f /etc/ros/rosdep/sources.list.d/20-default.list ]; then
        sudo rm /etc/ros/rosdep/sources.list.d/20-default.list
    fi
    sudo rosdep init
    rosdep update
    WORKSPACE_DIR=~/catkin_ws
    mkdir -p $WORKSPACE_DIR/src
    cd $WORKSPACE_DIR
    rosdep install --from-paths src --ignore-src -r -y
    catkin_make
    echo "source /home/pi/$WORKSPACE_DIR/devel/setup.bash" >> ~/.bashrc
    source ~/.bashrc
    sudo apt auto remove
    copyOnboardConf
    patchOnboardAutostart
}

copyOnboardConf() {
    echo "Copy onboard default configuration ..."
    mkdir -p /etc/onboard
    cp -v /tmp/overlay/onboard-defaults.conf /etc/onboard/
    echo "Copy onboard default configuration ... [DONE]"
}

patchOnboardAutostart() {
    local conf
    conf="/etc/xdg/autostart/onboard-autostart.desktop"
    echo "Patch Onboard Autostart file ..."
    sed -i '/OnlyShowIn/s/^/# /' "${conf}"
    echo "Patch Onboard Autostart file ... [DONE]"
}


Main "$@"
