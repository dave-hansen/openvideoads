//---- SET THE LOCATION OF THE DISTRIBUTION FILES (SWF, IMAGE AND VAST TEMPLATES)

var OVA_DIST_A_SWF_2 = "../../dist/swf/";
var OVA_DIST_A_SWF_3 = "../../../dist/swf/";
var OVA_DIST_A_SWF_5 = "../../../../../dist/swf/";
var OVA_DIST_B_SWF_2 = "../../dist/swf/";
var OVA_DIST_B_SWF_3 = "../../../dist/swf/";
var OVA_DIST_TEMPLATES_2 = "../../dist/templates/";
var OVA_DIST_TEMPLATES_3 = "../../../dist/templates/";
var OVA_DIST_IMAGES_2 = "../../dist/images/";
var OVA_DIST_IMAGES_3 = "../../../dist/images/";

var IN_TEST_MODE = false;
var ACTIVE_OVA_OAS_VERSION = "ova.swf"
var OVA_OAS_DEBUG = 'fatal, config, vast_template, vpaid, display_events, playlist, http_calls, api, tracking_events';


//---- DO NOT CHANGE ANY VALUES BEYOND HERE

// Flowplayer SWF versions

var FP_3_2_3 = 'flowplayer-3.2.3.swf'
var FP_3_2_4 = 'flowplayer-3.2.4.swf'
var FP_3_2_6 = 'flowplayer-3.2.6.swf'
var FP_3_2_7 = 'flowplayer-3.2.7.swf'
var FP_3_2_8 = 'flowplayer-3.2.8.swf'
var FP_3_2_9 = 'flowplayer-3.2.9.swf'
var FP_3_2_10 = 'flowplayer-3.2.10.swf'
var FP_3_2_11 = 'flowplayer-3.2.11.swf'
var FP_3_2_12 = 'flowplayer-3.2.12.swf'
var FP_3_2_15 = 'flowplayer-3.2.15.swf'
var FP_3_2_16 = 'flowplayer-3.2.16.swf'
var FP_CONTROLS_3_2_2 = 'flowplayer.controls-3.2.2.swf'
var FP_CONTROLS_3_2_4 = 'flowplayer.controls-3.2.4.swf'
var FP_CONTROLS_3_2_5 = 'flowplayer.controls-3.2.5.swf'
var FP_CONTROLS_3_2_8 = 'flowplayer.controls-3.2.8.swf'
var FP_CONTROLS_3_2_9 = 'flowplayer.controls-3.2.9.swf'
var FP_CONTROLS_3_2_10 = 'flowplayer.controls-3.2.10.swf'
var FP_CONTROLS_3_2_11 = 'flowplayer.controls-3.2.11.swf'
var FP_CONTROLS_3_2_12 = 'flowplayer.controls-3.2.12.swf'
var FP_CONTROLS_3_2_14 = 'flowplayer.controls-3.2.14.swf'
var FP_CONTROLS_3_2_15 = 'flowplayer.controls-3.2.15.swf'
var FP_PSEUDO_3_1_3 = 'flowplayer.pseudostreaming-3.1.3.swf'
var FP_PSEUDO_3_2_7 = 'flowplayer.pseudostreaming-3.2.7.swf'
var FP_PSEUDO_3_2_8 = 'flowplayer.pseudostreaming-3.2.8.swf'
var FP_PSEUDO_3_2_9 = 'flowplayer.pseudostreaming-3.2.9.swf'
var FP_RTMP_3_2_0 = 'flowplayer.rtmp-3.2.0.swf'
var FP_RTMP_3_2_3 = 'flowplayer.rtmp-3.2.3.swf'
var FP_RTMP_3_2_8 = 'flowplayer.rtmp-3.2.8.swf'
var FP_RTMP_3_2_9 = 'flowplayer.rtmp-3.2.9.swf'
var FP_RTMP_3_2_10 = 'flowplayer.rtmp-3.2.10.swf'
var FP_BWCHECK_3_2_3 = 'flowplayer.bwcheck-3.2.3.swf';
var FP_BWCHECK_3_2_5 = 'flowplayer.bwcheck-3.2.5.swf';
var FP_BWCHECK_3_2_8 = 'flowplayer.bwcheck-3.2.8.swf';
var FP_BWCHECK_3_2_9 = 'flowplayer.bwcheck-3.2.9.swf';
var FP_CLUSTER_3_2_2 = 'flowplayer.cluster-3.2.2.swf';
var FP_CLUSTER_3_2_3 = 'flowplayer.cluster-3.2.3.swf';
var FP_CLUSTER_3_2_8 = 'flowplayer.cluster-3.2.8.swf';
var FP_AKAMAI_3_2_0 = 'flowplayer.akamai-3.2.0.swf';
var FP_SECURE_3_2_3 = 'flowplayer.securestreaming-3.2.3.swf';
var FP_SECURE_3_2_8 = 'flowplayer.securestreaming-3.2.8.swf';
var FP_SHARING_3_2_1 = 'flowplayer.sharing-3.2.1.swf';
var FP_SHARING_3_2_8 = 'flowplayer.sharing-3.2.8.swf';
var FP_AUDIO_3_2_2 = 'flowplayer.audio-3.2.2.swf';
var FP_AUDIO_3_2_8 = 'flowplayer.audio-3.2.8.swf';
var FP_AUDIO_3_2_9 = 'flowplayer.audio-3.2.9.swf';
var FP_SMIL_3_2_8 = 'flowplayer.smil-3.2.8.swf';
var FP_BWSELECT_3_2_10 = 'flowplayer.bitrateselect-3.2.10.swf';
var FP_MENU_3_2_9 = 'flowplayer.menu-3.2.9.swf';
var FP_F4M_3_2_9 = "flowplayer.f4m-3.2.9.swf";
var FP_HTTP_STREAMING_3_2_10 = "flowplayer.httpstreaming-3.2.10.swf"; 

