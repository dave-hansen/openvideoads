/*
 *    Copyright (c) 2010 LongTail AdSolutions, Inc
 *
 *    This file is part of the OVA for JW4x plugin.
 *
 *    The OVA for JW4x plugin is commercial software: you can redistribute it
 *    and/or modify it under the terms of the OVA Commercial License.
 *
 *    You should have received a copy of the OVA Commercial License along with
 *    the source code.  If not, see <http://www.openvideoads.org/licenses>.
 */
package org.openvideoads.plugin.jwplayer.streamer {
	import com.adobe.serialization.json.JSON;
	import com.jeroenwijering.events.*;
	
	import flash.display.MovieClip;
	
	import org.openvideoads.base.Debuggable;
	import org.openvideoads.plugin.jwplayer.streamer.playlist.*;
	import org.openvideoads.server.events.TemplateEvent;
	import org.openvideoads.util.DisplayProperties;
	import org.openvideoads.util.StringUtils;
	import org.openvideoads.util.Timestamp;
	import org.openvideoads.vast.VASTController;
	import org.openvideoads.vast.config.Config;
	import org.openvideoads.vast.config.ConfigLoadListener;
	import org.openvideoads.vast.config.groupings.analytics.AnalyticsConfigGroup;
	import org.openvideoads.vast.config.groupings.analytics.google.GoogleAnalyticsConfigGroup;
	import org.openvideoads.vast.events.AdNoticeDisplayEvent;
	import org.openvideoads.vast.events.CompanionAdDisplayEvent;
	import org.openvideoads.vast.events.LinearAdDisplayEvent;
	import org.openvideoads.vast.events.OVAControlBarEvent;
	import org.openvideoads.vast.events.OverlayAdDisplayEvent;
	import org.openvideoads.vast.events.TrackingPointEvent;
	import org.openvideoads.vast.events.VPAIDAdDisplayEvent;
	import org.openvideoads.vast.schedule.Stream;
	import org.openvideoads.vast.schedule.StreamSequence;
	import org.openvideoads.vast.schedule.ads.AdSlot;
	import org.openvideoads.vast.tracking.TimeEvent;
	import org.openvideoads.vpaid.IVPAID;
	    
	public class OpenAdStreamer extends MovieClip implements PluginInterface, ConfigLoadListener {
		protected var _rawConfig:Object;
        protected var _activeStreamIndex:Number = 0;
        protected var _vastController:VASTController;
        protected var _playlist:JWPlaylist;
        protected var _resumingMainStreamPlayback:Boolean = false;
        protected var _timeOverlayLinearVideoAdTriggered:int = -1;
        protected var _activeOverlayAdSlotKey:int = -1;
        protected var _lastTimeTick:Number = 0;
        protected var _lastTickActiveIndex:Number = -1;
        protected var _previousDivContent:Array = new Array();
	    protected var _view:AbstractView;
	    protected var _originalWidth:Number = -1;
	    protected var _originalHeight:Number = -1;
	    protected var _forcedStop:Boolean = false;
	    protected var _playerPaused:Boolean = false;
	    protected var _needToDoStartPreProcessing:Boolean = true;
		protected var _delayedInitialisation:Boolean = false;
		protected var _pendingVPAIDPlaylistItem:JWPlaylistItem = null;
		protected var _justStarted:Boolean = true;
		protected var _heightAllowanceForLinearControlBar:int = 24; 
		protected var _heightAllowanceForNonLinearControlBar:int = 24; 
		protected var _defaultControlBarVisibilityState:Boolean = true;

		protected static const OVA_JW4_DEFAULT_GA_ACCOUNT_ID:String = "UA-4011032-6";

		protected static const OVA_VERSION:String = "v1.0.0 Final (build 3)";
		
		public var config:Object = {
			build: "OVA for JW 4.x - " + OVA_VERSION,
			json: null,
			tag: null,
			tagParams: null, 
			vast: null
		};
                
		public function OpenAdStreamer():void {
		}

		protected function setDefaultPlayerConfigGroup():void {
			_vastController.setDefaultPlayerConfigGroup(
				{
					width: _view.config["width"], 
					height: _view.config["height"], 
					controls: { 
						height: getControlBarHeight(),
						visible: getControlBarVisibilityState()
					},
                    margins: {
                        normal: {
                           withControls: 3,
                           withControlsOverride: 3,
                           withoutControls: 3,
                           withoutControlsOverride: 3
                        },
                        fullscreen: {
                           withControls: 3,
                           withControlsOverride: 3,
                           withoutControls: 3,
                           withoutControlsOverride: 3
                        }
                    },
					modes: {
                       linear: {
                         controls: {
                             visible: true,
                             manage: true,
                             enablePlay: true,
                             enablePause: true,
                             enablePlaylist: false,
                             enableTime: false,
                             enableMute: false,
                             enableVolume: false
                         }
                       },
                       nonLinear: {
 	                     margins: {
	                        fullscreen: {
	                           withControls: 46,
	                           withoutControls: 2
	                        }
	                     }
                      }
				   }
				}
			);
		}

		protected function loadExistingPlaylist(rawConfig:Object):void {
			if(_view.playlist == null) return;
			if(_view.playlist.length > 0) {
				doLog("Importing pre-defined playlist - number of show clips is " + _view.playlist.length, Debuggable.DEBUG_ALWAYS);
				var newStreams:Array = new Array();
				for(var i:int=0; i < _view.playlist.length; i++) {
					var newShow:Object = new Object();
					newShow = { 
						"file": _view.playlist[i].file,
						"duration": Timestamp.secondsToTimestamp(_view.playlist[i].duration),
						"startTime": Timestamp.secondsToTimestamp(_view.playlist[i].start),
						"provider": _view.playlist[i].provider,
						"customProperties": {
							"originalPlaylistItem": _view.playlist[i]
						}
					}					
					newStreams.push(newShow);
					doLog("+ Imported clip: " + newShow.file + 
					      ", startTime: " + newShow.startTime + 
					      ", duration: " + newShow.duration + 
					      ", provider: " + newShow.provider, Debuggable.DEBUG_CONFIG
					);
				}
				if(rawConfig.shows == undefined) {
					rawConfig.shows = { "streams" : newStreams };								
				}
				else rawConfig.shows.streams = newStreams;
			}
			else doLog("No pre-defined playlist clips to import before scheduling", Debuggable.DEBUG_ALWAYS);
		}

		protected function getNewEmptyConfigWithDefaultAnalytics():Config {
			var newConfig:Config = new Config();
            newConfig.analytics.update(
        		[
        			{ 
        				type: AnalyticsConfigGroup.GOOGLE_ANALYTICS,
        				element: GoogleAnalyticsConfigGroup.OVA,
        				displayObject: this,
            			analyticsId: OVA_JW4_DEFAULT_GA_ACCOUNT_ID,
						impressions: {
							enable: true,
							linear: "/ova/impression/jw4?ova_format=linear",
							nonLinear: "/ova/impression/jw4?ova_format=non-linear",
							companion: "/ova/impression/jw4?ova_format=companion"
						},
						adCalls: {
							enable: false,
							fired: "/ova/ad-call/jw4?ova_action=fired",
							complete: "/ova/ad-call/jw4?ova_action=complete",
							failover: "/ova/ad-call/jw4?ova_action=failover",
							error: "/ova/ad-call/jw4?ova_action=error",
							timeout: "/ova/ad-call/jw4?ova_action=timeout",
							deferred: "/ova/ad-call/jw4?ova_action=deferred"
						},
						template: {
							enable: false,
							loaded: "/ova/template/jw4?ova_action=loaded",
							error: "/ova/template/jw4?ova_action=error",
							timeout: "/ova/template/jw4?ova_action=timeout",
							deferred: "/ova/template/jw4?ova_action=deferred"
						},
						adSlot: {
							enable: false,
							loaded: "/ova/ad-slot/jw4?ova_action=loaded",
							error: "/ova/ad-slot/jw4?ova_action=error",
							timeout: "/ova/ad-slot/jw4?ova_action=timeout",
							deferred: "/ova/ad-slot/jw4?ova_action=deferred"
						},
						progress: {
							enable: false,
							start: "/ova/progress/jw4?ova_action=start",
							stop: "/ova/progress/jw4?ova_action=stop",
							firstQuartile: "/ova/progress/jw4?ova_action=firstQuartile",
							midpoint: "/ova/progress/jw4?ova_action=midpoint",
							thirdQuartile: "/ova/progress/jw4?ova_action=thirdQuartile",
							complete: "/ova/progress/jw4?ova_action=complete",
							pause: "/ova/progress/jw4?ova_action=pause",
							resume: "/ova/progress/jw4?ova_action=resume",
							fullscreen: "/ova/progress/jw4?ova_action=fullscreen",
							mute: "/ova/progress/jw4?ova_action=mute",
							unmute: "/ova/progress/jw4?ova_action=unmute",
							expand: "/ova/progress/jw4?ova_action=expand",
							collapse: "/ova/progress/jw4?ova_action=collapse",
							userAcceptInvitation: "/ova/progress/jw4?ova_action=userAcceptInvitation",
							close: "/ova/progress/jw4?ova_action=close"
						},
						clicks: {
							enable: false,
							linear: "/ova/clicks/jw4?ova_action=linear",
							nonLinear: "/ova/clicks/jw4?ova_action=nonLinear",
							vpaid: "/ova/clicks/jw4?ova_action=vpaid"
						},
						vpaid: {
							enable: false,
							loaded: "/ova/vpaid/jw4?ova_action=loaded",
							started: "/ova/vpaid/jw4?ova_action=started",
							complete: "/ova/vpaid/jw4?ova_action=complete",
							stopped: "/ova/vpaid/jw4?ova_action=stopped",
							linearChange: "/ova/vpaid/jw4?ova_action=linearChange",
							expandedChange: "/ova/vpaid/jw4?ova_action=expandedChange",
							remainingTimeChange: "/ova/vpaid/jw4?ova_action=remainingTimeChange",
							volumeChange: "/ova/vpaid/jw4?ova_action=volumeChange",
							videoStart: "/ova/vpaid/jw4?ova_action=videoStart",
							videoFirstQuartile: "/ova/vpaid/jw4?ova_action=videoFirstQuartile",
							videoMidpoint: "/ova/vpaid/jw4?ova_action=videoMidpoint",
							videoThirdQuartile: "/ova/vpaid/jw4?ova_action=videoThirdQuartile",
							videoComplete: "/ova/vpaid/jw4?ova_action=videoComplete",
							userAcceptInvitation: "/ova/vpaid/jw4?ova_action=userAcceptInvitation",
							userClose: "/ova/vpaid/jw4?ova_action=userClose",
							paused: "/ova/vpaid/jw4?ova_action=paused",
							playing: "/ova/vpaid/jw4?ova_action=playing",
							error: "/ova/vpaid/jw4?ova_action=error"
						}	
        			}
        		]            
            );
            return newConfig;
		}
		
		public function initializePlugin(view:AbstractView):void {
			if(config.json == null && config.tag != null) {
				if(config.debug != null) {
					config.json = '{' +
					                  ' "tag": "' + config.tag + '",' +
					                  ' "debug": { "debugger": "firebug", "levels": "' + config.debug + '" }';
				}
				else config.json = '{ "tag": "' + config.tag + '" }';
				if(config.delayadrequestuntilplay != null) config.json += ', "delayAdRequestUntilPlay": ' + config.delayadrequestuntilplay;				
				if(config.autoplay != null) config.json += ', "autoPlay": ' + config.autoplay;
				config.json += '}';
				config.tag = null;
			}	
			if(config.json == null && config.vast != null) {
				// Direct injection of the VAST data via the "vast" variable - assume pre-roll configuration
				config.json = '{' +
					             ' "ads": { ' +
					             '     "schedule": [' +
				                 '         {' +
				                 '            "position": "pre-roll",' +
				                 '            "server": {' +
				                 '                "type": "inject",' +
				                 '                "tag": "' + config.vast + '"' +
				                 '            }' +
					             '         }' +
					             '     ]' +   
					             ' }';
				if(config.debug != null) config.json += ', "debug": { "debugger": "firebug", "levels": "' + config.debug + '" }';
				if(config.delayadrequestuntilplay != null) config.json += ', "delayAdRequestUntilPlay": ' + config.delayadrequestuntilplay;
				if(config.autoplay != null) config.json += ', "autoPlay": ' + config.autoplay;
				config.json += '}';
				config.vast = null;
			}
			if(config.json != null) {			
				try {
					_rawConfig = JSON.decode(config.json);
				}
				catch(e:Error) {
					doLog("OVA Configuration parsing exception - " + e.message, Debuggable.DEBUG_ALWAYS);
				}
				if(config.tag != null) {
					if(_rawConfig == null) {
						_rawConfig = { tag: config.tag };	
					}
					else _rawConfig.tag = config.tag;
				}	
				if(_rawConfig.debug == undefined) _rawConfig.debug = {"levels":"fatal, config"};
				Debuggable.getInstance().configure(_rawConfig.debug);
				doLog(config.build, Debuggable.DEBUG_ALL);
				doLog("Raw config loaded as " + config.json, Debuggable.DEBUG_CONFIG);
				if(_rawConfig.delayAdRequestUntilPlay == undefined) {
					_rawConfig.delayAdRequestUntilPlay = false;
				}
				else if(_rawConfig.delayAdRequestUntilPlay is String) {
					_rawConfig.delayAdRequestUntilPlay = (_rawConfig.delayAdRequestUntilPlay.toUpperCase() == "TRUE");
				}			
				if(_rawConfig.autoPlay == undefined) {
					_rawConfig.autoPlay = false;
				}
				else if(_rawConfig.autoPlay is String) {
					_rawConfig.autoPlay = (_rawConfig.autoPlay.toUpperCase() == "TRUE");
				}			
			}
			else {
				_rawConfig.delayAdRequestUntilPlay = false;	
				_rawConfig.autoPlay = false;		
				Debuggable.getInstance().configure({"levels":"fatal, config"});
				doLog(config.build, Debuggable.DEBUG_ALL);
				doLog("No OVA configuration provided - ad streamer will not be capable of playing any ads", Debuggable.DEBUG_CONFIG);	
			}

			if(config.tagparams != undefined && config.tagparams != null) {
				// tag properties allow the "customProperties" element of an ad server configuration to be passed through
				_rawConfig.tagParams = StringUtils.convertStringToObject(config.tagparams, ",", ":");
				doLog("Additional Ad Tag Parameters have been specified - they will be added to the ad request(s)", Debuggable.DEBUG_CONFIG);				
			}

			_view = view;			
			setControlBarDefaults();
			_view.addControllerListener(ControllerEvent.RESIZE, onResizeEvent);

			// Load up the config and configure the debugger
			_vastController = new VASTController();
			_vastController.startStreamSafetyMargin = 300;			
			_vastController.endStreamSafetyMargin = 300;			
			_vastController.additionMetricsParams = "ova_plugin_version=" + OVA_VERSION + "&ova_player_version=" + _view.config["version"];

			if(_rawConfig.ads != undefined) {
				// set the default mime types allowed - can be overridden in config with "acceptedLinearAdMimeTypes" and "filterOnLinearAdMimeTypes"
				if(_rawConfig.ads.filterOnLinearAdMimeTypes == undefined) {
					doLog("Setting accepted Linear Ad mime types to default list - swf, mp4 and flv", Debuggable.DEBUG_CONFIG);
					_rawConfig.ads.acceptedLinearAdMimeTypes = [ "video/flv", "video/mp4", "video/x-flv", "video/x-mp4", "application/x-shockwave-flash", "flv", "mp4", "swf" ];
					_rawConfig.ads.filterOnLinearAdMimeTypes = true;		
				}
				else doLog("Setting accepted Linear Ad mime types and enabled state = " + _rawConfig.ads.filterOnLinearAdMimeTypes, Debuggable.DEBUG_CONFIG);
			}

            // auto set the blocking property based on whether or not a file flashvar has been specified
			_rawConfig.blockUntilOriginalPlaylistLoaded = (_view.config["file"] != undefined);
			doLog("Setting 'blockUntilOriginalPlaylistLoaded' to " + _rawConfig.blockUntilOriginalPlaylistLoaded, Debuggable.DEBUG_CONFIG);
			doLog("Holding clip (image) is " + _vastController.config.adsConfig.vpaidConfig.holdingClipUrl, Debuggable.DEBUG_CONFIG);
           
			if(_rawConfig.blockUntilOriginalPlaylistLoaded) {
				if(_view.playlist == null) {
					doLog("Blocking OVA plugin initialisation until the original JW flashvar specified playlist is loaded...", Debuggable.DEBUG_CONFIG);
					_view.addControllerListener(ControllerEvent.PLAYLIST, onOriginalPlaylistLoad);
				}
				else {
					if(_rawConfig.delayAdRequestUntilPlay && !_rawConfig.autoPlay) {
						setupPlayerToDeferInitialisation();
					}
					else continuePluginInitialisation();
				}
			}
			else {
				if(_rawConfig.delayAdRequestUntilPlay && !_rawConfig.autoPlay) {
					setupPlayerToDeferInitialisation();
				}
				else continuePluginInitialisation();
			}
		}

		protected function setupPlayerToDeferInitialisation():void {
			doLog("Deferring initialisation of the VASTController until the Play button is hit", Debuggable.DEBUG_CONFIG);
			_view.addViewListener(ViewEvent.PLAY, onPlayEventWithDeferredInitialisation);
			_delayedInitialisation = true;
		}

		private function onPlayEventWithDeferredInitialisation(evt:ViewEvent):void {
			doLog("Triggering deferred initialisation of the VASTController...", Debuggable.DEBUG_CONFIG);
			_view.removeViewListener(ViewEvent.PLAY, onPlayEventWithDeferredInitialisation);
			continuePluginInitialisation();
		}

		private function onOriginalPlaylistLoad(evt:ControllerEvent):void {
			doLog("Original playlist loaded - " + ((_view.playlist != null) ? _view.playlist.length : 0) + " items loaded", Debuggable.DEBUG_CONFIG);
			_view.removeControllerListener(ControllerEvent.PLAYLIST, onOriginalPlaylistLoad);
			if(_rawConfig.delayAdRequestUntilPlay && !_rawConfig.autoPlay) {
				setupPlayerToDeferInitialisation();
			}
			else continuePluginInitialisation();
		} 
		
		protected function continuePluginInitialisation():void {			
			doLog("Continuing with OVA plugin initialisation...", Debuggable.DEBUG_CONFIG);
			loadExistingPlaylist(_rawConfig);			
			_vastController.initialise(_rawConfig, false, this, getNewEmptyConfigWithDefaultAnalytics());
		}
			
		public function isOVAConfigLoading():Boolean { return true; }
						
		public function onOVAConfigLoaded():void {	
			if(!_vastController.config.hasProviders()) {
				doLog("Missing providers in the user config - automatically setting the defaults where missing to http(video) and rtmp(rtmp)", Debuggable.DEBUG_CONFIG);
				_vastController.config.setMissingProviders("video", "rtmp");
			}

			// Config the player to autostart based on the config setting for "autoPlay"
			if(_vastController.autoPlay()) {
				_forcedStop = true; // stops the VAST "stop" event firing incorrectly when autoStart is set
				_view.config['autostart'] = _vastController.autoPlay();
			}
			
            // Setup the playlist tracking events
			_view.addControllerListener(ControllerEvent.ITEM, playlistSelectionHandler);			
			_view.addModelListener(ModelEvent.STATE, streamStateHandler);
			_view.addModelListener(ModelEvent.TIME, timeHandler);
			_view.addModelListener(ModelEvent.META, onMetaData);

			// Setup the player tracking events
			_view.addControllerListener(ControllerEvent.MUTE, onMuteEvent);	
			_view.addControllerListener(ControllerEvent.VOLUME, onVolumeEvent);
			_view.addControllerListener(ControllerEvent.PLAY, onPauseResumeEvent);
			_view.addViewListener(ViewEvent.LOAD, onLoadEvent);
			_view.addViewListener(ViewEvent.STOP, onUserStopEvent);
            
            // Setup the critical listeners for the template loading process
            _vastController.addEventListener(TemplateEvent.LOADED, onTemplateLoaded);
            _vastController.addEventListener(TemplateEvent.LOAD_FAILED, onTemplateLoadError);
            _vastController.addEventListener(TemplateEvent.LOAD_TIMEOUT, onTemplateLoadTimeout);
            _vastController.addEventListener(TemplateEvent.LOAD_DEFERRED, onTemplateLoadDeferred);
          
            // Setup the companion display listeners
            _vastController.addEventListener(CompanionAdDisplayEvent.DISPLAY, onDisplayCompanionAd);
            _vastController.addEventListener(CompanionAdDisplayEvent.HIDE, onHideCompanionAd);

            // enable display of regions
            _vastController.enableRegionDisplay(
            	new DisplayProperties(
            			this, 
            			_view.config["width"], 
            			_view.config["height"],
            			getDisplayMode(),
            			_vastController.getActiveDisplaySpecification(!activeStreamIsLinearAd()),
            			controlBarVisibleAtBottom(),
            			_view.config["controlbar.margin"],
            			getControlBarYPosition()
            	)
            );
    
            // Setup standard overlay event handlers
            _vastController.addEventListener(OverlayAdDisplayEvent.DISPLAY, onDisplayOverlay);
            _vastController.addEventListener(OverlayAdDisplayEvent.HIDE, onHideOverlay);
            _vastController.addEventListener(OverlayAdDisplayEvent.DISPLAY_NON_OVERLAY, onDisplayNonOverlay);
            _vastController.addEventListener(OverlayAdDisplayEvent.HIDE_NON_OVERLAY, onHideNonOverlay);
            _vastController.addEventListener(OverlayAdDisplayEvent.CLICKED, onOverlayClicked);
            _vastController.addEventListener(OverlayAdDisplayEvent.CLOSE_CLICKED, onOverlayCloseClicked);

            // Setup ad notice event handlers
            _vastController.addEventListener(AdNoticeDisplayEvent.DISPLAY, onDisplayNotice);
            _vastController.addEventListener(AdNoticeDisplayEvent.HIDE, onHideNotice);

            // Setup VPAID event handlers
            _vastController.addEventListener(VPAIDAdDisplayEvent.LINEAR_START, onVPAIDLinearAdStart); 
            _vastController.addEventListener(VPAIDAdDisplayEvent.LINEAR_COMPLETE, onVPAIDLinearAdComplete); 
            _vastController.addEventListener(VPAIDAdDisplayEvent.LINEAR_ERROR, onVPAIDLinearAdError); 
            _vastController.addEventListener(VPAIDAdDisplayEvent.LINEAR_LINEAR_CHANGE, onVPAIDLinearAdLinearChange); 
            _vastController.addEventListener(VPAIDAdDisplayEvent.LINEAR_EXPANDED_CHANGE, onVPAIDLinearAdExpandedChange); 
            _vastController.addEventListener(VPAIDAdDisplayEvent.LINEAR_TIME_CHANGE, onVPAIDLinearAdTimeChange); 
            _vastController.addEventListener(VPAIDAdDisplayEvent.NON_LINEAR_START, onVPAIDNonLinearAdStart); 
            _vastController.addEventListener(VPAIDAdDisplayEvent.NON_LINEAR_COMPLETE, onVPAIDNonLinearAdComplete); 
            _vastController.addEventListener(VPAIDAdDisplayEvent.NON_LINEAR_ERROR, onVPAIDNonLinearAdError); 
            _vastController.addEventListener(VPAIDAdDisplayEvent.NON_LINEAR_LINEAR_CHANGE, onVPAIDNonLinearAdLinearChange); 
            _vastController.addEventListener(VPAIDAdDisplayEvent.NON_LINEAR_EXPANDED_CHANGE, onVPAIDNonLinearAdExpandedChange); 
            _vastController.addEventListener(VPAIDAdDisplayEvent.NON_LINEAR_TIME_CHANGE, onVPAIDNonLinearAdTimeChange); 
          
            // Setup linear tracking events
            _vastController.addEventListener(LinearAdDisplayEvent.SKIPPED, onLinearAdSkipped);
            _vastController.addEventListener(LinearAdDisplayEvent.CLICK_THROUGH, onLinearAdClickThrough);           
            
            // Setup the hander for tracking point set events
            _vastController.addEventListener(TrackingPointEvent.SET, onSetTrackingPoint);
            _vastController.addEventListener(TrackingPointEvent.FIRED, onTrackingPointFired);
            
            // Setup the hander for display events on the control bar
            _vastController.addEventListener(OVAControlBarEvent.ENABLE, onControlBarEnable);
            _vastController.addEventListener(OVAControlBarEvent.DISABLE, onControlBarDisable);

            // Ok, let's load up the VAST data from our Ad Server
            _vastController.load();
			doLog("Initialisation complete.", Debuggable.DEBUG_ALL);
		}
		
		protected function getDisplayMode():String {
			if(_view != null) {
				if(_view.config["fullscreen"]) {
					return DisplayProperties.DISPLAY_FULLSCREEN;
				}			
			}
			return DisplayProperties.DISPLAY_NORMAL;
		}
		
		protected function getActiveStreamIndex():int {
			return (_vastController.allowPlaylistControl) 
						? _activeStreamIndex : 
						((_playlist != null) ? _playlist.playingTrackIndex : 0);
		}
		
		protected function getPlayerPlaylistIndex():int {
			return (_vastController.allowPlaylistControl) ? _playlist.playingTrackIndex : 0;
		}

		protected function activeStreamIsLinearAd():Boolean {
			if(_vastController != null) {
				if(_vastController.streamSequence != null) {
					return (_vastController.streamSequence.streamAt(getActiveStreamIndex()) is AdSlot);							
				}
			}
			return false;
		}
		
		protected function createPlaylist():JWPlaylist {
			return new JWPlaylist(_vastController.streamSequence, 
			                      _vastController.config.showsConfig.providersConfig, 
			                      _vastController.config.adsConfig.providersConfig);
		}

		protected function clearPlayerPlaylist(addHoldingClip:Boolean = false):void {
			if(_view.playlist != null) {
				for(var i:int=0; i < _view.playlist.length; i++) {
					_view.playlist.pop();
				}
				if(addHoldingClip) {
					_view.playlist.push({ file: _vastController.config.adsConfig.vpaidConfig.holdingClipUrl, type: "image" });
				}				
			}
		}

		protected function loadJWClip(item:JWPlaylistItem, forcePlay:Boolean=false, closeActiveVPAIDAds:Boolean=true):void {
			if(item != null) {
				if(closeActiveVPAIDAds) {
					if(_vastController != null) _vastController.closeActiveVPAIDAds();
				}
				if(item.isInteractive()) {
					if(_justStarted && !_vastController.autoPlay()) { 
						// If the player is just starting up, don't trigger the play of the VPAID ad just yet -
						// wait for the play button to be pressed first
						doLog("First stream is a VPAID ad, but autoPlay is false and play hasn't been hit yet, so wait for play before loading..", Debuggable.DEBUG_PLAYLIST);
						_pendingVPAIDPlaylistItem = item;
						clearPlayerPlaylist(true);
						_view.addViewListener(ViewEvent.PLAY, onStartupPlayEventWithVPAIDLinear);
					}
					else {
						doLog("Loading VPAID linear playlist item...", Debuggable.DEBUG_PLAYLIST);
						_vastController.playVPAIDAd(AdSlot(item.stream), _view.config["mute"]);				
						_pendingVPAIDPlaylistItem = null;
					}
				}
				else {
		            var playlist:Array = new Array();
		            playlist.push(item.toJWPlaylistItemObject(true, _vastController.config.adsConfig.metaDataConfig));
		            if(playlist.length > 0) {
		                doLog("Loading playlist track " + item.toString(), Debuggable.DEBUG_PLAYLIST);
		                // always enable the control bar for show streams
						setControlBarState(false);
		                // now load the new clip
		                _view.sendEvent("LOAD", playlist);
			        	_justStarted = false;
			        	if(forcePlay) {
							startPlayback();
			        	}
		                
		    	    }
		        	else doLog("Cannot convert the clip to a JW clip object - loading failed");                								
				}
			}
			else doLog("Cannot load JW clip from null JWPlaylistItem", Debuggable.DEBUG_PLAYLIST);
		}

        // VPAID specific playback handlers

		protected function moveFromVPAIDLinearToNextPlaylistItem():void {
			if(_vastController.hideControlbarDuringVPAIDLinearPlayback()) {
				setControlBarVisibility(_defaultControlBarVisibilityState);
			}
			else turnOnControlBar();
        	streamStateHandler(null, false, false);
		}

        protected function onVPAIDLinearAdStart(event:VPAIDAdDisplayEvent):void {
        	doLog("PLUGIN NOTIFICATION: VPAID Linear Ad started", Debuggable.DEBUG_VPAID);
			if(_vastController.hideControlbarDuringVPAIDLinearPlayback()) {
				setControlBarVisibility(false);
			}
			else turnOffControlBar();
        }
        
        protected function onVPAIDLinearAdComplete(event:VPAIDAdDisplayEvent):void {
        	if(activeStreamIsLinearAd()) {
	        	doLog("PLUGIN NOTIFICATION: VPAID Linear Ad complete - proceeding to next playlist item", Debuggable.DEBUG_VPAID);
	        	moveFromVPAIDLinearToNextPlaylistItem();
	        }
	        else {
	        	if(playerPaused()) {
		        	doLog("PLUGIN NOTIFICATION: VPAID Linear Ad complete - show stream is already active - resuming playback", Debuggable.DEBUG_VPAID);
	        		resumePlayback();
	        	}
		        else doLog("PLUGIN NOTIFICATION: VPAID Linear Ad complete - show stream is already active - no additional action required", Debuggable.DEBUG_VPAID);
	        }
        }

		protected function onVPAIDLinearAdError(error:VPAIDAdDisplayEvent):void {
        	if(activeStreamIsLinearAd()) {
	        	doLog((error != null) 
    	    	         ? "PLUGIN NOTIFICATION: VPAID Linear Ad error ('" + ((error.data != null) ? error.data.message : "") + "') proceeding to next playlist item"
        		         : "PLUGIN NOTIFICATION: VPAID Linear Ad error proceeding to next playlist item", Debuggable.DEBUG_VPAID);
        		moveFromVPAIDLinearToNextPlaylistItem();
        	}
        	else {
        		if(playerPaused()) {
		        	doLog("PLUGIN NOTIFICATION: VPAID Linear Ad error ('" + ((error.data != null) ? error.data.message : "") + "') - Active stream is a show stream - resuming playback", Debuggable.DEBUG_VPAID);
        			resumePlayback();			
        		}
        		else doLog("PLUGIN NOTIFICATION: VPAID Linear Ad error ('" + ((error.data != null) ? error.data.message : "") + "') - Active stream is a show stream - no additional action required", Debuggable.DEBUG_VPAID);
        	} 
		}

		protected function onVPAIDLinearAdLinearChange(event:VPAIDAdDisplayEvent):void {
			doLog("PLUGIN NOTIFICATION: VPAID Linear Ad linear change", Debuggable.DEBUG_VPAID);
			if(event.data == false) { 
				// event.data represents the "adLinear" value - in this case adLinear == false so ad is no longer in linear state
			}
		}

		protected function onVPAIDLinearAdExpandedChange(event:VPAIDAdDisplayEvent):void {
			doLog("PLUGIN NOTIFICATION: VPAID Linear Ad expanded change - expanded state == " + ((event != null) ? event.data.expanded : "'not provided'") + ", linear playback underway == " + event.data.linearPlayback + ", player paused == " + playerPaused(), Debuggable.DEBUG_VPAID);
			if(event.data.expanded == false && event.data.linearPlayback == false) {
			    // VPAID ad has been minimised as the "adExpanded" state == false (event.data represents the "adExpanded" state
			    if(activeStreamIsLinearAd()) {
					moveFromVPAIDLinearToNextPlaylistItem();				
				}
				else {
					// We have a show stream as the active stream
					if(playerPaused()) resumePlayback();
				}
			}
			else if(event.data.expanded) { 
				// VPAID ad has been expanded as the "adExpanded" state == true
				pausePlayback();
			}
		}

		protected function onVPAIDLinearAdTimeChange(event:VPAIDAdDisplayEvent):void {
			doLog("PLUGIN NOTIFICATION: VPAID Linear Ad linear time change", Debuggable.DEBUG_VPAID);
		}          
		
		protected function onVPAIDNonLinearAdStart(event:VPAIDAdDisplayEvent):void {
			doLog("PLUGIN NOTIFICATION: VPAID Non-Linear Ad start", Debuggable.DEBUG_VPAID);
		}
		
		protected function onVPAIDNonLinearAdComplete(event:VPAIDAdDisplayEvent):void { 
			if(playerPaused()) {
				doLog("PLUGIN NOTIFICATION: VPAID Non-Linear Ad complete - resuming playback", Debuggable.DEBUG_VPAID);
				resumePlayback();
			}
			else doLog("PLUGIN NOTIFICATION: VPAID Non-Linear Ad complete - no action required", Debuggable.DEBUG_VPAID);
		}
		
		protected function onVPAIDNonLinearAdError(event:VPAIDAdDisplayEvent):void {
			if(playerPaused()) {
				doLog("PLUGIN NOTIFICATION: VPAID Non-Linear Ad error ('" + ((event.data != null) ? event.data.message : "") + "') - resuming playback", Debuggable.DEBUG_VPAID);
				resumePlayback();
			}
        	else doLog("PLUGIN NOTIFICATION: VPAID Non-Linear Ad error ('" + ((event.data != null) ? event.data.message : "") + "')", Debuggable.DEBUG_VPAID);
		}
		
		protected function onVPAIDNonLinearAdLinearChange(event:VPAIDAdDisplayEvent):void {
			doLog("PLUGIN NOTIFICATION: VPAID Non-Linear Ad linear change", Debuggable.DEBUG_VPAID);
		}
		
		protected function onVPAIDNonLinearAdExpandedChange(event:VPAIDAdDisplayEvent):void {
			doLog("PLUGIN NOTIFICATION: VPAID Non-Linear Ad expanded change - expanded state == " + ((event != null) ? event.data : "'not provided'") + ", player paused == " + playerPaused(), Debuggable.DEBUG_VPAID);
			if(event.data == false) { 
			    // VPAID ad has been minimised as the "adExpanded" state == false (event.data represents the "adExpanded" state
				if(_playerPaused) {
					resumePlayback();
				}
			}
			else { 
				// VPAID ad has been expanded as the "adExpanded" state == true
				pausePlayback();
			}
		}

		protected function onVPAIDNonLinearAdTimeChange(event:VPAIDAdDisplayEvent):void {
			doLog("PLUGIN NOTIFICATION: VPAID Non-Linear Ad time change", Debuggable.DEBUG_VPAID);
		}          

		// MetaData handler

		private function attemptCurrentStreamDurationAdjustment(theStream:Stream, newDuration:Number):Boolean {
			var currentDuration:int = theStream.getDurationAsInt();
			var roundedNewDuration:int = Math.floor(newDuration);
			if(currentDuration != roundedNewDuration && roundedNewDuration > 0) {
	   			doLog(((theStream is AdSlot) ? "Ad" : "Show") + " stream duration requires adjustment - original duration: " + currentDuration + ", metadata duration: " + newDuration + " rounded: " + roundedNewDuration, Debuggable.DEBUG_CONFIG);
                var currentClip:Object = _view.playlist[getPlayerPlaylistIndex()]; 
	   			if(currentClip != null) {
					currentClip["duration"] = newDuration;
					theStream.duration = String(roundedNewDuration);
					doLog("Active stream duration updated to " + currentClip.duration, Debuggable.DEBUG_CONFIG);
					return true;
	   			}				
		 		else doLog("Not changing " + ((theStream is AdSlot) ? "Ad" : "Show") + " stream duration - cannot get a handle to the 'current' stream in the playlist", Debuggable.DEBUG_CONFIG);
			}							
			else doLog("Not adjusting the " + ((theStream is AdSlot) ? "Ad" : "Show") + " stream duration based on metadata (" + newDuration + ") - it is either zero or the same as currently set on the clip (" + currentDuration + " == " + roundedNewDuration + ")", Debuggable.DEBUG_CONFIG);
			return false;
		}

		private function onMetaData(evt:ModelEvent):void {
			if(evt.data != null) {
				if(evt.data.duration != undefined) {
					var newDuration:Number = Number(evt.data.duration);
					doLog("Duration metadata received for active clip - metadata duration is " + newDuration, Debuggable.DEBUG_CONFIG);
					var theScheduledStream:Stream = _vastController.streamSequence.streamAt(getActiveStreamIndex());
					if(theScheduledStream != null) {
						/*
						 * Here are the rules for using the metadata duration as the duration on a clip:
						 *    1. If the clip is an Ad 
						 *           a. If the duration is 0 - set it from the metadata
						 *           b. If the metadata duration differs from the VAST value and the "deriveAdDurationFromMetaData" flag 
						 *              is true set it from the metadata
						 *    2. If the clip is a Show and the "deriveShowDurationFromMetaData" flag is true (it is false by default)
						 *           a. If the metadata duration differs from the duration on the clip, set it from the metadata
						 */
						if(theScheduledStream is AdSlot) {
							if(theScheduledStream.hasZeroDuration()) {
								if(attemptCurrentStreamDurationAdjustment(theScheduledStream, newDuration)) {
									_vastController.resetDurationForAdStreamAtIndex(getActiveStreamIndex(), Math.floor(newDuration));					   				
								}
							}
							else if(_vastController.deriveAdDurationFromMetaData()) {
								if(attemptCurrentStreamDurationAdjustment(theScheduledStream, newDuration)) {
									_vastController.resetDurationForAdStreamAtIndex(getActiveStreamIndex(), Math.floor(newDuration));										
								}								
							}
							else doLog("Not adjusting the ad stream metadata - deriveAdDurationFromMetaData == false", Debuggable.DEBUG_CONFIG);	
						} 
						else if(theScheduledStream is Stream) {
							if(_vastController.deriveShowDurationFromMetaData()) {
								attemptCurrentStreamDurationAdjustment(theScheduledStream, newDuration);								
							}	
							else doLog("Not adjusting the ad stream metadata - deriveShowDurationFromMetaData == false", Debuggable.DEBUG_CONFIG);								
						}
						else doLog("Not adjusting the stream duration based on the metadata - the clip is of an unknown type", Debuggable.DEBUG_CONFIG);
					}
				}			
			}
		}

		// Time point handler
		
		private function timeHandler(evt:ModelEvent):void {
			var activeIndex:int = getActiveStreamIndex();
			if((_vastController.streamSequence.streamAt(activeIndex) is AdSlot)) {
				/* 
				 * The next two conditions exist because for some strange reason, when changing between playlist items
				 * as the new item is loaded, a 0 timing event is fired, but a timing event for the previous stream may
				 * appear after that - e.g. 0 for playlist item 1 followed by 30.1 for playlist item 0 - we need to ignore
				 * any left over timing events once the new playlist item has been loaded
				 */
				if(!_vastController.isActiveOverlayVideoPlaying()) {
					if(evt.data.position > _lastTimeTick && _lastTickActiveIndex != activeIndex && _lastTickActiveIndex > -1) {
						if(evt.data.position >= _lastTimeTick) {
							doLog("Ignoring time event at " + evt.data.position + " - lastTimeTick = " + _lastTimeTick + ", lastTickActiveIndex = " + _lastTickActiveIndex + " but activeIndex = " + activeIndex, Debuggable.DEBUG_CUEPOINT_EVENTS);
							return;
						}
					}
					_lastTickActiveIndex = activeIndex;
					if(evt.data.position > (_lastTimeTick + 1.2)) {
						doLog("Ignoring time event at " + evt.data.position + " - the variation with the lastTickTime " + _lastTimeTick + " is greater than 1.2 - time event appears out of sync", Debuggable.DEBUG_CUEPOINT_EVENTS);				
						return;
					}				
				}
				if(_needToDoStartPreProcessing) {
					// used to enforce impression sending where needed for empty Ad slots
					_vastController.processImpressionFiringForEmptyAdSlots();				
					_needToDoStartPreProcessing = false;
				}				
			}
			if(!_vastController.isActiveOverlayVideoPlaying()) {
				_lastTimeTick = evt.data.position;
				_vastController.processTimeEvent(activeIndex, new TimeEvent(evt.data.position * 1000, evt.data.duration));		
			}
			else {
				_vastController.processOverlayLinearVideoAdTimeEvent(_activeOverlayAdSlotKey, new TimeEvent(evt.data.position * 1000, evt.data.duration));
			}				
		}
				
		// Tracking Point event callbacks
		
		protected function onSetTrackingPoint(event:TrackingPointEvent):void {
			// Not required for JW Player because we are constantly checking the 1/10th second timed events
			// by firing them directly through to the stream sequence to process.
			doLog("PLUGIN NOTIFICATION: Request received to set a tracking point (" + event.trackingPoint.label + ") at " + event.trackingPoint.milliseconds + " milliseconds", Debuggable.DEBUG_TRACKING_EVENTS);
		}

		protected function onTrackingPointFired(event:TrackingPointEvent):void {
			// Not required for JW Player because we are constantly checking the 1/10th second timed events
			// by firing them directly through to the stream sequence to process.
			doLog("PLUGIN NOTIFICATION: Request received that a tracking point was fired (" + event.trackingPoint.label + ") at " + event.trackingPoint.milliseconds + " milliseconds", Debuggable.DEBUG_TRACKING_EVENTS);
		}
		
		// VAST data event callbacks
		
		protected function onTemplateLoaded(event:TemplateEvent):void {
			if(event.template.hasAds()) {
				doLog("PLUGIN NOTIFICATION: VAST template loaded - " + event.template.ads.length + " ads retrieved", Debuggable.DEBUG_VAST_TEMPLATE);
			}
			else doLog("PLUGIN NOTIFICATION: No ads to be scheduled - only show streams will be played", Debuggable.DEBUG_VAST_TEMPLATE);
        
			_playlist = createPlaylist();
			doLog("JW playlist created: " + _playlist.toString(true), Debuggable.DEBUG_PLAYLIST);

			if(_vastController.allowPlaylistControl) {
				doLog("Loading up full playlist - not implemented", Debuggable.DEBUG_PLAYLIST);
			}
			else { 
				// iterate through the playlist one clip at time, so just up the first
                var item:JWPlaylistItem = _playlist.nextTrackAsPlaylistItem() as JWPlaylistItem;
                if(item != null) {
                	loadJWClip(item);
                	if(_delayedInitialisation) {
                		_delayedInitialisation = false;
                		startPlayback();
                	}
                }
                else doLog("No clip available in the playlist to load into the player", Debuggable.DEBUG_PLAYLIST);
			}
		}
		
		protected function onTemplateLoadError(event:TemplateEvent):void {
			doLog("PLUGIN NOTIFICATION: FAILURE loading VAST template - " + event.toString(), Debuggable.DEBUG_FATAL);
		}

		protected function onTemplateLoadTimeout(event:TemplateEvent):void {
			doLog("PLUGIN NOTIFICATION: TIMEOUT loading VAST template - " + event.toString(), Debuggable.DEBUG_FATAL);
		}

		protected function onTemplateLoadDeferred(event:TemplateEvent):void {
			doLog("PLUGIN NOTIFICATION: DEFERRED loading VAST template - " + event.toString(), Debuggable.DEBUG_FATAL);
		}

        // Linear ad tracking callbacks

		public function onLinearAdSkipped(linearAdDisplayEvent:LinearAdDisplayEvent):void {
			doLog("PLUGIN NOTIFICATION: Event received that linear ad has been skipped - forcing player to skip to next track", Debuggable.DEBUG_DISPLAY_EVENTS);
            streamStateHandler(null);
		}	
        
		public function onLinearAdClickThrough(linearAdDisplayEvent:LinearAdDisplayEvent):void {
			doLog("PLUGIN NOTIFICATION: Event received that linear ad click through activated", Debuggable.DEBUG_DISPLAY_EVENTS);			
			if(_vastController.pauseOnClickThrough) _view.sendEvent(ControllerEvent.PLAY, false);
		}

        // Control bar operations

		public function onControlBarDisable(event:OVAControlBarEvent):void {
 		    doLog("PLUGIN NOTIFICATION: Request received to DISABLE the control bar", Debuggable.DEBUG_DISPLAY_EVENTS);
 			turnOffControlBar();
		}

		public function onControlBarEnable(event:OVAControlBarEvent):void {
 		    doLog("PLUGIN NOTIFICATION: Request received to ENABLE the control bar", Debuggable.DEBUG_DISPLAY_EVENTS);
 			turnOnControlBar();
		}

		private function getLinearHeightAllowanceForControlBar():int {
			return _heightAllowanceForLinearControlBar;
		}

		private function getNonLinearHeightAllowanceForControlBar():int {
			return _heightAllowanceForNonLinearControlBar;
		}

		protected function controlBarVisibleAtBottom():Boolean {
			return (StringUtils.matchesIgnoreCase(_view.config["controlbar"], "BOTTOM") || 
			       StringUtils.matchesIgnoreCase(_view.config["controlbar"], "OVER") || 
			       (_view.config["fullscreen"] && StringUtils.matchesIgnoreCase(_view.config["controlbar"], "TOP")));
		}
		
		private function getControlBarVisibilityState():Boolean {
			var controlbar:Object = _view.getPlugin('controlbar');
			if(controlbar != null) {
				if(controlbar.clip != null) {
					return controlbar.clip.visible;
				}
			}
			return true;
		}

		protected function getControlBarHeight():Number {
			return 24;	
		}
		
		protected function getControlBarYPosition():Number {
			if(getControlBarVisibilityState() == false || _view.config["fullscreen"] == false && StringUtils.matchesIgnoreCase(_view.config["controlbar"], "TOP")) {
			}
			else {
				var controlbar:Object = _view.getPlugin('controlbar');
				if(controlbar != null) {
					if(controlbar.clip != null) {
						return controlbar.clip.y;
					}
				}
			}
			return -1;
		}
		
		private function setControlBarDefaults():void {
			if(StringUtils.matchesIgnoreCase(_view.config["controlbar"], "NONE")) {
				// there isn't a control bar
				_defaultControlBarVisibilityState = false;
				_heightAllowanceForLinearControlBar = 0;
				_heightAllowanceForNonLinearControlBar = 0;
			}
			else if(StringUtils.matchesIgnoreCase(_view.config["controlbar"], "OVER")) {
				// there is a control bar, but it doesn't create a bottom margin
				_defaultControlBarVisibilityState = getControlBarVisibilityState();
				_heightAllowanceForLinearControlBar = 0;
				_heightAllowanceForNonLinearControlBar = 0;
			}						
			else {
				// there is a control bar top or bottom so detect and set the defaults accordingly		
				_defaultControlBarVisibilityState = getControlBarVisibilityState();
				_heightAllowanceForLinearControlBar = _view.config["controlbar.margin"];
				_heightAllowanceForNonLinearControlBar = _view.config["controlbar.margin"];
			}			
			doLog("Control bar defaults set to - default visibility state = " + _defaultControlBarVisibilityState + ", height allowance (linear) = " +  _heightAllowanceForLinearControlBar + ", height allowance (non-linear) = " + _heightAllowanceForNonLinearControlBar, Debuggable.DEBUG_CONFIG);
		}

		protected function turnOnControlBar():void {
			setControlBarState(false);
		}
		
		protected function turnOffControlBar():void {
			setControlBarState(true);
		}
		
        protected function setControlBarState(turnOff:Boolean):void {
        	if(_vastController != null) {
        		if(_vastController.config.playerConfig.shouldManageControlsDuringLinearAds(false)) { 
					var controlbar:Object = _view.getPlugin('controlbar');
					if(!_vastController.config.playerConfig.shouldDisableControlsDuringLinearAds()) {
						turnOff = false;
					}
					controlbar.block(turnOff);
					doLog("Control bar state changed to " + ((turnOff) ? "BLOCKED" : "ON"));        			
        		}
        	}
        }
        
		protected function setControlBarVisibility(visible:Boolean):void {
			var controlbar:Object = _view.getPlugin('controlbar');
			if(controlbar != null) {
				if(controlbar.clip != null) {
					controlbar.clip.visible = visible;
				}
			}
		}    

        // VAST display callbacks

		public function onDisplayNotice(displayEvent:AdNoticeDisplayEvent):void {	
			doLog("PLUGIN NOTIFICATION: Event received to display ad notice", Debuggable.DEBUG_DISPLAY_EVENTS);
		}
				
		public function onHideNotice(displayEvent:AdNoticeDisplayEvent):void {	
			doLog("PLUGIN NOTIFICATION: Event received to hide ad notice", Debuggable.DEBUG_DISPLAY_EVENTS);
		}
				
		public function onDisplayOverlay(displayEvent:OverlayAdDisplayEvent):void {
			doLog("PLUGIN NOTIFICATION: Event received to display non-linear overlay ad (" + displayEvent.toString() + ")", Debuggable.DEBUG_DISPLAY_EVENTS);
		}

		public function onOverlayCloseClicked(displayEvent:OverlayAdDisplayEvent):void {
			doLog("PLUGIN NOTIFICATION: Event received - overlay close has been clicked (" + displayEvent.toString() + ")", Debuggable.DEBUG_DISPLAY_EVENTS);
		}

		public function onOverlayClicked(displayEvent:OverlayAdDisplayEvent):void {
			doLog("PLUGIN NOTIFICATION: Event received - overlay has been clicked (" + displayEvent.toString() + ") - time is " + _lastTimeTick, Debuggable.DEBUG_DISPLAY_EVENTS);

            if(displayEvent.nonLinearVideoAd.hasAccompanyingVideoAd()) {
            	var overlayStreamSequence:StreamSequence = _vastController.getActiveOverlayStreamSequence();
            	if(overlayStreamSequence != null) {
	            	var playlist:JWPlaylist = new JWPlaylist(overlayStreamSequence, _vastController.config.providersForShows(), _vastController.config.providersForAds());
	            	if(playlist.length > 0) {            		
						doLog("Loading the overlay linear ad track as playlist " + playlist, Debuggable.DEBUG_PLAYLIST);
		                var item:JWPlaylistItem = playlist.nextTrackAsPlaylistItem() as JWPlaylistItem;
		                if(item != null) {
		                	stopPlayback();
							_vastController.activeOverlayVideoPlaying = true;
		                	loadJWClip(item);
							_activeOverlayAdSlotKey = displayEvent.adSlot.key; 
							startPlayback();
		                }
		                else {
			                doLog("No clip available in the overlay linear playlist to load into the player", Debuggable.DEBUG_PLAYLIST);
		                }							
	            	}
					else doLog("Cannot play the linear ad - playlist is empty: " + playlist, Debuggable.DEBUG_PLAYLIST);            		
            	}
            	else {
					_vastController.activeOverlayVideoPlaying = false;
					_activeOverlayAdSlotKey = -1;					
					doLog("Cannot play the linear ad - playlist is empty: " + playlist, Debuggable.DEBUG_PLAYLIST);            		
            	}
            }
			else {
				if(displayEvent.nonLinearVideoAd.hasClickThroughURL() && _vastController.pauseOnClickThrough) {
					// it's a website click through overlay so stop the video stream
					stopPlayback();
			 	}
			}
		}
	
		public function onHideOverlay(displayEvent:OverlayAdDisplayEvent):void {
			doLog("PLUGIN NOTIFICATION: Event received to hide non-linear overlay ad (" + displayEvent.toString() + ")", Debuggable.DEBUG_DISPLAY_EVENTS);
		}
		
		public function onDisplayNonOverlay(displayEvent:OverlayAdDisplayEvent):void {
			doLog("PLUGIN NOTIFICATION: Event received to display non-linear non-overlay ad (" + displayEvent.toString() + ")", Debuggable.DEBUG_DISPLAY_EVENTS);
		}
		
		public function onHideNonOverlay(displayEvent:OverlayAdDisplayEvent):void {
			doLog("PLUGIN NOTIFICATION: Event received to hide non-linear non-overlay ad (" + displayEvent.toString() + ")", Debuggable.DEBUG_DISPLAY_EVENTS);
		}

        // Companion Ad Display Events
        
        public function onDisplayCompanionAd(companionEvent:CompanionAdDisplayEvent):void {
			doLog("PLUGIN NOTIFICATION: Event received to display companion ad (" + companionEvent.companionAd.width + "X" + companionEvent.companionAd.height + ")", Debuggable.DEBUG_DISPLAY_EVENTS);
        }

		public function onHideCompanionAd(companionEvent:CompanionAdDisplayEvent):void {
            doLog("PLUGIN NOTIFICATION: Request received to hide companion ad (" + companionEvent.companionAd.width + "X" + companionEvent.companionAd.height + ")", Debuggable.DEBUG_DISPLAY_EVENTS);
		}

        // VAST tracking actions

        private function onSeekEvent(evt:ControllerEvent):void {
        	if(_vastController != null) {
				if(_vastController.isActiveOverlayVideoPlaying()) {
        			_vastController.onPlayerSeek(_activeOverlayAdSlotKey, true);
        		}
        		else _vastController.onPlayerSeek(getActiveStreamIndex());
        	}
        }
        
		private function onMuteEvent(evt:ControllerEvent):void {
        	if(_vastController != null) {
				var vpaidAd:IVPAID 
				if(evt.data.state) {
	        		if(_vastController.isVPAIDAdPlaying()) {
	        			vpaidAd = _vastController.getActiveVPAIDAd();
	        			if(vpaidAd != null) {
	        				vpaidAd.adVolume = 0;
	        			}
	        		}
	        		else {
			        	if(_vastController != null) {
							if(_vastController.isActiveOverlayVideoPlaying()) {
			        			_vastController.onPlayerMute(_activeOverlayAdSlotKey, true);
			        		}
			        		else _vastController.onPlayerMute(getActiveStreamIndex());	        	
			        	}
			        }
	        	}
				else {
	        		if(_vastController.isVPAIDAdPlaying()) {
	        			vpaidAd = _vastController.getActiveVPAIDAd();
	        			if(vpaidAd != null) {
	        				vpaidAd.adVolume = _view.config["volume"];
	        			}
	        		}
	        		else {
			        	if(_vastController != null) {
							if(_vastController.isActiveOverlayVideoPlaying()) {
			        			_vastController.onPlayerUnmute(_activeOverlayAdSlotKey, true);
			        		}
			        		else _vastController.onPlayerUnmute(getActiveStreamIndex());	        	
			        	}
			        }
	        	}
			}
		}

		private function onUserStopEvent(evt:ViewEvent):void {
			if(!_forcedStop) {
		       	if(_vastController != null) {
					if(_vastController.isActiveOverlayVideoPlaying()) {
		       			_vastController.onPlayerStop(_activeOverlayAdSlotKey, true);
		       		}
		       		else _vastController.onPlayerStop(getActiveStreamIndex());
		       	}			
			}
			_forcedStop = false;
		}

		private function onStartupPlayEventWithVPAIDLinear(evt:ViewEvent):void {
			_view.removeViewListener(ViewEvent.PLAY, onStartupPlayEventWithVPAIDLinear);
			if(_pendingVPAIDPlaylistItem != null) {
				stopPlayback();
				_vastController.playVPAIDAd(AdSlot(_pendingVPAIDPlaylistItem.stream), _view.config["mute"]); 			
				_pendingVPAIDPlaylistItem = null;		
				_justStarted = false;			
			}
		}

		private function onPauseResumeEvent(evt:ControllerEvent):void {
			if(evt.data.state) {
				// we are playing again
		       	if(_vastController != null) {
	 				if(_vastController.isActiveOverlayVideoPlaying()) {
						_vastController.onPlayerResume(_activeOverlayAdSlotKey, true);
		       		}
		       		else _vastController.onPlayerResume(getActiveStreamIndex());
		       	}
			}
			else {
				// we are pausing
		       	if(_vastController != null) {
					if(_vastController.isActiveOverlayVideoPlaying()) {
		       			_vastController.onPlayerPause(_activeOverlayAdSlotKey, true);
		       		}
   					else _vastController.onPlayerPause(getActiveStreamIndex());
		       	}
			}
		}

		private function onVolumeEvent(evt:ControllerEvent):void {
        	if(_vastController != null) {
				var vpaidAd:IVPAID 
        		if(_vastController.isVPAIDAdPlaying()) {
        			vpaidAd = _vastController.getActiveVPAIDAd();
        			if(vpaidAd != null) {
        				if(_view.config["volume"] == 0) {
	        				vpaidAd.adVolume = 0;    				        					
        				}
        				else {
	        				vpaidAd.adVolume = (_view.config["volume"] / 100);    				
        				}
        			}
        		}
        		else {
					if(evt.data.percentage == 0) {
						if(_vastController.isActiveOverlayVideoPlaying()) {
		    	   			_vastController.onPlayerMute(_activeOverlayAdSlotKey, true);
		       			}
						else _vastController.onPlayerMute(getActiveStreamIndex());
					}
        		}
		    }
		}

		private function onResizeEvent(evt:ControllerEvent):void {
			// if we haven't already stored the original dimensions, do so now
			if(_originalWidth < 0) {
				_originalWidth = evt.data.width; 
			}
			if(_originalHeight < 0) {
				_originalHeight =  evt.data.height; 
			}
			if(_vastController != null) {
				_vastController.resizeOverlays(
		            	new DisplayProperties(
		            			this, 
		            			evt.data.width, 
		            			((evt.data.fullscreen) ? evt.data.height : _originalHeight),
		            			getDisplayMode(),
		            			_vastController.getActiveDisplaySpecification(!activeStreamIsLinearAd()),
		            			controlBarVisibleAtBottom(),
		            			_view.config["controlbar.margin"],
		            			getControlBarYPosition()
		            	)					
				);					
			}
			doLog("*** current - w:" + evt.data.width + " h:" + evt.data.height + "  original - w:" + _originalWidth + " h:" + _originalHeight, Debuggable.DEBUG_DISPLAY_EVENTS);
		}

		// Playlist specific load event handling
		
		private function onLoadEvent(evt:ViewEvent):void {
			if(evt.data != null) {
				if(evt.data.object != undefined) {
					if(evt.data.object["ova.reload"]) {
						// ok, a manually triggered reload has been fired in via sendEvent("LOAD", { ..., "ova.reload":true });
						// so reload the VAST controller taking the newly loaded clip
						doLog("Reloading the VAST Controller based on a newly loaded playlist...", Debuggable.DEBUG_ALWAYS);
						loadExistingPlaylist(_rawConfig);
						_vastController.initialise(_rawConfig, false, null, getNewEmptyConfigWithDefaultAnalytics());
						_vastController.load();
						doLog("Reloading complete", Debuggable.DEBUG_ALWAYS);
					}
				}
			}
		}
		
		private function playlistSelectionHandler(evt:ControllerEvent):void {
			_activeStreamIndex = evt.data.index;
			
			_vastController.hideAllOverlays();
			_vastController.closeActiveOverlaysAndCompanions();
			_vastController.disableVisualLinearAdClickThroughCue();
			_vastController.closeActiveAdNotice();
			
			if(!_vastController.isActiveOverlayVideoPlaying()) {
       			_vastController.resetAllTrackingPointsAssociatedWithStream(_activeStreamIndex);
			}
            doLog("Active playlist stream index changed to " + _activeStreamIndex, Debuggable.DEBUG_PLAYLIST);
		}

		private function resumeMainPlaylistPlayback():void {
			doLog("Restoring the last active main playlist clip	- seeking forward to time " + _lastTimeTick, Debuggable.DEBUG_PLAYLIST);
			var item:JWPlaylistItem = _playlist.currentTrackAsPlaylistItem(_lastTimeTick, true) as JWPlaylistItem;
	        if(item != null) {
	            doLog("Reloading main playlist track at " + _lastTimeTick + " which was interrupted by an overlay linear video ad " + item.toString(), Debuggable.DEBUG_PLAYLIST);
				_vastController.activeOverlayVideoPlaying = false;
				_resumingMainStreamPlayback = true;
				_activeOverlayAdSlotKey = -1;
				loadJWClip(item);
				startPlayback();
	        }
	        else doLog("Oops, no main playlist stream in the playlist to load", Debuggable.DEBUG_FATAL);
		}
		
		private function startPlayback():void {
           	_view.sendEvent(ViewEvent.PLAY, true);
           	_playerPaused = false;			
		}
		
		public function stopPlayback():void {
			_forcedStop = true;
           	_view.sendEvent(ViewEvent.PLAY, false);						
		}

		protected function playerPaused():Boolean {
			return _playerPaused;
		}
		
		protected function pausePlayback():void {
			_playerPaused = true;
           	_view.sendEvent(ViewEvent.PLAY, false);						
		}
		
		protected function resumePlayback():void {
			_playerPaused = false;
           	_view.sendEvent(ViewEvent.PLAY, true);						
		}
				
		private function streamStateHandler(evt:ModelEvent, forcePlay:Boolean=false, closeActiveVPAIDAds:Boolean=true):void {
			doLog("Stream state change - " + ((evt != null) ? evt.data.newstate : "no event and player state provided"), Debuggable.DEBUG_PLAYLIST);
			if(!_vastController.isActiveOverlayVideoPlaying()) {
			    if(!_vastController.allowPlaylistControl) {
					// We are handling a state change on the main playlist
					switch((evt != null) ? evt.data.newstate : "COMPLETED") {
						case "COMPLETED":
			                var item:JWPlaylistItem = _playlist.nextTrackAsPlaylistItem() as JWPlaylistItem;
			                if(item != null) {
			                	loadJWClip(item, forcePlay, closeActiveVPAIDAds);
			                	startPlayback();
			                }
		                    else {
		                        doLog("Rewinding and reloading the entire playlist", Debuggable.DEBUG_PLAYLIST);
		                        _view.config['autostart'] = false;
		                    	_playlist.rewind();
		                    	_justStarted = true;
			                	loadJWClip(_playlist.nextTrackAsPlaylistItem() as JWPlaylistItem, forcePlay, closeActiveVPAIDAds);
		                    }
							break;
					}						
			    }
			}
			else {
				// We are handling the state change of an overlay linear video ad
				if(evt != null) {
					switch(evt.data.newstate) {
						case "COMPLETED":
							doLog("Overlay linear video ad complete - resuming normal stream", Debuggable.DEBUG_PLAYLIST);
							resumeMainPlaylistPlayback();
							break;				
					}					
				}
			}
		}
		
		// DEBUG METHODS
		
		protected static function doLog(data:String, level:int=1):void {
			Debuggable.getInstance().doLog(data, level);
		}
		
		protected static function doTrace(o:Object, level:int=1):void {
			Debuggable.getInstance().doTrace(o, level);
		}
	}
}