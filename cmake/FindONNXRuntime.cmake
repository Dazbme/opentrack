# FindONNXRuntime
# ===============
#
# Find an ONNX Runtime installation.
# ONNX Runtime is a cross-platform inference and training machine-learning
# accelerator.
#
# Input variables
# ---------------
# 
#   ONNXRuntime_ROOT            Set root installation. This is an environment
#                               variable
#   ONNXRuntime_DIR             CMake variable to set the installation root.
#
# Output variable
# ---------------
# 
#   ONNXRuntime_FOUND           True if headers and requested libraries were found
#   ONNXRuntime_LIBRARIES       Component libraries to be linked.
#   ONNXRuntime_INCLUDE_DIRS    Include directories.

set(ONNXRuntime_DIR CACHE PATH "Root directory of the ONNX Runtime installation")

# This script is mostly inspired by the guide there:
# https://gitlab.kitware.com/cmake/community/-/wikis/doc/tutorials/How-To-Find-Libraries
# Finding of the DLLs was added so we can install them with the application.
# We adhere to modern CMake standards and also define an import library.

find_library(ONNXRuntime_LIBRARY onnxruntime
    HINTS
        ${ONNXRuntime_DIR}
    PATHS
        ${CMAKE_INSTALL_PREFIX}
    PATH_SUFFIXES lib lib64 bin
    CMAKE_FIND_ROOT_PATH_BOTH)

if(WIN32)
    SET(CMAKE_FIND_LIBRARY_SUFFIXES ".dll" ".DLL")
    find_library(ONNXRuntime_RUNTIME onnxruntime
        HINTS
            ${ONNXRuntime_DIR}
        PATHS
            ${CMAKE_INSTALL_PREFIX}
        PATH_SUFFIXES lib lib64 bin
        CMAKE_FIND_ROOT_PATH_BOTH)
else()
    SET(ONNXRuntime_RUNTIME ${ONNXRuntime_LIBRARY})
endif()

find_path(ONNXRuntime_INCLUDE_DIR onnxruntime_cxx_api.h
    HINTS
        ${ONNXRuntime_DIR}/include
        ${ONNXRuntime_DIR}
    PATHS
        ${CMAKE_INSTALL_PREFIX}/include
    PATH_SUFFIXES onnxruntime/core/session
    CMAKE_FIND_ROOT_PATH_BOTH)


include(FindPackageHandleStandardArgs)
# handle the QUIETLY and REQUIRED arguments and set ONNXRuntime_FOUND to TRUE
# if all listed variables are TRUE
find_package_handle_standard_args(ONNXRuntime  DEFAULT_MSG
                                  ONNXRuntime_LIBRARY ONNXRuntime_INCLUDE_DIR ONNXRuntime_RUNTIME)

if(ONNXRuntime_FOUND)
    if(NOT TARGET onnxruntime::onnxruntime)
        # Following this quide:
        # https://cmake.org/cmake/help/git-stage/guide/importing-exporting/index.html#importing-libraries
        add_library(onnxruntime::onnxruntime SHARED IMPORTED)
        set_target_properties(onnxruntime::onnxruntime PROPERTIES
            IMPORTED_LOCATION "${ONNXRuntime_RUNTIME}"
            INTERFACE_INCLUDE_DIRECTORIES "${ONNXRuntime_INCLUDE_DIR}"
            IMPORTED_IMPLIB "${ONNXRuntime_LIBRARY}")
    endif()
endif()

mark_as_advanced(ONNXRuntime_INCLUDE_DIR ONNXRuntime_LIBRARY ONNXRuntime_RUNTIME)

set(ONNXRuntime_INCLUDE_DIRS ${ONNXRuntime_INCLUDE_DIR})
set(ONNXRuntime_LIBRARIES ${ONNXRuntime_LIBRARY})