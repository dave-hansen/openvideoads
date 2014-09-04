#!/bin/sh

OVA_AS3_VERSION="1.2.0"
OVA_FLOWPLAYER_VERSION="1.2.0"
OVA_JW4X_VERSION="1.2.0"
OVA_JW5X_VERSION="1.2.0"

echo "Tagging ova.as3 trunk as ${OVA_AS3_VERSION} ..."
svn copy http://paul@developer.longtailvideo.com/svn/ova/trunk/ova.as3 http://paul@developer.longtailvideo.com/svn/ova/tags/ova.as3/release-${OVA_AS3_VERSION} -m "Tagging of the ${OVA_AS3_VERSION} release of the ova.as3 framework"

echo "Tagging ova.as3 release package as ${OVA_AS3_VERSION} ..."
svn copy http://paul@developer.longtailvideo.com/svn/ova/packages/ova.as3 http://paul@developer.longtailvideo.com/svn/ova/tags/ova.as3/package-${OVA_AS3_VERSION} -m "Tagging of the ${OVA_AS3_VERSION} release package of the ova.as3 framework"

echo "Tagging ova.flowplayer trunk as ${OVA_FLOWPLAYER_VERSION} ..."
svn copy http://paul@developer.longtailvideo.com/svn/ova/trunk/ova.flowplayer http://paul@developer.longtailvideo.com/svn/ova/tags/ova.flowplayer/release-${OVA_FLOWPLAYER_VERSION} -m "Tagging of the ${OVA_FLOWPLAYER_VERSION} release of the ova.flowplayer plugin"

echo "Tagging ova.flowplayer release package as ${OVA_FLOWPLAYER_VERSION} ..."
svn copy http://paul@developer.longtailvideo.com/svn/ova/packages/ova.flowplayer http://paul@developer.longtailvideo.com/svn/ova/tags/ova.flowplayer/package-${OVA_FLOWPLAYER_VERSION} -m "Tagging of the ${OVA_FLOWPLAYER_VERSION} release package of the ova.flowplayer plugin"

# DEPRECIATED
# echo "Tagging ova.jwplayer.4x trunk as ${OVA_JW4X_VERSION} ..."
# svn copy http://paul@developer.longtailvideo.com/svn/ova/trunk/ova.jwplayer.4x http://paul@developer.longtailvideo.com/svn/ova/tags/ova.jwplayer.4x/release-${OVA_JW4X_VERSION} -m "Tagging of the ${OVA_JW4X_VERSION} release of the ova.jwplayer.4x plugin"
# echo "Tagging ova.jwplayer.4x release package as ${OVA_JW4X_VERSION} ..."
# svn copy http://paul@developer.longtailvideo.com/svn/ova/packages/ova.jwplayer.4x http://paul@developer.longtailvideo.com/svn/ova/tags/ova.jwplayer.4x/package-${OVA_JW4X_VERSION} -m "Tagging of the ${OVA_JW4X_VERSION} package of the ova.jwplayer.4x plugin"

echo "Tagging ova.jwplayer.5x trunk as ${OVA_JW5X_VERSION} ..."
svn copy http://paul@developer.longtailvideo.com/svn/ova/trunk/ova.jwplayer.5x http://paul@developer.longtailvideo.com/svn/ova/tags/ova.jwplayer.5x/release-${OVA_JW5X_VERSION} -m "Tagging of the ${OVA_JW5X_VERSION} release of the ova.jwplayer.4x plugin"

echo "Tagging ova.jwplayer.5x release package as ${OVA_JW5X_VERSION} ..."
svn copy http://paul@developer.longtailvideo.com/svn/ova/packages/ova.jwplayer.5x http://paul@developer.longtailvideo.com/svn/ova/tags/ova.jwplayer.5x/package-${OVA_JW5X_VERSION} -m "Tagging of the ${OVA_JW5X_VERSION} package of the ova.jwplayer.4x plugin"

echo "Tagging asset release as 1.2.0 ..."
svn copy http://paul@developer.longtailvideo.com/svn/ova/trunk/assets http://paul@developer.longtailvideo.com/svn/ova/tags/assets/v1.1.0 -m "Tagging of the OVA assets for the 1.2.0 release"
