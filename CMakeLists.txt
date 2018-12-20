cmake_minimum_required(VERSION 3.2)

project(SenseMediaAlgoService_FilterCelebrity)

set(CMAKE_C_COMPILER "gcc")
set(CMAKE_CXX_COMPILER "g++")

set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -Wall -std=c++14 -pthread")
if (${CMAKE_BUILD_TYPE} STREQUAL "DEBUG") 
   add_definitions(-DDEBUG)
endif()
set(CMAKE_CXX_FLAGS_DEBUG "${CMAKE_CXX_FLAGS} -O0 -g -ggdb")
set(CMAKE_CXX_FLAGS_RELEASE "${CMAKE_CXX_FLAGS} -O2")

######################################################################
# compile options
######################################################################
option(WITH_GPU "with gpu core" OFF)
option(WITH_CPU "with cpu core" OFF)
option(PRODUCT_SAAS "SenseMedia-SaaS" OFF)
option(PRODUCT_CLOUDSP "SenseMedia-Cloud-SP" OFF)
option(PRODUCT_PRIVATECLOUD "SenseMedia-PrivateCloud" OFF)
option(POLITICIAN "politician" OFF)
option(STAR "star" OFF)

# product & license
if (PRODUCT_SAAS) 
    message("-- Build PRODUCT_NAME=SenseMedia-Saas LICENSE=offline_license")
    set(PRODUCT_NAME "SenseMedia-SaaS")
    set(LICENSE_TYPE offline_license)
    add_definitions(-DOFFLINE_LICENSE)
elseif(PRODUCT_CLOUDSP)
    message("--Build PRODUCT_NAME=SenseMedia-Cloud-SP LICENSE=online_license")
    set(PRODUCT_NAME "SenseMedia-Cloud-SP")  
    set(LICENSE_TYPE online_license)
    add_definitions(-DONLINE_LICENSE)
elseif(PRODUCT_PRIVATECLOUD)
    message("--Build PRODUCT_NAME=SenseMedia-PrivateCloud LICENSE=offline_license")
    set(PRODUCT_NAME "SenseMedia-PrivateCloud")  
    set(LICENSE_TYPE offline_license)
    add_definitions(-DOFFLINE_LICENSE)
else()
    message(FATAL_ERROR "-- Build with NO product name, use PRODUCT_SAAS|PRODUCT_CLOUDSP|PRODUCT_PRIVATECLOUD")
endif()

configure_file (
    "${CMAKE_CURRENT_SOURCE_DIR}/../AlgoFoundation/product_config.h.in"
    "${CMAKE_CURRENT_SOURCE_DIR}/../AlgoFoundation/product_config.h"
)

# db type
if(POLITICIAN)
    message("-- Build POLITICIAN")
    add_definitions(-DPOLITICIAN)
elseif(STAR)
    message("-- Build STAR")
    add_definitions(-DSTAR)
else()
    message(FATAL_ERROR "-- Build with NO celebrity type, use POLITICIAN|STAR")
endif()

######################################################################
# commons
######################################################################
include_directories(${CMAKE_CURRENT_SOURCE_DIR}/../AlgoChannels)
include_directories(${CMAKE_CURRENT_SOURCE_DIR}/../AlgoChannels/grpc)
include_directories(${CMAKE_CURRENT_SOURCE_DIR}/../AlgoChannels/grpc/proto_gen)
include_directories(${CMAKE_CURRENT_SOURCE_DIR}/../AlgoChannels/http)
include_directories(${CMAKE_CURRENT_SOURCE_DIR}/../AlgoChannels/kafka)
include_directories(${CMAKE_CURRENT_SOURCE_DIR}/../AlgoFoundation)
include_directories(${CMAKE_CURRENT_SOURCE_DIR}/../AlgoFoundation/config)
include_directories(${CMAKE_CURRENT_SOURCE_DIR}/../AlgoFoundation/constants)
include_directories(${CMAKE_CURRENT_SOURCE_DIR}/../AlgoFoundation/download)
include_directories(${CMAKE_CURRENT_SOURCE_DIR}/../AlgoFoundation/filter)
include_directories(${CMAKE_CURRENT_SOURCE_DIR}/../AlgoFoundation/json)
include_directories(${CMAKE_CURRENT_SOURCE_DIR}/../AlgoFoundation/proxy)
include_directories(${CMAKE_CURRENT_SOURCE_DIR}/../AlgoFoundation/utils)
include_directories(${CMAKE_CURRENT_SOURCE_DIR}/../AlgoFoundation/thirdparty)
include_directories(${CMAKE_CURRENT_SOURCE_DIR}/../cpp_log)
include_directories(${CMAKE_CURRENT_SOURCE_DIR}/sdk_wrapper)
include_directories(${CMAKE_CURRENT_SOURCE_DIR}/managedb)
include_directories(${CMAKE_CURRENT_SOURCE_DIR}/sdk_release/include/${LICENSE_TYPE})

