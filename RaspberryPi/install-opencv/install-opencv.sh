#!/bin/bash
###############################################################################
# Script to compile and install eibd on a debian jessie (8) based systems
# 
# Liam Shi zilongshi@gmail.com
# 2016-09-27
# Useage:
#     sudo -u root bash installOpenCV.sh <version>
# Changes:
#
# License: GPLv2
###############################################################################

if [ "$EUID" -ne 0 ]; then
   echo "     Attention!!!"
   echo "     Start script must run as super user" 1>&2
   echo "     Start a root shell with"
   echo "     sudo -u root bash $0 <version>"
   exit 1
fi

if [ $# -eq 0 ]; then
    echo "Please type your version message."
    exit 1
fi

export DEBIAN_FRONTEND=noninteractive



VERSION=$1
export USER_HOME="$(eval echo ~${SUDO_USER})"
export BUILD_PATH=$USER_HOME"/OpenCV"
export OPENCV_PATH=$BUILD_PATH'/opencv-'$VERSION
export OPENCV_CONTRIB_PATH=$BUILD_PATH'/opencv_contrib-'$VERSION


executeNormal() {
    echo "---> Execute : [$1]"
    /usr/bin/sudo -i -u $SUDO_USER bash -c "$1"
}

prepareEnvironment() {

    echo "Prepare our environment..."
    echo "--- create $BUILD_PATH directory"

    command='mkdir '$BUILD_PATH
    echo "Create $BUILD_PATH using "$command
    executeNormal "$command"
}

enternceEnvironment() {
    cd $BUILD_PATH
    echo "Enternce $(pwd)"
    # detect the file existed or not [TODO]
}

proceedFile() {
    echo "Starting proceeding [$1]..."

    echo "--- Downloading file: $1"
    command='wget -O '$2'.zip -q --show-progress '$1
    executeNormal "$command"
    command='unzip '$2'.zip -d '$BUILD_PATH
    executeNormal "$command"
    echo "--- Proceeding file finished."
    echo "Finished proceeding [$1]"
}

prepareVirtualEnv() {

    wget https://bootstrap.pypa.io/get-pip.py
    python get-pip.py
    pip install virtualenv virtualenvwrapper

    rm -rf $USER_HOME/.cache/pip
    echo "--- Parenttask finished"

    command="/bin/bash $USER_HOME/set-virtualenv.sh $USER_HOME $BUILD_PATH $OPENCV_PATH $OPENCV_CONTRIB_PATH"
    executeNormal "$command"
}


installOpenCV() {
    echo "--- Parenttask [installOpenCV] started in : $(pwd)"

    source $USER_HOME/.profile
    workon cv

    cd $OPENCV_PATH
    cd build
    make install
    ldconfig

    mv /usr/local/lib/python3.4/site-packages/cv2.cpython-34m.so /usr/local/lib/python3.4/site-packages/cv2.so
    
    command="ln -s -f /usr/local/lib/python3.4/site-packages/cv2.so $USER_HOME/.virtualenvs/cv/lib/python3.4/site-packages/cv2.so"
    executeNormal "$command"
    echo "--- Parenttask [installOpenCV] ended in : $(pwd)"
}

installDependency() {
    echo "--- Installing dependency: $*"
    apt-get -q -y install $*
}

installPackages() {
    echo "--- Delete the Wolfram engine"
    apt-get purge wolfram-engine -y

    echo "--- Update Operation "
    apt-get update
    apt-get upgrade -y -q


    # echo "--- Removing any pre-installed ffmpeg and x264"
    # apt-get -qq remove ffmpeg x264 libx264-dev


    # Install a few developer tools
    installDependency build-essential git cmake pkg-config

    # Now we can move on to installing image I/O packages which allow us to load image file formats such as JPEG, PNG, TIFF, etc.:
    installDependency libjpeg-dev libtiff5-dev libjasper-dev libpng12-dev

    # Just like we need image I/O packages, we also need video I/O packages. These packages allow us to load various video file formats as well as work with video streams:
    installDependency libavcodec-dev libavformat-dev libswscale-dev libv4l-dev
    installDependency libxvidcore-dev libx264-dev

    # We need to install the GTK development library so we can compile the highgui  sub-module of OpenCV, which allows us to display images to our screen and build simple GUI interfaces:
    installDependency libgtk2.0-dev

    # Various operations inside of OpenCV (such as matrix operations) can be optimized using added dependencies:
    installDependency libatlas-base-dev gfortran

    # We’ll need to install the Python 2.7 and Python 3 header files so we can compile our OpenCV + Python bindings:
    installDependency python2.7-dev python3-dev

    installDependency libopencv-dev checkinstall yasm libdc1394-22-dev libxine2-dev libgstreamer0.10-dev libgstreamer-plugins-base0.10-dev python-dev python-numpy libtbb-dev libqt4-dev libfaac-dev libmp3lame-dev libopencore-amrnb-dev libopencore-amrwb-dev libtheora-dev libvorbis-dev libxvidcore-dev x264 v4l-utils unzip
    #installDependency ffmpeg

}

# ==================================================================================

installPackages

# ==================================================================================

echo "Current user  path is : $USER_HOME"
echo "Current build path is : $BUILD_PATH"
# echo $OPENCV_PATH
# echo $OPENCV_CONTRIB_PATH

OPENCV_ARCHIVE_URL="https://github.com/opencv/opencv/archive"
OPENCV_CONTRIB_ARCHIVE_URL="https://github.com/Itseez/opencv_contrib/archive"

# Using direct url method
OPENCV_ZIPBALL="$OPENCV_ARCHIVE_URL/$VERSION.zip"
OPENCV_TARBALL="$OPENCV_ARCHIVE_URL/$VERSION.tar.gz"

# Using direct url method
OPENCV_CONTRIB_ZIPBALL="$OPENCV_CONTRIB_ARCHIVE_URL/$VERSION.zip"
OPENCV_CONTRIB_TARBALL="$OPENCV_CONTRIB_ARCHIVE_URL/$VERSION.tar.gz"


if [ ! -d $BUILD_PATH ]; then
    echo "--- OpenCV directory not existed."
    prepareEnvironment
    enternceEnvironment
else
    echo "--- Enternce OpenCV directory."
    enternceEnvironment
fi

# OPENCV_API_URL="https://api.github.com/repos/opencv/opencv/releases"
# OPENCV_CONTRIB_API_URL="https://api.github.com/repos/opencv/opencv_contrib/releases"

# Using github api method
# OPENCV_ZIPBALL="$(curl -s $OPENCV_API_URL | grep zipball_url | cut -d '"' -f 4 | grep $VERSION'$')"
# OPENCV_TARBALL="$(curl -s $OPENCV_API_URL | grep tarball_url | cut -d '"' -f 4 | grep $VERSION'$')"

# Using github api method
# OPENCV_CONTRIB_ZIPBALL="$(curl -s $OPENCV_CONTRIB_API_URL | grep zipball_url | cut -d '"' -f 4 | grep $VERSION'$')"
# OPENCV_CONTRIB_TARBALL="$(curl -s $OPENCV_CONTRIB_API_URL | grep tarball_url | cut -d '"' -f 4 | grep $VERSION'$')"


proceedFile $OPENCV_ZIPBALL opencv
proceedFile $OPENCV_CONTRIB_ZIPBALL opencv_contrib

prepareVirtualEnv

installOpenCV
