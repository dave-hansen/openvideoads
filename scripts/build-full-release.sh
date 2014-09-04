#!/bin/sh
#
#   ./build-full-release.sh
#

WORKSPACE=".."
OVA_FOR_AS3_BUILD_DIR=${WORKSPACE}/ova.as3/build
OVA_FOR_FLOWPLAYER_BUILD_DIR=${WORKSPACE}/ova.flowplayer/build
OVA_FOR_JWPLAYER_5_BUILD_DIR=${WORKSPACE}/ova.jwplayer.5x/build
OVA_VPAID_EXAMPLES_BUILD_DIR=${WORKSPACE}/ova.vpaid.ads/build
STARTING_DIRECTORY=`pwd`

echo "Building the full release - OVA for Flowplayer, JW and AS3 + VPAID examples..."

echo "Building OVA for AS3..."
cd $OVA_FOR_AS3_BUILD_DIR
ant deploy
cd $STARTING_DIRECTORY

#DEPRECIATED SINCE 1.0.1
#OVA_FOR_JWPLAYER_4_BUILD_DIR=${WORKSPACE}/trunk/ova.jwplayer.4x/scripts/build
#echo "Building OVA for JW4..."
#cd ${OVA_FOR_JWPLAYER_4_BUILD_DIR}
#./build.sh
cd $STARTING_DIRECTORY

echo "Building OVA for JW5..."
cd $OVA_FOR_JWPLAYER_5_BUILD_DIR
ant build
cd $STARTING_DIRECTORY

echo "Building OVA for Flowplayer..."
cd $OVA_FOR_FLOWPLAYER_BUILD_DIR
ant build
cd $STARTING_DIRECTORY

echo "Building OVA VPAID Examples..."
cd $OVA_VPAID_EXAMPLES_BUILD_DIR
./build.sh
cd $STARTING_DIRECTORY

echo "Full release built."