// Our active settings for the examples

if(true) {
    // 3.2.16 player setup
	var ACTIVE_FP_VERSION = FP_3_2_16
	var ACTIVE_FP_CONTROLS_VERSION = FP_CONTROLS_3_2_15
	var ACTIVE_FP_RTMP_VERSION = FP_RTMP_3_2_10
	var ACTIVE_FP_BWCHECK_VERSION = FP_BWCHECK_3_2_9
	var ACTIVE_FP_PSEUDO_VERSION = FP_PSEUDO_3_2_9
	var ACTIVE_FP_AUDIO_VERSION = FP_AUDIO_3_2_9
	var ACTIVE_FP_SHARING_VERSION = FP_SHARING_3_2_8
	var ACTIVE_FP_SMIL_VERSION = FP_SMIL_3_2_8
	var ACTIVE_FP_CLUSTER_VERSION = FP_CLUSTER_3_2_8
	var ACTIVE_FP_AKAMAI_VERSION = FP_AKAMAI_3_2_0
	var ACTIVE_FP_SECURE_VERSION = FP_SECURE_3_2_8
	var ACTIVE_FP_BWSELECT_VERSION = FP_BWSELECT_3_2_10
	var ACTIVE_FP_MENU_VERSION = FP_MENU_3_2_9
	var ACTIVE_FP_F4M_VERSION = FP_F4M_3_2_9
	var ACTIVE_FP_HTTP_STREAMING_VERSION = FP_HTTP_STREAMING_3_2_10
}
else if(false) {
    // 3.2.12 player setup
	var ACTIVE_FP_VERSION = FP_3_2_12
	var ACTIVE_FP_CONTROLS_VERSION = FP_CONTROLS_3_2_12
	var ACTIVE_FP_RTMP_VERSION = FP_RTMP_3_2_10
	var ACTIVE_FP_BWCHECK_VERSION = FP_BWCHECK_3_2_9
	var ACTIVE_FP_PSEUDO_VERSION = FP_PSEUDO_3_2_9
	var ACTIVE_FP_AUDIO_VERSION = FP_AUDIO_3_2_9
	var ACTIVE_FP_SHARING_VERSION = FP_SHARING_3_2_8
	var ACTIVE_FP_SMIL_VERSION = FP_SMIL_3_2_8
	var ACTIVE_FP_CLUSTER_VERSION = FP_CLUSTER_3_2_8
	var ACTIVE_FP_AKAMAI_VERSION = FP_AKAMAI_3_2_0
	var ACTIVE_FP_SECURE_VERSION = FP_SECURE_3_2_8
	var ACTIVE_FP_BWSELECT_VERSION = FP_BWSELECT_3_2_10
	var ACTIVE_FP_MENU_VERSION = FP_MENU_3_2_9
}
else if(false) {
    // 3.2.11 player setup
	var ACTIVE_FP_VERSION = FP_3_2_11
	var ACTIVE_FP_CONTROLS_VERSION = FP_CONTROLS_3_2_11
	var ACTIVE_FP_RTMP_VERSION = FP_RTMP_3_2_10
	var ACTIVE_FP_BWCHECK_VERSION = FP_BWCHECK_3_2_9
	var ACTIVE_FP_PSEUDO_VERSION = FP_PSEUDO_3_2_9
	var ACTIVE_FP_AUDIO_VERSION = FP_AUDIO_3_2_9
	var ACTIVE_FP_SHARING_VERSION = FP_SHARING_3_2_8
	var ACTIVE_FP_SMIL_VERSION = FP_SMIL_3_2_8
	var ACTIVE_FP_CLUSTER_VERSION = FP_CLUSTER_3_2_8
	var ACTIVE_FP_AKAMAI_VERSION = FP_AKAMAI_3_2_0
	var ACTIVE_FP_SECURE_VERSION = FP_SECURE_3_2_8
	var ACTIVE_FP_BWSELECT_VERSION = FP_BWSELECT_3_2_10
	var ACTIVE_FP_MENU_VERSION = FP_MENU_3_2_9
}
else if(false) {
    // 3.2.10 player setup
	var ACTIVE_FP_VERSION = FP_3_2_10
	var ACTIVE_FP_CONTROLS_VERSION = FP_CONTROLS_3_2_10
	var ACTIVE_FP_RTMP_VERSION = FP_RTMP_3_2_9
	var ACTIVE_FP_BWCHECK_VERSION = FP_BWCHECK_3_2_9
	var ACTIVE_FP_PSEUDO_VERSION = FP_PSEUDO_3_2_9
	var ACTIVE_FP_AUDIO_VERSION = FP_AUDIO_3_2_9
	var ACTIVE_FP_SHARING_VERSION = FP_SHARING_3_2_8
	var ACTIVE_FP_SMIL_VERSION = FP_SMIL_3_2_8
	var ACTIVE_FP_CLUSTER_VERSION = FP_CLUSTER_3_2_8
	var ACTIVE_FP_AKAMAI_VERSION = FP_AKAMAI_3_2_0
	var ACTIVE_FP_SECURE_VERSION = FP_SECURE_3_2_8
	var ACTIVE_FP_BWSELECT_VERSION = FP_BWSELECT_3_2_10
	var ACTIVE_FP_MENU_VERSION = FP_MENU_3_2_9
}
else if(false) {
    // 3.2.9 player setup
	var ACTIVE_FP_VERSION = FP_3_2_9
	var ACTIVE_FP_CONTROLS_VERSION = FP_CONTROLS_3_2_9
	var ACTIVE_FP_RTMP_VERSION = FP_RTMP_3_2_8
	var ACTIVE_FP_BWCHECK_VERSION = FP_BWCHECK_3_2_8
	var ACTIVE_FP_PSEUDO_VERSION = FP_PSEUDO_3_2_8
	var ACTIVE_FP_AUDIO_VERSION = FP_AUDIO_3_2_8
	var ACTIVE_FP_SHARING_VERSION = FP_SHARING_3_2_8
	var ACTIVE_FP_SMIL_VERSION = FP_SMIL_3_2_8
	var ACTIVE_FP_CLUSTER_VERSION = FP_CLUSTER_3_2_3
	var ACTIVE_FP_AKAMAI_VERSION = FP_AKAMAI_3_2_0
	var ACTIVE_FP_SECURE_VERSION = FP_SECURE_3_2_3
	var ACTIVE_FP_BWSELECT_VERSION = FP_BWSELECT_3_2_10
	var ACTIVE_FP_MENU_VERSION = FP_MENU_3_2_9
}
else {
    // 3.2.7 player setup
	var ACTIVE_FP_VERSION = FP_3_2_7
	var ACTIVE_FP_CONTROLS_VERSION = FP_CONTROLS_3_2_5
	var ACTIVE_FP_RTMP_VERSION = FP_RTMP_3_2_3
	var ACTIVE_FP_BWCHECK_VERSION = FP_BWCHECK_3_2_5
	var ACTIVE_FP_PSEUDO_VERSION = FP_PSEUDO_3_2_7
	var ACTIVE_FP_AUDIO_VERSION = FP_AUDIO_3_2_2
	var ACTIVE_FP_SHARING_VERSION = FP_SHARING_3_2_1
	var ACTIVE_FP_SMIL_VERSION = FP_SMIL_3_2_8
	var ACTIVE_FP_CLUSTER_VERSION = FP_CLUSTER_3_2_3
	var ACTIVE_FP_AKAMAI_VERSION = FP_AKAMAI_3_2_0
	var ACTIVE_FP_SECURE_VERSION = FP_SECURE_3_2_3
	var ACTIVE_FP_BWSELECT_VERSION = FP_BWSELECT_3_2_10
	var ACTIVE_FP_MENU_VERSION = FP_MENU_3_2_9
}

