/*    
 *    Copyright (c) 2013 LongTail AdSolutions, Inc
 *
 *    This file is part of the Open Video Ads VAST framework.
 *
 *    The VAST framework is free software: you can redistribute it 
 *    and/or modify it under the terms of the GNU General Public License 
 *    as published by the Free Software Foundation, either version 3 of 
 *    the License, or (at your option) any later version.
 *
 *    The VAST framework is distributed in the hope that it will be 
 *    useful, but WITHOUT ANY WARRANTY; without even the implied warranty of
 *    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *    GNU General Public License for more details.
 *
 *    You should have received a copy of the GNU General Public License
 *    along with the framework.  If not, see <http://www.gnu.org/licenses/>.
 *
 *    @author  Paul Schulz
 *    @date    July 30, 2012
 *    @contact enquiries@openvideoads.org (www.openvideoads.org)
 * 
 */

(function(jwplayer) {

var ovaJWDebug = new function() {
    /*
     * Prints out the debug string to the Javascript console
     */
    this.out = function(output) {
   		try {
      		console.log(output);
   		}
   		catch(error) {}
    }
}

var template = function(_player, _options, div) {

    var _NOT_IMPLEMENTED = "Bridge implementation not available";
    var _nativeImplementation = null;
    
    var _callbacks = { };

    /*
     * PLUGIN STARTUP
     */

    function _initialise() {
        if(_player.getRenderingMode() == "html5" && false) {
		   if(eval("typeof NativeOVAImplementation == 'object'") == false) {
	   		  ovaJWDebug.out("Initialising the OVA HTML5 plugin - version 1.0.0 (Build 1) - loading the OVA for HTML5 library..");
           	  $.getScript('http://localhost/ova/ova.jwplayer.5x/src/html5/ova-jw-native.js',
		         function() {
 	         		   	ovaJWDebug.out("OVA for JW5 HTML5 library loaded - instantiating native implementation");
            			_nativeImplementation = new NativeOVAImplementation(_player, _options, _callbacks);
            			_nativeImplementation.start();
            		}
           	  );
           }
        }
        else ovaJWDebug.out("OVA JS plugin version 1.3.0 RC1 (Build 17) - operating in 'bridge' mode to the OVA SWF API");
    }


    /*
     * OVA PUBLIC API
     */

    /*
     * Method
     */
    this.play = function() {
        if(_player.getRenderingMode() == 'flash') {
            try {
               document.getElementById(_player.id).ovaPlay();
            }
            catch(error) {
               ovaJWDebug.out(error);
            }
        } else {
            ovaJWDebug.out(_NOT_IMPLEMENTED);
        }
    }
    
    /*
     * Method
     */
    this.stop = function() {
        if(_player.getRenderingMode() == 'flash') {
            try {
               document.getElementById(_player.id).ovaStop();
            }
            catch(error) {
               ovaJWDebug.out(error);
            }
        } else {
            ovaJWDebug.out(_NOT_IMPLEMENTED);
        }
    }

    /*
     * Method
     */
    this.pause = function() {
        if(_player.getRenderingMode() == 'flash') {
            try {
               document.getElementById(_player.id).ovaPause();
            }
            catch(error) {
               ovaJWDebug.out(error);
            }
        } else {
            ovaJWDebug.out(_NOT_IMPLEMENTED);
        }
    }

    /*
     * Method
     */
    this.resume = function() {
        if(_player.getRenderingMode() == 'flash') {
            try {
               document.getElementById(_player.id).ovaResume();
            }
            catch(error) {
               ovaJWDebug.out(error);
            }
        } else {
            ovaJWDebug.out(_NOT_IMPLEMENTED);
        }
    }

    /*
     * Method
     */
    this.getActiveAdDescriptor = function() {
        if(_player.getRenderingMode() == 'flash') {
            try {
               return document.getElementById(_player.id).ovaGetActiveAdDescriptor();
            }
            catch(error) {
               ovaJWDebug.out(error);
            }
        } else {
            ovaJWDebug.out(_NOT_IMPLEMENTED);
        }
        return null;
    }

    /*
     * Method
     */
    this.getVersion = function() {
        if(_player.getRenderingMode() == 'flash') {
            try {
               document.getElementById(_player.id).ovaGetVersion();
            }
            catch(error) {
               ovaJWDebug.out(error);
            }
        } else {
            ovaJWDebug.out(_NOT_IMPLEMENTED);
        }
    };

    /*
     * Method
     */
    this.enableAds = function() {
        if(_player.getRenderingMode() == 'flash') {
            try {
               document.getElementById(_player.id).ovaEnableAds();
            }
            catch(error) {
               ovaJWDebug.out(error);
            }
        } else {
            ovaJWDebug.out(_NOT_IMPLEMENTED);
        }
    };

    /*
     * Method
     */
    this.disableAds = function() {
        if(_player.getRenderingMode() == 'flash') {
            try {
               document.getElementById(_player.id).ovaDisableAds();
            }
            catch(error) {
               ovaJWDebug.out(error);
            }
        } else {
            ovaJWDebug.out(_NOT_IMPLEMENTED);
        }
    };

    /*
     * Method
     */
    this.scheduleAds = function(playlist, newConfig) {
        if(_player.getRenderingMode() == 'flash') {
            try {
               document.getElementById(_player.id).ovaScheduleAds(playlist, newConfig);
            }
            catch(error) {
               ovaJWDebug.out(error);
            }
        } else {
        	if(_nativeImplementation != null) {
        		_nativeImplementation.scheduleAds(playlist, newConfig);
        	}
        	else {
            	ovaJWDebug.out(_NOT_IMPLEMENTED);
        	}
        }
    };

    /*
     * Method
     */
    this.loadPlaylist = function() {
        if(_player.getRenderingMode() == 'flash') {
            try {
               document.getElementById(_player.id).ovaLoadPlaylist();
            }
            catch(error) {
               ovaJWDebug.out(error);
            }
        } else {
            ovaJWDebug.out(_NOT_IMPLEMENTED);
        }
    };

    /*
     * Method
     */
    this.getAdSchedule = function() {
        if(_player.getRenderingMode() == 'flash') {
            try {
               document.getElementById(_player.id).ovaGetAdSchedule();
            }
            catch(error) {
               ovaJWDebug.out(error);
            }
        } else {
            ovaJWDebug.out(_NOT_IMPLEMENTED);
        }
    };

    /*
     * Method
     */
    this.getStreamSequence = function() {
        if(_player.getRenderingMode() == 'flash') {
            try {
               document.getElementById(_player.id).ovaGetStreamSequence();
            }
            catch(error) {
               ovaJWDebug.out(error);
            }
        } else {
            ovaJWDebug.out(_NOT_IMPLEMENTED);
        }
    };

    /*
     * Method
     */
    this.setDebugLevel = function(levels) {
        if(_player.getRenderingMode() == 'flash') {
            try {
               document.getElementById(_player.id).ovaSetDebugLevel(levels);
            }
            catch(error) {
               ovaJWDebug.out(error);
            }
        } else {
            ovaJWDebug.out(_NOT_IMPLEMENTED);
        }
    };

    /*
     * Method
     */
    this.getDebugLevel = function() {
        if(_player.getRenderingMode() == 'flash') {
            try {
               document.getElementById(_player.id).ovaGetDebugLevel();
            }
            catch(error) {
               ovaJWDebug.out(error);
            }
        } else {
            ovaJWDebug.out(_NOT_IMPLEMENTED);
        }
    };

    /*
     * Method
     */
    this.skipAd = function() {
        if(_player.getRenderingMode() == 'flash') {
            try {
               document.getElementById(_player.id).ovaSkipAd();
            }
            catch(error) {
               ovaJWDebug.out(error);
            }
        } else {
            ovaJWDebug.out(_NOT_IMPLEMENTED);
        }
    };

    /*
     * Method
     */
    this.clearOverlays = function() {
        if(_player.getRenderingMode() == 'flash') {
            try {
               document.getElementById(_player.id).ovaClearOverlays();
            }
            catch(error) {
               ovaJWDebug.out(error);
            }
        } else {
            ovaJWDebug.out(_NOT_IMPLEMENTED);
        }
    };

    /*
     * Method
     */
    this.showOverlay = function() {
        if(_player.getRenderingMode() == 'flash') {
            try {
               document.getElementById(_player.id).ovaShowOverlay();
            }
            catch(error) {
               ovaJWDebug.out(error);
            }
        } else {
            ovaJWDebug.out(_NOT_IMPLEMENTED);
        }
    };

    /*
     * Method
     */
    this.hideOverlay = function() {
        if(_player.getRenderingMode() == 'flash') {
            try {
               document.getElementById(_player.id).ovaHideOverlay();
            }
            catch(error) {
               ovaJWDebug.out(error);
            }
        } else {
            ovaJWDebug.out(_NOT_IMPLEMENTED);
        }
    };

    /*
     * Method
     */
    this.enableAPI = function() {
        if(_player.getRenderingMode() == 'flash') {
            try {
               document.getElementById(_player.id).ovaEnableAPI();
            }
            catch(error) {
               ovaJWDebug.out(error);
            }
        } else {
            ovaJWDebug.out(_NOT_IMPLEMENTED);
        }
    };

    /*
     * Method
     */
    this.disableAPI = function() {
        if(_player.getRenderingMode() == 'flash') {
            try {
               document.getElementById(_player.id).ovaDisableAPI();
            }
            catch(error) {
               ovaJWDebug.out(error);
            }
        } else {
            ovaJWDebug.out(_NOT_IMPLEMENTED);
        }
    };

    /*
     * Method
     */
    this.setActiveLinearAdVolume = function(volume) {
        if(_player.getRenderingMode() == 'flash') {
            try {
               return document.getElementById(_player.id).ovaSetActiveLinearAdVolume(volume);
            }
            catch(error) {
               ovaJWDebug.out(error);
            }
        } else {
            ovaJWDebug.out(_NOT_IMPLEMENTED);
            return false;
        }
    };
    
    /**
     * OVA EVENT CALLBACK HANDLERS
     */
    
	/*
	 * Takes the callback from the OVA SWF and directs it back to the scoped local function
	 * 
	 *    args[0] is always the callback event name
	 *    args[1...n] are the additional parameter values that are to be passed in the callback
	 * 
	 */    
	this.onOVAEventCallback = function(args) {
		if(args != null) {
			if(_callbacks[args[0]] != undefined) {
				_callbacks[args[0]](args);
			}
		}
	}
    
    // The individual callback registration methods
    
	this.onAdSchedulingStarted = function(callback) {
		_callbacks.onAdSchedulingStarted = callback;
	}
	
	this.onLinearAdScheduled = function(callback) {
		_callbacks.onLinearAdScheduled = callback;
	}

	this.onNonLinearAdScheduled = function(callback) {
		_callbacks.onNonLinearAdScheduled = callback;
	}

	this.onCompanionAdScheduled = function(callback) {
		_callbacks.onCompanionAdScheduled = callback;
	}

	this.onAdSchedulingComplete = function(callback) {
		_callbacks.onAdSchedulingComplete = callback;
	}
	
	this.onTemplateLoadSuccess = function(callback) {
		_callbacks.onTemplateLoadSuccess = callback;
	}

	this.onTemplateLoadFailure = function(callback) {
		_callbacks.onTemplateLoadFailure = callback;
	}

	this.onTemplateLoadTimeout = function(callback) {
		_callbacks.onTemplateLoadTimeout = callback;
	}
	
	this.onAdCallStarted = function(callback) {
		_callbacks.onAdCallStarted = callback;
	}

	this.onAdCallFailover = function(callback) {
		_callbacks.onAdCallFailover = callback;
	}

	this.onAdCallComplete = function(callback) {
		_callbacks.onAdCallComplete = callback;
	}
	
	this.onAdSlotLoaded = function(callback) {
		_callbacks.onAdSlotLoaded = callback;
	}

	this.onAdSlotLoadError = function(callback) {
		_callbacks.onAdSlotLoadError = callback;
	}

	this.onAdSlotLoadTimeout = function(callback) {
		_callbacks.onAdSlotLoadTimeout = callback;
	}

	this.onAdSlotLoadDeferred = function(callback) {
		_callbacks.onAdSlotLoadDeferred = callback;
	}
	
	this.onLinearAdStart = function(callback) {
		_callbacks.onLinearAdStart = callback;
	}

	this.onLinearAdStop = function(callback) {
		_callbacks.onLinearAdStop = callback;
	}

	this.onLinearAdPause = function(callback) {
		_callbacks.onLinearAdPause = callback;
	}

	this.onLinearAdResume = function(callback) {
		_callbacks.onLinearAdResume = callback;
	}

	this.onLinearAdClick = function(callback) {
		_callbacks.onLinearAdClick = callback;
	}

	this.onLinearAdFullscreen = function(callback) {
		_callbacks.onLinearAdFullscreen = callback;
	}

	this.onLinearAdFullscreenExit = function(callback) {
		_callbacks.onLinearAdFullscreenExit = callback;
	}

	this.onLinearAdMute = function(callback) {
		_callbacks.onLinearAdMute = callback;
	}

	this.onLinearAdUnmute = function(callback) {
		_callbacks.onLinearAdUnmute = callback;
	}

	this.onLinearAdReplay = function(callback) {
		_callbacks.onLinearAdReplay = callback;
	}

	this.onLinearAdMidPointComplete = function(callback) {
		_callbacks.onLinearAdMidPointComplete = callback;
	}

	this.onLinearAdFirstQuartileComplete = function(callback) {
		_callbacks.onLinearAdFirstQuartileComplete = callback;
	}

	this.onLinearAdThirdQuartileComplete = function(callback) {
		_callbacks.onLinearAdThirdQuartileComplete = callback;
	}

	this.onLinearAdFinish = function(callback) {
		_callbacks.onLinearAdFinish = callback;
	}

	this.onVPAIDAdLoaded = function(callback) {
		_callbacks.onVPAIDAdLoaded = callback;
	}

	this.onVPAIDAdImpression = function(callback) {
		_callbacks.onVPAIDAdImpression = callback;
	}

	this.onVPAIDAdStart = function(callback) {
		_callbacks.onVPAIDAdStart = callback;
	}

	this.onVPAIDAdComplete = function(callback) {
		_callbacks.onVPAIDAdComplete = callback;
	}

	this.onVPAIDAdError = function(callback) {
		_callbacks.onVPAIDAdError = callback;
	}

	this.onVPAIDAdVideoStart = function(callback) {
		_callbacks.onVPAIDAdVideoStart = callback;
	}

	this.onVPAIDAdVideoFirstQuartile = function(callback) {
		_callbacks.onVPAIDAdVideoFirstQuartile = callback;
	}

	this.onVPAIDAdVideoMidpoint = function(callback) {
		_callbacks.onVPAIDAdVideoMidpoint = callback;
	}

	this.onVPAIDAdVideoThirdQuartile = function(callback) {
		_callbacks.onVPAIDAdVideoThirdQuartile = callback;
	}

	this.onVPAIDAdVideoComplete = function(callback) {
		_callbacks.onVPAIDAdVideoComplete = callback;
	}

	this.onVPAIDAdClickThru = function(callback) {
		_callbacks.onVPAIDAdClickThru = callback;
	}

	this.onVPAIDAdUserAcceptInvitation = function(callback) {
		_callbacks.onVPAIDAdUserAcceptInvitation = callback;
	}

	this.onVPAIDAdUserMinimize = function(callback) {
		_callbacks.onVPAIDAdUserMinimize = callback;
	}

	this.onVPAIDAdUserClose = function(callback) {
		_callbacks.onVPAIDAdUserClose = callback;
	}

	this.onVPAIDAdPaused = function(callback) {
		_callbacks.onVPAIDAdPaused = callback;
	}

	this.onVPAIDAdPlaying = function(callback) {
		_callbacks.onVPAIDAdPlaying = callback;
	}

	this.onVPAIDAdExpandedChange = function(callback) {
		_callbacks.onVPAIDAdExpandedChange = callback;
	}

	this.onVPAIDAdLinearChange = function(callback) {
		_callbacks.onVPAIDAdLinearChange = callback;
	}

	this.onVPAIDAdRemainingTimeChange = function(callback) {
		_callbacks.onVPAIDAdRemainingTimeChange = callback;
	}

	this.onVPAIDAdLog = function(callback) {
		_callbacks.onVPAIDAdLog = callback;
	}
	
	this.onNonLinearAdShow = function(callback) {
		_callbacks.onNonLinearAdShow = callback;
	}

	this.onNonLinearAdHide = function(callback) {
		_callbacks.onNonLinearAdHide = callback;
	}

	this.onNonLinearAdClicked = function(callback) {
		_callbacks.onNonLinearAdClicked = callback;
	}

	this.onNonLinearAdCloseClicked = function(callback) {
		_callbacks.onNonLinearAdCloseClicked = callback;
	}
	
	this.onCompanionAdShow = function(callback) {
		_callbacks.onCompanionAdShow = callback;
	}

	this.onCompanionAdHide = function(callback) {
		_callbacks.onCompanionAdHide = callback;
	}

	this.onImpressionEvent = function(callback) {
		_callbacks.onImpressionEvent = callback;
	}

	this.onTrackingEvent = function(callback) {
		_callbacks.onTrackingEvent = callback;
	}

	this.onClickTrackingEvent = function(callback) {
		_callbacks.onClickTrackingEvent = callback;
	}

	this.onCustomClickTrackingEvent = function(callback) {
		_callbacks.onCustomClickTrackingEvent = callback;
	}

	this.onAdNoticeShow = function(callback) {
		_callbacks.onAdNoticeShow = callback;
	}

	this.onAdNoticeHide = function(callback) {
		_callbacks.onAdNoticeHide = callback;
	}

	this.onAdNoticeTick = function(callback) {
		_callbacks.onAdNoticeTick = callback;
	}

	this.onOVAReadyToPlay = function(callback) {
		_callbacks.onOVAReadyToPlay = callback;
	}

    _player.onReady(_initialise);
};


/** Register the plugin with JW Player. **/
jwplayer().registerPlugin('ova', template,'ova-jw.swf');

})(jwplayer);


