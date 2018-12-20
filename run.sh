#! /bin/bash -e

SCRIPT_DIR="$( cd "$( dirname "$0"  )" && pwd )"
cd $SCRIPT_DIR

USAGE='USAGE: sh run.sh release|debug cpu|gpu online_license|offline_license'

if [ $# != 3 ];then
    echo $USAGE
    exit 1
fi

echo "recv" $1 $2 $3

if [ 'debug' = $1 ];then
    RELEASE_TYPE='debug'
    export GLOG_minloglevel=0
elif [ 'release' = $1 ];then
    RELEASE_TYPE='release'
    export GLOG_minloglevel=2
else
    echo $USAGE
    exit 1
fi

if [ 'online_license' = $3 ];then
    LICENSE_TYPE='online_license'
##########################################################################################
    if [ -z $PRIVATE_CA_HOST ];then
        echo "PRIVATE_CA_HOST not exists"
    else
        echo "$PRIVATE_CA_HOST private.ca.sensetime.com" >> /etc/hosts
    fi
    if [ -z $SLAVE_PRIVATE_CA_HOST ];then
        echo "SLAVE_PRIVATE_CA_HOST not exists"
    else
        echo "$SLAVE_PRIVATE_CA_HOST slave.private.ca.sensetime.com" >> /etc/hosts
    fi
##########################################################################################
elif [ 'offline_license' = $3 ];then
    LICENSE_TYPE='offline_license'
else
    echo $USAGE
    exit 1
fi

if [ 'cpu' = $2 ];then
    export LD_LIBRARY_PATH=lib:sdk_release/lib_cpu/${LICENSE_TYPE}:sdk_release/plugins:/usr/local/lib:$LD_LIBRARY_PATH
    BUILD_DIR='build_cpu' 
    GPU_NUM=-1
elif [ 'gpu' = $2 ];then
    export LD_LIBRARY_PATH=lib:sdk_release/lib_gpu/${LICENSE_TYPE}:sdk_release/plugins:/usr/local/lib:/usr/local/cuda-8.0/lib64:$LD_LIBRARY_PATH
    BUILD_DIR='build_gpu'    
    if [ -z $GPU_NUM ]; then
        GPU_NUM=0
    else 
        GPU_NUM=$GPU_NUM
    fi
else 
    echo $USAGEq
    exit 1
fi

EXECUTABLE=`ls $BUILD_DIR/$RELEASE_TYPE/SenseMediaAlgoService*`

echo ''$EXECUTABLE'  config/config.ini '$GPU_NUM''

$EXECUTABLE  conf/config.ini  $GPU_NUM  
