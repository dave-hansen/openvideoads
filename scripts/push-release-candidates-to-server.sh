#!/bin/sh
#
#   ./push-release-candidates-to-server.sh
#

WORKSPACE="../../packages"

OVA_FOR_AS3_PACKAGE_DIR=${WORKSPACE}/ova.as3/
OVA_FOR_FLOWPLAYER_PACKAGE_DIR=${WORKSPACE}/ova.flowplayer
OVA_FOR_JWPLAYER_4_PACKAGE_DIR=${WORKSPACE}/ova.jwplayer.4x
OVA_FOR_JWPLAYER_5_PACKAGE_DIR=${WORKSPACE}/ova.jwplayer.5x
OVA_VPAID_EXAMPLES_PACKAGE_DIR=${WORKSPACE}/ova.vpaid.ads

STARTING_DIRECTORY=`pwd`

echo "Pushing the release candidates to the QA server - OVA for Flowplayer, JW and AS3 + VPAID examples..."

echo "Pushing OVA for AS3..."
cd ${OVA_FOR_AS3_PACKAGE_DIR}
scp ova.as3-rc.tar.gz pauls@static.openvideoads.org:/home/pauls

echo "Pushing OVA for JW4..."
cd ${OVA_FOR_JWPLAYER_4_PACKAGE_DIR}
scp ova.jwplayer.4x-rc.tar.gz pauls@static.openvideoads.org:/home/pauls

echo "Pushing OVA for JW5..."
cd ${OVA_FOR_JWPLAYER_5_PACKAGE_DIR}
scp ova.jwplayer.5x-rc.tar.gz pauls@static.openvideoads.org:/home/pauls

echo "Pushing OVA for Flowplayer..."
cd ${OVA_FOR_FLOWPLAYER_PACKAGE_DIR}
scp ova.flowplayer-rc.tar.gz pauls@static.openvideoads.org:/home/pauls

# echo "Pushing OVA VPAID Examples..."

cd ${STARTING_DIRECTORY}
echo "Release candidates pushed."
