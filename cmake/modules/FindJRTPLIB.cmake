################################################################################
 # 
 # Copyright (c) 2017 南京航空航天大学 航空通信网络研究室
 # 
 # @file
 # @author   姜阳 (j824544269@gmail.com)
 # @date     2017-11
 # @brief    
 # @version  0.0.1
 # 
 # Last Modified:  2017-12-25
 # Modified By:    姜阳 (j824544269@gmail.com)
 # 
################################################################################

# - Find JRTPLIB library
# Once done this will define
# JRTPLIB_FOUND - system has JRTPLIB
# JRTPLIB_INCLUDE_DIR - JRTPLIB include directories
# JRTPLIB_LIBRARY - where to find the JRTPLIB library

if(JRTPLIB_INCLUDE_DIR)
    # Already in cache, be silent
    set(JRTPLIB_FIND_QUIETLY TRUE)
endif()

find_path(JRTPLIB_INCLUDE_DIR
    NAMES rtpsession.h
    PATH_SUFFIXES jrtplib jrtplib3
    DOC "JRTPLIB include directories"
    )

find_library(JRTPLIB_LIBRARY
    NAMES jrtp
    DOC "JRTPLIB library"
    )

# handle the QUIETLY and REQUIRED arguments and set JRTPLIB_FOUND to TRUE if all listed variables are TRUE
include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(JRTPLIB
                                  REQUIRED_VARS JRTPLIB_LIBRARY JRTPLIB_INCLUDE_DIR
                                  VERSION_VAR JRTPLIB_VERSION_STRING)

if(JRTPLIB_INCLUDE_DIR AND JRTPLIB_LIBRARY)
    set(JRTPLIB_FOUND TRUE)
    set(JRTPLIB_LIBRARIES ${JRTPLIB_LIBRARY})
    set(JRTPLIB_INCLUDE_DIRS ${JRTPLIB_INCLUDE_DIR})
else()
    set (JRTPLIB_FOUND FALSE)
    message(FATAL_ERROR "JRTPLIB not found")
endif()

mark_as_advanced(
    JRTPLIB_INCLUDE_DIR
    JRTPLIB_LIBRARY)