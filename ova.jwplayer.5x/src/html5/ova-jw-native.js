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
 *    @date    August 20, 2013
 *    @contact enquiries@openvideoads.org (www.openvideoads.org)
 * 
 */

function NativeOVAImplementation(_player, _options, _callbacks) {

 	// Analytics Constants
 	
	this.OVA_JW5_DEFAULT_LINEAR_IMPRESSION_PATH = "/ova/impression/jw5-html?ova_format=linear";
	this.OVA_JW5_DEFAULT_NON_LINEAR_IMPRESSION_PATH = "/ova/impression/jw5-html?ova_format=non-linear";
	this.OVA_JW5_DEFAULT_COMPANION_IMPRESSION_PATH = "/ova/impression/jw5-html?ova_format=companion";
	this.OVA_JW5_DEFAULT_GA_ACCOUNT_ID = "UA-4011032-6";
	this.GOOGLE_ANALYTICS = "GA";
	this.OVA = "OVA";
    
	this.vastController = new VASTController();

	this.player = _player;
	this.options = _options;
	this.callbacks = _callbacks;
}

NativeOVAImplementation.prototype = (function() {
	    
    /*
     * Start the native implementation running
     */
    function _start() {
		this._(_initialise)(this.options);
	}

    /*
     * Method
     */
    function _validateConfig(config) {
		var ovaConfig = null;
		
		if(config.json == null && (config.tag != null || config.vast != null)) {
			
			// Minimal setup of a VAST ad tag via the "tag" variable
			
			ovaConfig = {
			    "ads": {
                    "companions": {
                    	"restore": false,
                     	"regions": [
                            { "id": "companion-300x250", "width": 300, "height": 250 }
                        ]
                    },
                    "schedule": [
                        {
                            "position": "pre-roll",
                            "server": {
                                "type": ((config.tag != null) ? "direct" : "inject"),
	                            "tag": ((config.tag != null) ? config.tag : config.vast)
	                        }
                        }
                    ]
			    }
			};
			if(config.debug != null) {
				ovaConfig.debug = { "levels": config.debug };
			}
			else ovaConfig.debug = { "levels": "fatal, config, vast_template, vpaid" };
			if(config.autoplay != null) ovaConfig.autoPlay =  config.autoplay;
			config.tag = null;
		}
		else if(config.json != null) {
			try {
				ovaConfig = jQuery.parseJSON(config.json)
			}
			catch(e) {
				ovaDebug.out("OVA Configuration parsing exception - " + e.description, ovaDebug.DEBUG_CONFIG);
				return null;
			}
			if(config.tag != null) {
				if(ovaConfig == null) {
					ovaConfig = { tag: config.tag };
				}
				else ovaConfig.tag = config.tag;
			}
		}
		else if(config.ads != undefined || config.debug != undefined) {
			ovaConfig = config;
		}

		if(ovaConfig != null) {
			
			// now set any defaults if not configured manually within OVA config

			if(ovaConfig.debug == undefined) ovaConfig.debug = { "levels": "fatal, config" };
			ovaDebug.initialise(ovaConfig.debug);
			if(ovaConfig.autoPlay == undefined) {
				ovaConfig.autoPlay = false;
			}
			else if(typeof ovaConfig.autoPlay == "string") {
				ovaConfig.autoPlay = new Boolean(ovaConfig.autoPlay);
			}
			if(this.player.config.autostart) {
				ovaConfig.autoPlay = true;
				this.player.config.autostart = (this.player.config.repeat == "always");
				ovaDebug.out("autoPlay set to true as 'autostart' flashvar specified - endless looping = " + this.player.config.autostart, ovaDebug.DEBUG_CONFIG);
			}
			if(config.json != undefined) {
				ovaDebug.out("Config has been loaded via a 'json' string (dump follows) - " + config.json, ovaDebug.DEBUG_CONFIG);
			}
			else {
				ovaDebug.out("Have attached the config object passed from player (dump follows)", ovaDebug.DEBUG_CONFIG);
			}
			ovaDebug.out(ovaConfig, ovaDebug.DEBUG_CONFIG);
		}
		else {
			ovaConfig = {
				json: null,
				tag: null,
				debug: null
			};
			ovaDebug.initialise({ "levels": "fatal, config" });
			ovaDebug.out("No OVA configuration provided - ad streamer will not be capable of playing any ads", ovaDebug.DEBUG_CONFIG);
			return null;
		}

		if(config.tagparams != undefined && config.tagparams != null) {
			
			// tag properties allow the "customProperties" element of an ad server configuration to be passed through
			
			ovaConfig.tagParams = config.tagparams.paramStringToObject(",", ":");
			ovaDebug.out("Additional Ad Tag Parameters have been specified - they will be added to the ad request(s)", ovaDebug.DEBUG_CONFIG);
		}

		// TO DO: vastController.additionMetricsParams = "ova_plugin_version=" + OVA_VERSION + "&ova_player_version=" + _player.version;

		if(ovaConfig.ads != undefined) {
			
			// set the default mime types allowed - can be overridden in config with "acceptedLinearAdMimeTypes" and "filterOnLinearAdMimeTypes"			

			if(ovaConfig.ads.filterOnLinearAdMimeTypes == undefined) {
				ovaDebug.out("Setting accepted Linear Ad mime types to default list - mp4, webm");
				ovaConfig.ads.acceptedLinearAdMimeTypes = [ "video/mp4", "video/x-mp4", "mp4", "video/webm", "video/x-webm", "webm" ];
				ovaConfig.ads.filterOnLinearAdMimeTypes = true;
			}
			else ovaDebug.out("Setting accepted Linear Ad mime types and enabled state = " + ovaConfig.ads.filterOnLinearAdMimeTypes, ovaDebug.DEBUG_CONFIG);
		}  
		
		// Make sure the player attributes are declared in the config because some ad calls require height, width etc.
		
		if(ovaConfig.player != undefined) {
			if(ovaConfig.player.width == undefined) {
				ovaConfig.player.width = _getPlayerWidth();
			}
			if(ovaConfig.player.height == undefined) {
				ovaConfig.player.height = _getPlayerHeight();
			}
			if(ovaConfig.player.volume == undefined) {
				ovaConfig.player.volume = this.player.getVolume();
			}
			if(ovaConfig.player.startStreamSafetyMargin == undefined) {
				ovaConfig.player.startStreamSafetyMargin = 300;
			}
			if(ovaConfig.player.endStreamSafetyMargin == undefined) {
				ovaConfig.player.endStreamSafetyMargin = 300;
			}
		}
		else {
			ovaConfig.player = {
    			width: _getPlayerWidth(),
    			height: _getPlayerHeight(),
    			volume: this.player.getVolume(),				
    			startStreamSafetyMargin: 300,
    			endStreamSafetyMargin: 300
			};
		}

		// Setup the default GA tracking IDs for OVA to use
		
		ovaConfig.analytics = {
			type: this.GOOGLE_ANALYTICS,
			element: this.OVA,
			displayObject: this,
			analyticsId: this.OVA_JW5_DEFAULT_GA_ACCOUNT_ID,
			impressions: {
				linear: this.OVA_JW5_DEFAULT_LINEAR_IMPRESSION_PATH,
				nonLinear: this.OVA_JW5_DEFAULT_NON_LINEAR_IMPRESSION_PATH,
				companion: this.OVA_JW5_DEFAULT_COMPANION_IMPRESSION_PATH
			}
		};
		
	    // Add the player playlist to the OVA "playlist" configuration block so that it can be used in Ad Scheduling

		this._(_addExistingPlaylistToOVAConfig)(ovaConfig);
		
		return ovaConfig;  	
    }	


    /*
     * Method
     */
    function _initialise(config) {
        ovaDebug.out("Initialising the native OVA for JW5 HTML5 implementation", ovaDebug.DEBUG_CONFIG);
			
	    // Initialise the controller given the OVA configuration that has been provided

	    this.vastController.initialise(this._(_validateConfig)(config, true));

		// Register the two sets of event handlers - player and OVA

		this._(_registerPlayerEventHandlers)();
		this._(_registerOVAEventHandlers)();

	    // Ok, tell OVA to do any preloading and setup
	    
    	this.vastController.load();
	}


    /*
     * Method
     */
    function _reinitialise(config) {
    	this.vastController.unload();
    	this._(_initialise)(config);
    }
    

    /*
     * Fires the callback back to the method that is registered with the OVA JW JS plugin - assumes that
     * _callbacks has been declared in ova-jw.js (perhaps this is a bit of a bad assumption)
     */
	function _firePluginCallback(method, args) {
		if(this.callbacks != undefined) {
			if(method != null) {
				if(args != undefined && args != null) {
					this.callbacks[method](args);							
				}
				else {
					this.callbacks[method]();				
				}
			}
		}
	}
	

    /*
     * Method
     */
    function _abort() {
    	// TO DO
	}
	
	function _readyToPlay() {
		ovaDebug.out("OVA initialisation complete.", ovaDebug.DEBUG_ALL);
		this._(_firePluginCallback)("onOVAReadyToPlay")
	}

    /*
     * Method
     */
    function _registerPlayerEventHandlers() {
		this.player.onPlaylist(_onPlaylistLoadedAtStartupEvent);
 	    this.player.onTime(_onTimeEvent);
	    this.player.onMeta(_onMetaDataEvent);
	    this.player.onMute(_onMuteEvent);
	    this.player.onVolume(_onVolumeChangeEvent);
	    this.player.onPlay(_onPlayEvent);
	    this.player.onIdle(_onIdleEvent); 
	    this.player.onComplete(_onCompleteEvent);
	    this.player.onPause(_onPauseEvent);
	    this.player.onBuffer(_onBufferEvent);
	    this.player.onFullscreen(_onFullscreenEvent);
	    this.player.onError(_onErrorEvent);
	}

    /*
     * Method
     */
    function _registerOVAEventHandlers() {
        
        // Register the startup event listeners
        
        this.vastController.addEventListener(EventConstants.READY_TO_PLAY, this._(_readyToPlay));
        
        // Setup the critical listeners for the template loading process - used by the ad slot "preloaded model"
        
	    this.vastController.addEventListener(EventConstants.LOADED, this._(_onTemplateLoaded));
	    this.vastController.addEventListener(EventConstants.LOAD_FAILED, this._(_onTemplateLoadError));
	    this.vastController.addEventListener(EventConstants.LOAD_TIMEOUT, this._(_onTemplateLoadTimeout));
	    this.vastController.addEventListener(EventConstants.LOAD_DEFERRED, this._(_onTemplateLoadDeferred));

        // Setup the critical listeners for the ad slot loading process - used by the ad slot "on demand load model"
	    
	    this.vastController.addEventListener(EventConstants.LOADED, this._(_onAdSlotLoaded));
	    this.vastController.addEventListener(EventConstants.LOAD_ERROR, this._(_onAdSlotLoadError));
	    this.vastController.addEventListener(EventConstants.LOAD_TIMEOUT, this._(_onAdSlotLoadTimeout));
	    this.vastController.addEventListener(EventConstants.LOAD_DEFERRED, this._(_onAdSlotLoadDeferred));

        // Setup the companion display listeners
	    
	    this.vastController.addEventListener(EventConstants.DISPLAY, this._(_onDisplayCompanionAd));
	    this.vastController.addEventListener(EventConstants.HIDE, this._(_onHideCompanionAd));

        // Setup standard overlay event handlers
        
        this.vastController.addEventListener(EventConstants.DISPLAY, this._(_onDisplayOverlay));
        this.vastController.addEventListener(EventConstants.HIDE, this._(_onHideOverlay));
        this.vastController.addEventListener(EventConstants.DISPLAY_NON_OVERLAY, this._(_onDisplayNonOverlay));
        this.vastController.addEventListener(EventConstants.HIDE_NON_OVERLAY, this._(_onHideNonOverlay));
        this.vastController.addEventListener(EventConstants.CLICKED, this._(_onOverlayClicked));
        this.vastController.addEventListener(EventConstants.CLOSE_CLICKED, this._(_onOverlayCloseClicked));

        // Setup ad notice event handlers
        
        this.vastController.addEventListener(EventConstants.DISPLAY, this._(_onDisplayNotice));
        this.vastController.addEventListener(EventConstants.HIDE, this._(_onHideNotice));

        // Setup linear tracking events
        
        this.vastController.addEventListener(EventConstants.SKIPPED, this._(_onLinearAdSkipped));
        this.vastController.addEventListener(EventConstants.CLICK_THROUGH, this._(_onLinearAdClickThrough));

        // Setup the hander for tracking point set events
        
        this.vastController.addEventListener(EventConstants.SET, this._(_onSetTrackingPoint));
        this.vastController.addEventListener(EventConstants.FIRED, this._(_onTrackingPointFired));

        // Setup the hander for display events on the seeker bar
        
        this.vastController.addEventListener(EventConstants.ENABLE, this._(_onControlBarEnable));
        this.vastController.addEventListener(EventConstants.DISABLE, this._(_onControlBarDisable));
	}


    // --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    // PLAYER DISPLAY METHODS
    // --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

    /*
     * Method
     */
    function _getPlayerWidth() {
		if(this.vastController != null) {
			if(this.vastController.initialised) {
				if((this.player.fullscreen == false) && this.vastController.config.hasPlayerWidth()) {
					return this.vastController.config.playerWidth;
				}
			}
		}
		if(this.player != null) {
			return this.player.getWidth();
		}
		return -1;
    }


    /*
     * Method
     */
    function _getPlayerHeight() {
		if(this.vastController != null) {
			if(this.vastController.initialised) {
				if((this.player.fullscreen == false) && this.vastController.config.hasPlayerHeight()) {
					return this.vastController.config.playerHeight;
				}
			}
		}
		if(this.player != null) {
			return this.player.getHeight();
		}
		return -1;
    }


    // --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    // PLAYLIST RELATED METHODS
    // --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

    /*
     * Method
     */
    function _addExistingPlaylistToOVAConfig(_ovaConfig) {
	}
	
    /*
     * Method
     */	
	function _onPlaylistLoadedAtStartupEvent(event) {
		
	}

    // --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    // PLAYER EVENT HANDLERS
    // --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

    /*
     * Method
     */
    function _onTimeEvent(event) {
        /*
	    TO DO
        if(this.vastController != null) {
           this.vastController.processTimeEvent(new TimeEvent(event.position))
        }
        */
    }

    /*
     * Method
     */
    function _onMetaDataEvent(event) {
	    // TO DO
        ovaDebug.out("on meta data event", ovaDebug.DEBUG_TRACKING_EVENTS);
    }

    /*
     * Method
     */
	function _onMuteEvent(event) {
	    // TO DO
        ovaDebug.out("on mute event", ovaDebug.DEBUG_TRACKING_EVENTS);
	}

    /*
     * Method
     */
	function _onVolumeChangeEvent(event) {
	    // TO DO
        ovaDebug.out("on volume change event", ovaDebug.DEBUG_TRACKING_EVENTS);
	}

    /*
     * Method
     */
	function _onPlayEvent(event) {
	    // TO DO
        ovaDebug.out("on play event", ovaDebug.DEBUG_TRACKING_EVENTS);
	}

    /*
     * Method
     */
	function _onIdleEvent(event) {
	    // TO DO
        ovaDebug.out("on idle event", ovaDebug.DEBUG_TRACKING_EVENTS);
	}

    /*
     * Method
     */
	function _onCompleteEvent(event) {
	    // TO DO
        ovaDebug.out("on complete event", ovaDebug.DEBUG_TRACKING_EVENTS);
	}

    /*
     * Method
     */
	function _onPauseEvent(event) {
	    // TO DO
        ovaDebug.out("on pause event", ovaDebug.DEBUG_TRACKING_EVENTS);
	}

    /*
     * Method
     */
	function _onBufferEvent(event) {
	    // TO DO
        ovaDebug.out("on buffer event", ovaDebug.DEBUG_TRACKING_EVENTS);
	}

    /*
     * Method
     */
	function _onFullscreenEvent(event) {
	    // TO DO
        ovaDebug.out("on fullscreen event", ovaDebug.DEBUG_TRACKING_EVENTS);
	}

    /*
     * Method
     */
	function _onErrorEvent(event) {
	    // TO DO
        ovaDebug.out("on error event", ovaDebug.DEBUG_TRACKING_EVENTS);
	}


    // --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    // VAST LOAD CALLBACKS
    // --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

    /*
     * Method
     */
    function _onTemplateLoaded() {
	    // TO DO
    }

    /*
     * Method
     */
    function _onTemplateLoadError() {
	    // TO DO
    }

    /*
     * Method
     */
    function _onTemplateLoadTimeout() {
	    // TO DO
    }

    /*
     * Method
     */
    function _onTemplateLoadDeferred() {
	    // TO DO
    }

    // ON-DEMAND AD SLOT LOADING

    /*
     * Method
     */
    function _onAdSlotLoaded() {
	    // TO DO
    }

    /*
     * Method
     */
    function _onAdSlotLoadError() {
	    // TO DO
    }

    /*
     * Method
     */
    function _onAdSlotLoadTimeout() {
	    // TO DO
    }

    /*
     * Method
     */
    function _onAdSlotLoadDeferred() {
	    // TO DO
    }

    // --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    // AD NOTICE DISPLAY
    // --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

    /*
     * Method
     */
	function _onDisplayNotice(event) {
	    // TO DO
	}

    /*
     * Method
     */
	function _onHideNotice(event) {
	    // TO DO
	}

    // --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    // AD CLICK ACTIONS
    // --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

    /*
     * Method
     */
	function _onLinearAdSkipped(event) {
	    // TO DO
	}

    /*
     * Method
     */
	function _onLinearAdClickThrough(event) {
	    // TO DO
	}

    // --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    // TRACKING POINT CALLBACKS
    // --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

    /*
     * Method
     */
	function _onSetTrackingPoint(event) {
	    // TO DO
	}

    /*
     * Method
     */
	function _onTrackingPointFired(event) {
	    // TO DO
	}

    // --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    // CONTROL BAR CALLBACKS
    // --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

    /*
     * Method
     */
	function _onControlBarEnable(event) {
	    // TO DO
	}

    /*
     * Method
     */
	function _onControlBarDisable(event) {
	    // TO DO
	}
	
	
    // --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    // NON-LINEAR ACTIONS
    // --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

    /*
     * Method
     */
	function _onDisplayOverlay(event) {
	    // TO DO
	}


    /*
     * Method
     */
	function _onHideOverlay(event) {
	    // TO DO
	}


    /*
     * Method
     */
	function _onDisplayNonOverlay(event) {
	    // TO DO
	}


    /*
     * Method
     */
	function _onHideNonOverlay(event) {
	    // TO DO
	}


    /*
     * Method
     */
	function _onOverlayClicked(event) {
	    // TO DO
	}


    /*
     * Method
     */
	function _onOverlayCloseClicked(event) {
	    // TO DO
	}


    // --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    // COMPANION ACTIONS
    // --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

    /*
     * Method
     */
    function _onDisplayCompanionAd() {
	    // TO DO
    }

    /*
     * Method
     */
    function _onHideCompanionAd() {
	    // TO DO
    }
    
        
    /*
     * Method
     */
    function _play() {
    	ovaDebug.out("ova.play() called - to be implemented", ovaDebug.DEBUG_API);
    }

    
    /*
     * Method
     */
    function _stop() {
    	ovaDebug.out("ova.stop() called - to be implemented", ovaDebug.DEBUG_API);
    }


    /*
     * Method
     */
    function _pause() {
    	ovaDebug.out("ova.pause() called - to be implemented", ovaDebug.DEBUG_API);
    }


    /*
     * Method
     */
    function _resume() {
    	ovaDebug.out("ova.resume() called - to be implemented", ovaDebug.DEBUG_API);
    }


    /*
     * Method
     */
    function _getActiveAdDescriptor() {
    	ovaDebug.out("ova.getActiveAdDescriptor() called - to be implemented", ovaDebug.DEBUG_API);
    }
    

    /*
     * Method
     */
    function _getVersion() {
    	ovaDebug.out("ova.getVersion() called - to be implemented", ovaDebug.DEBUG_API);
    }


    /*
     * Method
     */
    function _enableAds() {
    	ovaDebug.out("ova.enableAds() called - to be implemented", ovaDebug.DEBUG_API);
    }


    /*
     * Method
     */
    function _disableAds() {
    	ovaDebug.out("ova.disableAds() called - to be implemented", ovaDebug.DEBUG_API);
    }


    /*
     * Method
     */
    function _scheduleAds(playlist, newConfig) {
    	ovaDebug.out("ova.scheduleAds() called - re-initialising the OVA plugin...", ovaDebug.DEBUG_API);
    	if(newConfig != undefined) {
	    	if(typeof newConfig == "string") {
	    		_reinitialise({ json: newConfig });
	    	}
	    	else _reinitialise(newConfig);
    	}
    	else {
    		_reinitialise({});
    	}
    }


    /*
     * Method
     */
    function _loadPlaylist() {
    	ovaDebug.out("ova.loadPlaylist() called - to be implemented", ovaDebug.DEBUG_API);
    }


    /*
     * Method
     */
    function _getAdSchedule() {
    	ovaDebug.out("ova.getAdSchedule() called - to be implemented", ovaDebug.DEBUG_API);
    }


    /*
     * Method
     */
    function _getStreamSequence() {
    	ovaDebug.out("ova.getStreamSequence() called - to be implemented", ovaDebug.DEBUG_API);
    }


    /*
     * Method
     */
    function _setDebugLevel(levels) {
    	ovaDebug.out("ova.setDebugLevel() called - to be implemented", ovaDebug.DEBUG_API);
    }


    /*
     * Method
     */
    function _getDebugLevel() {
    	ovaDebug.out("ova.getDebugLevel() called - to be implemented", ovaDebug.DEBUG_API);
    }


    /*
     * Method
     */
    function _skipAd() {
    	ovaDebug.out("ova.skipAd() called - to be implemented", ovaDebug.DEBUG_API);
    }


    /*
     * Method
     */
    function _clearOverlays() {
    	ovaDebug.out("ova.clearOverlays() called - to be implemented", ovaDebug.DEBUG_API);
    }


    /*
     * Method
     */
    function _showOverlay() {
    	ovaDebug.out("ova.showOverlay() called - to be implemented", ovaDebug.DEBUG_API);
    }


    /*
     * Method
     */
    function _hideOverlay() {
    	ovaDebug.out("ova.hideOverlay() called - to be implemented", ovaDebug.DEBUG_API);
    }


    /*
     * Method
     */
    function _enableAPI() {
    	ovaDebug.out("ova.enableAPI() called - to be implemented", ovaDebug.DEBUG_API);
    }


    /*
     * Method
     */
    function _disableAPI() {
    	ovaDebug.out("ova.disableAPI() called - to be implemented", ovaDebug.DEBUG_API);
    }


    /*
     * Method
     */
    function _setActiveLinearAdVolume(volume) {
    	ovaDebug.out("ova.setActiveLinearAdVolume() called - to be implemented", ovaDebug.DEBUG_API);
    }
    
    
	// -------------------------------------------------------------------------------------------------
    // PUBLIC API
    // -------------------------------------------------------------------------------------------------

    return {
        constructor: NativeOVAImplementation,

        _: function(callback) {
             var self = this;
             return function() {
                 return callback.apply(self, arguments);
             };
        },

        /*
         * Public API
         */
        start: function() { this._(_start)(); },
        initialise: function(config) { this._(_initialise)(config); },
		play: function() { this._(_play)(); },
		stop: function() { this._(_stop)(); },
		pause: function() { this._(_pause)(); },   
		resume: function() { this._(_rename)(); },
		getActiveAdDescriptor: function() {	this._(_getActiveAdDescriptor)(); },
		getVersion: function() { this._(_getVersion)(); },
		enableAds: function() {	this._(_enableAds)(); },
		disableAds: function() { this._(_disableAds)(); },
		scheduleAds: function(playlist, newConfig) { this._(_scheduleAds)(playlist, newConfig); },
		loadPlaylist: function() { this._(_loadPlaylist)(); },
		getAdSchedule: function() { this._(_getAdSchedule)(); },
		getStreamSequence: function() { this._(_getStreamSequence)(); },
		setDebugLevel: function(levels) { this._(_setDebugLevel)(levels); },
		getDebugLevel: function() { this._(_getDebugLevel)(); },
		skipAd: function() { this._(_skipAd)(); },
		showOverlay: function() { this._(_showOverlay)(); },
		hideOverlay: function() { this._(_hideOverlay)(); },
		enableAPI: function() { this._(_enableAPI)(); },
		disableAPI: function() { this._(_disableAPI)(); },
		setActiveLinearAdVolume: function(volume) { this._(_setActiveLinearAdVolume)(volume); }
    }    
})();

//@ sourceURL=ova/ova.jwplayer.5x/ova-jw-native.js

