# This is a simple script that compiles the plugin using MXMLC (free & cross-platform).
# To use, make sure you have downloaded and installed the Flex SDK in the following directory:

FLEXPATH=/Applications/flex_sdk_3

echo "Compiling the OVA for JW 4.x plugin v1.0.0 (creating ova-jw.swf in the release directory)..."
$FLEXPATH/bin/mxmlc ../../src/ova.as -source-path ../../src -o ../../release/ova-jw.swf -warnings=false -debug=false -library-path ../../lib -use-network=false
cp ../../release/ova-jw.swf ../../dist/swf
echo "OVA for JW Player 4 build done."