// Setup the paths

var FP_SWF = OVA_DIST_A_SWF_3 + ACTIVE_FP_VERSION
var FP_SWF_2 = OVA_DIST_A_SWF_2 + ACTIVE_FP_VERSION
var FP_SWF_5 = OVA_DIST_A_SWF_5 + ACTIVE_FP_VERSION
var FP_CONTROLS_SWF = OVA_DIST_A_SWF_3 + ACTIVE_FP_CONTROLS_VERSION
var FP_CONTROLS_SWF_2 = OVA_DIST_A_SWF_2 + ACTIVE_FP_CONTROLS_VERSION
var FP_RTMP_SWF = OVA_DIST_A_SWF_3 + ACTIVE_FP_RTMP_VERSION
var FP_RTMP_SWF_2 = OVA_DIST_A_SWF_2 + ACTIVE_FP_RTMP_VERSION
var FP_PSEUDO_SWF = OVA_DIST_A_SWF_3 + ACTIVE_FP_PSEUDO_VERSION
var FP_PSEUDO_SWF_2 = OVA_DIST_A_SWF_2 + ACTIVE_FP_PSEUDO_VERSION
var FP_BWCHECK_SWF = OVA_DIST_A_SWF_3 + ACTIVE_FP_BWCHECK_VERSION
var FP_BWCHECK_SWF_2 = OVA_DIST_A_SWF_2 + ACTIVE_FP_BWCHECK_VERSION
var FP_CLUSTER_SWF = OVA_DIST_A_SWF_3 + ACTIVE_FP_CLUSTER_VERSION
var FP_CLUSTER_SWF_2 = OVA_DIST_A_SWF_2 + ACTIVE_FP_CLUSTER_VERSION
var FP_AKAMAI_SWF = OVA_DIST_A_SWF_3 + ACTIVE_FP_AKAMAI_VERSION
var FP_AKAMAI_SWF_2 = OVA_DIST_A_SWF_2 + ACTIVE_FP_AKAMAI_VERSION
var FP_SECURE_SWF = OVA_DIST_A_SWF_3 + ACTIVE_FP_SECURE_VERSION
var FP_SECURE_SWF_2 = OVA_DIST_A_SWF_2 + ACTIVE_FP_SECURE_VERSION
var FP_SHARING_SWF = OVA_DIST_A_SWF_3 + ACTIVE_FP_SHARING_VERSION
var FP_SHARING_SWF_2 = OVA_DIST_A_SWF_2 + ACTIVE_FP_SHARING_VERSION
var FP_AUDIO_SWF = OVA_DIST_A_SWF_3 + ACTIVE_FP_AUDIO_VERSION
var FP_AUDIO_SWF_2 = OVA_DIST_A_SWF_2 + ACTIVE_FP_AUDIO_VERSION
var FP_SMIL_SWF = OVA_DIST_A_SWF_3 + ACTIVE_FP_SMIL_VERSION
var FP_BWSELECT_SWF = OVA_DIST_A_SWF_3 + ACTIVE_FP_BWSELECT_VERSION
var FP_F4M_SWF = OVA_DIST_A_SWF_3 + ACTIVE_FP_F4M_VERSION;
var FP_HTTP_STREAMING_SWF = OVA_DIST_A_SWF_3 + ACTIVE_FP_HTTP_STREAMING_VERSION;

