// Environment configuration - change this section to configure appropriately

var OVA_DIST_A_SWF_2 = "../../../dist/swf/";
var OVA_DIST_A_SWF_3 = "../../../../dist/swf/";
var OVA_DIST_A_SWF_4 = "../../../../../dist/swf/";
var OVA_DIST_B_SWF_2 = "../../../dist/swf/";
var OVA_DIST_B_SWF_3 = "../../../../dist/swf/";
var OVA_DIST_B_SWF_4 = "../../../../../dist/swf/";
var OVA_DIST_B_SWF_5 = "../../../../../../dist/swf/";
var OVA_DIST_TEMPLATES_2 = "../../../dist/templates/";
var OVA_DIST_TEMPLATES_3 = "../../../../dist/templates/";
var OVA_DIST_TEMPLATES_4 = "../../../../../dist/templates/";
var OVA_DIST_IMAGES_2 = "../../../dist/images/";
var OVA_DIST_IMAGES_3 = "../../../../dist/images/";
var OVA_DIST_IMAGES_4 = "../../../../../dist/images/";
var OVA_CONFIG_DOCROOT_2 = "../../config/";
var OVA_CONFIG_DOCROOT_3 = "../../../config/";
var OVA_CONFIG_DOCROOT_4 = "../../../../config/";

// Don't change from here down

var OVA_PLUGIN_2 = OVA_DIST_A_SWF_2 + 'ova-jw.swf';
var OVA_PLUGIN_3 = OVA_DIST_A_SWF_3 + 'ova-jw.swf';
var OVA_PLUGIN_4 = OVA_DIST_A_SWF_4 + 'ova-jw.swf';
var OVA_PLAYER_55_2 = OVA_DIST_B_SWF_2 + '5.5.swf';
var OVA_PLAYER_55_3 = OVA_DIST_B_SWF_3 + '5.5.swf';
var OVA_PLAYER_56_2 = OVA_DIST_B_SWF_2 + '5.6.swf';
var OVA_PLAYER_56_3 = OVA_DIST_B_SWF_3 + '5.6.swf';
var OVA_PLAYER_57_2 = OVA_DIST_B_SWF_2 + '5.7.swf';
var OVA_PLAYER_57_3 = OVA_DIST_B_SWF_3 + '5.7.swf';
var OVA_PLAYER_57_4 = OVA_DIST_B_SWF_4 + '5.7.swf';
var OVA_PLAYER_57_5 = OVA_DIST_B_SWF_5 + '5.7.swf';
var OVA_PLAYER_58_2 = OVA_DIST_B_SWF_2 + '5.8.swf';
var OVA_PLAYER_58_3 = OVA_DIST_B_SWF_3 + '5.8.swf';
var OVA_PLAYER_58_4 = OVA_DIST_B_SWF_4 + '5.8.swf';
var OVA_PLAYER_58_5 = OVA_DIST_B_SWF_5 + '5.8.swf';
var OVA_PLAYER_59_2 = OVA_DIST_B_SWF_2 + '5.9.swf';
var OVA_PLAYER_59_3 = OVA_DIST_B_SWF_3 + '5.9.swf';
var OVA_PLAYER_59_4 = OVA_DIST_B_SWF_4 + '5.9.swf';
var OVA_PLAYER_59_5 = OVA_DIST_B_SWF_5 + '5.9.swf';
var OVA_PLAYER_510_2 = OVA_DIST_B_SWF_2 + '5.10.swf';
var OVA_PLAYER_510_3 = OVA_DIST_B_SWF_3 + '5.10.swf';
var OVA_PLAYER_510_4 = OVA_DIST_B_SWF_4 + '5.10.swf';
var OVA_PLAYER_510_5 = OVA_DIST_B_SWF_5 + '5.10.swf';
var OVA_PLAYER_2 = OVA_PLAYER_510_2;
var OVA_PLAYER_3 = OVA_PLAYER_510_3;
var OVA_PLAYER_4 = OVA_PLAYER_510_4;
var OVA_PLAYER_4 = OVA_PLAYER_510_5;
var OVA_PLAYER_5 = OVA_PLAYER_510_5;
var BOTR_PLAYER = 'http://content.bitsontherun.com/staticfiles/videoplayer.swf';
var OVA_PLAYER_LICENSED = 'http://static.openvideoads.org/support/players/5.8-licensed.swf';

