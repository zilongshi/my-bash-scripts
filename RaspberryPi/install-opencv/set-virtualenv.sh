#!/bin/bash
###############################################################################
# Script to compile and install eibd on a debian jessie (8) based systems
# 
# Liam Shi zilongshi@gmail.com
# 2016-09-27
# Changes:
#
# License: GPLv2
###############################################################################

if [ "$EUID" -ne 1000 ]; then
   echo "     Start a subtask of sudo"
   echo "     Execute $0 USER_HOME BUILD_PATH OPENCV_PATH OPENCV_CONTRIB_PATH"
   exit 1
fi

if [ $# -eq 0 ]; then
    echo "Please type your arguments."
    echo "Execute $0 USER_HOME BUILD_PATH OPENCV_PATH OPENCV_CONTRIB_PATH"
    exit 1
fi

USER_HOME=$1
BUILD_PATH=$2
OPENCV_PATH=$3
OPENCV_CONTRIB_PATH=$4

echo "--- Subtask HOME directory is : $USER_HOME"
echo "--- Subtask BUILD_PATH directory is : $BUILD_PATH"
echo "--- Subtask OPENCV_PATH directory is : $OPENCV_PATH"
echo "--- Subtask OPENCV_CONTRIB_PATH directory is : $OPENCV_CONTRIB_PATH"
echo "--- Subtask started in : $(pwd)"

rm -rf $USER_HOME/.cache/pip

echo -e "\n# virtualenv and virtualenvwrapper" >> $USER_HOME/.profile
echo "export WORKON_HOME=$USER_HOME/.virtualenvs" >> $USER_HOME/.profile
echo "source /usr/local/bin/virtualenvwrapper.sh" >> $USER_HOME/.profile

source $USER_HOME/.profile
mkvirtualenv cv -p python3

source $USER_HOME/.profile
workon cv

pip install numpy

cd $OPENCV_PATH
mkdir build
cd build
cmake -D CMAKE_BUILD_TYPE=RELEASE \
      -D CMAKE_INSTALL_PREFIX=/usr/local \
      -D INSTALL_PYTHON_EXAMPLES=ON \
      -D OPENCV_EXTRA_MODULES_PATH=$OPENCV_CONTRIB_PATH/modules \
      -D BUILD_EXAMPLES=ON ..

make -j4

echo "--- Subtask finished in : $(pwd)"