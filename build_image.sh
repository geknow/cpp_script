#!/bin/bash

SCRIPT_DIR="$( cd "$( dirname "$0"  )" && pwd )"
cd $SCRIPT_DIR

USAGE='sh build_image.sh version cpu|gpu online_license|offline_license politician|star'

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

IMAGE_NAME='sensemedia_algoservice_filter_celebrity_'${DB_TYPE}'_'${CORE_TYPE}'_'${LICENSE_TYPE}''

echo "build ${IMAGE_NAME}"

sudo docker build -f docker/Dockerfile --build-arg CORE_TYPE=${CORE_TYPE} --build-arg LICENSE_TYPE=${LICENSE_TYPE} --build-arg DB_TYPE=${DB_TYPE}  -t $IMAGE_NAME:$version .
sudo docker tag $IMAGE_NAME:$version registry.sensetime.com/sensemaster/$IMAGE_NAME:$version
sudo docker push registry.sensetime.com/sensemaster/$IMAGE_NAME:$version
