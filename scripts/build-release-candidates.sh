#!/bin/sh
#
#   ./create-release-candidates.sh
#

WORKSPACE=".."

OVA_FOR_AS3_BUILD_DIR=${WORKSPACE}/ova.as3/build
OVA_FOR_JWPLAYER_5_BUILD_DIR=${WORKSPACE}/ova.jwplayer.5x/build
OVA_FOR_FLOWPLAYER_BUILD_DIR=${WORKSPACE}/ova.flowplayer/build
OVA_VPAID_EXAMPLES_BUILD_DIR=${WORKSPACE}/ova.vpaid.ads/build

# OVA_FOR_JWPLAYER_4_BUILD_DIR=${WORKSPACE}/ova.jwplayer.4x/scripts/build
# OVA_FOR_JWPLAYER_4_RELEASE_DIR=${WORKSPACE}/ova.jwplayer.4x/scripts/release

STARTING_DIRECTORY=`pwd`

echo "Building the full release - OVA for Flowplayer, JW and AS3 + VPAID examples..."

echo "Building OVA for AS3..."
cd $OVA_FOR_AS3_BUILD_DIR
ant deploy
ant package-release-candidate
cd $STARTING_DIRECTORY

# DEPRECIATED
# echo "Building OVA for JW4..."
# cd $OVA_FOR_JWPLAYER_4_BUILD_DIR
# ./build.sh
# cd $OVA_FOR_JWPLAYER_4_RELEASE_DIR
# ./create-release-candidate.sh

echo "Building OVA for JW5..."
cd $OVA_FOR_JWPLAYER_5_BUILD_DIR
ant package-release-candidate
cd $STARTING_DIRECTORY

echo "Building OVA for Flowplayer..."
cd $OVA_FOR_FLOWPLAYER_BUILD_DIR
ant package-release-candidate
cd $STARTING_DIRECTORY

# NOT RELEASED AS RC
# echo "Building OVA VPAID Examples..."
# cd $OVA_VPAID_EXAMPLES_BUILD_DIR
# ./build.sh
cd $STARTING_DIRECTORY

echo "Release candidates built."