link_directories(/usr/local/lib)
link_directories(${CMAKE_CURRENT_SOURCE_DIR}/lib)
link_directories(${CMAKE_CURRENT_SOURCE_DIR}/sdk_release/plugins)

set(LIB_SDK sdk_core plugin tbb)
set(LIB_GRPC protobuf grpc grpc++_unsecure)
set(LIB_HTTP PocoNet PocoUtil PocoFoundation)
set(LIB_KAFKA rdkafka++ rdkafka aws-cpp-sdk-core aws-cpp-sdk-s3)
set(LIB_OPENCV opencv_imgproc opencv_highgui opencv_core opencv_calib3d)
set(LIB_COMMON pthread dl z  stdc++ m curl libssl.a libcrypto.a sasl2 zipLib)

set(SRC_COMMON 
   ${CMAKE_CURRENT_SOURCE_DIR}/../AlgoFoundation/config/config.cc
   ${CMAKE_CURRENT_SOURCE_DIR}/../AlgoFoundation/download/algo_garner.cc
   ${CMAKE_CURRENT_SOURCE_DIR}/../AlgoFoundation/download/ceph_client.cc
   ${CMAKE_CURRENT_SOURCE_DIR}/../AlgoFoundation/download/unzip_client.cc
   ${CMAKE_CURRENT_SOURCE_DIR}/../AlgoFoundation/download/curl_client.cc
   ${CMAKE_CURRENT_SOURCE_DIR}/../AlgoFoundation/filter/algo_filter.cc
   ${CMAKE_CURRENT_SOURCE_DIR}/../AlgoFoundation/json/json.cc
   ${CMAKE_CURRENT_SOURCE_DIR}/../AlgoFoundation/proxy/algo_proxy.cc
   ${CMAKE_CURRENT_SOURCE_DIR}/../AlgoFoundation/utils/getDeviceUuid.cc
   ${CMAKE_CURRENT_SOURCE_DIR}/../AlgoFoundation/utils/md5.cc
   ${CMAKE_CURRENT_SOURCE_DIR}/../cpp_log/spdlog_wrapper.cc
   )

file(GLOB SRC_ALGO_CHANNEL_GRPC_PROTO ${CMAKE_CURRENT_SOURCE_DIR}/../AlgoChannels/grpc/proto_gen/*.cc)
file(GLOB SRC_ALGO_CHANNEL_GRPC ${CMAKE_CURRENT_SOURCE_DIR}/../AlgoChannels/grpc/*.cc)
file(GLOB SRC_ALGO_CHANNEL_HTTP ${CMAKE_CURRENT_SOURCE_DIR}/../AlgoChannels/http/*.cc)
file(GLOB SRC_ALGO_CHANNEL_KAFKA ${CMAKE_CURRENT_SOURCE_DIR}/../AlgoChannels/kafka/*.cc)

file(GLOB SRC_ALGO_UNIT ${CMAKE_CURRENT_SOURCE_DIR}/sdk_wrapper/*.cc)
file(GLOB SRC_ALGO_UNIT_EXTRA ${CMAKE_CURRENT_SOURCE_DIR}/managedb/*.cc)
file(GLOB SRC_MAIN ${CMAKE_CURRENT_SOURCE_DIR}/main/main.cc)

######################################################################
# core type
######################################################################
if(WITH_CPU)
    link_directories(${CMAKE_CURRENT_SOURCE_DIR}/sdk_release/lib_cpu/${LICENSE_TYPE})
elseif(WITH_GPU)
    link_directories(/usr/local/cuda-8.0/lib64)
    link_directories(${CMAKE_CURRENT_SOURCE_DIR}/sdk_release/lib_gpu/${LICENSE_TYPE})    
else()
    message(FATAL_ERROR "-- Build with NO core type, use WITH_CPU|WITH_GPU")
endif()

######################################################################
# executable
######################################################################
add_executable(${PROJECT_NAME} ${SRC_MAIN} ${SRC_ALGO_CHANNEL_HTTP} ${SRC_ALGO_CHANNEL_KAFKA} ${SRC_ALGO_CHANNEL_GRPC} ${SRC_ALGO_CHANNEL_GRPC_PROTO} ${SRC_ALGO_UNIT} ${SRC_ALGO_UNIT_EXTRA} ${SRC_COMMON})

target_link_libraries(${PROJECT_NAME} ${LIB_SDK} ${LIB_KAFKA} ${LIB_HTTP} ${LIB_GRPC} ${LIB_OPENCV} ${LIB_COMMON})
