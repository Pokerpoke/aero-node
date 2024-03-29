#!/bin/bash
################################################################################
# 
# Copyright (c) 2018 NUAA AeroLab
# 
# @author   Jiang Yang (pokerpoke@qq.com)
# @date     2018-01
# @brief    
# @version  0.0.1
# 
# Last Modified:  2018-10-22
# Modified By:    Jiang Yang (pokerpoke@qq.com)
# 
################################################################################

################################################################################
# 
# Variables
# 
################################################################################
# get scripts path
SCRIPT_DIR=$(dirname $(readlink -f $0))
cd ${SCRIPT_DIR}/..
CMAKE_SOURCE_DIR=$(pwd)
SYS_ROOT_DIR="/opt/FriendlyARM/toolschain/4.5.1/arm-none-linux-gnueabi/sys-root"
cd ${SCRIPT_DIR}
# git repository prefix
GIT_REPOSITORY_PREFIX="http://192.168.0.9:8086/git/aero-node"
# build target
TARGET="apt arm-linux-gcc log4cpp qte bcg729 jthread jrtplib"
# build target platform
TARGET_PLATFORM="x86 tiny4412"
################################################################################
# 
# Help
# 
################################################################################
function help()
{
    cat << HELP
Set up cross compile environment for aero-node.

USAGE: set-up-cross-compile-environment [-hgp:t:]

OPTIONS: -h help
         -g specify git address
         -p specify target platform
            [x86|tiny4412] 
            default is all platform
         -t specify target
            [apt|bcg729|jthread|jrtplib|arm-linux-gcc|log4cpp|qte] 
            default is all target

EXAMPLE: set-up-cross-compile-environment all
HELP
exit 0
}
################################################################################
# 
# Install debs
# 
################################################################################
function git-x86-apt()
{
    # cross compile necessary libraries
    DEPENDENCIES=(
                "git"
                "lib32z1"
                "build-essential"
                "liblog4cpp5-dev"
                "qt4-dev-tools"
                "libasound2-dev"
                "swig3.0"
                "cmake"
                )

    for DEP in ${DEPENDENCIES[@]} ; do
        dpkg --get-selections | grep "${DEP}"
        if [ $? -ne 0 ]
        then
            echo "${DEP} is required, but not installed, going to install it."
            sudo apt-get install -y ${DEP}
            if [ $? -ne 0 ]
            then
                exit 1
            fi
        fi
    done
}

function git-tiny4412-apt()
{
    echo
}
################################################################################
# 
# Compile log4cpp
# 
################################################################################
function git-x86-log4cpp()
{
    sudo apt-get install -y liblog4cpp5-dev
}

function git-tiny4412-log4cpp()
{
    # if exist, clean it
    if [ -d aero-node-tools ]
    then
        rm -rf aero-node-tools
    fi
    mkdir ${SCRIPT_DIR}/aero-node-tools && cd ${SCRIPT_DIR}/aero-node-tools

    wget -c -t 5 http://192.168.0.9/share/aero-node-tools/log4cpp-1.1.3.tar.gz

    export PATH=/opt/FriendlyARM/toolschain/4.5.1/bin:$PATH

    # unpack
    tar xvzf log4cpp-1.1.3.tar.gz && cd log4cpp

    # build and clean for host
    # WARNING: it will confilct while use `sudo apt install liblog4cpp`
    # ./configure && make && sudo make install && make clean

    # build for cross compile toolschain
    ./configure --host=arm-linux \
                --prefix=/opt/FriendlyARM/toolschain/4.5.1/arm-none-linux-gnueabi/sys-root/usr
    make

    # it is unable to pass environment variable to sudo commands
    # so, use a shell script to run make install
    cat > ${SCRIPT_DIR}/temp_make-install.sh << EOF
#!/bin/bash

export PATH=/opt/FriendlyARM/toolschain/4.5.1/bin:$PATH

make install
EOF
    sudo bash ${SCRIPT_DIR}/temp_make-install.sh
    rm ${SCRIPT_DIR}/temp_make-install.sh

    # clean
    cd ${SCRIPT_DIR}
    rm -rf aero-node-tools
}
################################################################################
# 
# Extract arm-linux-gcc & qte
# 
################################################################################
function git-x86-arm-linux-gcc()
{
    # if exist, clean it
    if [ -d aero-node-tools ]
    then
        rm -rf aero-node-tools
    fi
    mkdir ${SCRIPT_DIR}/aero-node-tools && cd ${SCRIPT_DIR}/aero-node-tools

    wget -c -t 5 http://192.168.0.9/share/aero-node-tools/arm-linux-gcc-4.5.1-v6-vfp-20120301.tgz

    sudo tar xvzf ./arm-linux-gcc-4.5.1-v6-vfp-20120301.tgz -C /

    # clean
    cd ${SCRIPT_DIR}
    rm -rf aero-node-tools
}