// Our active OAS settings

var OVA_OAS_URL = OVA_DIST_B_SWF_3 + ACTIVE_OVA_OAS_VERSION;
var OVA_OAS_URL_2 = OVA_DIST_B_SWF_2 + ACTIVE_OVA_OAS_VERSION;
var OVA_OAS_URL_5 = OVA_DIST_A_SWF_5 + ACTIVE_OVA_OAS_VERSION;

// OpenX addresses

var OVA_OPENX_API = "http://openx.openvideoads.org/openx/www/delivery/fc.php";
var OVA_OPENX_V3_HOSTED = "http://oxdemo-d.openxenterprise.com/v/1.0/av";

// Streaming server base addresses

var OVA_HTTP_BASE_URL = "http://streaming.openvideoads.org/shows";
var OVA_RTMP_BASE_URL = "rtmp://ne7c0nwbit.rtmphost.com/videoplayer";
var OVA_PSEUDO_BASE_URL = "http://streaming.openvideoads.org:81/shows";

// Specific streams

var OVA_HTTP_SHOW_STREAM_1 = "http://streaming.openvideoads.org/shows/the-black-hole.mp4";
var OVA_PSEUDO_SHOW_STREAM_1 = "http://streaming.openvideoads.org:81/shows/the-black-hole.mp4";
var OVA_RTMP_SHOW_STREAM_1 = "rtmp://ne7c0nwbit.rtmphost.com/videoplayer/mp4:the-black-hole.mp4";
var OVA_PSEUDO_BUNNY_STREAM = "http://streaming.openvideoads.org:81/shows/bbb-640x360.mp4"
var OVA_HTTP_BUNNY_STREAM = "http://streaming.openvideoads.org/shows/bbb-640x360.mp4"
var OVA_RTMP_SHOW_STREAM_FILE = "mp4:the-black-hole.mp4";
var OVA_HTTP_SHOW_STREAM_FILE = "the-black-hole.mp4";
var OVA_HTTP_SHOW_STREAM_FILE_FLV = "the-black-hole.flv";
var OVA_PSEUDO_SHOW_STREAM_FILE = "the-black-hole.mp4";
var OVA_BLANK_IMAGE_CLIP = "http://static.openvideoads.org/ads/blank/blank-pixel.jpg";
var OVA_HOLDING_CLIP="http://content.bitsontherun.com/videos/CWV6XUu0-8ULb9uN9.mp4"

