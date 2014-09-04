#!/bin/sh
#
#   ./build-release-packages.sh
#

WORKSPACE=".."

OVA_FOR_AS3_BUILD_DIR=${WORKSPACE}/ova.as3/build
OVA_FOR_FLOWPLAYER_BUILD_DIR=${WORKSPACE}/ova.flowplayer/build
OVA_FOR_JWPLAYER_5_BUILD_DIR=${WORKSPACE}/ova.jwplayer.5x/build


STARTING_DIRECTORY=`pwd`

echo "Building the final release packages..."

echo "Building OVA for AS3..."
cd $OVA_FOR_AS3_BUILD_DIR
ant deploy
ant package-release
cd $STARTING_DIRECTORY

# DEPRECIATED
# OVA_FOR_JWPLAYER_4_RELEASE_DIR=${WORKSPACE}/trunk/ova.jwplayer.4x/scripts/release
# echo "Building OVA for JW4..."
# cd ${OVA_FOR_JWPLAYER_4_RELEASE_DIR}
# ./create-distribution.sh

echo "Building OVA for JW5..."
cd $OVA_FOR_JWPLAYER_5_BUILD_DIR
ant package-release
cd $STARTING_DIRECTORY

echo "Building OVA for Flowplayer..."
cd $OVA_FOR_FLOWPLAYER_BUILD_DIR
ant package-release
cd $STARTING_DIRECTORY

cd ${STARTING_DIRECTORY}
echo "Full set of release packages created."
