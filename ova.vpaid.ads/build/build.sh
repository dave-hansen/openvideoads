# This is a simple script that compiles the plugin using MXMLC (free & cross-platform).
# To use, make sure you have downloaded and installed the Flex SDK in the following directory:
FLEXPATH=/Applications/flex_sdk_3

echo "Compiling OVA VPAID 1.x Examples..."
echo "Example 1: Simple Countdown Timer..."
$FLEXPATH/bin/mxmlc ../src/org/openvideoads/examples/vpaid/v1/SimpleCountdownExample.as -source-path ../src -o ../dist/vpaid1-countdown-example.swf -warnings=false -debug=false -library-path ../lib $FLEXPATH/frameworks/libs -use-network=false
echo "Example 2: Expandable Countdown Timer..."
$FLEXPATH/bin/mxmlc ../src/org/openvideoads/examples/vpaid/v1/ExpandableNonLinearExample.as -source-path ../src -o ../dist/vpaid1-expandable-example.swf -warnings=false -debug=false -library-path ../lib $FLEXPATH/frameworks/libs -use-network=false
echo "Example 3: Linear Tracking Events Test Harness..."
$FLEXPATH/bin/mxmlc ../src/org/openvideoads/examples/vpaid/v1/LinearTrackingEventsTest.as -source-path ../src -o ../dist/vpaid1-linear-tracking-events-test.swf -warnings=false -debug=false -library-path ../lib $FLEXPATH/frameworks/libs -use-network=false
echo "Example 4: Non-Linear Tracking Events Test Harness..."
$FLEXPATH/bin/mxmlc ../src/org/openvideoads/examples/vpaid/v1/NonLinearTrackingEventsTest.as -source-path ../src -o ../dist/vpaid1-non-linear-tracking-events-test.swf -warnings=false -debug=false -library-path ../lib $FLEXPATH/frameworks/libs -use-network=false
echo "Example 5: Blank Ad..."
$FLEXPATH/bin/mxmlc ../src/org/openvideoads/examples/vpaid/v1/BlankAd.as -source-path ../src -o ../dist/vpaid1-non-linear-blank.swf -warnings=false -debug=false -library-path ../lib $FLEXPATH/frameworks/libs -use-network=false
echo "Example 6: Terminate on Log Text Ad..."
$FLEXPATH/bin/mxmlc ../src/org/openvideoads/examples/vpaid/v1/LogTerminateTestAd.as -source-path ../src -o ../dist/vpaid1-log-terminate-test-ad.swf -warnings=false -debug=false -library-path ../lib $FLEXPATH/frameworks/libs -use-network=false
echo "Example 7: Error Event Test Ad..."
$FLEXPATH/bin/mxmlc ../src/org/openvideoads/examples/vpaid/v1/ErrorTestAd.as -source-path ../src -o ../dist/vpaid1-error-test.swf -warnings=false -debug=false -library-path ../lib $FLEXPATH/frameworks/libs -use-network=false

echo "Compiling OVA VPAID 2.x Examples..."
echo "Example 1: Linear Ad Test Harness..."
$FLEXPATH/bin/mxmlc ../src/org/openvideoads/examples/vpaid/v2/LinearAdTest.as -source-path ../src -o ../dist/vpaid2-linear-test-ad.swf -warnings=false -debug=false -library-path ../lib $FLEXPATH/frameworks/libs -use-network=false
echo "Example 2: Non-Linear Ad Test Harness..."
$FLEXPATH/bin/mxmlc ../src/org/openvideoads/examples/vpaid/v2/NonLinearAdTest.as -source-path ../src -o ../dist/vpaid2-non-linear-test-ad.swf -warnings=false -debug=false -library-path ../lib $FLEXPATH/frameworks/libs -use-network=false

echo "done."
