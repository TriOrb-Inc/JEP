#!/bin/bash
#
# Copyright (c) 2022, NVIDIA CORPORATION.  All rights reserved.
#
# NVIDIA Corporation and its licensors retain all intellectual property
# and proprietary rights in and to this software, related documentation
# and any modifications thereto.  Any use, reproduction, disclosure or
# distribution of this software and related documentation without an express
# license agreement from NVIDIA Corporation is strictly prohibited.
#

version="4.8.0"
folder="workspace"

set -e

for (( ; ; ))
do
    echo "Do you want to remove the default OpenCV (yes/no)?"
    rm_old="yes"

    if [ "$rm_old" = "yes" ]; then
        echo "** Remove other OpenCV first"
        sudo apt -y purge *libopencv*
	break
    elif [ "$rm_old" = "no" ]; then
	break
    fi
done


echo "------------------------------------"
echo "** Install requirement (1/4)"
echo "------------------------------------"
sudo apt-get update
sudo apt-get install -y build-essential cmake git libgtk2.0-dev pkg-config libavcodec-dev libavformat-dev libswscale-dev
sudo apt-get install -y libgstreamer1.0-dev libgstreamer-plugins-base1.0-dev
sudo apt-get install -y python3.10-dev python3-numpy
sudo apt-get install -y libtbb2 libtbb-dev libjpeg-dev libpng-dev libtiff-dev libdc1394-dev
sudo apt-get install -y libv4l-dev v4l-utils qv4l2
sudo apt-get install -y curl unzip gcc-10 g++-10
export CC=/usr/bin/gcc-10
export CXX=/usr/bin/g++-10
export CUDA_ROOT=/usr/local/cuda
sudo unlink $CUDA_ROOT/bin/gcc
sudo unlink $CUDA_ROOT/bin/g++
sudo ln -s /usr/bin/gcc-10 $CUDA_ROOT/bin/gcc
suo ln -s /usr/bin/g++-10 $CUDA_ROOT/bin/g++


echo "------------------------------------"
echo "** Download opencv "${version}" (2/4)"
echo "------------------------------------"
mkdir $folder
cd ${folder}
curl -L https://github.com/opencv/opencv/archive/${version}.zip -o opencv-${version}.zip
curl -L https://github.com/opencv/opencv_contrib/archive/${version}.zip -o opencv_contrib-${version}.zip
unzip opencv-${version}.zip
unzip opencv_contrib-${version}.zip
rm opencv-${version}.zip opencv_contrib-${version}.zip
cd opencv-${version}/


echo "------------------------------------"
echo "** Build opencv "${version}" (3/4)"
echo "------------------------------------"
mkdir release
cd release/
cmake -D WITH_CUDA=ON -D WITH_CUDNN=OFF -D CUDA_ARCH_BIN="7.2,8.6,8.7" -D CUDA_ARCH_PTX="" -D OPENCV_GENERATE_PKGCONFIG=ON -D OPENCV_EXTRA_MODULES_PATH=../../opencv_contrib-${version}/modules -D WITH_GSTREAMER=ON -D WITH_LIBV4L=ON -D BUILD_opencv_python3=ON -D BUILD_TESTS=OFF -D BUILD_PERF_TESTS=OFF -D BUILD_EXAMPLES=OFF -D CMAKE_BUILD_TYPE=RELEASE -D CMAKE_INSTALL_PREFIX=/usr/local ..
make -j$(nproc)


echo "------------------------------------"
echo "** Install opencv "${version}" (4/4)"
echo "------------------------------------"
sudo make install
echo 'export LD_LIBRARY_PATH=/usr/local/lib:$LD_LIBRARY_PATH' >> ~/.bashrc
echo 'export PYTHONPATH=/usr/local/lib/python3.10/site-packages/:$PYTHONPATH' >> ~/.bashrc
source ~/.bashrc


echo "** Install opencv "${version}" successfully"
echo "** Bye :)"
