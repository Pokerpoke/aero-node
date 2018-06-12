#!/bin/bash
################################################################################
# 
# Copyright (c) 2018 南京航空航天大学 航空通信网络研究室
# 
# @author   姜阳 (j824544269@gmail.com)
# @date     2018-01
# @brief    
# @version  0.0.1
# 
# Last Modified:  2018-01-08
# Modified By:    姜阳 (j824544269@gmail.com)
# 
################################################################################

# get the destation ip
echo "Enter destination IP (Default : 192.168.0.22) : " 
read DESTIP

if test -z ${DESTIP}
then
    DESTIP="192.168.0.22"
fi

# get CMAKE_SOURCE_DIR
CMAKE_SOURCE_DIR=$(dirname $(readlink -f "$0"))
cd ${CMAKE_SOURCE_DIR}/../..

# update CMAKE_SOURCE_DIR
CMAKE_SOURCE_DIR=$(pwd)

# go to build directory
if [ ! -d ${CMAKE_SOURCE_DIR}/build ] 
then
   mkdir ${CMAKE_SOURCE_DIR}build 
fi
cd ${CMAKE_SOURCE_DIR}/build/

# if directory exists delete it
if [ -d ./Tiny4412 ] 
then
    rm -rf Tiny4412
fi

mkdir Tiny4412
cd Tiny4412

export PATH=/opt/FriendlyARM/toolschain/4.5.1/bin:$PATH

# make
# cmake -DCMAKE_BUILD_TYPE=Debug \
cmake -DCMAKE_BUILD_TYPE=Release \
      -DCMAKE_INSTALL_PREFIX=${CMAKE_SOURCE_DIR}/build/Tiny4412 \
      -DCMAKE_BUILD_TARGET=Tiny4412 ../../
make -j4
make install

# copy files
scp -rp ./usr/bin/* root@${DESTIP}:/home/aero-node/
scp -rp ./usr/share/* root@${DESTIP}:/home/aero-node/
scp -rp ./usr/lib/* root@${DESTIP}:/usr/lib/
# scp -p ${CMAKE_SOURCE_DIR}/scripts/an-run root@${DESTIP}:/bin/

# ssh -l root ${DESTIP} "an-run /home/aero-node/main"