function git-tiny4412-arm-linux-gcc()
{
    echo
}

function git-x86-qte()
{
    # if exist, clean it
    if [ -d aero-node-tools ]
    then
        rm -rf aero-node-tools
    fi
    mkdir ${SCRIPT_DIR}/aero-node-tools && cd ${SCRIPT_DIR}/aero-node-tools

    wget -c -t 5 http://192.168.0.9/share/aero-node-tools/target-qte-4.8.5-to-hostpc.tgz

    sudo tar xvzf ./target-qte-4.8.5-to-hostpc.tgz -C /

    # clean
    cd ${SCRIPT_DIR}
    rm -rf aero-node-tools
}

function git-tiny4412-qte()
{
    echo
}
################################################################################
# 
# Git clone and compile
# 
################################################################################
function git-cmake-x86()
{
    if test -z "$1"
    then
        echo "please input git repository"
        exit 1
    fi

    # if exist, clean it
    cd ${SCRIPT_DIR} 
    if [ -d temp ]
    then
        rm -rf temp
    fi

    # preparation
    PROJECT_DIR="${SCRIPT_DIR}/temp"
    git clone $1 temp
    if [ $? -ne 0 ]
    then
        echo "git clone failed, plaese try again"
        exit 1
    fi
    cd ${PROJECT_DIR}
    # build for host
    mkdir build && cd build && cmake .. && make -j8 && sudo make install

    # clean
    cd ${SCRIPT_DIR} && rm -rf ${PROJECT_DIR}
}

function git-cmake-tiny4412()
{
    if test -z "$1"
    then
        echo "please input git repository"
        exit 1
    fi

    # if exist, clean it
    cd ${SCRIPT_DIR}
    if [ -d temp ]
    then
        rm -rf temp
    fi

    # preparation
    PROJECT_DIR="${SCRIPT_DIR}/temp"
    git clone $1 temp
    if [ $? -ne 0 ]
    then
        echo "git clone failed, plaese try again"
        exit 1
    fi
    cd ${PROJECT_DIR}

    # build for cross compile toolschain
    # copy toolschain file
    mkdir -p cmake/toolschain && wget ${GIT_REPOSITORY_PREFIX}/aero-node/raw/master/cmake/toolschain/Tiny4412.cmake -O ./cmake/toolschain/Tiny4412.cmake

    # insert cmake toolschain file path into CMakeLists.txt
    sed -i "1i \
    set(CMAKE_TOOLCHAIN_FILE ${PROJECT_DIR}/cmake/toolschain/Tiny4412.cmake)" CMakeLists.txt

    # build
    mkdir build && cd build && cmake -DCMAKE_INSTALL_PREFIX=${SYS_ROOT_DIR}/usr/ ..
    if [ $? -ne 0 ]
    then
        echo "cmake build failed, please check output for more infomation."
        exit 1
    fi
    make -j8 && sudo make install

    # clean
    cd ${SCRIPT_DIR} && rm -rf ${PROJECT_DIR}
}
function git-x86-jthread()
{
    git-cmake-x86 ${GIT_REPOSITORY_PREFIX}/jthread.git
}
function git-tiny4412-jthread()
{
    git-cmake-tiny4412 ${GIT_REPOSITORY_PREFIX}/jthread.git
}
function git-x86-jrtplib()
{
    git-cmake-x86 ${GIT_REPOSITORY_PREFIX}/jrtplib.git
}
function git-tiny4412-jrtplib()
{
    git-cmake-tiny4412 ${GIT_REPOSITORY_PREFIX}/jrtplib.git
}
function git-x86-googletest()
{
    git-cmake-x86 ${GIT_REPOSITORY_PREFIX}/googletest.git
}
function git-tiny4412-googletest()
{
    echo
}
function git-x86-bcg729()
{
    git-cmake-x86 ${GIT_REPOSITORY_PREFIX}/bcg729.git
}
function git-tiny4412-bcg729()
{
    git-cmake-tiny4412 ${GIT_REPOSITORY_PREFIX}/bcg729.git
}
################################################################################
#
# Main funcition
#
################################################################################
while getopts "hg:p:t:" arg 
do
    case ${arg} in
        h)
            help
            ;;
        g)
            GIT_REPOSITORY_PREFIX=${OPTARG}
            ;;
        t)
            if [ "${OPTARG}" != "all" ]
            then
                TARGET=${OPTARG}
            fi
            ;;
        p)
            if [ "${OPTARG}" != "all" ]
            then
                TARGET_PLATFORM=${OPTARG}
                echo ${OPTARG}
            fi
            ;;
        *) 
            help
            ;;
    esac
done

for _target_platform in ${TARGET_PLATFORM}
do
    for _target in ${TARGET}
    do
        git-${_target_platform}-${_target}
    done
done

sudo ldconfig