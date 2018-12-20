#!/bin/bash -e

SCRIPT_DIR="$( cd "$( dirname "$0"  )" && pwd )"

USAGE='USAGE: sh make.sh release|debug cpu|gpu saas|cloudsp|privatecloud politician|star'

if [ $# != 4 ];then
    echo $USAGE
    exit 1
fi

# build directory
CPU_DEBUG_DIR=$SCRIPT_DIR/build_cpu/debug
if [ ! -d "$CPU_DEBUG_DIR" ];then
    mkdir -p $CPU_DEBUG_DIR
fi

CPU_RELEASE_DIR=$SCRIPT_DIR/build_cpu/release
if [ ! -d "$CPU_RELEASE_DIR" ];then
    mkdir -p $CPU_RELEASE_DIR
fi

GPU_DEBUG_DIR=$SCRIPT_DIR/build_gpu/debug
if [ ! -d "$GPU_DEBUG_DIR" ];then
    mkdir -p $GPU_DEBUG_DIR
fi

GPU_RELEASE_DIR=$SCRIPT_DIR/build_gpu/release
if [ ! -d "$GPU_RELEASE_DIR" ];then
    mkdir -p $GPU_RELEASE_DIR
fi

# debug & release
if [ 'debug' = $1 ];then
    ARGS_BUILD_TYPE='-DCMAKE_BUILD_TYPE=DEBUG'
    BUILD_DIR='debug'
else
    ARGS_BUILD_TYPE='-DCMAKE_BUILD_TYPE=RELEASE'
    BUILD_DIR='release'
fi

# product
if [ 'saas' = $3 ];then
    ARGS_PRODUCT='-DPRODUCT_SAAS=ON'
elif [ 'cloudsp' = $3 ];then
    ARGS_PRODUCT='-DPRODUCT_CLOUDSP=ON'
elif [ 'privatecloud' = $3 ];then
    ARGS_PRODUCT='-DPRODUCT_PRIVATECLOUD=ON'
else
    echo $USAGE
    exit 1
fi

# politician & star
if [ 'politician' = $4 ];then
    ARGS_CELEBRITY_TYPE='-DPOLITICIAN=ON'
elif [ 'star' = $4 ];then
    ARGS_CELEBRITY_TYPE='-DSTAR=ON'
else 
    echo $USAGE
    exit 1
fi

clean_cmake_cache(){
    rm -rf CMakeFiles
    rm -ff cmake_install.cmake
    rm -ff CMakeCache.txt
    rm -rf Makefile
}

execute_cmake() {
  echo "execute cmake"
  cd $2

  echo "clean cmake cache"
  clean_cmake_cache
    
  CMAKE_ARGS=''${ARGS_BUILD_TYPE}' '${ARGS_CORE_TYPE}' '${ARGS_PRODUCT}' '${ARGS_CELEBRITY_TYPE}' '$SCRIPT_DIR''
  echo 'cmake '$CMAKE_ARGS''
  cmake $CMAKE_ARGS
  make -j5
  echo "execute cmake $1 done"
}

# cpu & gpu
if [ 'cpu' = $2 ];then
    ARGS_CORE_TYPE='-DWITH_CPU=ON'
    execute_cmake 'cpu' build_cpu/$BUILD_DIR
elif [ 'gpu' = $2 ];then
    ARGS_CORE_TYPE='-DWITH_GPU=ON'
    execute_cmake 'gpu' build_gpu/$BUILD_DIR
else
    echo $USAGE
    exit 1
fi
