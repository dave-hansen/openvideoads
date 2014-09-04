#!/bin/sh
#
#   ./build-all-examples.sh
#

WORKSPACE=".."
# OVA_FOR_JWPLAYER_4_PUBLISH_DIR=${WORKSPACE}/ova.jwplayer.4x/scripts/publish
OVA_FOR_JWPLAYER_5_PUBLISH_DIR=${WORKSPACE}/ova.jwplayer.5x/scripts/publish
STARTING_DIRECTORY=`pwd`

# DEPRECIATED echo "Building OVA for JW4..."
# cd ${OVA_FOR_JWPLAYER_4_PUBLISH_DIR}
# ./create-local-examples.sh

echo "Building OVA for JW5..."
cd ${OVA_FOR_JWPLAYER_5_PUBLISH_DIR}
./create-local-examples.sh

cd ${STARTING_DIRECTORY}
echo "Full release build done."
