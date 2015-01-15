/*
 * Examplifier script used on the OVA support site - generates OVA for JW5 and OVA for Flowplayer embed code
 *
 *    Author: Paul Schulz
 *    Date: July 30, 2012
 *    Version: 1.1.0
 *
 */

$(document).ready(function() {

// PLAYERS AND PLUGINS

var OVA_JW5_PLAYER_SWF = "/content/ova/jwplayer/player.swf"
var OVA_JW5_LICENSED_PLAYER_SWF = "/content/ova/jwplayer/player.swf"

if(true) {
    // Flowplayer 3.2.12 setup for OVA 1.1.0 release
	var OVA_FLOWPLAYER_PLUGIN_SWF = "/content/ova/flowplayer/ova-1.1.0.swf"
	var OVA_FLOWPLAYER_SWF = "/content/ova/flowplayer/flowplayer-3.2.12.swf"
	var OVA_FLOWPLAYER_AUDIO_PLUGIN_SWF = "/content/ova/flowplayer/flowplayer.audio-3.2.9.swf"
	var OVA_FLOWPLAYER_RTMP_PLUGIN_SWF = "/content/ova/flowplayer/flowplayer.rtmp-3.2.10.swf"
	var OVA_FLOWPLAYER_BWCHECK_PLUGIN_SWF = "/content/ova/flowplayer/flowplayer.bwcheck-3.2.10.swf"
	var OVA_FLOWPLAYER_SMIL_PLUGIN_SWF = "/content/ova/flowplayer/flowplayer.smil-3.2.8.swf"
	var OVA_FLOWPLAYER_CLUSTER_PLUGIN_SWF = "/content/ova/flowplayer/flowplayer.cluster-3.2.8.swf"
	var OVA_FLOWPLAYER_PROXY_PLUGIN_SWF = "/content/ova/flowplayer/flowplayer.akamai-3.2.0.swf"
	var OVA_FLOWPLAYER_SECURE_PLUGIN_SWF = "/content/ova/flowplayer/flowplayer.securestreaming-3.2.8.swf"
}
else if(false) {
    // Flowplayer 3.2.9 setup for OVA 1.0.1 release
	var OVA_FLOWPLAYER_PLUGIN_SWF = "/content/ova/flowplayer/ova-1.0.1.swf"
	var OVA_FLOWPLAYER_SWF = "/content/ova/flowplayer/flowplayer-3.2.9.swf"
	var OVA_FLOWPLAYER_AUDIO_PLUGIN_SWF = "/content/ova/flowplayer/flowplayer.audio-3.2.8.swf"
	var OVA_FLOWPLAYER_RTMP_PLUGIN_SWF = "/content/ova/flowplayer/flowplayer.rtmp-3.2.8.swf"
	var OVA_FLOWPLAYER_BWCHECK_PLUGIN_SWF = "/content/ova/flowplayer/flowplayer.bwcheck-3.2.8.swf"
	var OVA_FLOWPLAYER_SMIL_PLUGIN_SWF = "/content/ova/flowplayer/flowplayer.smil-3.2.8.swf"
	var OVA_FLOWPLAYER_CLUSTER_PLUGIN_SWF = "/content/ova/flowplayer/flowplayer.cluster-3.2.3.swf"
	var OVA_FLOWPLAYER_PROXY_PLUGIN_SWF = "/content/ova/flowplayer/flowplayer.akamai-3.2.0.swf"
	var OVA_FLOWPLAYER_SECURE_PLUGIN_SWF = "/content/ova/flowplayer/flowplayer.securestreaming-3.2.3.swf"
}
else {
    // Flowplayer 3.2.7 setup for OVA 1.0.0 release
	var OVA_FLOWPLAYER_PLUGIN_SWF = "/content/ova/flowplayer/ova-1.0.0.swf"
	var OVA_FLOWPLAYER_SWF = "/content/ova/flowplayer/flowplayer-3.2.7.swf"
	var OVA_FLOWPLAYER_AUDIO_PLUGIN_SWF = "/content/ova/flowplayer/flowplayer.audio-3.2.2.swf"
	var OVA_FLOWPLAYER_RTMP_PLUGIN_SWF = "/content/ova/flowplayer/flowplayer.rtmp-3.2.3.swf"
	var OVA_FLOWPLAYER_BWCHECK_PLUGIN_SWF = "/content/ova/flowplayer/flowplayer.bwcheck-3.2.5.swf"
	var OVA_FLOWPLAYER_CLUSTER_PLUGIN_SWF = "/content/ova/flowplayer/flowplayer.cluster-3.2.3.swf"
	var OVA_FLOWPLAYER_PROXY_PLUGIN_SWF = "/content/ova/flowplayer/flowplayer.akamai-3.2.0.swf"
	var OVA_FLOWPLAYER_SECURE_PLUGIN_SWF = "/content/ova/flowplayer/flowplayer.securestreaming-3.2.3.swf"
	var OVA_FLOWPLAYER_SMIL_PLUGIN_SWF = "/content/ova/flowplayer/flowplayer.smil-3.2.8.swf"
}

var OVA_JW5_PLUGIN_SWF = "ova-jw"
var OVA_JW5_PLUGIN_JS = "ova-jw"
var OVA_JW5_PLUGIN = OVA_JW5_PLUGIN_JS;
var OVA_FLOWPLAYER_SECURE_TOKEN = escape('#ed%h0#w@1')

// STREAMS

var OVA_HTTP_SHOW_STREAM = "http://video.bitmedianetwork.com/ads/testpattern.mp4"
var OVA_HTTP_SHOW_STREAM_2 = "http://video.bitmedianetwork.com/ads/testpattern.mp4"
var OVA_PSEUDO_SHOW_STREAM = "http://video.bitmedianetwork.com/ads/testpattern.mp4"
var OVA_AUDIO_SHOW_STREAM = "/jw/upload/bunny.mp3"

// IMAGES, SKINS

var OVA_HTTP_SHOW_STREAM_IMAGE = "/content/ova/images/train-splash-640x480.jpg"
var OVA_CUSTOM_LOGO = "/content/ova/images/hc-player.png"
var OVA_JW5_SKIN = "/files/skins/lulu/5/lulu.zip"
var OVA_BOTR_PLAYLIST = "http://video.bitmedianetwork.com/ads/testpattern.mp4"

// LIVE AD TAGS

var OVA_OPENX_API = "http://openx.openvideoads.org/openx/www/delivery/fc.php"
var OVA_AD_TAG_LINEAR_STREAM_WITH_80x300_COMPANION = "http://openx.openvideoads.org/openx/www/delivery/fc.php?script=bannerTypeHtml:vastInlineBannerTypeHtml:vastInlineHtml__amp__zones=pre-roll:0.0-0%3D50__amp__nz=1__amp__source=__amp__r=R0.05822725687175989__amp__block=1__amp__format=vast__amp__charset=UTF-8";
var OVA_ADFORM_PRE_ROLL = "http://track.adform.net/serving/videoad/?bn=453599__amp__ord=1328005854622"
var OVA_LIVERAIL_PRE_ROLL = "http://ad3.liverail.com/?LR_PUBLISHER_ID=1331__amp__LR_CAMPAIGN_ID=229__amp__LR_SCHEMA=vast2"
var OVA_BAD_OPENX_PRE_ROLL = "http://openx.openvideoads.org/openx/www/delivery/fc.php?script=bannerTypeHtml:vastInlineBannerTypeHtml:vastInlineHtml__amp__zones=pre-roll:0.0-0%3D978__amp__nz=1__amp__source=__amp__r=R0.05822725687175989__amp__block=1__amp__format=vast__amp__charset=UTF-8"
var OVA_AD_TAG_VPAID = "http://www.adotube.com/kernel/vast/vast.php?omlSource=http://www.adotube.com/php/services/player/OMLService.php?avpid=UDKjuff__amp__ad_type=pre-rolls__amp__platform_version=vast20as3__amp__vpaid=1__amp__rtb=0__amp__publisher=adotube.com__amp__title=[VIDEO_TITLE]__amp__tags=[VIDEO_TAGS]__amp__description=[VIDEO_DESCRIPTION]__amp__videoURL=[VIDEO_FILE_URL]"
var OVA_AD_TAG_NON_LINEAR_VPAID = "http://www.adotube.com/kernel/vast/vast.php?omlSource=http://www.adotube.com/php/services/player/OMLService.php?avpid=pctozxH__amp__ad_type=overlays__amp__platform_version=vast20as3__amp__vpaid=1__amp__rtb=0__amp__publisher=adotube.com__amp__title=[VIDEO_TITLE]__amp__tags=[VIDEO_TAGS]__amp__description=[VIDEO_DESCRIPTION]__amp__videoURL=[VIDEO_FILE_URL]"
var OVA_AD_TAG_FAILOVER_1 = "http://xxxadserver.adtech.de/?adrawdata/3.0/990.1/2366662/0/1725/noperf=1;cc=2;header=yes;cookie=yes;adct=204;alias=;key=key1+key2;;=;grp=[group];misc=__random-number__"
var OVA_AD_TAG_FAILOVER_2 = "http://adserver.adtech.de/?adrawdata/3.0/990.1/2366662/0/1725/noperf=1;cc=2;header=yes;cookie=yes;adct=204;alias=;key=key1+key2;;=;grp=[group];misc=__random-number__"

// TEMPLATE BASED AD TAGS

var OVA_AUDIO_AD_TAG = "/content/ova/tags/vast1-mp3-linear.xml"
var OVA_AD_TAG_VAST1_MP4_NO_MARKERS = "/content/ova/tags/vast1-mp4-no-markers.xml"
var OVA_AD_TAG_FLOWPLAYER_PROXY = "/content/ova/tags/akamai-vast-response.xml"
var OVA_AD_TAG_LINEAR_WITH_CLICK_TRACKING = "/content/ova/tags/vast1-linear-with-click-tracking.xml"
var OVA_AD_TAG_MULTIPLE_NON_LINEAR_TYPES = "/content/ova/tags/vast2-multi-types.xml"
var OVA_AD_TAG_BITRATES = "/content/ova/tags/openx-bitrates-vast.xml"
var OVA_AD_TAG_SCALABLE_NON_LINEAR_IMAGE = "/content/ova/tags/vast2-image-scalable.xml"

// PLAYER SPECIFIC OVA SETTINGS

var PLAYER_SPECIFIC_AUDIO_PROVIDER = {
    "flowplayer": "audio",
    "jw5": "sound"
}

function _ovaDebug(output) {
	try {
   		console.log(output);
  	}
  	catch(error) {}
}

function _ovaStripNewlines(data) {
    if(data != null) {
		return data.replace(/(\r\n|\n|\r)/gm,"");
    }
    return data;
}

function _ovaShortenString(data, front, back) {
    if(data != null) {
	    if(data.length > (front + back)) {
    	   return data.substring(0, front) + " ... " + data.substring(data.length-back, data.length);
    	}
    }
    return data;
}

function _ovaReplaceVariables(data, shorten, replaceAmps, playerName) {
    if(data != null) {
    	var result = data.replace(/OVA_FLOWPLAYER_SWF/gm, OVA_FLOWPLAYER_SWF);
    	result = result.replace(/OVA_JW5_PLAYER_SWF/gm, OVA_JW5_PLAYER_SWF);
    	result = result.replace(/OVA_JW5_LICENSED_PLAYER_SWF/gm, OVA_JW5_LICENSED_PLAYER_SWF);
    	result = result.replace(/OVA_FLOWPLAYER_PLUGIN_SWF/gm, OVA_FLOWPLAYER_PLUGIN_SWF);
    	result = result.replace(/OVA_JW5_PLUGIN_SWF/gm, OVA_JW5_PLUGIN_SWF);
    	result = result.replace(/OVA_FLOWPLAYER_AUDIO_PLUGIN_SWF/gm, OVA_FLOWPLAYER_AUDIO_PLUGIN_SWF);
    	result = result.replace(/OVA_FLOWPLAYER_RTMP_PLUGIN_SWF/gm, OVA_FLOWPLAYER_RTMP_PLUGIN_SWF);
    	result = result.replace(/OVA_FLOWPLAYER_BWCHECK_PLUGIN_SWF/gm, OVA_FLOWPLAYER_BWCHECK_PLUGIN_SWF);
    	result = result.replace(/OVA_FLOWPLAYER_CLUSTER_PLUGIN_SWF/gm, OVA_FLOWPLAYER_CLUSTER_PLUGIN_SWF);
    	result = result.replace(/OVA_FLOWPLAYER_PROXY_PLUGIN_SWF/gm, OVA_FLOWPLAYER_PROXY_PLUGIN_SWF);
    	result = result.replace(/OVA_FLOWPLAYER_SECURE_PLUGIN_SWF/gm, OVA_FLOWPLAYER_SECURE_PLUGIN_SWF);
    	result = result.replace(/OVA_FLOWPLAYER_SMIL_PLUGIN_SWF/gm, OVA_FLOWPLAYER_SMIL_PLUGIN_SWF);
    	result = result.replace(/OVA_FLOWPLAYER_SECURE_TOKEN/gm, OVA_FLOWPLAYER_SECURE_TOKEN);
    	result = result.replace(/OVA_CUSTOM_LOGO/gm, OVA_CUSTOM_LOGO);
    	result = result.replace(/OVA_JW5_SKIN/gm, OVA_JW5_SKIN);
    	result = result.replace(/OVA_OPENX_API/gm, OVA_OPENX_API);

    	if(shorten) {
		    result = result.replace(/OVA_AD_TAG_LINEAR_STREAM_WITH_80x300_COMPANION/gm, _ovaShortenString(OVA_AD_TAG_LINEAR_STREAM_WITH_80x300_COMPANION, 25, 20));
		    result = result.replace(/OVA_ADFORM_PRE_ROLL/gm, _ovaShortenString(OVA_ADFORM_PRE_ROLL, 25, 20));
		    result = result.replace(/OVA_LIVERAIL_PRE_ROLL/gm, _ovaShortenString(OVA_LIVERAIL_PRE_ROLL, 25, 20));
		    result = result.replace(/OVA_BAD_OPENX_PRE_ROLL/gm, _ovaShortenString(OVA_BAD_OPENX_PRE_ROLL, 25, 20));
		    result = result.replace(/OVA_AUDIO_AD_TAG/gm, _ovaShortenString(OVA_AUDIO_AD_TAG, 25, 20));
		    result = result.replace(/OVA_AD_TAG_VAST1_MP4_NO_MARKERS/gm, _ovaShortenString(OVA_AD_TAG_VAST1_MP4_NO_MARKERS, 25, 20));
		    result = result.replace(/OVA_AD_TAG_FLOWPLAYER_PROXY/gm, _ovaShortenString(OVA_AD_TAG_FLOWPLAYER_PROXY, 25, 20));
		    result = result.replace(/OVA_AD_TAG_VPAID/gm, _ovaShortenString(OVA_AD_TAG_VPAID, 25, 20));
		    result = result.replace(/OVA_AD_TAG_LINEAR_WITH_CLICK_TRACKING/gm, _ovaShortenString(OVA_AD_TAG_LINEAR_WITH_CLICK_TRACKING, 25, 20));
		    result = result.replace(/OVA_AD_TAG_MULTIPLE_NON_LINEAR_TYPES/gm, _ovaShortenString(OVA_AD_TAG_MULTIPLE_NON_LINEAR_TYPES, 25, 20));
		    result = result.replace(/OVA_AD_TAG_NON_LINEAR_VPAID/gm, _ovaShortenString(OVA_AD_TAG_NON_LINEAR_VPAID, 25, 20));
		    result = result.replace(/OVA_AD_TAG_BITRATES/gm, _ovaShortenString(OVA_AD_TAG_BITRATES, 25, 20));
		    result = result.replace(/OVA_AD_TAG_FAILOVER_1/gm, _ovaShortenString(OVA_AD_TAG_FAILOVER_1, 25, 20));
		    result = result.replace(/OVA_AD_TAG_FAILOVER_2/gm, _ovaShortenString(OVA_AD_TAG_FAILOVER_2, 25, 20));
		    result = result.replace(/OVA_AD_TAG_SCALABLE_NON_LINEAR_IMAGE/gm, _ovaShortenString(OVA_AD_TAG_SCALABLE_NON_LINEAR_IMAGE, 25, 20));
    	}
    	else {
		    result = result.replace(/OVA_AD_TAG_LINEAR_STREAM_WITH_80x300_COMPANION/gm, OVA_AD_TAG_LINEAR_STREAM_WITH_80x300_COMPANION);
		    result = result.replace(/OVA_ADFORM_PRE_ROLL/gm, OVA_ADFORM_PRE_ROLL);
		    result = result.replace(/OVA_LIVERAIL_PRE_ROLL/gm, OVA_LIVERAIL_PRE_ROLL);
		    result = result.replace(/OVA_BAD_OPENX_PRE_ROLL/gm, OVA_BAD_OPENX_PRE_ROLL);
		    result = result.replace(/OVA_AUDIO_AD_TAG/gm, OVA_AUDIO_AD_TAG);
		    result = result.replace(/OVA_AD_TAG_VAST1_MP4_NO_MARKERS/gm, OVA_AD_TAG_VAST1_MP4_NO_MARKERS);
		    result = result.replace(/OVA_AD_TAG_FLOWPLAYER_PROXY/gm, OVA_AD_TAG_FLOWPLAYER_PROXY);
		    result = result.replace(/OVA_AD_TAG_VPAID/gm, OVA_AD_TAG_VPAID);
		    result = result.replace(/OVA_AD_TAG_LINEAR_WITH_CLICK_TRACKING/gm, OVA_AD_TAG_LINEAR_WITH_CLICK_TRACKING);
		    result = result.replace(/OVA_AD_TAG_MULTIPLE_NON_LINEAR_TYPES/gm, OVA_AD_TAG_MULTIPLE_NON_LINEAR_TYPES);
		    result = result.replace(/OVA_AD_TAG_NON_LINEAR_VPAID/gm, OVA_AD_TAG_NON_LINEAR_VPAID);
		    result = result.replace(/OVA_AD_TAG_BITRATES/gm, OVA_AD_TAG_BITRATES);
		    result = result.replace(/OVA_AD_TAG_FAILOVER_1/gm, OVA_AD_TAG_FAILOVER_1);
		    result = result.replace(/OVA_AD_TAG_FAILOVER_2/gm, OVA_AD_TAG_FAILOVER_2);
		    result = result.replace(/OVA_AD_TAG_SCALABLE_NON_LINEAR_IMAGE/gm, OVA_AD_TAG_SCALABLE_NON_LINEAR_IMAGE);
    	}

    	result = result.replace(/OVA_HTTP_SHOW_STREAM_2/gm, OVA_HTTP_SHOW_STREAM_2);
    	result = result.replace(/OVA_HTTP_SHOW_STREAM_IMAGE/gm, OVA_HTTP_SHOW_STREAM_IMAGE);
    	result = result.replace(/OVA_HTTP_SHOW_STREAM/gm, OVA_HTTP_SHOW_STREAM);
    	result = result.replace(/OVA_PSEUDO_SHOW_STREAM/gm, OVA_PSEUDO_SHOW_STREAM);
    	result = result.replace(/OVA_AUDIO_SHOW_STREAM/gm, OVA_AUDIO_SHOW_STREAM);
    	result = result.replace(/OVA_BOTR_PLAYLIST/gm, OVA_BOTR_PLAYLIST);

    	result = result.replace(/PLAYER_SPECIFIC_AUDIO_PROVIDER/gm, PLAYER_SPECIFIC_AUDIO_PROVIDER[playerName]);
        if(replaceAmps) {
           result = result.replace(/__amp__/gm, "&");
        }
    	return result;
    }
    return "";
}

// === The following methods generates the final player configuration objects =============================================

function _ovaBuildFinalPlayerConfigObject(playerName, ovaConfigObject, pluginID, replaceAmps) {
    // Base config is the template in the flowplayer config DIV
    var finalConfigObject = JSON.parse(_ovaReplaceVariables(_ovaStripNewlines($("#ova-" + playerName + "-config").html()), false, replaceAmps, playerName));

	// Now add in the example specific config options to the "ova" config variable
	if(ovaConfigObject != null && finalConfigObject != null) {
	    if(finalConfigObject.hasOwnProperty("plugins") == false) finalConfigObject["plugins"] = {};
	    if(finalConfigObject.plugins.hasOwnProperty(pluginID) == false) finalConfigObject.plugins[pluginID] = {};
		for(var attr in ovaConfigObject) {
        	if(ovaConfigObject.hasOwnProperty(attr)) finalConfigObject.plugins[pluginID][attr] = ovaConfigObject[attr];
    	}
	}
	return finalConfigObject;
}

function _ovaBuildFinalFlowplayerConfigObject(ovaConfigObject) {
    return _ovaBuildFinalPlayerConfigObject("flowplayer", ovaConfigObject, "ova", false);
}

function _ovaBuildFinalJW5ConfigObject(ovaConfigObject) {
    return _ovaBuildFinalPlayerConfigObject("jw5", ovaConfigObject, OVA_JW5_PLUGIN, true);
}

// === The following methods generates printable versions of the config ===================================================

function _ovaExtractOVAConfigAsObject(shorten, replaceAmps, playerName) {
    return JSON.parse(
    		_ovaReplaceVariables(
	    		_ovaStripNewlines(
    				$("#ova-config").html()
    			),
    			shorten,
    			replaceAmps,
    			playerName
    		)
    );
}

function _ovaGetPrintableJSONConfig(ovaConfigObject) {
	return 	"<pre class='prettyprint lang-html'>\n" +
	            JSON.stringify(ovaConfigObject, undefined, 2) +
			"</pre>"
}

function _ovaGetPrintableFlowplayerConfig(ovaConfigObject) {
	return "<pre class='prettyprint lang-html'>\n" +
			  "&lt;script type='text/javascript'>\n" +
				"flowplayer('a.container', { src: 'flowplayer-3.2.7.swf', wmode: 'opaque' }, " +
				    JSON.stringify(_ovaBuildFinalFlowplayerConfigObject(ovaConfigObject), undefined, 2) +
				");\n" +
			  "&lt;/script>\n" +
			"</pre>";
}

function _ovaGetPrintableJW5Config(ovaConfigObject) {
	return "<pre class='prettyprint lang-html'>\n" +
			  "&lt;script type='text/javascript'>\n" +
                "jwplayer('ova-jwplayer-container').setup(" +
				    JSON.stringify(_ovaBuildFinalJW5ConfigObject(ovaConfigObject), undefined, 2) +
				");\n" +
			  "&lt;/script>\n" +
			"</pre>";
}

// === The following methods support tab activation  ======================================================================

function _ovaActivateConfigTab(activeProduct, inactiveProduct1, inactiveProduct2) {
    // Activate the required tab, deactivate the rest

    $("#ova-tab-" + activeProduct).children("a").addClass("current");
    $("#ova-tab-" + inactiveProduct1).children("a").removeClass("current");
    $("#ova-tab-" + inactiveProduct2).children("a").removeClass("current");

    // Show the associated config code block and player instance

    var container = "";

    if(activeProduct == "flowplayer") {
        // insert the config code block
	   	$("#ova-example-config").html(_ovaGetPrintableFlowplayerConfig(_ovaExtractOVAConfigAsObject(true, false, "flowplayer")));

	   	if($("#ova-config").attr("companion") == "true") {
	   	   container = "<div style='width:540px;'>\n" +
	   	                  "<div style='background:#000000;float:left;width:450px;height:300px;'>\n" +
	   	                      "<a class='ova-flowplayer-container' style='background:#000000;width:100%;height:300px;float:left;'></a>\n" +
	   	                  "</div>\n" +
	   	                  "<div id='companion' style='width:80px;height:300px;background:#DDDDDD;float:right;'></div>\n" +
	   	               "</div>";
	   	}
	   	else if($("#ova-config").attr("companion_300x250") == "true") {
	   	   container = "<div style='width:700px;'>\n" +
	   	                  "<div style='background:#000000;float:left;width:400px;height:250px;'>\n" +
	   	                      "<a class='ova-flowplayer-container' style='background:#000000;width:100%;height:250px;float:left;'></a>\n" +
	   	                  "</div>\n" +
	   	                  "<div id='companion' style='width:300px;height:250px;background:#DDDDDD;float:right;'></div>\n" +
	   	               "</div>";
	   	}
	   	else container = "<a class='ova-flowplayer-container' style='height:300px;width:450px;'></a>\n";

	   	// setup the flowplayer instance
        $("#ova-example-player").html(
            container +
		    "<script type='text/javascript'>\n" +
			  "flowplayer('a.ova-flowplayer-container', { src: '" + OVA_FLOWPLAYER_SWF + "', wmode: 'opaque' },\n" +
			      JSON.stringify(_ovaBuildFinalFlowplayerConfigObject(_ovaExtractOVAConfigAsObject(false, false, "flowplayer")), undefined, 2) +
			  ");\n" +
		    "</script>\n"
		);
    }
    else if(activeProduct == "jw5") {
        // insert the config code block
	    $("#ova-example-config").html(_ovaGetPrintableJW5Config(_ovaExtractOVAConfigAsObject(true, true, "jw5")));

	   	if($("#ova-config").attr("companion") == "true") {
	   	   container = "<div style='width:540px;'>\n" +
	   	                  "<div style='background:#000000;width:450px;float:left;'><div id='ova-jwplayer-container'></div></div>\n" +
	   	                  "<div id='companion' style='width:80px;height:300px;background:#DDDDDD;float:right;'></div>" +
	   	               "</div>";
	   	}
	   	else if($("#ova-config").attr("companion_300x250") == "true") {
	   	   container = "<div style='width:700px;'>\n" +
	   	                  "<div style='background:#000000;width:400px;float:left;'><div id='ova-jwplayer-container'></div></div>\n" +
	   	                  "<div id='companion' style='width:300px;height:250px;background:#DDDDDD;float:right;'></div>" +
	   	               "</div>";
	   	}
	   	else container = "<div id='ova-jwplayer-container'></div>\n";

        // setup the jw5 player instance
        $("#ova-example-player").html(
            container +
		    "<script type='text/javascript'>\n" +
              "jwplayer('ova-jwplayer-container').setup(" +
			      JSON.stringify(_ovaBuildFinalJW5ConfigObject(_ovaExtractOVAConfigAsObject(false, true, "jw5")), undefined, 2) +
			  ");\n" +
		    "</script>\n"
		);
    }
    else {
	    $("#ova-example-config").html(_ovaGetPrintableJSONConfig(_ovaExtractOVAConfigAsObject(true, true, "jw5")));
    }
}

function _ovaActivateJSON() {
    _ovaActivateConfigTab("json", "flowplayer", "jw5");
}

function _ovaActivateFlowplayer() {
    _ovaActivateConfigTab("flowplayer", "jw5", "json");
}

function _ovaActivateJW5() {
    _ovaActivateConfigTab("jw5", "flowplayer", "json");
}

function _ovaInsertExampleConfig() {
    // Setup the click handlers for each tab

    $("#ova-tab-json").click(function() { _ovaActivateJSON() });
    $("#ova-tab-flowplayer").click(function() { _ovaActivateFlowplayer() });
    $("#ova-tab-jw5").click(function() { _ovaActivateJW5() });

    // Setup the clean example page click handler
    $("#ova-clean-example-link").click(function() { alert("Not implemented"); });

    // Now insert the default example content
   	if($("#ova-flowplayer-config").attr("active") == "true") {
   	   _ovaActivateFlowplayer();
   	}
   	else _ovaActivateJW5();
}

_ovaInsertExampleConfig();
});
