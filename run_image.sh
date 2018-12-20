#!/bin/bash -e

#!/bin/bash

SCRIPT_DIR="$( cd "$( dirname "$0"  )" && pwd )"
cd $SCRIPT_DIR

USAGE='sh run_image.sh version cpu|gpu online_license|offline_license politician|star'

check_core_type() {
    if [ $1 = 'cpu' ];then
        CORE_TYPE='cpu'
    elif [ $1 = 'gpu' ];then
        CORE_TYPE='gpu'
    else 
        echo $USAGE
        exit 1
    fi
}

check_db_type() {
    if [ $1 = 'politician' ];then
        DB_TYPE='politician'
    elif [ $1 = 'star' ];then
        DB_TYPE='star'
    else 
        echo $USAGE
        exit 1
    fi
}

check_license_type() {
    if [ $1 = 'online_license' ];then
        LICENSE_TYPE='online_license'
    elif [ $1 = 'offline_license' ];then
        LICENSE_TYPE='offline_license'
    else
        echo $USAGE
        exit 1
    fi
}

if [ $# = 4 ];then
    version=$1
    check_core_type $2
    check_license_type $3
    check_db_type $4
elif [ $# = 3 ];then
    git_commit_id=`git rev-list --tags --max-count=1`
    version=`git describe --tags $git_commit_id`
    check_core_type $1
    check_license_type $2
    check_db_type $3
else
    echo $USAGE
    exit 1
fi

IMAGE_NAME='registry.sensetime.com/sensemaster/sensemedia_algoservice_filter_celebrity_'${DB_TYPE}'_'${CORE_TYPE}'_'${LICENSE_TYPE}''

echo "run ${IMAGE_NAME}:${version}"

if [ 'online_license' = ${LICENSE_TYPE} ];then
    sudo nvidia-docker run -it -p 50053:50053 -p 50054:50054 \
         -e PRIVATE_CA_HOST="172.20.20.225" \
         -e SLAVE_PRIVATE_CA_HOST="172.20.20.225" \
         -e LOG_LEVEL="info" \
         $IMAGE_NAME:$version
else
    sudo nvidia-docker run -it -p 50053:50053 -p 50054:50054 \
         -e LOG_LEVEL="info" \
         -v /data/sensemedia/frameextract/data:/data/sensemedia/frameextract/data \
         $IMAGE_NAME:$version
fi

echo "exit"
