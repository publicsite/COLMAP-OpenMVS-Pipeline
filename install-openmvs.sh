#!/bin/sh

OLD_UMASK="$(umask)"
umask 0022

thepwd=${PWD}

#Prepare and empty machine for building:
sudo apt-get update && sudo apt-get install
sudo apt-get -y install git cmake libpng-dev libjpeg-dev libtiff-dev libglu1-mesa-dev libeigen3-dev

#Boost (Required)
sudo apt-get -y install libboost-iostreams-dev libboost-program-options-dev libboost-system-dev libboost-serialization-dev

#OpenCV (Required)
sudo apt-get -y install libopencv-dev

#CGAL (Required)
sudo apt-get -y install libcgal-dev libcgal-qt5-dev

#VCGLib (Required)
git clone https://github.com/cdcseacave/VCG.git vcglib

#Ceres (Optional)
sudo apt-get -y install libatlas-base-dev libsuitesparse-dev libceres-dev

#GLFW3 (Optional)
sudo apt-get -y install freeglut3-dev libglew-dev libglfw3-dev

#OpenMVS
git clone https://github.com/cdcseacave/openMVS.git -b develop openMVS

##PATCH TO REMOVE NON-FREE DEPENDENCIES
rm -rf openMVS/libs/Math/TRWS
rm -rf openMVS/libs/Math/IBFS
rm openMVS/COPYRIGHT.md
cp patches/openMVS/COPYRIGHT.md openMVS/COPYRIGHT.md
rm openMVS/libs/Math/CMakeLists.txt
cp patches/openMVS/libs/Math/CMakeLists.txt openMVS/libs/Math/CMakeLists.txt
patch -p1 < patches/openMVS/libs/MVS/Scene.h.patch
patch -p1 < patches/openMVS/libs/MVS/SceneReconstruct.cpp.patch
patch -p1 < patches/openMVS/libs/MVS/SceneDensify.h.patch
patch -p1 < patches/openMVS/libs/MVS/SceneDensify.cpp.patch
patch -p1 < patches/openMVS/libs/IO/Image.cpp.patch
rm openMVS/apps/DensifyPointCloud/DensifyPointCloud.cpp
cp patches/openMVS/apps/DensifyPointCloud/DensifyPointCloud.cpp openMVS/apps/DensifyPointCloud/DensifyPointCloud.cpp

sed -i "s/OpenMVS_USE_CERES OFF/OpenMVS_USE_CERES ON/g" openMVS/CMakeLists.txt
sed -i "s/OpenMVS_USE_NONFREE ON/OpenMVS_USE_NONFREE OFF/g" openMVS/CMakeLists.txt

mkdir openMVS_build && cd openMVS_build
cmake . ../openMVS -DCMAKE_BUILD_TYPE=Release -DVCG_ROOT="${thepwd}/vcglib" -DBUILD_SHARED_LIBS=OFF -DCGAL_ROOT="/usr/lib/x86_64-linux-gnu/cmake/CGAL/"

#use this option instead for 32 bit
#-DCGAL_ROOT="/usr/lib/i386-linux-gnu/cmake/CGAL/"

#build OpenMVS library:
make -j2

umask "${OLD_UMASK}"