// Example specific functions

function writePlayerEmbedCode(configFile, level, width, height, extraFlashVars, extraPlugins) {
  	if(extraPlugins == null) extraPlugins = "";
	var result =  '';
    result += '<OBJECT classid="clsid:D27CDB6E-AE6D-11cf-96B8-444553540000"';
    result += ' codebase="http://download.macromedia.com/pub/shockwave/cabs/flash/swflash.cab#version=9,0"';
    result += ' WIDTH="' + width + '" HEIGHT="' + height + '" id="player">\n';
    result += ' <PARAM NAME=movie VALUE="' + ((level == 2) ? OVA_PLAYER_2 : OVA_PLAYER_3) + '">\n';
    result += ' <PARAM NAME=quality VALUE=high>\n';
    result += ' <PARAM NAME=bgcolor VALUE=#000000>\n';
    result += ' <PARAM NAME=allowfullscreen VALUE="true">\n';
    result += ' <PARAM NAME=allowscriptaccess VALUE="always">\n';
    if(level == 2) {
    	result += ' <PARAM NAME=flashvars VALUE="plugins=' + OVA_PLUGIN_2 + extraPlugins + '&config=' + OVA_CONFIG_DOCROOT_2 + configFile + '">\n';
    }
    else {
    	result += ' <PARAM NAME=flashvars VALUE="plugins=' + OVA_PLUGIN_3 + extraPlugins + '&config=' + OVA_CONFIG_DOCROOT_3 + configFile + '">\n';
    }
	result += '<EMBED\n';
  	result += ' id="player"\n';
  	if(level == 2) {
	  	result += ' data="' + OVA_PLAYER_2 + '"\n';
  		result += ' src="' + OVA_PLAYER_2 + '"\n';
	}
  	else if(level == 3) {
	  	result += ' data="' + OVA_PLAYER_3 + '"\n';
  		result += ' src="' + OVA_PLAYER_3 + '"\n';
  	}
	else {
	  	result += ' data="' + OVA_PLAYER_4 + '"\n';
  		result += ' src="' + OVA_PLAYER_4 + '"\n';
	}
	result += ' width="' + width + '"\n';
	result += ' height="' + height + '"\n';
  	result += ' allowscriptaccess="always"\n';
  	result += ' allowfullscreen="true"\n';
  	if(configFile != null) {
	  	if(level == 2) {
	  		result += ' flashvars="plugins=' + OVA_PLUGIN_2 + extraPlugins + '&config=' + OVA_CONFIG_DOCROOT_2 + configFile;
	  	}
	  	else if(level == 3) {
	 		result += ' flashvars="plugins=' + OVA_PLUGIN_3 + extraPlugins + '&config=' + OVA_CONFIG_DOCROOT_3 + configFile;
	  	}
	  	else {
	 		result += ' flashvars="plugins=' + OVA_PLUGIN_4 + extraPlugins + '&config=' + OVA_CONFIG_DOCROOT_4 + configFile;
	  	}
  	}
  	else {
	  	if(level == 2) {
	  		result += ' flashvars="plugins=' + OVA_PLUGIN_2 + extraPlugins;
	  	}
	  	else if(level == 3) {
	 		result += ' flashvars="plugins=' + OVA_PLUGIN_3 + extraPlugins;
	  	}
	  	else {
	 		result += ' flashvars="plugins=' + OVA_PLUGIN_4 + extraPlugins;
	  	}
  	}
  	if(extraFlashVars != null) {
  	    result += extraFlashVars;
  	}
  	result += '"\n>\n</EMBED>\n</OBJECT>\n';
  	return result;
}

function htmlEncode(rawString) {
	var result = rawString;

	// less-thans (<)
	result = result.replace(/\</g,'&lt;');
	// greater-thans (>)
	result = result.replace(/\>/g,'&gt;');

	return result;
}

// OVA Javascript Callback Methods

function debug(output) {
    try {
    	console.log(output);
    }
    catch(error) {}
}

function onVPAIDAdStart(ad) {
	debug("OVA CALLBACK EVENT: VPAID Ad Start");
	debug(ad);
}

function onLinearAdStart(ad) {
	debug("OVA CALLBACK EVENT: Linear Ad Start");
	debug(ad);
}