// Specific static files (VAST responses, images and playlists)

var OVA_INTERACTIVE_PREROLL_1 = OVA_DIST_TEMPLATES_2 + "interactive/interactive-preroll.xml";
var OVA_INTERACTIVE_PREROLL_2 = OVA_DIST_TEMPLATES_2 + "interactive/interactive-preroll2.xml";
var OVA_INTERACTIVE_PREROLL_3 = OVA_DIST_TEMPLATES_2 + "interactive/interactive-preroll3.xml";
var OVA_INTERACTIVE_PREROLL_4 = OVA_DIST_TEMPLATES_2 + "interactive/interactive-preroll4.xml";
var OVA_COMPANIONS_VAST_1 = OVA_DIST_TEMPLATES_2 + "companions/companions-vast1.xml"
var OVA_COMPANIONS_VAST_2 = OVA_DIST_TEMPLATES_2 + "companions/companions-vast2.xml"
var OVA_COMPANIONS_VAST_NO_CREATIVE_TYPE = OVA_DIST_TEMPLATES_2 + "companions/companions-no-creative-type-vast1.xml"
var OVA_VAST_MP4_RTMP_AD_WITH_MARKERS = OVA_DIST_TEMPLATES_2 + "rtmp-ads/vast1-mp4-with-markers.xml"
var OVA_VAST_MP4_RTMP_AD_NO_MARKERS = OVA_DIST_TEMPLATES_2 + "rtmp-ads/vast1-mp4-no-markers.xml"
var OVA_VAST_MP4_RTMP_AD_NO_MARKERS_NO_MIME_TYPE = OVA_DIST_TEMPLATES_2 + "rtmp-ads/vast1-mp4-no-markers-no-mime-type.xml"
var OVA_VAST_MP4_RTMP_AD_NO_MARKERS_NO_MIME_TYPE_NO_EXTENSION = OVA_DIST_TEMPLATES_2 + "rtmp-ads/vast1-mp4-no-markers-no-mime-type-no-extension.xml"
var OVA_VAST_FLV_RTMP_AD_WITH_MARKERS = OVA_DIST_TEMPLATES_2 + "rtmp-ads/vast1-flv-with-markers.xml"
var OVA_VAST_FLV_RTMP_AD_NO_MARKERS = OVA_DIST_TEMPLATES_2 + "rtmp-ads/vast1-flv-no-markers.xml"
var OVA_VAST_FLV_RTMP_AD_NO_MARKERS_NO_MIME_TYPE = OVA_DIST_TEMPLATES_2 + "rtmp-ads/vast1-flv-no-markers-no-mime-type.xml"
var OVA_EMPTY_VAST_RESPONSE = OVA_DIST_TEMPLATES_2 + "error-responses/vast1.0/empty-ad-vast-response.xml";
var OVA_EMPTY_VAST2_RESPONSE = OVA_DIST_TEMPLATES_2 + "error-responses/vast2.0/empty-ad-vast-response.xml";
var OVA_EMPTY_VAST2_WRAPPED_RESPONSE = OVA_DIST_TEMPLATES_2 + "error-responses/vast2.0/empty-wrapped-vast-response.xml";
var OVA_EMPTY_VAST1_WRAPPED_RESPONSE = OVA_DIST_TEMPLATES_2 + "error-responses/vast1.0/empty-wrapped-vast-response.xml";
var OVA_EMPTY_VAST2_WRAPPED_RESPONSE_WITH_TEMPLATE_AD = OVA_DIST_TEMPLATES_2 + "error-responses/vast2.0/empty-wrapped-vast-with-template-ad.xml";
var OVA_BLANK_VAST_RESPONSE = OVA_DIST_TEMPLATES_2 + "error-responses/vast1.0/blank-vast-response.xml";
var OVA_BAD_VAST_RESPONSE = OVA_DIST_TEMPLATES_2 + "error-responses/vast1.0/bad-vast-response.xml";
var OVA_ZERO_DURATION_VAST = OVA_DIST_TEMPLATES_3 + "error-responses/vast1.0/zero-duration.xml";
var OVA_VAST_1_WRAPPER_RESPONSE = OVA_DIST_TEMPLATES_2 + "wrapper/vast1-wrapper.xml";
var OVA_VPAID_LINEAR_1_VAST= OVA_DIST_TEMPLATES_3 + "ad-servers/eyewonder/vpaid-linear-01.xml"
var OVA_VPAID_NON_LINEAR_1_VAST= OVA_DIST_TEMPLATES_3 + "ad-servers/eyewonder/vpaid-non-linear-01.xml"
var OVA_VPAID_LINEAR_2_VAST= "http://www.adotube.com/kernel/vast/vast.php?omlSource=http://www.adotube.com/php/services/player/OMLService.php?avpid=UDKjuff__amp__ad_type=pre-rolls__amp__platform_version=vast20as3__amp__vpaid=1__amp__rtb=0__amp__publisher=adotube.com__amp__title=[VIDEO_TITLE]__amp__tags=[VIDEO_TAGS]__amp__description=[VIDEO_DESCRIPTION]__amp__videoURL=[VIDEO_FILE_URL]"
var OVA_VPAID_LINEAR_3_VAST= OVA_DIST_TEMPLATES_2 + "ad-servers/eyewonder/vpaid-linear-01.xml"
var OVA_VPAID_LINEAR_4_VAST= OVA_DIST_TEMPLATES_2 + "ad-servers/iroll/vpaid-linear-01.xml"
var OVA_VPAID_NON_LINEAR_2_VAST= OVA_DIST_TEMPLATES_2 + "ad-servers/eyewonder/vpaid-non-linear-01.xml"
var OVA_DELAYED_RESPONSE_AD_TAG = "http://static.openvideoads.org/tests/delayed-ad-tag-processor.php"
var OVA_DELAYED_RESPONSE_WRAPPED_AD_TAG = "http://static.openvideoads.org/tests/vast1-wrapper-to-delayed-response.xml"
var OVA_VAST_OVERLAY_SCALED_MAINTAIN_TAG = OVA_DIST_TEMPLATES_2 + "overlays/scaled-maintain-aspect.xml"
var OVA_VAST_OVERLAY_SCALED_NOT_MAINTAINED_TAG = OVA_DIST_TEMPLATES_2 + "overlays/scaled-no-aspect-maintained.xml"
var OVA_VAST_NOT_SCALED_TAG = OVA_DIST_TEMPLATES_2 + "overlays/not-scaled.xml"
var OVA_VAST_EXTENSION_TAGS = OVA_DIST_TEMPLATES_2 + "custom-tags/extensions-clicktracking.xml"
var OVA_VAST_WRAPPED_VPAID = OVA_DIST_TEMPLATES_2 + "wrapper/vast2-wrapper-vpaid.xml"
var OVA_BAD_VAST_XML = OVA_DIST_TEMPLATES_2 + "error-responses/bad-xml.xml"
var OVA_WRAPPER_EMPTY_2 = OVA_DIST_TEMPLATES_2 + "wrapper/vast2-wrapper-empty.xml"
var OVA_VPAID_LINEAR_INNOVID = OVA_DIST_TEMPLATES_3 + "ad-servers/innovid/vpaid-linear.xml"
var OVA_VPAID_LINEAR_INNOVID_2 = OVA_DIST_TEMPLATES_2 + "ad-servers/innovid/vpaid-linear.xml"
var OVA_VPAID_LINEAR_SPOTXCHANGE = "http://search.spotxchange.com/vast/2.00/74856?VPAID=1OVA_VPAID_LINEAR_SPOTXCHANGEcontent_page_url=[page_url]OVA_VPAID_LINEAR_SPOTXCHANGEcb=__random-number__"
var OVA_VPAID_SECURITY_EXCEPTION = OVA_DIST_TEMPLATES_2 + "error-responses/vast2.0/security-exception.xml"
var OVA_VPAID_SECURITY_EXCEPTION_3 = OVA_DIST_TEMPLATES_3 + "error-responses/vast2.0/security-exception.xml"
var OVA_HTTP_AUDIO_STREAM_1 = "http://static.openvideoads.org/shows/girlwho.mp3"
var OVA_AUDIO_LINEAR_VAST = OVA_DIST_TEMPLATES_2 + "audio-ads/vast1-mp3-linear.xml"
var OVA_OPENX_BITRATED_VAST = OVA_DIST_TEMPLATES_2 + "bitrated/openx-bitrates-vast.xml"
var OVA_OPENX_BITRATED_VAST_WRAPPED = OVA_DIST_TEMPLATES_2 + "bitrated/vast1-wrapper-bitrates-tag.xml"
var OVA_RSS_PLAYLIST_1 = OVA_DIST_TEMPLATES_2 + "playlists/playlist.rss"
var OVA_RSS_PLAYLIST_1_3 = OVA_DIST_TEMPLATES_3 + "playlists/playlist.rss"
var OVA_RSS_PLAYLIST_2 = OVA_DIST_TEMPLATES_2 + "playlists/example12.rss"
var OVA_RSS_PLAYLIST_2_3 = OVA_DIST_TEMPLATES_3 + "playlists/example12.rss"
var OVA_RSS_PLAYLIST_3 = OVA_DIST_TEMPLATES_2 + "playlists/example08.rss"
var OVA_RSS_PLAYLIST_3_3 = OVA_DIST_TEMPLATES_3 + "playlists/example08.rss"
var OVA_LOGO_IMAGE = OVA_DIST_IMAGES_2 + "logo.png"
var OVA_LOGO_IMAGE_3 = OVA_DIST_IMAGES_3 + "logo.png"
var OVA_EXAMPLE_OVERLAY_CUSTOM_BUTTON =  OVA_DIST_IMAGES_3 + "button-custom-sepia.png"
var OVA_SKIP_BUTTON_IMAGE_ALT_1 = OVA_DIST_IMAGES_2 + "skip-ad-alt-1.jpg"
var OVA_VPAID_LINEAR_ADOTUBE = "http://www.adotube.com/kernel/vast/vast.php?omlSource=http://www.adotube.com/php/services/player/OMLService.php?avpid=UDKjuff__amp__ad_type=pre-rolls__amp__platform_version=vast20as3__amp__vpaid=1__amp__rtb=0__amp__publisher=adotube.com__amp__title=[VIDEO_TITLE]__amp__tags=[VIDEO_TAGS]__amp__description=[VIDEO_DESCRIPTION]__amp__videoURL=[VIDEO_FILE_URL]"
var OVA_VPAID_NON_LINEAR_ADOTUBE = "http://www.adotube.com/kernel/vast/vast.php?omlSource=http://www.adotube.com/php/services/player/OMLService.php?avpid=pctozxH__amp__ad_type=overlays__amp__platform_version=vast20as3__amp__vpaid=1__amp__rtb=0__amp__publisher=adotube.com"
var OVA_SMIL_FILE = OVA_DIST_TEMPLATES_3 + "playlists/bitrates.smil.xml"
var OVA_BAD_STREAM_URL = OVA_DIST_TEMPLATES_2 + "error-responses/vast1.0/bad-stream-url.xml";
var OVA_VAST_OVERLAY_EXPANDABLE = OVA_DIST_TEMPLATES_3 + "overlays/expandable/vast2-vpaid-expandable.xml"
var OVA_VAST_OVERLAY_SCALABLE_EXPANDABLE = OVA_DIST_TEMPLATES_3 + "overlays/expandable/vast2-vpaid-expandable-scalable.xml"
var OVA_VAST_VPAID_LINEAR_TRACKING = OVA_DIST_TEMPLATES_3 + "vpaid/vast2-vpaid1-linear-tracking.xml"
var OVA_VAST_VPAID_OVERLAY_TRACKING = OVA_DIST_TEMPLATES_3 + "vpaid/vast2-vpaid1-non-linear-tracking.xml"
var OVA_VAST_CLOSE_TRACKING = OVA_DIST_TEMPLATES_2 + "skip-ad/vast1.xml"

if(IN_TEST_MODE) { // in test mode - used during development - leave false for production
	OVA_OAS_URL = 'http://localhost/ova-fp-dev/ova.swf';
	OVA_OAS_URL_2 = OVA_OAS_URL;
    OVA_OAS_DEBUG = 'fatal, config, vast_template';
}

function debug(output) {
    try {
       console.log(output);
    }
    catch(error) {}
}

// OVA Javascript Callback Methods

function onVPAIDAdStart(ad) {
	debug("OVA CALLBACK EVENT: VPAID Ad Start");
	debug(ad);
}

function onLinearAdStart(ad) {
	debug("OVA CALLBACK EVENT: Linear Ad Start");
	debug(ad);
}
