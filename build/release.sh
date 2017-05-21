#!/bin/sh
d=${PWD}
bd=${d}/../
sd=${bd}/src/
id=${bd}/install
ed=${d}/../
rd=${d}/../reference/
d=${PWD}
is_debug="n"
build_dir="build_unix"
cmake_build_type="Release"
cmake_config="Release"
debug_flag=""
debugger=""
cmake_generator=""

# Detect OS.
if [ "$(uname)" == "Darwin" ]; then
    if [ "${cmake_generator}" = "" ] ; then
        cmake_generator="Unix Makefiles"
    fi
    os="mac"
elif [ "$(expr substr $(uname -s) 1 5)" = "Linux" ]; then
    if [ "${cmake_generator}" = "" ] ; then
        cmake_generator="Unix Makefiles"
    fi
    os="linux"
else
    if [ "${cmake_generator}" = "" ] ; then
        cmake_generator="Visual Studio 14 2015 Win64"
        build_dir="build_vs2015"
    fi
    os="win"
fi

# Detect Command Line Options
for var in "$@"
do
    if [ "${var}" = "debug" ] ; then
        is_debug="y"
        cmake_build_type="Debug"
        cmake_config="Debug"
        debug_flag="_debug"
        debugger="lldb"
    elif [ "${var}" = "xcode" ] ; then
        build_dir="build_xcode"
        cmake_generator="Xcode"
        build_dir="build_xcode"
    fi
done

# Create unique name for this build type.
bd="${d}/${build_dir}.${cmake_build_type}"

if [ ! -d ${bd} ] ; then 
    mkdir ${bd}
fi

# Compile the library.
cd ${bd}

# Simple function which compiles the library
# for different architectures.
function build() {

    arch=$1
    arch_bd="${bd}.${arch}"
    arch_id=${id}/${arch}

    echo "BUILDING FOR: ${arch}"
    
    if [ ! -d ${arch_bd} ] ; then
        mkdir ${arch_bd}
    fi

    cd ${arch_bd}
    cmake -DCMAKE_INSTALL_PREFIX=${arch_id} \
          -DCMAKE_BUILD_TYPE=${cmake_build_type} \
          -DCMAKE_TOOLCHAIN_FILE="${d}/${arch}.cmake" \
          -DPOLY_DIR=${ed}/extern/2016_109_polytrope \
          -G "${cmake_generator}" \
          ..

    if [ $? -ne 0 ] ; then
        echo "Failed to configure"
        exit
    fi

    cmake --build . --target install --config ${cmake_build_type}

    if [ $? -ne 0 ] ; then
        echo "Failed to build"
        exit
    fi
}

# Combines the multi-arch / fat libraries
function create_fat_lib() {
    libname=${1}
    lipo -create \
         "${id}/ios.armv7/lib/${libname}.a" \
         "${id}/ios.armv7s/lib/${libname}.a" \
         "${id}/ios.arm64/lib/${libname}.a" \
         "${id}/ios.simulator64/lib/${libname}.a" \
         "${id}/ios.i386/lib/${libname}.a" \
         -output \
         "${id}/lib/${libname}.a"
}

# Compile library for iOS
build "ios.armv7"
build "ios.armv7s"
build "ios.arm64"
build "ios.i386"
build "ios.simulator64"
build "macos.x86_64"

# Create fat library
if [ ! -d ${id}/lib ] ; then
    mkdir ${id}/lib
fi
if [ ! -d ${id}/include ] ; then
    mkdir ${id}/include
fi

# And create the fat libs for the dependencies
create_fat_lib "libmultiarch"

cd ${id}/macos.x86_64/bin
./test_multi_arch
