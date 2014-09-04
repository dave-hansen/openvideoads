/*
 *    Copyright (c) 2013 LongTail AdSolutions, Inc
 *
 *    This file is part of the OVA for Flowplayer plugin.
 *
 *    The OVA for Flowplayer plugin is commercial software: you can redistribute it
 *    and/or modify it under the terms of the OVA Commercial License.
 *
 *    You should have received a copy of the OVA Commercial License along with
 *    the source code.  If not, see <http://www.openvideoads.org/licenses>.
 */
package org.openvideoads.plugin.flowplayer.streamer {
	import com.adobe.serialization.json.JSON;
	
	import flash.display.DisplayObject;
	import flash.events.TimerEvent;
	import flash.external.ExternalInterface;
	import flash.system.Security;
	import flash.utils.Timer;
	import flash.utils.Dictionary;
	
	import org.flowplayer.model.Clip;
	import org.flowplayer.model.ClipEvent;
	import org.flowplayer.model.ClipType;
	import org.flowplayer.model.Cuepoint;
	import org.flowplayer.model.DisplayPluginModel;
	import org.flowplayer.model.DisplayPluginModelImpl;
	import org.flowplayer.model.MediaSize;
	import org.flowplayer.model.PlayerEvent;
	import org.flowplayer.model.Plugin;
	import org.flowplayer.model.PluginEvent;
	import org.flowplayer.model.PluginModel;
	import org.flowplayer.model.State;
	import org.flowplayer.util.PropertyBinder;
	import org.flowplayer.view.AbstractSprite;
	import org.flowplayer.view.Flowplayer;
	import org.openvideoads.base.Debuggable;
	import org.openvideoads.plugin.flowplayer.streamer.clip.HoldingClip;
	import org.openvideoads.plugin.flowplayer.streamer.clip.PlaylistConstructor;
	import org.openvideoads.plugin.flowplayer.streamer.clip.ScheduledClip;
	import org.openvideoads.plugin.flowplayer.streamer.config.StaticPlayerConfig;
	import org.openvideoads.util.ControlsSpecification;
	import org.openvideoads.util.DisplayProperties;
	import org.openvideoads.util.StringUtils;
	import org.openvideoads.util.Timestamp;
	import org.openvideoads.vast.VASTController;
	import org.openvideoads.vast.analytics.AnalyticsProcessor;
	import org.openvideoads.vast.config.Config;
	import org.openvideoads.vast.config.ConfigLoadListener;
	import org.openvideoads.vast.config.groupings.ShowsConfigGroup;
	import org.openvideoads.vast.config.groupings.VPAIDConfig;
	import org.openvideoads.vast.config.groupings.analytics.AnalyticsConfigGroup;
	import org.openvideoads.vast.config.groupings.analytics.google.GoogleAnalyticsConfigGroup;
	import org.openvideoads.vast.events.AdNoticeDisplayEvent;
	import org.openvideoads.vast.events.AdSlotLoadEvent;
	import org.openvideoads.vast.events.AdTagEvent;
	import org.openvideoads.vast.events.CompanionAdDisplayEvent;
	import org.openvideoads.vast.events.LinearAdDisplayEvent;
	import org.openvideoads.vast.events.NonLinearSchedulingEvent;
	import org.openvideoads.vast.events.OverlayAdDisplayEvent;
	import org.openvideoads.vast.events.SeekerBarEvent;
	import org.openvideoads.vast.events.StreamSchedulingEvent;
	import org.openvideoads.vast.events.TrackingPointEvent;
	import org.openvideoads.vast.events.VPAIDAdDisplayEvent;
	import org.openvideoads.vast.playlist.Playlist;
	import org.openvideoads.vast.schedule.Stream;
	import org.openvideoads.vast.schedule.StreamConfig;
	import org.openvideoads.vast.schedule.ads.AdSlot;
	import org.openvideoads.vast.server.events.TemplateEvent;
	import org.openvideoads.vast.tracking.TimeEvent;
	import org.openvideoads.vast.tracking.TrackingPoint;
	import org.openvideoads.vast.tracking.TrackingTable;
	import org.openvideoads.vpaid.IVPAID;
    	
	/**
	 * @author Paul Schulz
	 */
	public class OpenAdStreamer extends AbstractSprite implements Plugin, ConfigLoadListener {
		protected var _player:Flowplayer;
		protected var _model:PluginModel;
       	protected var _vastController:VASTController;
		protected var _wasZeroVolume:Boolean = false;
		protected var _activeStreamIndex:int = -1;
        protected var _playlist:Playlist;
        protected var _clipList:Array = new Array();
        protected var _activeShowClip:Clip = null;
        protected var _prependedClipCount:int = 0;
        protected var _associatedPrerollClipIndex:int = -1;
		protected var _delayedInitialisation:Boolean = false;
		protected var _config:Config;
		protected var _defaultControlbarVisibilityState:Boolean = true;
		protected var _loadEventHasBeenDispatched:Boolean = false;
		protected var _removeFirstImageClipBeforeLoading:Boolean = false;
		protected var _playingVPAIDLinear:Boolean = false;
		protected var _autoHidingControlBar:Boolean = false;
		protected var _controlBarVisible:Boolean = true;
        protected var _originalPlaylistClips:Array = null;
		protected var _playerControlEventHandlersSetup:Boolean = false;
		protected var _playerPlayOnceEventHandlersSetup:Boolean = false;
		protected var _instreamMidRollScheduled:Boolean = true;
		protected var _forcedAdLoadOnInitialisation:Boolean = false;
		protected var _lastOnBeforeBeginEvent:Object = null;
		protected var _timeBeforeSeek:Number = -1;
		protected var _duplicateBeforeBeginEventCount:int = 0;
		protected var _badMuteEventFired:Boolean = false;
		protected var _playerShouldBeMuted:Boolean = false;
		protected var _forceUnmuteOfPlayer:Boolean = false;
		protected var _forceMuteOfPlayer:Boolean = false;
		protected var _streamBeforeBegin:Boolean = false;
		protected var _playbackStarted:Boolean = false;	
		protected var _timedAdSlot:AdSlot = null;
		
        protected static const DEFAULT_CONTROLBAR_HEIGHT:int = 29;   
        
		protected static const OVA_FP_DEFAULT_GA_ACCOUNT_ID:String = "UA-4011032-6";
		protected static const CONTROLS_PLUGIN_NAME:String = "controls";
		
        public static const OVA_VERSION:String = "v1.3.0 RC1 (Build 37)";
        
        protected static var STREAMING_PROVIDERS:Object = {
            rtmp: "flowplayer.rtmp-3.1.2.swf"
        };

		public function OpenAdStreamer() {
	    	Security.allowDomain("*");
		}

		public function onConfig(model:PluginModel):void {
			_model = model;
			if(_model.config != null) {
				if(_model.config.debug == undefined) {
					_model.config.debug = { "levels":"fatal,config,vast_template" };
				}
				if(_model.config.vast != undefined) {
					// we have a "vast" injection tag
					_model.config.ads = {
						"companions": {
							"restore": false,
							"regions": [
							    {
							    	"id": "companion-250x300",
							    	"width": 300,
							    	"height": 250
							    }
							]
						},
						"schedule": [
						    {
						    	"position": "pre-roll",
						    	"server": {
						    		"type": "inject",
						    		"tag": _model.config.vast
						    	}
						    }
						]
					}
				}
				if(_model.config.hasOwnProperty("tag") && (_model.config.hasOwnProperty("ads") == false)) {
					// expand out the tag config to a fuller version that includes the default companion setup
					_model.config.ads = {
						"companions": {
							"restore": false,
							"regions": [
							    {
							    	"id": "companion-250x300",
							    	"width": 300,
							    	"height": 250
							    }
							]
						},
						"schedule": [
						    {
						    	"position": "pre-roll",
						    	"tag": _model.config.tag
						    }
						]
					};
					_model.config.tag = null;
				}
				Debuggable.getInstance().configure(_model.config.debug);
				CONFIG::debugging { 
					doLog("Initialising OVA for Flowplayer - " + OVA_VERSION + " [Debug Version]", Debuggable.DEBUG_CONFIG);
					doTrace(_model.config, Debuggable.DEBUG_ALL);			
				}
				CONFIG::release {
					if(Debuggable.getInstance().printing()) {
						try {
							ExternalInterface.call("console.log", "Initialising OVA for Flowplayer - " + OVA_VERSION + " [Release Version]");					
						}
						catch(e:Error) {}
					}
				} 				
			}
			else {
				Debuggable.getInstance().configure({ "levels":"fatal,config,vast_template" });			
				CONFIG::debugging { 
					doLog("Initialising OVA for Flowplayer - " + OVA_VERSION + " [Debug Version]", Debuggable.DEBUG_CONFIG);
					doLog("No OVA configuration data has been provided", Debuggable.DEBUG_CONFIG);
				}
				CONFIG::release { 
					try {
						ExternalInterface.call("console.log", "Initialising OVA for Flowplayer - " + OVA_VERSION + " [Release Version]");
					}
					catch(e:Error) {}
				}
			}
		}

		public function getDefaultConfig():Object {
			return { top: 0, left: 0, width: "100%", height: "100%" };
		}

		protected function setDefaultPlayerConfigGroup():void {
			var controlsHeight:Number = getPlayerReportedControlBarHeight();
			_vastController.setDefaultPlayerConfigGroup(
				{
					width: _player.screen.getDisplayObject().width, 
					height: _player.screen.getDisplayObject().height, 
					controls: { 
						height: controlsHeight
					},
                    margins: {
                        normal: {
                           withControls: controlsHeight,
                           withoutControls: 0
                        },
                        fullscreen: {
                           withControls: controlsHeight,
                           withoutControls: 0
                        }
                    },
					modes: {
                       linear: {
                         controls: {
                             stream: {
	                             visible: true,
	                             manage: true,
	                             enablePlay: true,
	                             enablePause: true,
	                             enablePlaylist: false,
	                             enableTime: false,
	                             enableFullscreen: true,
	                             enableMute: true,
	                             enableVolume: true
                             },
                             vpaid: {
                             	visible: false,
                             	manage: true,
                             	enabled: false
                             }
                         }
                      },
                      nonLinear: {
 	                     margins: {
	                        fullscreen: {
	                           withControls: controlsHeight,
	                           withoutControls: 0
	                        }
	                     }
                      }
				   }
				}
			);
			_vastController.config.playerConfig = _vastController.getDefaultPlayerConfig();
			if(_model.config.hasOwnProperty("player")) {
				// now update the default to include any config customisations
				_vastController.config.playerConfig.initialise(_model.config.player); 
			}		
		}
						
		public function onLoad(player:Flowplayer):void {
			_player = player;
			_playerShouldBeMuted = _player.muted;
			saveOriginalPlaylist();
            initialiseVASTFramework();
    	    registerControlbarListeners();
		}
				
		protected function registerControlbarListeners():void {
			var model:DisplayPluginModel = _player.pluginRegistry.getPlugin(CONTROLS_PLUGIN_NAME) as DisplayPluginModel;
			if(model != null) {
				model.onPluginEvent(function controlBarShown(event:PluginEvent):void {
					if(event.id == "onShowed") {
						_controlBarVisible = true;
						onResizeWithControls();
					}
					else if(event.id == "onHidden") {
						_controlBarVisible = false;
						resizeWithHiddenControls();					
					}
				});
			}
		}	

		protected function getPlayerWidth():Number {
			return width;
		}
		
		protected function getPlayerHeight():Number {
			return height;
		}

		protected function getDisplayMode():String {
			if(_player != null) {
				if(_player.isFullscreen()) {
					return DisplayProperties.DISPLAY_FULLSCREEN;
				}			
			}
			return DisplayProperties.DISPLAY_NORMAL;
		}

        protected function initialiseRegionController():void {
			// This workaround been put in to capture the case where the Flowplayer control bar 
			// isn't reporting the correct sizing until the first resize() event fires
			setDefaultPlayerConfigGroup();
            _vastController.enableRegionDisplay(
            	new DisplayProperties(
            			this, 
            			getPlayerWidth(), 
            			getPlayerHeight(),
            			getDisplayMode(),
            			_vastController.getActiveDisplaySpecification(activeStreamIsShowStream()),
            			true,
            			getControlBarHeight(),
            			getControlBarYPosition()
            	)
            );
        }			

		protected function resizeWithHiddenControls():void {
			if(_vastController != null) {
				if(activeStreamIsLinearAd()) {
					if(_vastController.config.adsConfig.vpaidConfig.callResizeOnControlbarShowHide == false) {
						doLog("Aborting resize of VPAID region when controlbar disappears - config has turned it off", Debuggable.DEBUG_CONFIG);				
						return;
					}
				}
				if(_vastController.overlayController == null) { 
					initialiseRegionController();
				}
				else {
					_vastController.resizeOverlays(
		            	new DisplayProperties(
		            			this, 
		            			getPlayerWidth(), 
		            			getPlayerHeight(),
		            			getDisplayMode(),
		            			_vastController.getActiveDisplaySpecification(activeStreamIsShowStream()),
		            			false,
		            			0,
		            			getControlBarYPosition()
		            	)
					);									
				}
			}
		}

		protected function onResizeWithControls():void {
			if(_vastController != null) {
				if(activeStreamIsLinearAd()) {
					if(_vastController.config.adsConfig.vpaidConfig.callResizeOnControlbarShowHide == false) {
						doLog("Aborting resize of VPAID region when controlbar appears - config has turned it off", Debuggable.DEBUG_CONFIG);				
						return;
					}
				}
				if(_vastController.overlayController == null) {
					initialiseRegionController();
				}
				else {
					_vastController.resizeOverlays(
		            	new DisplayProperties(
		            			this, 
		            			getPlayerWidth(), 
		            			getPlayerHeight(),
		            			getDisplayMode(),
		            			_vastController.getActiveDisplaySpecification(activeStreamIsShowStream()),
		            			true,
		            			getControlBarHeight(),
		            			getControlBarYPosition()
		            	)				
					);
				}
			}
		}
		
		override protected function onResize():void {
			super.onResize();
			if(_vastController != null) {
				if(_vastController.overlayController == null) {
					initialiseRegionController();
				}
				else {
					_vastController.resizeOverlays(
		            	new DisplayProperties(
		            			this, 
		            			getPlayerWidth(), 
		            			getPlayerHeight(),
		            			getDisplayMode(),
		            			_vastController.getActiveDisplaySpecification(activeStreamIsShowStream()),
		            			true,
		            			getControlBarHeight(),
		            			getControlBarYPosition()
		            	)				
					);
				}
			}
		}
		
		protected function isBitRatedClip(clip:Clip):Boolean {
			if(clip != null) {
				if(clip.customProperties != null) {
					return (clip.customProperties["bitrates"] != null);
				}				
			}
			return false;
		}

		protected function loadExistingPlaylist(config:Config):void {
			// preserve the playlist if one has been specified and set that as the "shows" config before initialising
			// the VASTController - there is always 1 clip in the flowplayer playlist
			// even if no clips have been specified in the config - if there isn't a URL in the first clip, then
			// it's empty in the config - this is a bit of a hack - is there a better way to determine this?

			if(_player.playlist.clips.length > 0) {
				if(_player.playlist.clips[0].url != null || isBitRatedClip(_player.playlist.clips[0])) {
					CONFIG::debugging { 
						if(config.outputingDebug()) {
							doLog("Shows configuration include items from the Flowplayer playlist " + _player.playlist.toString(), Debuggable.DEBUG_CONFIG); 
						}
					}
					if(config.hasStreams()) {
						config.prependStreams(convertFlowplayerPlaylistToShowStreamConfig());
					}
					else {
						config.streams = convertFlowplayerPlaylistToShowStreamConfig();
					}
					CONFIG::debugging { 
						if(config.outputingDebug())  {
							if(config.outputingDebug()) {
								doLog("Total show configuration is: " + config.streams.length + " (length)", Debuggable.DEBUG_CONFIG);
							}	
							for(var i:int=0; i < config.streams.length; i++) {
								if(config.outputingDebug()) {
									doLog("- stream " + i + ": " + ((config.streams[i].file == null) ? "To be determined - e.g. bwcheck etc." : config.streams[i].file), Debuggable.DEBUG_CONFIG);
								}
							}					
						}
					}					
				}
				else {
					CONFIG::debugging { 
						if(config.outputingDebug()) {
							doLog("No Flowplayer playlist defined - first clip does not have a URL or 'bitrates' specified", Debuggable.DEBUG_CONFIG); 
						}
					}
				}	
			}
			else {
				CONFIG::debugging { 
					if(config.outputingDebug()) {
						doLog("No Flowplayer playlist defined - relying on internal show stream configuration", Debuggable.DEBUG_CONFIG);	
					}
				}
			}					
		}

		protected function initialiseControllersAndHandlers():void {
			initialiseVASTController();
	        registerPlayOnceHandlers();
		}
		
		protected function getNewConfigWithDefaults():Config {
			var newConfig:Config = new Config();
            newConfig.analytics.update(
            		[
            			{ 
            				type: AnalyticsConfigGroup.GOOGLE_ANALYTICS,
            				element: GoogleAnalyticsConfigGroup.OVA,
            				displayObject: _player.screen.getDisplayObject(),
	            			analyticsId: OVA_FP_DEFAULT_GA_ACCOUNT_ID,
							impressions: {
								enable: true,
								linear: "/ova/impression/flowplayer?ova_format=linear",
								nonLinear: "/ova/impression/flowplayer?ova_format=non-linear",
								companion: "/ova/impression/flowplayer?ova_format=companion"
							},
							adCalls: {
								enable: false,
								fired: "/ova/ad-call/flowplayer?ova_action=fired",
								complete: "/ova/ad-call/flowplayer?ova_action=complete",
								failover: "/ova/ad-call/flowplayer?ova_action=failover",
								error: "/ova/ad-call/flowplayer?ova_action=error",
								timeout: "/ova/ad-call/flowplayer?ova_action=timeout",
								deferred: "/ova/ad-call/flowplayer?ova_action=deferred"
							},
							template: {
								enable: false,
								loaded: "/ova/template/flowplayer?ova_action=loaded",
								error: "/ova/template/flowplayer?ova_action=error",
								timeout: "/ova/template/flowplayer?ova_action=timeout",
								deferred: "/ova/template/flowplayer?ova_action=deferred"
							},
							adSlot: {
								enable: false,
								loaded: "/ova/ad-slot/flowplayer?ova_action=loaded",
								error: "/ova/ad-slot/flowplayer?ova_action=error",
								timeout: "/ova/ad-slot/flowplayer?ova_action=timeout",
								deferred: "/ova/ad-slot/flowplayer?ova_action=deferred"
							},
							progress: {
								enable: false,
								start: "/ova/progress/flowplayer?ova_action=start",
								stop: "/ova/progress/flowplayer?ova_action=stop",
								firstQuartile: "/ova/progress/flowplayer?ova_action=firstQuartile",
								midpoint: "/ova/progress/flowplayer?ova_action=midpoint",
								thirdQuartile: "/ova/progress/flowplayer?ova_action=thirdQuartile",
								complete: "/ova/progress/flowplayer?ova_action=complete",
								pause: "/ova/progress/flowplayer?ova_action=pause",
								resume: "/ova/progress/flowplayer?ova_action=resume",
								fullscreen: "/ova/progress/flowplayer?ova_action=fullscreen",
								mute: "/ova/progress/flowplayer?ova_action=mute",
								unmute: "/ova/progress/flowplayer?ova_action=unmute",
								expand: "/ova/progress/flowplayer?ova_action=expand",
								collapse: "/ova/progress/flowplayer?ova_action=collapse",
								userAcceptInvitation: "/ova/progress/flowplayer?ova_action=userAcceptInvitation",
								close: "/ova/progress/flowplayer?ova_action=close"
							},
							clicks: {
								enable: false,
								linear: "/ova/clicks/flowplayer?ova_action=linear",
								nonLinear: "/ova/clicks/flowplayer?ova_action=nonLinear",
								vpaid: "/ova/clicks/flowplayer?ova_action=vpaid"
							},
							vpaid: {
								enable: false,
								loaded: "/ova/vpaid/flowplayer?ova_action=loaded",
								started: "/ova/vpaid/flowplayer?ova_action=started",
								complete: "/ova/vpaid/flowplayer?ova_action=complete",
								stopped: "/ova/vpaid/flowplayer?ova_action=stopped",
								linearChange: "/ova/vpaid/flowplayer?ova_action=linearChange",
								expandedChange: "/ova/vpaid/flowplayer?ova_action=expandedChange",
								remainingTimeChange: "/ova/vpaid/flowplayer?ova_action=remainingTimeChange",
								volumeChange: "/ova/vpaid/flowplayer?ova_action=volumeChange",
								videoStart: "/ova/vpaid/flowplayer?ova_action=videoStart",
								videoFirstQuartile: "/ova/vpaid/flowplayer?ova_action=videoFirstQuartile",
								videoMidpoint: "/ova/vpaid/flowplayer?ova_action=videoMidpoint",
								videoThirdQuartile: "/ova/vpaid/flowplayer?ova_action=videoThirdQuartile",
								videoComplete: "/ova/vpaid/flowplayer?ova_action=videoComplete",
								userAcceptInvitation: "/ova/vpaid/flowplayer?ova_action=userAcceptInvitation",
								userClose: "/ova/vpaid/flowplayer?ova_action=userClose",
								paused: "/ova/vpaid/flowplayer?ova_action=paused",
								playing: "/ova/vpaid/flowplayer?ova_action=playing",
								error: "/ova/vpaid/flowplayer?ova_action=error",
								skipped: "/ova/vpaid/jw5?ova_action=skipped",
								skippableStateChange: "/ova/vpaid/jw5?ova_action=skippableStateChange",
								sizeChange: "/ova/vpaid/jw5?ova_action=sizeChange",
								durationChange: "/ova/vpaid/jw5?ova_action=durationChange",
								adInteraction: "/ova/vpaid/jw5?ova_action=adInteractionr"
							}	            			
            			}
            		]
            );
			return newConfig;						
		}

		protected function initialiseVASTFramework(newConfig:Object=null):void {
			_instreamMidRollScheduled = false;
			_lastOnBeforeBeginEvent = null;
			
			// Initialise the VAST Controller
			_vastController = new VASTController();
			_vastController.startStreamSafetyMargin = 500;   // needed because cuepoints at 0 for FLVs don't fire	
			_vastController.endStreamSafetyMargin = 500;     // minimum needed because timings too close to the end of the stream don't seem to work
			_vastController.playerVolume = (_player.muted) ? 0 : getPlayerVolume(); 			
			_vastController.additionMetricsParams = "ova_plugin_version=" + OVA_VERSION + "&ova_player_version=" + _player.version;
			
			// setup some default ad properties before processing the config into it's final format
			var mimeTypeDebugMessage:String = null;
			var configInUse:Object = (newConfig != null) ? newConfig : _model.config;
			if(configInUse != null) {
				if(configInUse.ads != undefined) {
					// set the default mime types allowed - can be overridden in config with "acceptedLinearAdMimeTypes" and "filterOnLinearAdMimeTypes"
					if(configInUse.ads.filterOnLinearAdMimeTypes == undefined) {
						mimeTypeDebugMessage = "Setting accepted Linear Ad mime types to default list - swf, mp4 and flv";
						configInUse.ads.acceptedLinearAdMimeTypes = [ "video/flv", "video/mp4", "video/x-flv", "video/x-mp4", "application/x-shockwave-flash", "flv", "mp4", "swf" ];
						configInUse.ads.filterOnLinearAdMimeTypes = true;		
					}
					else mimeTypeDebugMessage = "Setting accepted Linear Ad mime types based on config - enabled = " + configInUse.ads.filterOnLinearAdMimeTypes;
				}
				else {
					mimeTypeDebugMessage = "Setting accepted Linear Ad mime types to defaults - swf, mp4 and flv";
					configInUse.ads = new Object();
					configInUse.ads.acceptedLinearAdMimeTypes = [ "video/flv", "video/mp4", "video/x-flv", "video/x-mp4", "application/x-shockwave-flash", "flv", "mp4", "swf" ];
					configInUse.ads.filterOnLinearAdMimeTypes = true;					
				}			
				
				// load up the Open Ad Stream JSON config
				_config = (new PropertyBinder(getNewConfigWithDefaults(), null).copyProperties(_vastController.preProcessDepreciatedConfig(configInUse)) as Config);
			}
			else _config = getNewConfigWithDefaults(); 
			_config.signalInitialisationComplete();

			CONFIG::debugging { 
				if(_config.outputingDebug()) {
					if(mimeTypeDebugMessage != null) doLog(mimeTypeDebugMessage, Debuggable.DEBUG_CONFIG);
					doLog("OVA Plugin zIndex is " + DisplayPluginModelImpl(_model).zIndex, Debuggable.DEBUG_CONFIG); 
				}
			}
	
            _clipList = new Array()
			loadExistingPlaylist(_config);

			if(_config.delayAdRequestUntilPlay && !_config.autoPlay) {
				setupPlayerToDeferInitialisation();
			}
			else initialiseControllersAndHandlers();
		}

		protected function informPlayerOVAPluginLoaded():void {
			CONFIG::debugging { doLog("Informing Flowplayer that OVA load is complete", Debuggable.DEBUG_CONFIG); }
            _loadEventHasBeenDispatched = true;
            _model.dispatchOnLoad();

            if(activeClipIsVPAIDLinearAd() && _vastController.autoPlay()) {
            	// This is a bit of a hack to force autoPlay to work for VPAID pre-rolls
            	CONFIG::debugging { doLog("Forcing auto-play on the VPAID pre-roll", Debuggable.DEBUG_CONFIG); }
	            startPlayback();
            }
		}
				
		protected function setupPlayerToDeferInitialisation():void {
			CONFIG::debugging { doLog("Holding on initialising the vastController until the Play button is pressed - loading holding clip/image", Debuggable.DEBUG_CONFIG); }
			_player.playlist.onBeforeBegin(onPlayEventWithDeferredInitialisation);
			_delayedInitialisation = true;
			replacePlaylistWithHoldingClip();
			informPlayerOVAPluginLoaded();
		}

		protected function onPlayEventWithDeferredInitialisation(playerEvent:ClipEvent):void {
			if(_delayedInitialisation) {
				if(_player.playlist.clips.length > 0) {
					if(!clipIsSplashImage(_player.playlist.clips[_player.playlist.currentIndex])) {
						CONFIG::debugging { doLog("Triggering deferred initialisation of the VASTController...", Debuggable.DEBUG_CONFIG); }
						_delayedInitialisation = false;
						initialiseControllersAndHandlers();
					}
				}
			}
		}
		
		protected function initialiseVASTController():void {
			_vastController.disableRegionDisplay();
			_vastController.initialise(_config, false, this);
		}

		public function isOVAConfigLoading():Boolean { return false; }		

		public function onOVAConfigLoaded():void {	
			if(_vastController.config.adsConfig.vpaidConfig.hasLinearRegionSpecified() == false) {
				if(controlBarIsHidden() == false) {
					if(_vastController.config.playerConfig.shouldHideControlsOnLinearPlayback(true)) { 
						_vastController.config.adsConfig.vpaidConfig.linearRegion = VPAIDConfig.RESERVED_FULLSCREEN_BLACK_WITH_CB_HEIGHT;						
					}
					else {
						_vastController.config.adsConfig.vpaidConfig.linearRegion = VPAIDConfig.RESERVED_FULLSCREEN_TRANSPARENT_BOTTOM_MARGIN_ADJUSTED;
					}				
				}
				else _vastController.config.adsConfig.vpaidConfig.linearRegion = VPAIDConfig.RESERVED_FULLSCREEN_BLACK_WITH_CB_HEIGHT;
			}	
			if(_vastController.config.adsConfig.vpaidConfig.hasNonLinearRegionSpecified() == false) {
				_vastController.config.adsConfig.vpaidConfig.nonLinearRegion = VPAIDConfig.RESERVED_FULLSCREEN_TRANSPARENT_BOTTOM_MARGIN_ADJUSTED;
			}

			// Setup the player tracking events
			
			if(_playerControlEventHandlersSetup == false) {
				_player.onFullscreen(onFullScreen);
				_player.onFullscreenExit(onFullScreenExit);
				_player.onMute(onMuteEvent);
				_player.onUnmute(onUnmuteEvent);
				_player.onVolume(onProcessVolumeEvent);  
				_player.playlist.onPause(onPauseEvent);
				_player.playlist.onResume(onResumeEvent);
				_player.playlist.onBeforeBegin(onStreamBeforeBegin);
				_player.playlist.onFinish(onStreamFinish);
				_player.playlist.onMetaData(onMetaDataEvent);
				_player.playlist.onBeforeSeek(onBeforeSeekEvent);
				_player.playlist.onSeek(onSeekEvent);
				_player.playlist.onStart(onStart);				
				_playerControlEventHandlersSetup = true;
			
				if(getPlayerVersion() >= 3208) {
					// required by HoldingClips that need a valid URL in 3.2.8
					_player.playlist.onBegin(onStreamBegin); 
				}
			}

			recordDefaultControlbarState();

            // Setup the critical listeners for the ad tag call process
            _vastController.addEventListener(AdTagEvent.CALL_STARTED, onAdCallStarted);
            _vastController.addEventListener(AdTagEvent.CALL_FAILOVER, onAdCallFailover);
            _vastController.addEventListener(AdTagEvent.CALL_COMPLETE, onAdCallComplete);

            // Setup the critical listeners for the template loading process - used by the ad slot "preloaded model"
            _vastController.addEventListener(TemplateEvent.LOADED, onTemplateLoaded);
            _vastController.addEventListener(TemplateEvent.LOAD_FAILED, onTemplateLoadError);
            _vastController.addEventListener(TemplateEvent.LOAD_TIMEOUT, onTemplateLoadTimeout);
            _vastController.addEventListener(TemplateEvent.LOAD_DEFERRED, onTemplateLoadDeferred);

            // Setup the critical listeners for the ad slot loading process - used by the ad slot "on demand load model"
            _vastController.addEventListener(AdSlotLoadEvent.LOADED, onAdSlotLoaded);
            _vastController.addEventListener(AdSlotLoadEvent.LOAD_ERROR, onAdSlotLoadError);
            _vastController.addEventListener(AdSlotLoadEvent.LOAD_TIMEOUT, onAdSlotLoadTimeout);
            _vastController.addEventListener(AdSlotLoadEvent.LOAD_DEFERRED, onAdSlotLoadDeferred);

            // Setup the linear ad listeners
            _vastController.addEventListener(LinearAdDisplayEvent.STARTED, onLinearAdStarted);
            _vastController.addEventListener(LinearAdDisplayEvent.SKIPPED, onLinearAdSkipped);
            _vastController.addEventListener(LinearAdDisplayEvent.COMPLETE, onLinearAdComplete); 
            _vastController.addEventListener(LinearAdDisplayEvent.CLICK_THROUGH, onLinearAdClickThrough);           

           // Setup the companion display listeners
            _vastController.addEventListener(CompanionAdDisplayEvent.DISPLAY, onDisplayCompanionAd);
            _vastController.addEventListener(CompanionAdDisplayEvent.HIDE, onHideCompanionAd);

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
            
            // Setup the hander for tracking point set events
            _vastController.addEventListener(TrackingPointEvent.SET, onSetTrackingPoint);
            _vastController.addEventListener(TrackingPointEvent.FIRED, onTrackingPointFired);
            
            // Setup the hander for display events on the seeker bar
            _vastController.addEventListener(SeekerBarEvent.TOGGLE, onToggleSeekerBar);
            
            // Ok, let's load up the VAST data from our Ad Server - when the stream sequence is constructed, register for callbacks
            _vastController.addEventListener(StreamSchedulingEvent.SCHEDULE, onStreamSchedule);
            _vastController.addEventListener(NonLinearSchedulingEvent.SCHEDULE, onNonLinearSchedule);

            // Setup VPAID event handlers
            _vastController.addEventListener(VPAIDAdDisplayEvent.LINEAR_LOADING, onVPAIDLinearAdLoading);
            _vastController.addEventListener(VPAIDAdDisplayEvent.LINEAR_LOADED, onVPAIDLinearAdLoaded);            
            _vastController.addEventListener(VPAIDAdDisplayEvent.NON_LINEAR_LOADING, onVPAIDUnusedEvent);
            _vastController.addEventListener(VPAIDAdDisplayEvent.NON_LINEAR_LOADED, onVPAIDUnusedEvent);
            _vastController.addEventListener(VPAIDAdDisplayEvent.LINEAR_START, onVPAIDLinearAdStart); 
            _vastController.addEventListener(VPAIDAdDisplayEvent.LINEAR_COMPLETE, onVPAIDLinearAdComplete); 
            _vastController.addEventListener(VPAIDAdDisplayEvent.LINEAR_ERROR, onVPAIDLinearAdError); 
            _vastController.addEventListener(VPAIDAdDisplayEvent.AD_LOG, onVPAIDAdLog);             
            _vastController.addEventListener(VPAIDAdDisplayEvent.LINEAR_LINEAR_CHANGE, onVPAIDLinearAdLinearChange); 
            _vastController.addEventListener(VPAIDAdDisplayEvent.LINEAR_EXPANDED_CHANGE, onVPAIDLinearAdExpandedChange); 
            _vastController.addEventListener(VPAIDAdDisplayEvent.LINEAR_TIME_CHANGE, onVPAIDLinearAdTimeChange); 
            _vastController.addEventListener(VPAIDAdDisplayEvent.NON_LINEAR_START, onVPAIDNonLinearAdStart); 
            _vastController.addEventListener(VPAIDAdDisplayEvent.NON_LINEAR_COMPLETE, onVPAIDNonLinearAdComplete); 
            _vastController.addEventListener(VPAIDAdDisplayEvent.NON_LINEAR_ERROR, onVPAIDNonLinearAdError); 
            _vastController.addEventListener(VPAIDAdDisplayEvent.NON_LINEAR_LINEAR_CHANGE, onVPAIDNonLinearAdLinearChange); 
            _vastController.addEventListener(VPAIDAdDisplayEvent.NON_LINEAR_EXPANDED_CHANGE, onVPAIDNonLinearAdExpandedChange); 
            _vastController.addEventListener(VPAIDAdDisplayEvent.NON_LINEAR_TIME_CHANGE, onVPAIDNonLinearAdTimeChange); 
            _vastController.addEventListener(VPAIDAdDisplayEvent.LINEAR_IMPRESSION, onVPAIDUnusedEvent);
            _vastController.addEventListener(VPAIDAdDisplayEvent.NON_LINEAR_IMPRESSION, onVPAIDUnusedEvent);
            _vastController.addEventListener(VPAIDAdDisplayEvent.VIDEO_AD_START, onVPAIDUnusedEvent);
            _vastController.addEventListener(VPAIDAdDisplayEvent.VIDEO_AD_FIRST_QUARTILE, onVPAIDUnusedEvent);
            _vastController.addEventListener(VPAIDAdDisplayEvent.VIDEO_AD_MIDPOINT, onVPAIDUnusedEvent);
            _vastController.addEventListener(VPAIDAdDisplayEvent.VIDEO_AD_THIRD_QUARTILE, onVPAIDUnusedEvent);
            _vastController.addEventListener(VPAIDAdDisplayEvent.VIDEO_AD_COMPLETE, onVPAIDUnusedEvent);
            _vastController.addEventListener(VPAIDAdDisplayEvent.LINEAR_CLICK_THRU, onVPAIDUnusedEvent);
            _vastController.addEventListener(VPAIDAdDisplayEvent.NON_LINEAR_CLICK_THRU, onVPAIDUnusedEvent);
            _vastController.addEventListener(VPAIDAdDisplayEvent.LINEAR_USER_ACCEPT_INVITATION, onVPAIDUnusedEvent);
            _vastController.addEventListener(VPAIDAdDisplayEvent.LINEAR_USER_MINIMIZE, onVPAIDUnusedEvent);
            _vastController.addEventListener(VPAIDAdDisplayEvent.LINEAR_USER_CLOSE, onVPAIDUnusedEvent);
            _vastController.addEventListener(VPAIDAdDisplayEvent.NON_LINEAR_USER_ACCEPT_INVITATION, onVPAIDUnusedEvent);
            _vastController.addEventListener(VPAIDAdDisplayEvent.NON_LINEAR_USER_MINIMIZE, onVPAIDUnusedEvent);
            _vastController.addEventListener(VPAIDAdDisplayEvent.NON_LINEAR_USER_CLOSE, onVPAIDUnusedEvent);
            _vastController.addEventListener(VPAIDAdDisplayEvent.LINEAR_VOLUME_CHANGE, onVPAIDLinearAdVolumeChange);
            _vastController.addEventListener(VPAIDAdDisplayEvent.NON_LINEAR_VOLUME_CHANGE, onVPAIDNonLinearAdVolumeChange);
            _vastController.addEventListener(VPAIDAdDisplayEvent.SKIPPED, onVPAIDAdSkipped);
            _vastController.addEventListener(VPAIDAdDisplayEvent.SKIPPABLE_STATE_CHANGE, onVPAIDAdSkippableStateChange);
            _vastController.addEventListener(VPAIDAdDisplayEvent.SIZE_CHANGE, onVPAIDAdSizeChange);
            _vastController.addEventListener(VPAIDAdDisplayEvent.DURATION_CHANGE, onVPAIDAdDurationChange);
            _vastController.addEventListener(VPAIDAdDisplayEvent.AD_INTERACTION, onVPAIDAdInteraction);

			// Identify which ad types are capable of supporting a "Skip Ad" button by default
//			_vastController.config.ads.skipAdConfig.adTypes = [ "pre-roll", "post-roll" ];
			
			// Make sure we have a region controller active
			if(_vastController.overlayController == null) initialiseRegionController();

            // Load up the ad set
            
            _vastController.load();
            
            CONFIG::debugging { doLog("OVA initialisation complete."); }
        }
		
		/*
		 * Holding clips are used to support the Deferred Loading flag and VPAID linear ads
		 */
		 
		protected function getHoldingClipURL():String {
			if(getPlayerVersion() >= 3208) {
				return _vastController.config.adsConfig.holdingClipUrl;
			}
			else return null;
		}
		
		protected function getDefaultHoldingClipProperties(autoPlaySetting:Boolean=true):Object {
			return { 
				url: getHoldingClipURL(),
				scaling: MediaSize.forName('scale'),
//				autoPlay: true //autoPlaySetting
				autoPlay: autoPlaySetting
			};	
		}
		
		protected function replacePlaylistWithHoldingClip():void {
			if(_player.playlist.clips.length > 0) {
				if(clipIsSplashImage(_player.playlist.clips[0])) {
					loadClipsIntoPlayer(
						[ 
							new HoldingClip(_player.playlist.clips[0]),
							new HoldingClip(getDefaultHoldingClipProperties(false))
						]
					);
					_removeFirstImageClipBeforeLoading = true;
					return;
				}
			}
			loadClipsIntoPlayer([ new HoldingClip(getDefaultHoldingClipProperties(false)) ]);
		}		

		protected function loadScheduledClipList():void {
			if(_removeFirstImageClipBeforeLoading) {
				if(_clipList.length > 0) {
					CONFIG::debugging { doLog("Removing the first (image) clip from the playlist before loading (it must be a delayed start with a splash image)...", Debuggable.DEBUG_PLAYLIST); }
					_clipList.shift();
				}
				else {
					CONFIG::debugging { doLog("Not removing the first (image) clip from the playlist before loading - the scheduled playlist is empty", Debuggable.DEBUG_PLAYLIST); }
				}
			}

			if(_clipList.length > 0) {
				CONFIG::debugging { doLog("Replacing the player playlist with the ad scheduled cliplist - " + _clipList.length, Debuggable.DEBUG_PLAYLIST); }
	            loadClipsIntoPlayer(_clipList);
	  		}
	  		else {
	  			CONFIG::debugging { doLog("Not modifying the existing playlist - the scheduled playlist is empty", Debuggable.DEBUG_PLAYLIST);	}	
	  		}	
		}

		protected function restorePlaylistAfterSchedulingProcess():void {
			if(_clipList.length > 0) {
				CONFIG::debugging { doLog("Loading the scheduled clip list after the scheduling process", Debuggable.DEBUG_PLAYLIST); }
				loadScheduledClipList();
			}
			else if(_clipList.length == 0 && _originalPlaylistClips != null) {
				CONFIG::debugging { doLog("Restoring the original playlist after the scheduling process - no scheduled clip list available", Debuggable.DEBUG_PLAYLIST); }
				restoreOriginalPlaylist();
			}
			else {
				CONFIG::debugging { doLog("Leaving the current playlist untouched after the scheduling process - probably not good", Debuggable.DEBUG_PLAYLIST); }
			}
			checkAutoPlaySettings();
			actionPlayerPostTemplateLoad();			
		}
		
		protected function saveOriginalPlaylist():void {
			CONFIG::debugging { doLog("Saving the original player playlist - " + _player.playlist.length + " clips", Debuggable.DEBUG_PLAYLIST); }
			_originalPlaylistClips = new Array();
			for(var i:int=0; i < _player.playlist.clips.length; i++) {
				_originalPlaylistClips.push(_player.playlist.getClip(i));
			}
		}
		
		protected function restoreOriginalPlaylist():void {
			if(_originalPlaylistClips != null) {
				CONFIG::debugging { doLog("Restoring the original player playlist - " + _originalPlaylistClips.length, Debuggable.DEBUG_PLAYLIST); }
				loadClipsIntoPlayer(_originalPlaylistClips);
			}
			else {
				CONFIG::debugging { doLog("Cannot restore the original player playlist - it is null", Debuggable.DEBUG_PLAYLIST); }
			}
		}
		
		protected function loadClipsIntoPlayer(playlist:Array):void {
			if(playlist != null) {
				CONFIG::debugging { 
					doLog("Loading a new set of " + playlist.length + " clips into the player playlist:", Debuggable.DEBUG_PLAYLIST);
					for(var i:int = 0; i < playlist.length; i++) {
						doLog("   + " + 
					       (
				    	      (playlist[i] is HoldingClip) 
				        	     ? "(holding clip)" + ((playlist[i].autoPlay) ? " auto-play" : "") 
				            	 : (
					                  (playlist[i].url != null) ? playlist[i].url : "(no url, stream may be bitrated)"
					               ) + ((playlist[i].autoPlay) ? ", auto-play" : "") + ", duration: " + playlist[i].duration
					       ),
					       Debuggable.DEBUG_PLAYLIST
					    );
					}
				}
				if(getPlayerVersion() >= 3208 && _vastController.delayAdRequestUntilPlay()) {			
					// required to address the bug recorded in ticket 447 - if the player isn't stopped when "delayAdRequestUntilPlay:true, playback doesn't 
					// occur correctly after the ad scheduled playlist is loaded. The first clip plays for 3 seconds and then stops.
//					_player.stop();
					stopPlayback();
				}
				_player.playlist.replaceClips2(playlist);
			}
		}
		
		protected function deriveBaseUrlFromClip(clip:Clip):String {
			if(clip != null) {
				if(clip.baseUrl != null) {
					return clip.baseUrl;
				}
				if(clip.customProperties != null) {
					if(clip.customProperties.hasOwnProperty("netConnectionUrl")) {
						return clip.customProperties.netConnectionUrl;
					}
				}
			}
			return null;
		}
		
		protected function convertFlowplayerPlaylistToShowStreamConfig():Array {
			var showStreams:Array = new Array();
			for(var index:int=0; index < _player.playlist.clips.length; index++) {
				showStreams.push(
				     new StreamConfig(
				     		_player.playlist.clips[index].url,  
				     		_player.playlist.clips[index].url, 
				     		Timestamp.secondsToTimestamp(_player.playlist.clips[index].duration),
				     		false, 
				     		"any", 
				     		false, 
				     		_player.playlist.clips[index].metaData, 
				     		_player.playlist.clips[index].autoPlay, 
				     		_player.playlist.clips[index].provider,
				     		{
								"isOriginallyPlaylistClip": true,
								"originalPlaylistIndex": index,				     								     		
								"baseUrl": deriveBaseUrlFromClip(_player.playlist.clips[index]),
								"originalClip": _player.playlist.clips[index]
				     		},
			     			{
								"customProperties": _player.playlist.clips[index].customProperties,
								"accelerated": _player.playlist.clips[index].accelerated,
								"autoBuffering": _player.playlist.clips[index].autoBuffering,
								"bufferLength": _player.playlist.clips[index].bufferLength,
								"fadeInSpeed": _player.playlist.clips[index].fadeInSpeed,
								"fadeOutSpeed": _player.playlist.clips[index].fadeOutSpeed,
								"image": _player.playlist.clips[index].image,
								"linkUrl": _player.playlist.clips[index].linkUrl,
								"linkWindow": _player.playlist.clips[index].linkWindow,
								"live": _player.playlist.clips[index].live,
								"position": _player.playlist.clips[index].position,
								"scaling": _player.playlist.clips[index].scaling,
								"seekableOnBegin": _player.playlist.clips[index].seekableOnBegin,
								"baseUrl": _player.playlist.clips[index].baseUrl,
								"autoPlay": _player.playlist.clips[index].autoPlay,
								"urlResolvers": _player.playlist.clips[index].urlResolvers,
								"metaData": _player.playlist.clips[index].metaData,
								"connectionProvider": ((_player.playlist.clips[index].connectionProvider != undefined) ? _player.playlist.clips[index].connectionProvider : null)
			     			},
			     			null,
			     			Timestamp.secondsToTimestamp(_player.playlist.clips[index].start)
				     )
				); 
			}
			return showStreams;        	
		}
		
	    protected function registerPlayOnceHandlers():void {
	    	if(_playerPlayOnceEventHandlersSetup == false) {
	            // Before the clip plays, check if it has already been played and reset the repeatable tracking points
	            _player.playlist.onBegin(
            		function(clipevent:ClipEvent):void {
	                        CONFIG::debugging { doLog("onBegin() event fired for clip @ index " + _player.playlist.currentIndex + " - " + _player.currentClip.url, Debuggable.DEBUG_PLAYLIST); }
							// Added for 3.2.8 where multiple onBeforeBegin events firing triggered an onMute to fire muting the player
							if(_forceMuteOfPlayer) {
								doLog("Forcibly muting on the player - a VPAID ad must have been muted", Debuggable.DEBUG_CONFIG);				
								_player.muted = true;
								_badMuteEventFired = false;
								_forceMuteOfPlayer = false;
								_forceUnmuteOfPlayer = false;
							}
							else if(_forceUnmuteOfPlayer) {
								doLog("Forcibly unmuting on the player - a VPAID ad must have been unmuted", Debuggable.DEBUG_CONFIG);				
								_player.muted = false;
								_badMuteEventFired = false;
								_forceUnmuteOfPlayer = false;
								_forceMuteOfPlayer = false;
							}
							else if(_badMuteEventFired && (_playerShouldBeMuted == false)) {
								doLog("Forcibly unmuting the player - mute invalidly set by bad onMuteEvents", Debuggable.DEBUG_CONFIG);				
								_player.muted = false;
								_badMuteEventFired = false;
							}
	                        _duplicateBeforeBeginEventCount = 0;
							var theScheduledStream:Stream = _vastController.streamSequence.streamAt(getActiveStreamIndex());
	            			_vastController.resetAllAdTrackingPointsAssociatedWithStream(getActiveStreamIndex());
	               			_vastController.resetAllTrackingPointsAssociatedWithStream(getActiveStreamIndex());
							if(theScheduledStream is AdSlot) {
		            			if(_vastController.playOnce) {
									var activeClip:ScheduledClip = _player.currentClip as ScheduledClip;
						        	if(activeClip.marked) {
										if(AdSlot(theScheduledStream).isMidRoll() == false) {
							        		CONFIG::debugging { doLog("Skipping ad clip at schedule index " + getActiveStreamIndex() + " as it's already been played", Debuggable.DEBUG_PLAYLIST); }
											moveToNextClip();
										}
										else {
											CONFIG::debugging { doLog("It's a mid-roll - playing it because 'playOnce' won't work with mid-rolls", Debuggable.DEBUG_PLAYLIST); }
										}
						        	}  
		            			}
		            			else onToggleSeekerBar(new SeekerBarEvent(SeekerBarEvent.TOGGLE, false));					
							}
	      					else {
		            			// make sure the control bar is always re-enabled
		            			onToggleSeekerBar(new SeekerBarEvent(SeekerBarEvent.TOGGLE, true));
								CONFIG::debugging { doLog("Not assessing marked (playOnce) state on clip at playlist index " + _player.playlist.currentIndex + " - it's not a Ad clip", Debuggable.DEBUG_PLAYLIST); }
	      					}
	            		} 
	            );
	
	            // Before the clip finishes, mark is as having been played
	            
	            _player.playlist.onFinish(
            		function(clipevent:ClipEvent):void { 
						if(_player.currentClip is HoldingClip) {
							CONFIG::debugging { doLog("onFinish event received for a holding clip - ignoring the event", Debuggable.DEBUG_PLAYLIST); }
							return;
						}          
						else if(clipIsSplashImage(_player.currentClip.url)) {
							CONFIG::debugging { doLog("onFinish event received for an image - ignoring the event", Debuggable.DEBUG_PLAYLIST); }
							return;
						} 
							
						// Check that the actual play time for this clip has exceeded 95% of the duration - if it hasn't then this is a bad onFinish()
						// event - this work around was put in place to deal with bad onFinish() events in the 3.2.16 player as a result of
						// runtime ad slot failure when the ad playing reports an error

						if(_player.currentClip != null) {
							if(_player.currentClip.getNetStream() != null) {
								if((_player.currentClip.duration * 0.95) <= _player.currentClip.getNetStream().time) {
			                        CONFIG::debugging { doLog("onFinish() event fired for clip @ index " + _player.playlist.currentIndex + " - " + _player.currentClip.url, Debuggable.DEBUG_PLAYLIST); }
			            			_vastController.closeActiveOverlaysAndCompanions();
									_vastController.disableVisualLinearAdClickThroughCue();
									_vastController.closeActiveAdNotice();
									var theScheduledStream:Stream = _vastController.streamSequence.streamAt(getActiveStreamIndex());
									if(theScheduledStream is AdSlot) {
										var activeClip:ScheduledClip = _player.currentClip as ScheduledClip;
							       		activeClip.marked = true;
				 						CONFIG::debugging { doLog("Marking the current clip (schedule index " + getActiveStreamIndex() + ") - it's an ad that has been played once", Debuggable.DEBUG_PLAYLIST); }
				            			if(_vastController.playOnce) {
											if(_player.currentClip.isInStream) {
												//THIS JUST DOESN'T WORK - THE CHILD SEEMS TO BE REMOVED, BUT THE PLAYER STILL PLAYS IT
												//doLog("Removing mid-roll ad stream being - playOnce = true on this ad", Debuggable.DEBUG_PLAYLIST);	
												//_player.currentClip.parent.removeChild(_player.currentClip);
											}
				            			}
			      					}
			      					else {
			      						CONFIG::debugging { doLog("Not setting marked state on clip at playlist index " + _player.playlist.currentIndex + " - it's not a scheduled ad slot", Debuggable.DEBUG_PLAYLIST); }
			      					}
								}
								else {
		     						CONFIG::debugging { doLog("Bad onFinish() event encountered - play time (" + _player.currentClip.getNetStream().time + ") < 95% clip duration (" + _player.currentClip.duration + ")", Debuggable.DEBUG_PLAYLIST); }
								}
							}
							else {
	     						CONFIG::debugging { doLog("Not setting marked state on clip at playlist index " + _player.playlist.currentIndex + " - no netstream available", Debuggable.DEBUG_PLAYLIST); }
							}
						}
						else {
     						CONFIG::debugging { doLog("Not setting marked state on clip at playlist index " + _player.playlist.currentIndex + " - no current clip available", Debuggable.DEBUG_PLAYLIST); }
						}
            		}
	            );
	            
				_playerPlayOnceEventHandlersSetup = true;    		
	    	}
	    }		

        /**
         * Buffering icon handlers
         * 
         **/
         
        protected function showOVABusy():void {
        	// Not implemented
        }
        
        protected function showOVAReady():void {
        	// Not implemented
        }
          
        /**
         * AD CALL HANDLERS
         * 
         **/ 
         
        protected function onAdCallStarted(event:AdTagEvent):void {
        	CONFIG::debugging { doLog("PLUGIN NOTIFICATION: Ad Tag call started", Debuggable.DEBUG_VAST_TEMPLATE); }
        	if(event.calledOnDemand() == false || (event.calledOnDemand() && event.includesLinearAds())) {
		       	showOVABusy();
        	}
        }

        protected function onAdCallFailover(event:AdTagEvent):void {
        	CONFIG::debugging { doLog("PLUGIN NOTIFICATION: Ad Tag call failover", Debuggable.DEBUG_VAST_TEMPLATE); }
        }
        
        protected function onAdCallComplete(event:AdTagEvent):void {
        	CONFIG::debugging { doLog("PLUGIN NOTIFICATION: Ad Tag call complete", Debuggable.DEBUG_VAST_TEMPLATE); }
        	if(event.calledOnDemand() == false || (event.calledOnDemand() && event.includesLinearAds())) {
	        	showOVAReady();
	       	}
        }
	    
        /**
         * STREAM SCHEDULING CALLBACKS
         * 
         **/ 
		
		protected function clipIsSplashImage(clipName:String):Boolean {
        	if(clipName != null) {
        		var pattern:RegExp = new RegExp('.jpg|.png|.gif|.JPG|.PNG|.GIF');
        		return (clipName.match(pattern) != null);
        	}
        	return false;			
		}

		protected function playlistStartsWithSplashImage():Boolean {
			if(_player.playlist.length > 0) {
				return clipIsSplashImage(_player.playlist.getClip(0).url);
			}
			return false;
		}

		protected function getClipNameFromStream(stream:Stream):String {
            if(stream.playerConfig.isOriginallyPlaylistClip == true) {
            	return stream.streamName;
            }    
            else { 
	            if(stream.isRTMP()) {
					return stream.streamName;  
	            }
	            else return stream.url;
            }       			
		}
						
		protected function setupTrackingCuepoints(clip:Clip, trackingTable:TrackingTable, scheduleIndex:int):void {
            // Setup the flowplayer cuepoints based on the tracking points defined for this stream
            clip.removeCuepoints();
			for(var i:int=0; i < trackingTable.length; i++) {
				var trackingPoint:TrackingPoint = trackingTable.pointAt(i);
				if(trackingPoint.isLinear()) {
		            clip.addCuepoint(new Cuepoint(trackingPoint.milliseconds, trackingPoint.label + ":" + scheduleIndex));
					if(trackingPoint.label == "SN" && trackingPoint.milliseconds < 1000) {
						// Add in a second 'safety' cuepoint just in case the first one doesn't get fired by the player (a workaroud to a Flowplayer bug)
		            	clip.addCuepoint(new Cuepoint(1000, trackingPoint.label + ":" + scheduleIndex));
		            }
					CONFIG::debugging { doLog("Flowplayer Linear CUEPOINT set at " + trackingPoint.milliseconds + " with label " + trackingPoint.label + ":" + scheduleIndex, Debuggable.DEBUG_CUEPOINT_FORMATION);	}					
				}
			}			
		}

		protected function modifyTrackingCuepoints(clip:Clip, trackingTable:TrackingTable, scheduleIndex:int):void {
			var existingCuepoints:Array = clip.cuepoints;
			if(clip.cuepoints != null) {
				if(clip.cuepoints.length > 0) {
					var originalCuepoints:Array = clip.cuepoints;
					if(originalCuepoints != null) {
						clip.removeCuepoints();
						for(var i:int=0; i < trackingTable.length; i++) {
							var trackingPoint:TrackingPoint = trackingTable.pointAt(i);
							if(trackingPoint.isLinear()) {
								// first check to see if this cuepoint was set in the original cuepoints - if so, remove it from that list
								var j:int = 0;
								while(j < originalCuepoints.length) {
									var nextCuepoint:Cuepoint;
									if(originalCuepoints[j] is Array) {
										// In Flowplayer 3.2.7 and earlier, the cuepoint structure is  [ [{ cuepoint },{ cuepoint }], [{ cuepoint }] ]
										nextCuepoint = originalCuepoints[j][0];
									}
									else {
										// In Flowplayer 3.2.8, the cuepoints structure is now [ { cuepoint }, { cuepoint } ]
										nextCuepoint = originalCuepoints[j];
									}
									if(nextCuepoint != null) {
										if(nextCuepoint.callbackId != null) {
											if(nextCuepoint.callbackId.substr(0,2) == trackingPoint.label) {
												originalCuepoints.splice(j, 1);
											}
											else j++;
										}
									}
								}
					            clip.addCuepoint(new Cuepoint(trackingPoint.milliseconds, trackingPoint.label + ":" + scheduleIndex));
								CONFIG::debugging { doLog("Flowplayer Linear CUEPOINT set at " + trackingPoint.milliseconds + " with label " + trackingPoint.label + ":" + scheduleIndex, Debuggable.DEBUG_CUEPOINT_FORMATION);	}				
							}
						}
						for(var k:int=0; k < originalCuepoints.length; k++) {
							var theCuepoint:Cuepoint;
							if(originalCuepoints[k] is Array) {
								// This is the case for Flowplayer 3.2.7 or earlier
								theCuepoint = originalCuepoints[k][0];
							}
							else {
								// This is the case for Flowplayer 3.2.8
								theCuepoint = originalCuepoints[k];
							}
							if(theCuepoint != null) {
					            clip.addCuepoint(theCuepoint);							
								CONFIG::debugging { doLog("Flowplayer Linear CUEPOINT reset at " + theCuepoint.time + " with label " + theCuepoint.callbackId, Debuggable.DEBUG_CUEPOINT_FORMATION); }													
							}
						}
					}
				}
				else setupTrackingCuepoints(clip, trackingTable, scheduleIndex);		
			}
			else setupTrackingCuepoints(clip, trackingTable, scheduleIndex);		
		}
		
		protected function qualifyStreamUrl(baseName:String, baseUrl:String):String {
			if(baseUrl != null) {
				if(StringUtils.beginsWith(baseUrl, "http://")) {
					if(StringUtils.beginsWith(baseName, baseUrl)) {
						return baseName;
					}
					else return StringUtils.concatEnsuringSeparator(baseUrl, baseName, "/");
				}
			}
			return baseName;
		}

		protected function insertLinearAdAsClip(adSlot:AdSlot, scheduleIndex:int=-1, insertionForcedAtStartup:Boolean=false):Boolean {
			if(adSlot != null) {
				var newClip:ScheduledClip = new ScheduledClip();
				var clipIndex:int = ((scheduleIndex < 0) ? _player.playlist.currentIndex : scheduleIndex);
				if(adSlot.isMidRoll()) {
					if(adSlot.isInteractive()) {
						// TO DO
					}
					else {
						if(setupClipFromStream(adSlot, adSlot.index, newClip) != null) {
							_player.playInstream(newClip);
							return true;
						}			
					}
				}
				else {
					if(setupClipFromStream(adSlot, adSlot.index, newClip) != null) {
						if(insertionForcedAtStartup && (_vastController.autoPlay() == false)) {
							newClip.autoPlay = false;
						}
						var newPlaylist:Array = new Array(); 
						for(var i:int=0; i < _player.playlist.clips.length; i++) {
							if(i == clipIndex) {
								CONFIG::debugging { doLog("Have replaced the clip at index " + clipIndex + " with the newly loaded on-demand ad clip", Debuggable.DEBUG_PLAYLIST); }
								newPlaylist.push(newClip);
							}
							else {
								newPlaylist.push(_player.playlist.clips[i]);
							}
						}
						stopPlayback();		

						_player.playlist.replaceClips2(newPlaylist);
						_player.playlist.toIndex(clipIndex);

						if(insertionForcedAtStartup == false) {
							startPlayback();
						}
						return true;	
					}			
				}
			}
			return false;	
		}
		
		protected function insertHoldingClipAtCurrentIndex(adSlot:AdSlot):Boolean {
			var clipIndex:int = _player.playlist.currentIndex;
			var newPlaylist:Array = new Array(); 
			for(var i:int=0; i < _player.playlist.clips.length; i++) {
				if(i == clipIndex) {
					CONFIG::debugging { doLog("Have replaced the clip at index " + clipIndex + " with a HoldingClip", Debuggable.DEBUG_PLAYLIST); }
					var holdingClip:HoldingClip = new HoldingClip(
						{ 
							url: getHoldingClipURL(), 
							scaling: MediaSize.forName('scale'),
							autoPlay: _vastController.autoPlay(),
							duration: 0,
							customProperties: {
								"title": _vastController.config.adsConfig.getLinearAdTitle("Advertisement", adSlot.duration, adSlot.key),
								"description": _vastController.config.adsConfig.getLinearAdDescription(adSlot.title, adSlot.duration, adSlot.key),
								"ovaAd": true,
								"ovaZone": adSlot.zone,
								"ovaSlotId": adSlot.id,
								"ovaPosition": adSlot.position,
								"ovaAssociatedStreamIndex": adSlot.associatedStreamIndex,
								"ovaAdType": (adSlot.isPreRoll() ? "pre-roll-on-demand" : (adSlot.isMidRoll() ? "mid-roll-on-demand" : "post-roll-on-demand"))
							}
						}
					);
					holdingClip.scheduleKey = clipIndex;
					newPlaylist.push(holdingClip);
				}
				else {
					newPlaylist.push(_player.playlist.clips[i]);
				}
			}
			stopPlayback();		
			_player.playlist.replaceClips2(newPlaylist);
			_player.playlist.toIndex(clipIndex);
			startPlayback();
			return true;			
		}
		
		private function setCustomPropertyOnClip(originalCustomProperties:Object, prop:String, clip:Clip, proxying:Boolean, haveSetAutoPlay:Boolean):void {
			if(prop == "customProperties") {
				for(var cpProp:String in originalCustomProperties.customProperties) {
					clip.setCustomProperty(cpProp, originalCustomProperties.customProperties[cpProp]);
				}
			}
			else if(prop == "accelerated") {	
				clip.accelerated = originalCustomProperties[prop];						
			}
			else if(prop == "autoBuffering") {							
				clip.autoBuffering = originalCustomProperties[prop];
			}
			else if(prop == "autoPlay" && !haveSetAutoPlay) {	
				clip.autoPlay = originalCustomProperties[prop];
			}
			else if(prop == "baseUrl") {							
				clip.baseUrl = originalCustomProperties[prop];
			}
			else if(prop == "bufferLength") {						
				clip.bufferLength = originalCustomProperties[prop];	
			}
			else if(prop == "fadeInSpeed") {							
				clip.fadeInSpeed = originalCustomProperties[prop];
			}
			else if(prop == "fadeOutSpeed") {							
				clip.fadeOutSpeed = originalCustomProperties[prop];
			}
			else if(prop == "image") {							
				clip.image = originalCustomProperties[prop];
			}
			else if(prop == "linkUrl") {						
				clip.linkUrl = originalCustomProperties[prop];	
			}
			else if(prop == "linkWindow") {							
				clip.linkWindow = originalCustomProperties[prop];
			}
			else if(prop == "metaData") {
				clip.metaData = originalCustomProperties[prop];
			}
			else if(prop == "live") {							
				clip.live = originalCustomProperties[prop];
			}
			else if(prop == "position") {						
				clip.position = originalCustomProperties[prop];	
			}
			else if(prop == "scaling") {
				try {
					if(originalCustomProperties[prop] is MediaSize) {
						clip.scaling = originalCustomProperties[prop];
					}
					else if(originalCustomProperties[prop] is String) {
						clip.scaling =  MediaSize.forName(originalCustomProperties[prop]);																								
					}
					else {
						CONFIG::debugging { doLog("Unknown MediaSize definition type '" + originalCustomProperties[prop] + "'", Debuggable.DEBUG_CONFIG); }
					}
				}
				catch(e:Error) {
					CONFIG::debugging { doLog("Unknown MediaSize '" + originalCustomProperties[prop] + "'", Debuggable.DEBUG_CONFIG); }
				}
			}
			else if(prop == "seekableOnBegin") {					
				clip.seekableOnBegin = originalCustomProperties[prop];		
			}
			else if(prop == "urlResolvers") {					
				if(proxying == false) {
					clip.setUrlResolvers(originalCustomProperties[prop]);
					if(StringUtils.beginsWith(clip.url, "http")) {	
						// this is done to ensure that the bwcheck plugin works with HTTP streams
						clip.setCustomProperty("netConnectionUrl", null); 
						CONFIG::debugging { doLog("Have set the URL resolvers on this clip and nullified the netConnectionUrl custom property", Debuggable.DEBUG_CONFIG); }
					}
				}	
			}
			else if(prop == "connectionProvider") {				
				if(originalCustomProperties[prop] != null) {
					clip.connectionProvider = originalCustomProperties[prop];										
				}	
			}
			else clip.setCustomProperty(prop, originalCustomProperties[prop]);
		}
		
		protected function setupClipFromStream(stream:Stream, scheduleIndex:int, clip:Clip, assessAutoPlayFromCliplist:Boolean=false):Clip {
			var haveSetAutoPlay:Boolean = false;
			var proxying:Boolean = false; 

			clip.type = ClipType.fromMimeType(stream.mimeType); 
			if(stream is AdSlot) {
				proxying = _vastController.areProxiesEnabledForAdStreams();
				clip.start = 0;
				if(AdSlot(stream).isInteractive()) {
					CONFIG::debugging { doLog("Linear ad is a VPAID ad - inserting a holding clip", Debuggable.DEBUG_CONFIG); }
					clip = new HoldingClip(
							{ 
								url: getHoldingClipURL(), 
								scaling: MediaSize.forName('scale'),
								autoPlay: _vastController.autoPlay(), //true, 
								duration: 0,
								customProperties: {
									"title": _vastController.config.adsConfig.getLinearAdTitle("Advertisement", AdSlot(stream).duration, AdSlot(stream).key),
									"description": _vastController.config.adsConfig.getLinearAdDescription(AdSlot(stream).title, AdSlot(stream).duration, AdSlot(stream).key),
									"ovaAd": true,
									"ovaZone": AdSlot(stream).zone,
									"ovaSlotId": AdSlot(stream).id,
									"ovaPosition": AdSlot(stream).position,
									"ovaAssociatedStreamIndex": AdSlot(stream).associatedStreamIndex,
									"ovaAdType": (AdSlot(stream).isPreRoll() ? "pre-roll-vpaid" : (AdSlot(stream).isMidRoll() ? "mid-roll-vpaid" : "post-roll-vpaid"))
								}
							});
					HoldingClip(clip).scheduleKey = scheduleIndex;
					if(AdSlot(stream).isPreRoll() && _associatedPrerollClipIndex == -1) {
						// record the index of this pre-roll so that it can be linked to a show clip in the playlist
						_associatedPrerollClipIndex = _clipList.length;
					}
				}
				else {
					clip.duration = stream.getDurationAsInt();
					CONFIG::debugging { doLog("Setting default duration on ad (" + stream.streamName + ") from VAST data - " + clip.duration + " seconds", Debuggable.DEBUG_CONFIG);	}				
				}
			}
			else {
				proxying = _vastController.areProxiesEnabledForShowStreams();
				clip.start = stream.getStartTimeAsSeconds();
				if(!_vastController.deriveShowDurationFromMetaData()) {
					if(stream.hasDuration()) {
						clip.duration = stream.getDurationAsInt();				
						CONFIG::debugging { doLog("Show duration has been set to " + clip.duration, Debuggable.DEBUG_CONFIG); }
					}
					else {
						CONFIG::debugging { doLog("Cannot set show duration for " + stream.streamName + " - no duration provided in the config", Debuggable.DEBUG_CONFIG); }
					}
				}
				else {
					CONFIG::debugging { doLog("Did not set duration on the show clip (" + stream.streamName + ") from config - duration to be determined from stream metadata.", Debuggable.DEBUG_CONFIG);	}
				}			
			}
		    
		    if(assessAutoPlayFromCliplist) {
			    // we need to set the autoPlay based on how this clip fits into the clip list
			    if(_clipList.length == 0) {
			    	if(clipIsSplashImage(getClipNameFromStream(stream))) {
			    		// don't do anything this time around, we'll set it on the next round
			    	}
			    	else {
			    		clip.autoPlay = _vastController.autoPlay();
			    		haveSetAutoPlay = true;
						CONFIG::debugging { doLog("clipList == 0: clip[0] is not an image so autoPlay set on clip[0] to: " + clip.autoPlay, Debuggable.DEBUG_CONFIG); }
			    	}			    		
			    }
			    else if(_clipList.length == 1) { 
			    	// we just have 1 pre-pended clip, so if it's an image, set autoplay on our clip, otherwise
			    	// set it on the pre-pended stream
			    	if(clipIsSplashImage(_clipList[0])) { 
			    		clip.autoPlay = _vastController.autoPlay();
			    		haveSetAutoPlay = true;
						CONFIG::debugging { doLog("clipList == 1: clip[0] is an image so autoPlay set on clip[1] to: " + clip.autoPlay, Debuggable.DEBUG_CONFIG); }
			    	}
			    	else {
			    		_clipList[0].autoPlay = _vastController.autoPlay();
						CONFIG::debugging { doLog("clipList == 1: autoPlay set on clip[0] to: " + _clipList[0].autoPlay, Debuggable.DEBUG_CONFIG); }
			    	}
			    }
		    }
		    
			// Now set the general clip properties as required
			
			if((clip is HoldingClip) == false) {
				(clip as ScheduledClip).originalDuration = stream.getOriginalDurationAsInt();
	            StaticPlayerConfig.setClipConfig(clip, stream.playerConfig);

				(clip as ScheduledClip).scheduleKey = scheduleIndex;
	
	            if(stream.playerConfig.isOriginallyPlaylistClip == true) {
	            	if(stream.playerConfig.baseUrl != null) {
	            		clip.url = qualifyStreamUrl(stream.streamName, stream.playerConfig.baseUrl);
	            		clip.baseUrl = stream.playerConfig.baseUrl;
						CONFIG::debugging { doLog("Common clip baseURL set to " + clip.baseUrl, Debuggable.DEBUG_CONFIG); }
	            	}
	            	else clip.url = stream.streamName;
	            	clip.setCustomProperty("netConnectionUrl", stream.playerConfig.baseUrl);
		           	clip.provider = stream.provider;
	            }    
	            else { 
	            	// it's either an internally declared show stream or an ad stream
		            if(stream.isRTMP()) {
			            clip.provider = _vastController.getProvider("rtmp");
		            	if(proxying == false) {
							clip.url = stream.streamName;  
							var netConnectionUrl:String = stream.baseURL;
							clip.setCustomProperty("netConnectionUrl", netConnectionUrl);
							CONFIG::debugging { doLog("Not proxying stream - OVA has determined that the clip URL is " + clip.url + " and the netConnectionURL is " + netConnectionUrl, Debuggable.DEBUG_CONFIG); }
		            	}
		            	else {
		            		// let a urlResolvers determine what the final address elements - e.g. use Akamai resolver etc. if configured
							clip.url = stream.url;
							CONFIG::debugging { doLog("Proxying stream - OVA will allow clip resolver(s) to be used to determine the netConnectionURL from " + clip.url, Debuggable.DEBUG_CONFIG); }
		            	}
		            }
		            else {
						clip.url = stream.url;
						CONFIG::debugging { doLog("Clip provider set to " + _vastController.getProvider("http"), Debuggable.DEBUG_CONFIG); }
			            clip.provider = _vastController.getProvider("http");
		            }	
		            clip.setCustomProperty(
		            	"bitrates", 
		            	[ 
		            		{
		            			url: clip.url,
		            			bitrate: 800,
		            			hd: true,
		            			sd: true,
		            			isDefault: true,
		            			label: "SD"
		            		}
		            	]
		            ); 
		            CONFIG::debugging { doLog("Clip URL is " + clip.url, Debuggable.DEBUG_CONFIG); }	
	            }       
	            
				if(stream is AdSlot) {
					var adSlot:AdSlot = stream as AdSlot;
					// add in a default title for the ad
					clip.setCustomProperty("title", _vastController.config.adsConfig.getLinearAdTitle("Advertisement", adSlot.duration, adSlot.key)); 
					clip.setCustomProperty("description", _vastController.config.adsConfig.getLinearAdDescription(adSlot.title, adSlot.duration, adSlot.key)); 
					clip.setCustomProperty("ovaAd", true);
					clip.setCustomProperty("ovaZone", adSlot.zone);
					clip.setCustomProperty("ovaSlotId", adSlot.id);
					clip.setCustomProperty("ovaPosition", adSlot.position);
					clip.setCustomProperty("ovaAssociatedStreamIndex", adSlot.associatedStreamIndex);
					clip.setCustomProperty("ovaAdType", (adSlot.isPreRoll() ? "pre-roll" : (adSlot.isMidRoll() ? "mid-roll" : "post-roll")));
					clip.setCustomProperty("ovaInteractive", adSlot.isInteractive());
					
					if(adSlot.isPreRoll() && _associatedPrerollClipIndex == -1) {
						// record the index of this pre-roll so that it can be linked to a show clip in the playlist
						_associatedPrerollClipIndex = _clipList.length;
					}
					
					// now process the scaling
					if(_vastController.config.adsConfig.hasLinearScalingPreference() == false) {
						if((adSlot.isInteractive() && _vastController.enforceLinearInteractiveAdScaling()) ||
						   (adSlot.isLinear() && _vastController.enforceLinearVideoAdScaling())) {
								if(adSlot.canScale()) {
									if(adSlot.shouldMaintainAspectRatio()) {			
										clip.scaling = MediaSize.forName('fit');
										CONFIG::debugging { doLog("Scaling set to (scale, maintain): FIT", Debuggable.DEBUG_CONFIG); }
									}
									else {
										clip.scaling = MediaSize.forName('scale');
										CONFIG::debugging { doLog("Scaling set to (scale, don't maintain): SCALE", Debuggable.DEBUG_CONFIG);	}
									}
								}
								else {
									if(adSlot.shouldMaintainAspectRatio() == false) {
										clip.scaling = MediaSize.forName('fit');
										CONFIG::debugging { doLog("Scaling set to (no scale, don't maintain): FIT", Debuggable.DEBUG_CONFIG);	}
									}
									else {
										clip.scaling = MediaSize.forName('orig');
										CONFIG::debugging { doLog("Scaling set to (no scale, maintain): ORIG", Debuggable.DEBUG_CONFIG);	}	
									}					
								}
						}	
					}
					else {
						try {
							clip.scaling = MediaSize.forName(_vastController.config.adsConfig.linearScaling);
							CONFIG::debugging { doLog("Linear ad scaling has been set to '" + _vastController.config.adsConfig.linearScaling + "'", Debuggable.DEBUG_CONFIG); }
						}
						catch(e:Error) {
							CONFIG::debugging { doLog("Scaling exception - cannot set scaling to '" + _vastController.config.adsConfig.linearScaling + "'", Debuggable.DEBUG_CONFIG); }	
						}
					}
				}
				else {
					if(_associatedPrerollClipIndex > -1) {
						clip.setCustomProperty("ovaAssociatedPrerollClipIndex", _associatedPrerollClipIndex);
					}
					clip.setCustomProperty("ovaAssociatedStreamIndex", scheduleIndex);
					_associatedPrerollClipIndex = -1;
				}
				clip.setCustomProperty("ovaIsEndBlock", stream.isEndBlock());
				
				setupTrackingCuepoints(clip, stream.getTrackingTable(), scheduleIndex);
	            clip.onCuepoint(processCuepoint);

				clip.onError(onClipError);	

				if(stream is AdSlot) {
					if(_vastController.config.playerConfig.setUrlResolversOnAdClips == false) {
   	                	CONFIG::debugging { doLog("Not setting the urlResolvers for this ad clip as 'setUrlResolversOnAdClips' is 'false'", Debuggable.DEBUG_PLAYLIST); }
						clip.setUrlResolvers(null);	
					}				
	            	if(adSlot.isMidRoll()) {
						// If it's a mid-roll, insert the clip as a child of the current show stream
    	                if(_activeShowClip is ScheduledClip) {
		    	        	_activeShowClip.duration = (_activeShowClip as ScheduledClip).originalDuration;	                	
    	                	CONFIG::debugging { doLog("Duration of underlying stream set to " + _activeShowClip.duration + " - mid-roll clip has been created", Debuggable.DEBUG_PLAYLIST); }
    	                }
    	                clip.position = stream.getStartTimeAsSeconds(); 
    	                clip.start = 0;
	           			return clip;            		            			
	            	}	
	            	if(_vastController.config.playerConfig.applyCommonClipProperties) {
	            		var commonClip:Clip = _player.playlist.commonClip;
	            		if(commonClip != null) {
	            			if(commonClip.customProperties != null) {
								for(var cprop:String in commonClip.customProperties) {
									CONFIG::debugging { doLog("Setting common clip property '" + cprop + "' on ad clip", Debuggable.DEBUG_CONFIG); }									
									setCustomPropertyOnClip(commonClip.customProperties, cprop, clip, proxying, haveSetAutoPlay);            				
								}
	            			}
	            		}
	            	}
				}
				else {
					_activeShowClip = clip;
					// Add in any "customProperties" that may be attached to the stream
					if(stream.hasCustomProperties()) {
						for(var prop:String in stream.customProperties) {
							setCustomPropertyOnClip(stream.customProperties, prop, clip, proxying, haveSetAutoPlay);
						}
					}
				}				
			}
			else { 
			    // Clip is a Holding Clip
			}

			if(_player.playlist.commonClip.accelerated) {
				doLog("Accelerated property has been set to true on the clip", Debuggable.DEBUG_CONFIG);
				clip.accelerated = _player.playlist.commonClip.accelerated;
			}
			
			return clip;
		}
		
		protected function onStreamSchedule(event:StreamSchedulingEvent):void {
			if(event != null) {
				if(event.stream != null) {
					if(event.stream.isSlicedStream() && !event.stream.isFirstSlice()) {							
						CONFIG::debugging { doLog("PLUGIN NOTIFICATION: Ignoring request to schedule stream '" + event.stream.id + "' ('" + event.stream.streamName + "') at index " + event.scheduleIndex + " - sliced and it's not the first segment", Debuggable.DEBUG_PLAYLIST); }
						return;
					}
					else {
						var clip:Clip = null;
						if(event.stream is AdSlot) {
							if(AdSlot(event.stream).loadOnDemand && (AdSlot(event.stream).hasLinearAd() == false)) {
								// it's a load on demand schedule event so place a holding clip into the playlist
								CONFIG::debugging { doLog("PLUGIN NOTIFICATION: Scheduling on-demand ad stream '" + event.stream.id + "' at index " + event.scheduleIndex, Debuggable.DEBUG_PLAYLIST); }
//								clip = new HoldingClip(getDefaultHoldingClipProperties((event.scheduleIndex > 0) ? _vastController.autoPlay() : false)); // was false - changed because of multiple on-demand pre-rolls
								clip = new HoldingClip(getDefaultHoldingClipProperties((event.scheduleIndex > 0) ? true : false)); // set to true because post-rolls weren't autoplaying
								HoldingClip(clip).scheduleKey = event.scheduleIndex;
							}
							else {
								CONFIG::debugging { doLog("PLUGIN NOTIFICATION: Scheduling pre-loaded ad stream '" + event.stream.id + "' ('" + event.stream.streamName + "') at index " + event.scheduleIndex, Debuggable.DEBUG_PLAYLIST); }
								clip = setupClipFromStream(event.stream, event.scheduleIndex, new ScheduledClip(), true);
							}
							if(AdSlot(event.stream).isMidRoll()) {
								// use the old approach to mid-rolls
								var time:int = 0;
								var label:String = null;
								var safetyLabel:String = null;
			            		if(_activeShowClip != null) {
 				    	   			if(AdSlot(event.stream).loadOnDemand) {
										CONFIG::debugging { doLog("Ad stream is an on-demand mid-roll - attempting to setup cuepoints to trigger load", Debuggable.DEBUG_PLAYLIST); }
 				    	   				if(_instreamMidRollScheduled == false) {
		    	        	                _activeShowClip.duration = (_activeShowClip as ScheduledClip).originalDuration;	                	
    	                	                CONFIG::debugging { doLog("Duration of underlying stream set to " + _activeShowClip.duration + " - mid-roll holding clip has been created", Debuggable.DEBUG_PLAYLIST); }
 				    	   					time = Timestamp.timestampToSeconds(event.stream.startTime) * 1000;
 				    	   					label = "OD:" + AdSlot(event.stream).index;
 				    	   					safetyLabel = "OX:" + AdSlot(event.stream).index;
											_activeShowClip.addCuepoint(new Cuepoint(time, label));
											_activeShowClip.addCuepoint(new Cuepoint(time + 900, safetyLabel));
	 					    	   			CONFIG::debugging { doLog("Added on-demand mid-roll cuepoint '" + label + "' @ " + time + " seconds to trigger ad call and instream insertion", Debuggable.DEBUG_CUEPOINT_FORMATION); }
 				    	   				}
 				    	   				else {
 				    	   					CONFIG::debugging { doLog("Ignoring on-demand mid-roll - non on-demand mid-rolls have already been inserted", Debuggable.DEBUG_PLAYLIST); }
 				    	   				}
 				    	   			}
									else {
										if(clip is HoldingClip) {
 				    	   					time = Timestamp.timestampToSeconds(event.stream.startTime) * 1000;
 				    	   					label = "VM:" + AdSlot(event.stream).index;
 				    	   					safetyLabel = "VX:" + AdSlot(event.stream).index;
											_activeShowClip.addCuepoint(new Cuepoint(time, label));
											_activeShowClip.addCuepoint(new Cuepoint(time + 500, safetyLabel));
											CONFIG::debugging { doLog("Adding pre-loaded VPAID mid-roll cuepoint '" + label + "' @ " + time + " to trigger VPAID playback", Debuggable.DEBUG_PLAYLIST); }
										}
										else {
											if(_player.playlist.commonClip.accelerated) {
												doLog("Accelerated property has been set to true on the instream clip", Debuggable.DEBUG_CONFIG);
												clip.accelerated = _player.playlist.commonClip.accelerated;
											}
											_activeShowClip.addChild(clip);
											_instreamMidRollScheduled = true;
 					    	   				CONFIG::debugging { doLog("Added mid-roll ad as child Stream (running time " + clip.duration + ") provider: " + clip.provider + ", baseUrl: " + clip.baseUrl + ", url: " + clip.url, Debuggable.DEBUG_PLAYLIST); }
										}
									}
								}
								return;
							}
						}
						else {
							CONFIG::debugging { doLog("PLUGIN NOTIFICATION: Scheduling stream '" + event.stream.id + "' ('" + event.stream.streamName + "') at index " + event.scheduleIndex, Debuggable.DEBUG_PLAYLIST); }
							clip = setupClipFromStream(event.stream, event.scheduleIndex, new ScheduledClip(), true);
							_activeShowClip = clip;
	    	                if(_activeShowClip is ScheduledClip) {
			    	        	_activeShowClip.duration = (_activeShowClip as ScheduledClip).originalDuration;	                	
	    	                	CONFIG::debugging { doLog("Duration of underlying stream set to " + _activeShowClip.duration + " seconds", Debuggable.DEBUG_PLAYLIST); }
	    	                }
						}
						if(clip != null) {
				        	_clipList.push(clip);
				        	CONFIG::debugging { 
								if(clip is HoldingClip) {
									doLog("Added Holding Clip to the playlist", Debuggable.DEBUG_PLAYLIST);
								}
 		   					    else {
 	   					    		doLog("Added Stream clip " + clip.provider + " - " + clip.baseUrl + ", " + clip.url, Debuggable.DEBUG_PLAYLIST); 
 	   					    	}
 	   					    }
						}
					}
				}
				else {
					CONFIG::debugging { doLog("PLUGIN NOTIFICATION: onStreamSchedule received an event without a stream - ignoring request to schedule", Debuggable.DEBUG_PLAYLIST); }
				}				
			}
		}

		protected function onNonLinearSchedule(event:NonLinearSchedulingEvent):void {
			var adjustedStreamIndex:int = _vastController.getStreamSequenceIndexGivenOriginatingIndex(event.adSlot.originatingAssociatedStreamIndex, true, true);
			CONFIG::debugging { doLog("PLUGIN NOTIFICATION: Scheduling " + ((event.adSlot.loadOnDemand) ? "on-demand " : "") + "non-linear ad '" + event.adSlot.id + "' against stream at index " + adjustedStreamIndex + " ad slot is " + event.adSlot.key, Debuggable.DEBUG_SEGMENT_FORMATION); }

            // setup the flowplayer cuepoints for non-linear ads (including companions attached to non-linear ads)
			var trackingTable:TrackingTable = event.adSlot.getTrackingTable();
			for(var i:int=0; i < trackingTable.length; i++) {
				var trackingPoint:TrackingPoint = trackingTable.pointAt(i);
				if(trackingPoint.isNonLinear() && !trackingPoint.isForLinearChild) {
					if(adjustedStreamIndex > -1) {
						if(adjustedStreamIndex <= _clipList.length) {
				            _clipList[adjustedStreamIndex].addCuepoint(new Cuepoint(trackingPoint.milliseconds, trackingPoint.label + ":" + event.adSlot.associatedStreamIndex)); 
							CONFIG::debugging { doLog("Flowplayer NonLinear CUEPOINT set at " + trackingPoint.milliseconds + " with label " + trackingPoint.label + ":" + event.adSlot.associatedStreamIndex, Debuggable.DEBUG_CUEPOINT_FORMATION);	}		
						}
						else {
							CONFIG::debugging { doLog("FATAL: Adjusted stream index (" + adjustedStreamIndex + ") to map overlay is greater than length of clip list (" + _clipList.length + ")", Debuggable.DEBUG_FATAL); }
						}
					}
					else {
						CONFIG::debugging { doLog("FATAL: Cannot map non-linear ad to a valid stream index", Debuggable.DEBUG_FATAL); }
					}
				}
			}
		}			

        /**
         * ON DEMAND LOADING CALLBACK HANDLERS AND METHODS
         * 
         **/ 

		protected function onAdSlotLoaded(event:AdSlotLoadEvent):void {
			CONFIG::debugging { doLog("PLUGIN NOTIFICATION: Ad slot loaded - processing...", Debuggable.DEBUG_PLAYLIST); }
			if(event.adSlotHasLinearAds()) {
				CONFIG::debugging { doLog("Inserting linear ad from freshly loaded ad slot into the playlist", Debuggable.DEBUG_PLAYLIST); }
				if(event.adSlot.isInteractive()) {
					CONFIG::debugging { doLog("Starting the newly loaded VPAID ad - player is playing at this time", Debuggable.DEBUG_PLAYLIST); }
					playVPAIDAdSlot(event.adSlot);					
// REMOVED			if(_player.isPlaying() || event.adSlot.index > 0 || _vastController.delayAdRequestUntilPlay() || event.adSlot.loadingOnFailover()) {
//					}
//					else {
//						CONFIG::debugging { doLog("Not starting newly loaded VPAID ad - player is not playing at this time", Debuggable.DEBUG_PLAYLIST); }
//						event.adSlot.flag = true; 
//						if(_forcedAdLoadOnInitialisation) {
//							actionPlayerPostTemplateLoad();
//						}
//					}
				}
				else {
					if(insertLinearAdAsClip(event.adSlot, _player.playlist.currentIndex, _forcedAdLoadOnInitialisation)) {
						event.adSlot.flag = true; 
						if(_forcedAdLoadOnInitialisation) {
							actionPlayerPostTemplateLoad();
						}
					}
					else {
						if(event.adSlot.isMidRoll()) {
							CONFIG::debugging { doLog("Failure to insert linear video ad as an instream mid-roll clip - skipping", Debuggable.DEBUG_PLAYLIST);	}
							_forcedAdLoadOnInitialisation = false;
							return;
						}
						else {
							if(_player.playlist.hasNext()) {
								CONFIG::debugging { doLog("Failure to insert linear video ad as current clip - skipping", Debuggable.DEBUG_PLAYLIST);	}					
								moveToNextClip();
							}
							else {
								CONFIG::debugging { doLog("Failure to insert linear video ad as current clip - at end of playlist - resetting to clip 0", Debuggable.DEBUG_PLAYLIST); }
								resetPlayback();
								dispatchEndPlaybackCallback({ type: "reset" });
							}
						}
					}
				}
			}
			else {
				if(event.adSlot.isNonLinear()) {
					// No action required
				}
				else {
					if(event.adSlot.isMidRoll() == false) {
						CONFIG::debugging { doLog("Ad slot loaded but it does not have any linear ads to play - skipping to the next playlist item - autoPlay='" + _vastController.autoPlay() + "', player.isPlaying()='" + _player.isPlaying() + "'", Debuggable.DEBUG_PLAYLIST); }
	
						if(_forcedAdLoadOnInitialisation) {
							actionPlayerPostTemplateLoad();
						}
	
						var playerShouldForceStop:Boolean = moveToNextClip();

						if(getPlayerVersion() >= 3212 && (playerShouldForceStop == false)) {
							// added for 3.2.16
							startPlayback();	
						}
					}
					else {
						CONFIG::debugging { doLog("Mid-roll ad slot loaded but without an ad to play - skipping", Debuggable.DEBUG_PLAYLIST);	}												
						if(playerPlaying() == false) {
							startPlayback();
						}
					}
				}
			}
			_forcedAdLoadOnInitialisation = false;
		}
		
		protected function onAdSlotLoadError(event:AdSlotLoadEvent):void {
			CONFIG::debugging { doLog("PLUGIN NOTIFICATION: Ad Slot load error (skipping) - " + event.toString(), Debuggable.DEBUG_PLAYLIST); }
			if(_forcedAdLoadOnInitialisation) {
				actionPlayerPostTemplateLoad();
				_forcedAdLoadOnInitialisation = false;
			}
			if(event.adSlot.isLinear()) {
				if(event.adSlot.isMidRoll() == false) {
					if(_player.playlist.hasNext()) {
						moveToNextClip();
						startPlayback(); // added for 3.2.16
					}
					else {
						resetPlayback();
						dispatchEndPlaybackCallback({ type: "reset" });
					}
				}
			}
		}

		protected function onAdSlotLoadTimeout(event:AdSlotLoadEvent):void {
			CONFIG::debugging { doLog("PLUGIN NOTIFICATION: TIMEOUT loading Ad Slot (skipping) - " + event.toString(), Debuggable.DEBUG_FATAL); }
			if(_forcedAdLoadOnInitialisation) {
				actionPlayerPostTemplateLoad();
				_forcedAdLoadOnInitialisation = false;
			}
			if(event.adSlot.isLinear()) {
				if(event.adSlot.isMidRoll() == false) {
					if(_player.playlist.hasNext()) {
						moveToNextClip();
					}
					else {
						resetPlayback();
						dispatchEndPlaybackCallback({ type: "reset" });
					}
				}
			}
		}

		protected function onAdSlotLoadDeferred(event:AdSlotLoadEvent):void {
			CONFIG::debugging { doLog("PLUGIN NOTIFICATION: DEFERRED loading Ad Slot (skipping) - " + event.toString(), Debuggable.DEBUG_FATAL); }
			if(_forcedAdLoadOnInitialisation) {
				actionPlayerPostTemplateLoad();
				_forcedAdLoadOnInitialisation = false;
			}
			if(event.adSlot.isLinear()) {
				if(event.adSlot.isMidRoll() == false) {
					if(_player.playlist.hasNext()) {
						moveToNextClip();
					}
					else {
						resetPlayback();
						dispatchEndPlaybackCallback({ type: "reset" });
					}
				}
			}
		}
		
		protected function loadAdSlot(adSlot:AdSlot):void {
			if(_vastController != null && adSlot != null) {
				CONFIG::debugging { doLog("Current stream is an 'on-demand' ad slot @ index " + adSlot.index + " that needs to be loaded - triggering the load", Debuggable.DEBUG_PLAYLIST); }

				// Look to modify when the delay is triggered - perhaps it's only needed if pre-rolls are configured? TBD
				
				if(true) {
					var myTimer:Timer = new Timer(500, 1); 
					_timedAdSlot = adSlot;
					myTimer.addEventListener(TimerEvent.TIMER, timedLoadAdSlot);
					myTimer.start();
				}
				else {
					_vastController.loadAdSlotOnDemand(adSlot);
				}
			}		
		}

		protected function timedLoadAdSlot(event:TimerEvent):void {
			_vastController.loadAdSlotOnDemand(_timedAdSlot);
		}	

        /**
         * VPAID PLAYBACK HANDLERS
         * 
         **/ 

		protected function restoreControlBarPostVPAIDLinear():void {
			enableControlBarWidgets();
		}
		
		protected function moveFromVPAIDLinearToNextPlaylistItem(isMidRoll:Boolean = false):void {
			restoreControlBarPostVPAIDLinear();
			if(isMidRoll || _player.playlist.hasNext()) {
				CONFIG::debugging { doLog("moveFromVPAIDLinearToNextPlaylistItem() called - triggering move to next clip", Debuggable.DEBUG_PLAYLIST); }
				moveToNextClip(isMidRoll);	
				if(getPlayerVersion() >= 3208) startPlayback(); // required because 3.2.8 requires actual URLs in the holding clip - these clips are hard paused when VPAID ads play
			}
			else {
				CONFIG::debugging { doLog("moveFromVPAIDLinearToNextPlaylistItem() - end of playlist - forcing player.stop() and resetting to index 0 because last clip is a VPAID Ad", Debuggable.DEBUG_PLAYLIST); }
				_vastController.closeActiveVPAIDAds();
				resetPlayback();
				dispatchEndPlaybackCallback({ type: "reset" });
			}				
		}
		
		protected function onVPAIDLinearAdLoading(event:VPAIDAdDisplayEvent):void {
        	CONFIG::debugging { doLog("PLUGIN NOTIFICATION: VPAID ad loading", Debuggable.DEBUG_VPAID); }
			showOVABusy();
//			disableControlBarWidgets(true);
		}

		protected function onVPAIDLinearAdLoaded(event:VPAIDAdDisplayEvent):void {
        	CONFIG::debugging { doLog("PLUGIN NOTIFICATION: VPAID ad loaded", Debuggable.DEBUG_VPAID); }
			showOVAReady();
			disableControlBarWidgets(true);
		}
		
        protected function onVPAIDLinearAdStart(event:VPAIDAdDisplayEvent):void {
        	CONFIG::debugging { doLog("PLUGIN NOTIFICATION: VPAID Linear Ad started", Debuggable.DEBUG_VPAID); }
        	_playingVPAIDLinear = true;
//			disableControlBarWidgets(true);
        }

        protected function onVPAIDLinearAdComplete(event:VPAIDAdDisplayEvent):void {
			showOVAReady();
        	if(activeStreamIsLinearAd()) {
	        	if(AdSlot(getActiveStream()).wasVPAIDForciblyClosed() == false) {
		        	_playingVPAIDLinear = false;
		        	CONFIG::debugging { doLog("PLUGIN NOTIFICATION: VPAID Linear Ad complete - proceeding to next playlist item", Debuggable.DEBUG_VPAID); }
		        	moveFromVPAIDLinearToNextPlaylistItem();
	        	}
	        	else {
		        	CONFIG::debugging { doLog("PLUGIN NOTIFICATION: VPAID Linear Ad complete - ignoring 'complete' event because VPAID ad forcibly stopped", Debuggable.DEBUG_VPAID); }
	        	}
	        }
	        else {
	        	if(playerPaused()) {
		        	CONFIG::debugging { doLog("PLUGIN NOTIFICATION: VPAID Linear Ad complete - show stream is already active - resuming playback", Debuggable.DEBUG_VPAID); }
					enableControlBarWidgets();
	        		resumePlayback();
	        	}
		        else {
		        	if(_vastController.config.adsConfig.forcePlayAfterVPAID) {
			        	CONFIG::debugging { doLog("PLUGIN NOTIFICATION: VPAID Linear Ad complete - show stream is already active - forcing play anyway as option set", Debuggable.DEBUG_VPAID); }
			        	startPlayback();
		        	}
		        	else {
			        	CONFIG::debugging { doLog("PLUGIN NOTIFICATION: VPAID Linear Ad complete - show stream is already active - no additional action required", Debuggable.DEBUG_VPAID); }
		        	}
		        }
	        }       		
        }

		protected function onVPAIDAdLog(event:VPAIDAdDisplayEvent):void {
        	if(_vastController.testingVPAID()) {
        		if(event != null) {
		    		CONFIG::debugging { doLog("PLUGIN NOTIFICATION (TEST MODE): VPAID AdLog event '" + ((event.data != null) ? event.data.message : "") + "'", Debuggable.DEBUG_VPAID); }
        		}
        	}
		}

		protected function onVPAIDLinearAdError(error:VPAIDAdDisplayEvent):void {
			showOVAReady();
        	if(activeStreamIsLinearAd() || error.adSlot.isMidRoll()) {        		
        		if(error.adSlot.shouldFailoverOnVPAIDError((error.data != null) ? error.data.message : null)) {
	        		CONFIG::debugging { 
	        			doLog("Attempting to failover to the next ad tag after a VPAID error event", Debuggable.DEBUG_VAST_TEMPLATE);
	        		}
	        		
					// This hack was inserted to trick the 3.1.2 or greater player into thinking that the holding clip is longer than it really is
					// when it fails over to a new stream - if we don't do this, the player sends a bad onFinish() event when the failed
					// over clip is played (2.3 seconds into the clip) causing the failed over ad clip to prematurely end.

					if(getPlayerVersion() > 312 && _player.playlist.current is HoldingClip) {
						_player.playlist.current.duration = 30;
					}
					
					if(_vastController.attemptAdSlotFailoverOnDemand(error.adSlot) == false) {
		        		CONFIG::debugging { 
		        			doLog("Cannot failover to another ad tag - all ad tag options have been explored - moving on..", Debuggable.DEBUG_VAST_TEMPLATE);
		        		}
		        		moveFromVPAIDLinearToNextPlaylistItem(error.adSlot.isMidRoll());
					}
        		}
        		else {
		        	_playingVPAIDLinear = false;
		        	CONFIG::debugging { 
			        	doLog((error != null) 
	    	    	         ? "PLUGIN NOTIFICATION: VPAID Linear Ad error ('" + ((error.data != null) ? error.data.message : "") + "') proceeding to next playlist item"
	        		         : "PLUGIN NOTIFICATION: VPAID Linear Ad error proceeding to next playlist item", Debuggable.DEBUG_VPAID);
	        		}
	        		moveFromVPAIDLinearToNextPlaylistItem();
        		}
        	}
        	else {
        		if(playerPaused()) {
		        	CONFIG::debugging { doLog("PLUGIN NOTIFICATION: VPAID Linear Ad error ('" + ((error.data != null) ? error.data.message : "") + "') - Active stream is a show stream - resuming playback", Debuggable.DEBUG_VPAID); }
					enableControlBarWidgets();
        			resumePlayback();			
        		}
        		else {
        			CONFIG::debugging { doLog("PLUGIN NOTIFICATION: VPAID Linear Ad error ('" + ((error.data != null) ? error.data.message : "") + "') - Active stream is a show stream - no additional action required", Debuggable.DEBUG_VPAID); }
        		}
        	} 
		}

		protected function onVPAIDLinearAdLinearChange(event:VPAIDAdDisplayEvent):void {
			CONFIG::debugging { doLog("PLUGIN NOTIFICATION: VPAID Linear Ad linear change - linear state == " + ((event != null) ? event.data : "'not provided'"), Debuggable.DEBUG_VPAID); }
			if(event.data == true) {
				// not doing anything here at present
			}
		}

		protected function onVPAIDLinearAdExpandedChange(event:VPAIDAdDisplayEvent):void {
			CONFIG::debugging { doLog("PLUGIN NOTIFICATION: VPAID Linear Ad expanded change - expanded state == " + ((event != null) ? event.data.expanded : "'not provided'") + ", linear playback underway == " + event.data.linearPlayback + ", player paused == " + playerPaused(), Debuggable.DEBUG_VPAID); }
			if(event.data.expanded == false && event.data.linearPlayback == false) {
			    // VPAID ad has been minimised as the "adExpanded" state == false and the linear playback == false
			    if(activeStreamIsLinearAd()) {
			    	if(nextStreamIsShowStream()) {
				    	// if we are operating in a mode where the control bar is hidden make sure that the minimised ad
				    	// sits correctly with the control bar (as per non-linear mode)
						onResize();
				    	// Now move into the next playlist item
						moveFromVPAIDLinearToNextPlaylistItem();				
			    	}
			    	else _vastController.closeActiveVPAIDAds();
				}
				else {
					// We have a show stream as the active stream
					restoreControlBarPostVPAIDLinear();
					if(playerPaused()) {
						//enableControlBarWidgets();
						onResize();
						resumePlayback();
					}
				}
			}
			else if(event.data.expanded && event.data.linearPlayback == false) { 
				// VPAID ad has been expanded as the "adExpanded" state == true and it's not still playing in linear mode so make sure playback is paused
				disableControlBarWidgets(true);
				pausePlayback();
			}
			else if((event.data.expanded && event.data.linearPlayback) && activeStreamIsShowStream()) {
				// this case is used when a linear VPAID is minimised going to non-linear mode then
				// is expanded to resume linear playback - then show stream needs to be paused at that time
				disableControlBarWidgets(true);
				onResize();
				pausePlayback();
			}
		}

		protected function onVPAIDLinearAdTimeChange(event:VPAIDAdDisplayEvent):void {
			CONFIG::debugging { doLog("PLUGIN NOTIFICATION: VPAID Linear Ad time change - time == " + ((event != null) ? event.data : "'not provided'"), Debuggable.DEBUG_VPAID); }
		}          
		
		protected function onVPAIDLinearAdVolumeChange(event:VPAIDAdDisplayEvent):void {
			if(event != null) {
				if(event.data > 0) {
					CONFIG::debugging { doLog("PLUGIN NOTIFICATION: VPAID Linear Ad volume change to " + event.data + " - will unmute the player if it is muted", Debuggable.DEBUG_VPAID); }
					_forceUnmuteOfPlayer = true;
					_forceMuteOfPlayer = false;
				}
				else {
					CONFIG::debugging { doLog("PLUGIN NOTIFICATION: VPAID Linear Ad volume change to " + event.data + " - will mute the player if it is not muted", Debuggable.DEBUG_VPAID); }
					_forceUnmuteOfPlayer = false;
					_forceMuteOfPlayer = true;
				}
			}
			else {
				CONFIG::debugging { doLog("PLUGIN NOTIFICATION: VPAID Linear Ad volume change - 'volume level not provided'", Debuggable.DEBUG_VPAID); }
			}
		}

		protected function onVPAIDNonLinearAdVolumeChange(event:VPAIDAdDisplayEvent):void {
			CONFIG::debugging { doLog("PLUGIN NOTIFICATION: VPAID Non-Linear Ad volume change " + ((event != null) ? event.data : "'volume level not provided'"), Debuggable.DEBUG_VPAID); }
		}

		protected function onVPAIDNonLinearAdStart(event:VPAIDAdDisplayEvent):void {
			CONFIG::debugging { doLog("PLUGIN NOTIFICATION: VPAID Non-Linear Ad start", Debuggable.DEBUG_VPAID); }
		}
		
		protected function onVPAIDNonLinearAdComplete(event:VPAIDAdDisplayEvent):void { 
			showOVAReady();
			enableControlBarWidgets();
			if(playerPaused()) {
				CONFIG::debugging { doLog("PLUGIN NOTIFICATION: VPAID Non-Linear Ad complete - resuming playback", Debuggable.DEBUG_VPAID); }
				resumePlayback();
			}
			else {
				CONFIG::debugging { doLog("PLUGIN NOTIFICATION: VPAID Non-Linear Ad complete - no action required", Debuggable.DEBUG_VPAID); }
			}
		}
		
		protected function onVPAIDNonLinearAdError(event:VPAIDAdDisplayEvent):void {
			enableControlBarWidgets();
			if(playerPaused()) {
				CONFIG::debugging { doLog("PLUGIN NOTIFICATION: VPAID Non-Linear Ad error ('" + ((event.data != null) ? event.data.message : "") + "') - resuming playback", Debuggable.DEBUG_VPAID); }
				resumePlayback();
			}
        	else {
        		CONFIG::debugging { doLog("PLUGIN NOTIFICATION: VPAID Non-Linear Ad error ('" + ((event.data != null) ? event.data.message : "") + "')", Debuggable.DEBUG_VPAID); }
        	}
		}
		
		protected function onVPAIDNonLinearAdLinearChange(event:VPAIDAdDisplayEvent):void {
			CONFIG::debugging { doLog("PLUGIN NOTIFICATION: VPAID Non-Linear Ad linear change - linear state == " + ((event != null) ? event.data : "'not provided'"), Debuggable.DEBUG_VPAID); }
			if(event.data == false) { 
			    // VPAID is not in linear playback mode
				enableControlBarWidgets();
				if(playerPaused()) {
					resumePlayback();
				}
			}
			else { 
				// VPAID ad is in linear playback mode
				disableControlBarWidgets(true);
				pausePlayback();
			}
		}
		
		protected function onVPAIDNonLinearAdExpandedChange(event:VPAIDAdDisplayEvent):void {
			CONFIG::debugging { doLog("PLUGIN NOTIFICATION: VPAID Non-Linear Ad expanded change - expanded state == " + ((event != null) ? event.data.expanded : "'not provided'") + ", linear playback underway == " + event.data.linearPlayback + ", player paused == " + playerPaused(), Debuggable.DEBUG_VPAID); }
			if(event.data.expanded == false && event.data.linearPlayback == false) { 
				if(_vastController.config.adsConfig.vpaidConfig.resumeOnCollapse) {
					// pause was forced on expand, so force resume on contract
					if(playerPaused()) {
						resumePlayback();
					}
				}
			}
			else { 
				if(event.data.expanded && event.data.linearPlayback) {
					// VPAID ad has been expanded as the "adExpanded" state == true
					pausePlayback();
				}
				else if(event.data.expanded && _vastController.config.adsConfig.vpaidConfig.pauseOnExpand) {
					// Force pause on expand
					pausePlayback();
				}
			}
		}

		protected function onVPAIDNonLinearAdTimeChange(event:VPAIDAdDisplayEvent):void {
			CONFIG::debugging { doLog("PLUGIN NOTIFICATION: VPAID Non-Linear Ad time change", Debuggable.DEBUG_VPAID); }
		}   

		protected function onVPAIDAdSkipped(event:VPAIDAdDisplayEvent):void {
			CONFIG::debugging { doLog("PLUGIN NOTIFICATION: VPAID Skipped Event - " + event.type, Debuggable.DEBUG_VPAID); }
		}          

		protected function onVPAIDAdSkippableStateChange(event:VPAIDAdDisplayEvent):void {
			CONFIG::debugging { doLog("PLUGIN NOTIFICATION: VPAID SkippableStateChange Event - " + event.type, Debuggable.DEBUG_VPAID); }
		}          

		protected function onVPAIDAdSizeChange(event:VPAIDAdDisplayEvent):void {
			CONFIG::debugging { doLog("PLUGIN NOTIFICATION: VPAID Size Change Event - " + event.type, Debuggable.DEBUG_VPAID); }
		}          

		protected function onVPAIDAdDurationChange(event:VPAIDAdDisplayEvent):void {
			CONFIG::debugging { doLog("PLUGIN NOTIFICATION: VPAID Duration Change Event - " + event.type, Debuggable.DEBUG_VPAID); }
		}          

		protected function onVPAIDAdInteraction(event:VPAIDAdDisplayEvent):void {
			CONFIG::debugging { doLog("PLUGIN NOTIFICATION: VPAID Ad Interaction Event - " + event.type, Debuggable.DEBUG_VPAID); }
		}          

		protected function onVPAIDUnusedEvent(event:VPAIDAdDisplayEvent):void {
			CONFIG::debugging { doLog("PLUGIN NOTIFICATION: VPAID Unused Event - " + event.type, Debuggable.DEBUG_VPAID); }
		}          
		
        /**
         * TRACKING POINT CALLBACKS
         * 
         **/ 

		protected function onSetTrackingPoint(event:TrackingPointEvent):void {
			// not in use
		}

		protected function onTrackingPointFired(event:TrackingPointEvent):void {
			// not in use
		}

		protected function processCuepoint(clipevent:ClipEvent):void {
			var cuepoint:Cuepoint = clipevent.info as Cuepoint;
	    	var streamIndex:int = parseInt(cuepoint.callbackId.substr(3));
    	    var eventCode:String = cuepoint.callbackId.substr(0,2);
			var stream:Stream = _vastController.streamSequence.getStreamAtIndex(streamIndex);				
			CONFIG::debugging { doLog("Cuepoint triggered " + clipevent.toString() + " - id: " + cuepoint.callbackId, Debuggable.DEBUG_CUEPOINT_EVENTS); }
			if(eventCode == 'OD') {
				if(stream is AdSlot) {
					if(AdSlot(stream).isMidRoll()) {
					    if(stream.flagged && _vastController.config.adsConfig.allowDuplicateODCuepoints == false) {
							// this cuepoint must have been fired on the restart of the main stream post playing the instream mid-roll so ignore it
							doLog("Duplicate OD event received - ignoring - " + clipevent.toString(), Debuggable.DEBUG_CUEPOINT_EVENTS);									
					    }
			    		else {
							// this is an on-demand mid-roll trigger - the index is the index of the ad slot in the stream sequence
							if(AdSlot(stream).loadOnDemand) {
								if(AdSlot(stream).requiresLoading()) {
									stream.flag = true; 
									this.loadAdSlot(stream as AdSlot);								
								}
								else {
									if(insertLinearAdAsClip(stream as AdSlot, streamIndex)) {
										// set the safety flag which helps stop endless insertion of the mid-roll instream
										// as Flowplayer refires the OD event when the main stream resumes
										stream.flag = true; 
									}
								}
							} 
						}
					}
			    }
			}
			else if(eventCode == "OX") {
				// this is the safety cuepoint that is set and fired after an on-demand mid-roll trigger 'OD'
				// because Flowplayer refires the OD after the instream mid-roll has played and a safety
				// event is needed to help determine if the OD event is the original one or a refire
				stream.flag = false;
			}
			else if(eventCode == "VM") {
				// Preloaded VPAID mid-roll - so pause the player and start playback of the VPAID ad
				if(stream is AdSlot) {
					if(stream.flagged) {
						// this cuepoint must be firing again post playing the VPAID ad the first time so ignore
					}
					else if(AdSlot(stream).isMidRoll() && AdSlot(stream).isInteractive()) {
						stream.flag = true;
						playVPAIDAdSlot(stream as AdSlot);
					}
				}
			}
			else if(eventCode == "VX") {
				// this is the safety cuepoint that is set and fired after a preloaded VPAID mid-roll trigger 'VM'
				// because Flowplayer refires the VM after the instream VPAID mid-roll has played and a safety
				// event is needed to help determine if the VM event is the original one or a refire
				stream.flag = false;
			}
			else {
		       	_vastController.processTimeEvent(streamIndex, new TimeEvent(clipevent.info.time, 0, eventCode));				
			}
		}

		protected function processOverlayVideoAdCuepoint(clipevent:ClipEvent):void {
			var cuepoint:Cuepoint = clipevent.info as Cuepoint;
	    	var streamIndex:int = parseInt(cuepoint.callbackId.substr(3));
	        var eventCode:String = cuepoint.callbackId.substr(0,2);
			CONFIG::debugging { doLog("Overlay cuepoint triggered " + clipevent.toString() + " - id: " + cuepoint.callbackId, Debuggable.DEBUG_CUEPOINT_EVENTS); }
	        _vastController.processOverlayLinearVideoAdTimeEvent(streamIndex, new TimeEvent(clipevent.info.time, 0, eventCode));            	            
		}
		
        /**
         * PLAYER OPERATIONS
         * 
         **/ 
		
		protected function moveToNextClip(isMidRoll:Boolean = false):Boolean {
			_vastController.closeAllAdMessages();
			if(isMidRoll) {
				CONFIG::debugging { doLog("Player: Moving to next clip from clip @ index " + _player.playlist.currentIndex + ", mid-roll = " + isMidRoll + " - doing nothing", Debuggable.DEBUG_PLAYLIST); }
			} 
			else if(_player.playlist.currentIndex < (_player.playlist.length-1)) {
				CONFIG::debugging { doLog("Player: Moving to next clip from clip @ index " + _player.playlist.currentIndex + ", mid-roll = " + isMidRoll, Debuggable.DEBUG_PLAYLIST); }
				_player.next();
			}
			else {
				if(activeStreamIsShowStream()) {
					CONFIG::debugging { doLog("Player: Attempt to move to next clip from index " + _player.playlist.currentIndex + " stopped. End of playlist - last clip is a show clip. Stopping playback" + ", mid-roll = " + isMidRoll, Debuggable.DEBUG_PLAYLIST); }
					stopPlayback();
					dispatchEndPlaybackCallback({ type: "stop" });
				}
				else {
					if(AdSlot(getActiveStream()).hasLinearAd() == false) {
						CONFIG::debugging { doLog("Player: Attempt to move to next clip from index " + _player.playlist.currentIndex + " stopped. End of playlist - last clip is an empty ad clip. Rewinding playlist" + ", mid-roll = " + isMidRoll, Debuggable.DEBUG_PLAYLIST); }
						resetPlayback();
						dispatchEndPlaybackCallback({ type: "reset" });
						return true;
					}
					else {
						CONFIG::debugging { doLog("Player: Attempt to move to next clip from index " + _player.playlist.currentIndex + " stopped. End of playlist - last clip is a valid ad clip. Stopping playback" + ", mid-roll = " + isMidRoll, Debuggable.DEBUG_PLAYLIST); }
						stopPlayback();
						dispatchEndPlaybackCallback({ type: "stop" });
					}
				}
			}
			return false;
		}

	    protected function startPlayback():void {
	    	CONFIG::debugging { doLog("Player: Starting playback from clip @ index " + _player.playlist.currentIndex, Debuggable.DEBUG_PLAYLIST); }
	   		if(playerPlaying() == false) {
	   			_player.play();
	   		}
	    } 

		protected function stopPlayback():void {
			CONFIG::debugging { doLog("Player: Stopping playback of clip @ index " + _player.playlist.currentIndex, Debuggable.DEBUG_PLAYLIST); }
			_player.stop();
		}
		
		protected function resetPlayback():void {
			CONFIG::debugging { doLog("Player: Resetting playback of clip @ index " + _player.playlist.currentIndex + " back to index 0", Debuggable.DEBUG_PLAYLIST); }
			stopPlayback();
			if(_player.playlist.length > 0) {
				if(clipIsSplashImage(_player.playlist.clips[0].url)) {
					_player.playlist.toIndex(0);					
					startPlayback();				
				}
				else {
					_player.playlist.clips[0].autoPlay = false;
					_player.playlist.toIndex(0);					
				}
			}
		}

		protected function pausePlayback():void {
			CONFIG::debugging { doLog("Player: Pausing playback of clip @ index " + _player.playlist.currentIndex, Debuggable.DEBUG_PLAYLIST); }
			_player.pause();
		}
		
		protected function resumePlayback():void {
			CONFIG::debugging { doLog("Player: Resuming playback from clip @ index " + _player.playlist.currentIndex, Debuggable.DEBUG_PLAYLIST); }
			_player.play();
		}
		
		protected function playerPaused():Boolean {
			return (_player.state == State.PAUSED);
		}
		
		protected function playerPlaying():Boolean {
			return (_player.state == State.PLAYING);
		}
		
		protected function resetPlayerDisplay():void {
			// safety valve to ensure control bar is always enabled at start of clip
			enableControlBarWidgets(); 
		    setControlBarVisibility(_defaultControlbarVisibilityState);
			_vastController.hideAllOverlays();
			_vastController.closeActiveOverlaysAndCompanions();
			CONFIG::debugging { doLog("Have reset the control bar and cleared out any visible regions.", Debuggable.DEBUG_PLAYLIST); }
		}
				
        /**
         * PRE-LOADED AD SLOT CALLBACKS
         * 
         **/ 
		
		protected function onTemplateLoaded(event:TemplateEvent):void {
			CONFIG::debugging { 
				if(event.template.hasAds()) {
					doLog("PLUGIN NOTIFICATION: VAST template loaded - " + event.template.ads.length + " ads retrieved", Debuggable.DEBUG_VAST_TEMPLATE);
				}
				else {
					doLog("PLUGIN NOTIFICATION: No ads to be scheduled - only show streams will be played", Debuggable.DEBUG_VAST_TEMPLATE); 
				}
			}
			loadScheduledClipList();
			actionPlayerPostTemplateLoad();
		}

		protected function onTemplateLoadError(event:TemplateEvent):void {
			CONFIG::debugging { doLog("PLUGIN NOTIFICATION: FAILURE loading VAST template - " + event.toString(), Debuggable.DEBUG_VAST_TEMPLATE); }
			restorePlaylistAfterSchedulingProcess();
		}

		protected function onTemplateLoadTimeout(event:TemplateEvent):void {
			CONFIG::debugging { doLog("PLUGIN NOTIFICATION: TIMEOUT loading VAST template - " + event.toString(), Debuggable.DEBUG_VAST_TEMPLATE); }
			restorePlaylistAfterSchedulingProcess();
		}

		protected function onTemplateLoadDeferred(event:TemplateEvent):void {
			CONFIG::debugging { doLog("PLUGIN NOTIFICATION: DEFERRED loading VAST template - " + event.toString(), Debuggable.DEBUG_VAST_TEMPLATE); }
			if(playlistStartsWithSplashImage() && (_vastController.autoPlay() == false)) {
				CONFIG::debugging { doLog("Playlist starts with an image - and the ad calls have been deferred - not triggering initial ad slot loads", Debuggable.DEBUG_VAST_TEMPLATE); }
				restorePlaylistAfterSchedulingProcess();				
			}
			else if(false && _vastController.playbackStartsWithPreroll() && ((_vastController.delayAdRequestUntilPlay() == false) || (_vastController.delayAdRequestUntilPlay() == true && _vastController.autoPlay()))) {
				CONFIG::debugging { doLog("Playlist starts with a pre-roll and delayAdRequestUntilPlay either false or we have autoPlay - triggering the first ad call", Debuggable.DEBUG_VAST_TEMPLATE); }
				loadScheduledClipList();
				_forcedAdLoadOnInitialisation = true;
				loadAdSlot(_vastController.getFirstPreRollAdSlot());
			}
			else {
				restorePlaylistAfterSchedulingProcess();
			}
		}
		
		protected function actionPlayerPostTemplateLoad():void {
			_forcedAdLoadOnInitialisation = false;
            if(_loadEventHasBeenDispatched == false) {
				informPlayerOVAPluginLoaded();
            }
            else {
				startPlayback();
            }
		}
		
		protected function checkAutoPlaySettings():void {
			if(_player.playlist.length == 0) {
				// don't do anything - no playlist
				CONFIG::debugging { doLog("Checking autoPlay after ad call processed - leaving as is - no playlist", Debuggable.DEBUG_CONFIG); }
				return;
			}
		    else if(_player.playlist.length == 1) {
		    	if(clipIsSplashImage(_player.playlist.clips[0]) == false) { 
					CONFIG::debugging { doLog("Checking autoPlay after ad call processed: playlist length == 1: clip[0] is not an image so set to - " + _vastController.autoPlay(), Debuggable.DEBUG_CONFIG); }
			    	_player.playlist.clips[0].autoPlay = _vastController.autoPlay();
			    }
			    else {
					CONFIG::debugging { doLog("Checking autoPlay after ad call processed: playlist length == 1: clip[0] is an image so leaving as is - " + _player.playlist.clips[0].autoPlay, Debuggable.DEBUG_CONFIG); }
			    }
		    }
		    else {
		    	if(clipIsSplashImage(_player.playlist.clips[0])) { 
		    		_player.playlist.clips[0].autoPlay = true;
		    		_player.playlist.clips[1].autoPlay = _vastController.autoPlay();
					CONFIG::debugging { doLog("Checking autoPlay after ad call processed: playlist length > 1: clip[0] is an image so autoPlay set on clip[1] to: " + _vastController.autoPlay(), Debuggable.DEBUG_CONFIG); }
		    	}
		    	else {
		    		_clipList[0].autoPlay = _vastController.autoPlay();
					CONFIG::debugging { doLog("Checking autoPlay after ad call processed: playlist length > 1: clip[0] is not an image so set to: " + _vastController.autoPlay(), Debuggable.DEBUG_CONFIG); }
		    	}
		    }
		}
		
        /**
         * CONTROL BAR OPERATIONS
         * 
         **/ 

		protected function controlBarIsHidden():Boolean {
			var hideSetting:String = getControlBarHideSetting();
			if(StringUtils.matchesIgnoreCase(hideSetting, "NONE") || hideSetting == null) {
				return true;
			}
			if(StringUtils.matchesIgnoreCase(hideSetting, "NEVER")) {
				return false;
			}
			return (_controlBarVisible == false);
		}
		
		protected function getControlBarHideSetting():String {
			var model:DisplayPluginModel = _player.pluginRegistry.getPlugin(CONTROLS_PLUGIN_NAME) as DisplayPluginModel;
			if(model != null) {
				var controls:DisplayObject = model.getDisplayObject();
				if(model.config["autoHide"] == null) {
					return "ALWAYS";
				}
				else {
					if(model.config["autoHide"] is Boolean) {
						if(model.config["autoHide"] == false) {
							return "NEVER";
						}	
					}
					else if(model.config["autoHide"] is String) {
						return model.config["autoHide"];
					}
					else if(model.config["autoHide"] is Object) {
						if(model.config["autoHide"].enabled == false) {
							return "NEVER";
						}
					} 
				}
			}
			return "ALWAYS";
		}	

		protected function recordDefaultControlbarState():void {
			var model:DisplayPluginModel = _player.pluginRegistry.getPlugin(CONTROLS_PLUGIN_NAME) as DisplayPluginModel;
			if(model != null) {
				var controls:DisplayObject = model.getDisplayObject();
				_defaultControlbarVisibilityState = controls.visible;
				_autoHidingControlBar = StringUtils.matchesIgnoreCase(getControlBarHideSetting(), "ALWAYS");
				CONFIG::debugging { doLog("Default controlbar state set to visibility=" + _defaultControlbarVisibilityState, Debuggable.DEBUG_CONFIG); }
			}
			else {
				_defaultControlbarVisibilityState = false;
				CONFIG::debugging { doLog("Cannot record the default state of the control bar - cannot get a handle to it", Debuggable.DEBUG_CONFIG); }
			}			
		}

        protected function getPlayerReportedControlBarHeight(controls:DisplayObject=null):Number {
			var controlsModel:DisplayObject = null;
			var model:DisplayPluginModel = _player.pluginRegistry.getPlugin(CONTROLS_PLUGIN_NAME) as DisplayPluginModel;
        	if(controls == null) {
				if(model != null) {
					controlsModel = model.getDisplayObject();
    			}	
        	}
        	else controlsModel = controls;
        	
			if(controlsModel != null) {
				if(controlsModel.height == 0) {
					CONFIG::debugging { doLog("Control bar height is being reported by Flowplayer as 0 so OVA will recommend a default height of 26", Debuggable.DEBUG_CONFIG); }
					return 26;
				}
				else {
					CONFIG::debugging { doLog("Flowplayer reports the control bar height as " + controlsModel.height, Debuggable.DEBUG_CONFIG); }
					return controlsModel.height; 
				}
			}      		
			return 0;        	
        }

		protected function getControlBarYPosition():int {
			return -1;
		}
	
        protected function getControlBarHeight(controls:DisplayObject=null):int {
        	if(_vastController != null) {
	        	return _vastController.config.playerConfig.getControlBarHeight();    		
        	}
        	else return getPlayerReportedControlBarHeight();
        }

		protected function getPlayerVersion():int {
			if(_player != null) {
				var version:Array = _player.version;
				if(version.length >= 3) {
					var versionNumber:int = (version[0] * 1000) + (version[1] * 100) + version[2];
					return versionNumber;
				}
			}
			return 0;
		}
		

		/*
		 * enabled = (org.flowplayer.controls.config::WidgetsEnabledStates)#19 
		 *       fullscreen = true 
		 *       fullscreenExit = true 
		 *       hd = true 
		 *       mute = true 
		 *       next = true 
		 *       pause = true 
		 *       play = true 
		 *       previous = true 
		 *       scrubber = true 
		 *       sd = false 
		 *       stop = true
		 *       nmute = true 
		 *       volume = true 
		 */
		protected function enableControlBarWidgets():void {
			var model:DisplayPluginModel = _player.pluginRegistry.getPlugin(CONTROLS_PLUGIN_NAME) as DisplayPluginModel;
			if(model != null) {
				CONFIG::debugging { doLog("Enabling control bar widgets", Debuggable.DEBUG_DISPLAY_EVENTS); }
				var controls:DisplayObject = model.getDisplayObject();
				if(controls != null) {
					if(controls["enable"] != undefined) {
						Object(controls).enable(
						    { 
						        scrubber: true, 
						        playlist: true, 
						        volume: true, 
						        stop: true, 
						        play: true, 
						        fullscreen: true, 
						        mute: true,
						        hd: true,
						        sd: true 
						    }
						);
					}							
					else {
						CONFIG::debugging { doLog("Cannot enable control bar - 'enabled' method is undefined", Debuggable.DEBUG_DISPLAY_EVENTS); }
					}
				}
				else {				
					CONFIG::debugging { doLog("Cannot enable the control bar - unable to get a handle to the display object", Debuggable.DEBUG_DISPLAY_EVENTS); }
				}
			}
			else {
				CONFIG::debugging { doLog("Cannot enable the control bar - unable to get a handle to the controls plugin model", Debuggable.DEBUG_DISPLAY_EVENTS); }
			}
		}
		
		protected function disableControlBarWidgets(isVPAID:Boolean):void {
			var model:DisplayPluginModel = _player.pluginRegistry.getPlugin(CONTROLS_PLUGIN_NAME) as DisplayPluginModel;

			if(model != null) {
				var controls:DisplayObject = model.getDisplayObject();
				if(controls != null) {
					if(controls["enable"] != undefined) {
						if(isVPAID) {
							// disable all controls because it is a VPAID ad - either linear or non-linear
							CONFIG::debugging { doLog("VPAID ad - disabling all control bar widgets", Debuggable.DEBUG_DISPLAY_EVENTS); }
  						    Object(controls).enable(
							    { 
							        scrubber: false,  
							        playlist: false,  
							        volume: false, 
							        stop: false,  
						    	    play: false,  
						        	fullscreen: false,  
						        	mute: false
						    	}
							);
						}
						else {
							CONFIG::debugging { doLog("Stream ad - disabling controls as per the spec", Debuggable.DEBUG_DISPLAY_EVENTS); }
						    Object(controls).enable(
							    { 
							        scrubber: _vastController.controlEnabledStateForLinearAdType(ControlsSpecification.TIME, false),  
							        playlist: _vastController.controlEnabledStateForLinearAdType(ControlsSpecification.PLAYLIST, false),  
							        volume: _vastController.controlEnabledStateForLinearAdType(ControlsSpecification.VOLUME, false), 
							        stop: _vastController.controlEnabledStateForLinearAdType(ControlsSpecification.STOP, false),  
						    	    play: _vastController.controlEnabledStateForLinearAdType(ControlsSpecification.PLAY, false),  
						        	fullscreen: _vastController.controlEnabledStateForLinearAdType(ControlsSpecification.FULLSCREEN, false),
						        	mute: _vastController.controlEnabledStateForLinearAdType(ControlsSpecification.MUTE, false)
						    	}
							);
						}
					}
					else {
						CONFIG::debugging { doLog("Cannot disable control bar - 'enabled' method is undefined", Debuggable.DEBUG_DISPLAY_EVENTS); }
					}							
				}
				else {
					CONFIG::debugging { doLog("Cannot disable the control bar - unable to get a handle to the display object", Debuggable.DEBUG_DISPLAY_EVENTS); }
				}
			}
			else {
				CONFIG::debugging { doLog("Cannot disable the control bar - unable to get a handle to the controls plugin model", Debuggable.DEBUG_DISPLAY_EVENTS); }
			}

		}

		protected function setControlBarVisibility(visible:Boolean):void {
			var model:DisplayPluginModel = _player.pluginRegistry.getPlugin(CONTROLS_PLUGIN_NAME) as DisplayPluginModel;
			if(model != null) {
				CONFIG::debugging { doLog("Setting the control bar visibility to " + visible, Debuggable.DEBUG_DISPLAY_EVENTS); }
				var controls:DisplayObject = model.getDisplayObject();
				controls.visible = visible;		
			}
			else {
				CONFIG::debugging { doLog("Cannot change the visibility of the controlbar - unable to get a handle to it", Debuggable.DEBUG_DISPLAY_EVENTS); }
			}
		}

		public function onToggleSeekerBar(event:SeekerBarEvent):void {
			if(_vastController != null && activeStreamIsLinearAd()) {
				var isVPAID:Boolean = activeClipIsVPAIDLinearAd();
				CONFIG::debugging { doLog("onToggleSeekerBar() event received - linear ad " + ((isVPAID) ? "is VPAID" : "is stream"), Debuggable.DEBUG_DISPLAY_EVENTS); }
				if(_vastController.config.playerConfig.shouldManageControlsDuringLinearAds(isVPAID)) { 
					if(event.turnOff()) {						
						if(_vastController.config.playerConfig.shouldHideControlsOnLinearPlayback(isVPAID)) {
						    CONFIG::debugging { doLog("Hiding the control bar", Debuggable.DEBUG_DISPLAY_EVENTS); }
							setControlBarVisibility(false);
						}
						else if(_vastController.config.playerConfig.shouldDisableControlsDuringLinearAds()) { 
						    CONFIG::debugging { doLog("Disabling the control bar", Debuggable.DEBUG_DISPLAY_EVENTS); }
							disableControlBarWidgets(isVPAID);
						}
					}
					else {
					    CONFIG::debugging { doLog("Enabling the control bar", Debuggable.DEBUG_DISPLAY_EVENTS); }
						enableControlBarWidgets();			
						setControlBarVisibility(_defaultControlbarVisibilityState);
					}				
				}
				else {
					CONFIG::debugging { doLog("OVA will not manipulate the control bar - the 'manage' config option is set to false", Debuggable.DEBUG_DISPLAY_EVENTS); }
				}
			}
			else {
			    CONFIG::debugging { doLog("Enabling the control bar - stream is not a linear ad", Debuggable.DEBUG_DISPLAY_EVENTS); }
				enableControlBarWidgets();			
				setControlBarVisibility(_defaultControlbarVisibilityState);
			}
		}

        /**
         * LINEAR AD CALLBACKS
         * 
         **/ 

		public function onLinearAdStarted(linearAdDisplayEvent:LinearAdDisplayEvent):void {
			CONFIG::debugging { doLog("PLUGIN NOTIFICATION: Event received that linear ad has started", Debuggable.DEBUG_DISPLAY_EVENTS); }
		}	

		public function onLinearAdComplete(linearAdDisplayEvent:LinearAdDisplayEvent):void {
			CONFIG::debugging { doLog("PLUGIN NOTIFICATION: Event received that linear ad is complete", Debuggable.DEBUG_DISPLAY_EVENTS); }
		}	

		public function onLinearAdSkipped(linearAdDisplayEvent:LinearAdDisplayEvent):void {
			CONFIG::debugging { doLog("PLUGIN NOTIFICATION: Event received that linear ad has been skipped - forcing player to skip to next track", Debuggable.DEBUG_DISPLAY_EVENTS); }
			if(activeClipIsVPAIDLinearAd()) {
				CONFIG::debugging { doLog("Closing the active VPAID ad before moving onto the next clip in the playlist", Debuggable.DEBUG_PLAYLIST); }
				_vastController.closeActiveVPAIDAds();
			}
			else {
				if(_player.playlist.current.isInStream) {
					// it's a mid-roll so cut short it's duration so that triggers the player to stop playing it
					_player.playlist.current.duration = 1; 
				}
				else {
					if(_player.playlist.hasNext()) {
						moveToNextClip();				
					}
					else {
						resetPlayback();
						dispatchEndPlaybackCallback({ type: "reset" });
					}
				}
			}
		}	

		public function onLinearAdClickThrough(linearAdDisplayEvent:LinearAdDisplayEvent):void {
			CONFIG::debugging { doLog("PLUGIN NOTIFICATION: Event received that linear ad click through activated", Debuggable.DEBUG_DISPLAY_EVENTS);	}	
			if(_vastController.config.adsConfig.skipAdConfig.skipAdOnClickThrough) {
				skipAd();
			}	
			else if(_vastController.pauseOnClickThrough) {
				pausePlayback(); 
			}
		}

        /**
         * AD NOTICE CALLBACKS
         * 
         **/ 

		public function onDisplayNotice(displayEvent:AdNoticeDisplayEvent):void {	
			CONFIG::debugging { doLog("PLUGIN NOTIFICATION: Event received to display ad notice", Debuggable.DEBUG_DISPLAY_EVENTS); }
		}
				
		public function onHideNotice(displayEvent:AdNoticeDisplayEvent):void {	
			CONFIG::debugging { doLog("PLUGIN NOTIFICATION: Event received to hide ad notice", Debuggable.DEBUG_DISPLAY_EVENTS); }
		}

        /**
         * INSTREAM AD PLAYBACK METHODS
         * 
         **/ 		
		protected function playInstreamAd(adSlot:AdSlot, overlayVideo:Boolean=true):void {
			if(adSlot != null) {
				var clip:ScheduledClip = new ScheduledClip();
				clip.type = ClipType.fromMimeType(adSlot.mimeType);
				clip.start = 0;
				clip.originalDuration = adSlot.getAttachedLinearAdDurationAsInt();
				clip.duration = clip.originalDuration;
				clip.setCustomProperty("metaData", adSlot.metaData);
	            if(adSlot.isRTMP()) {
					clip.url = adSlot.streamName;
					clip.setCustomProperty("netConnectionUrl", adSlot.baseURL);
		            clip.provider = _vastController.getProvider("rtmp");
	        	}
	        	else {
					clip.url = adSlot.url;
		            clip.provider = _vastController.getProvider("http");
	        	}
	            StaticPlayerConfig.setClipConfig(clip, adSlot.playerConfig);
	
	        	// Setup the flowplayer cuepoints based on the tracking points defined for this 
	        	// linear ad (including companions attached to linear ads)
	
				if(overlayVideo) {
		  		    clip.scheduleKey = adSlot.key; 
		  		    clip.isOverlayLinear = true; 
		        	clip.onCuepoint(processOverlayVideoAdCuepoint);
		  		}
		  		else {
		  		    clip.scheduleKey = adSlot.index; 
		  			clip.onCuepoint(processCuepoint);
		  		}
				var trackingTable:TrackingTable = adSlot.getTrackingTable();
				for(var i:int=0; i < trackingTable.length; i++) {
					var trackingPoint:TrackingPoint = trackingTable.pointAt(i);
					if(overlayVideo) {
						if(trackingPoint.isLinear() && trackingPoint.isForLinearChild) {
				            clip.addCuepoint(new Cuepoint(trackingPoint.milliseconds, trackingPoint.label + ":" + adSlot.key)); 
							CONFIG::debugging { doLog("Flowplayer CUEPOINT set for attached linear ad at " + trackingPoint.milliseconds + " with label " + trackingPoint.label + ":" + adSlot.key, Debuggable.DEBUG_CUEPOINT_FORMATION); }
						}
					}
					else {
						if(trackingPoint.isLinear()) {
				            clip.addCuepoint(new Cuepoint(trackingPoint.milliseconds, trackingPoint.label + ":" + adSlot.index)); 
							CONFIG::debugging { doLog("Flowplayer CUEPOINT set for attached linear ad at " + trackingPoint.milliseconds + " with label " + trackingPoint.label + ":" + adSlot.index, Debuggable.DEBUG_CUEPOINT_FORMATION); }
						}
					}
				}

				if(_player.playlist.commonClip.accelerated) {
					doLog("Accelerated property has been set to true on the instream clip", Debuggable.DEBUG_CONFIG);
					clip.accelerated = _player.playlist.commonClip.accelerated;
				}

				_player.playInstream(clip);				
			}
		}

        /**
         * OVERLAY CALLBACKS
         * 
         **/ 
				
		public function onOverlayCloseClicked(displayEvent:OverlayAdDisplayEvent):void {
			CONFIG::debugging { doLog("PLUGIN NOTIFICATION: Event received - overlay close has been clicked (" + displayEvent.toString() + ")", Debuggable.DEBUG_DISPLAY_EVENTS); }
		}

		public function onDisplayOverlay(displayEvent:OverlayAdDisplayEvent):void {
			CONFIG::debugging { doLog("PLUGIN NOTIFICATION: Event received to display non-linear overlay ad (" + displayEvent.toString() + ")", Debuggable.DEBUG_DISPLAY_EVENTS); }
		}

		public function onOverlayClicked(overlayAdDisplayEvent:OverlayAdDisplayEvent):void {
			CONFIG::debugging { doLog("PLUGIN NOTIFICATION: Event received - overlay has been clicked! (" + overlayAdDisplayEvent.toString() + ")", Debuggable.DEBUG_DISPLAY_EVENTS); }
			if(overlayAdDisplayEvent.nonLinearVideoAd.hasAccompanyingVideoAd()) {
				playInstreamAd(overlayAdDisplayEvent.adSlot, true);
			}
			else {
				if(overlayAdDisplayEvent.nonLinearVideoAd.hasClickThroughURL() && _vastController.pauseOnClickThrough) pausePlayback(); //_player.pause();
			}
		}
		
		public function onHideOverlay(displayEvent:OverlayAdDisplayEvent):void {
			CONFIG::debugging { doLog("PLUGIN NOTIFICATION: Event received to hide non-linear overlay ad (" + displayEvent.toString() + ")", Debuggable.DEBUG_DISPLAY_EVENTS); }
		}

		public function onDisplayNonOverlay(displayEvent:OverlayAdDisplayEvent):void {
			CONFIG::debugging { doLog("PLUGIN NOTIFICATION: Event received to display non-linear non-overlay ad (" + displayEvent.toString() + ")", Debuggable.DEBUG_DISPLAY_EVENTS); }
		}
		
		public function onHideNonOverlay(displayEvent:OverlayAdDisplayEvent):void {
			CONFIG::debugging { doLog("PLUGIN NOTIFICATION: Event received to hide non-linear non-overlay ad (" + displayEvent.toString() + ")", Debuggable.DEBUG_DISPLAY_EVENTS); }
		}

        /**
         * COMPANION AD CALLBACKS
         * 
         **/ 
        
        public function onDisplayCompanionAd(companionEvent:CompanionAdDisplayEvent):void {
			CONFIG::debugging { doLog("PLUGIN NOTIFICATION: Event received to display companion ad (" + companionEvent.companionAd.width + "X" + companionEvent.companionAd.height + ")", Debuggable.DEBUG_DISPLAY_EVENTS); }
        }

		public function onHideCompanionAd(companionEvent:CompanionAdDisplayEvent):void {
            CONFIG::debugging { doLog("PLUGIN NOTIFICATION: Request received to hide companion ad (" + companionEvent.companionAd.width + "X" + companionEvent.companionAd.height + ")", Debuggable.DEBUG_DISPLAY_EVENTS); }
		}

        /**
         * VAST TRACKING ACTIONS
         * 
         **/ 

        protected function getActiveStreamIndex():int {
        	if(_player.currentClip != null) {
				if(_player.currentClip is ScheduledClip) {
	        		return (_player.currentClip as ScheduledClip).scheduleKey;				
				}
				else {
					return _player.currentClip.index;
				}
        	}
        	return 0;
        }

		protected function activeStreamIsShowStream():Boolean {
			return !activeStreamIsLinearAd();
		}
		
		protected function nextStreamIsShowStream():Boolean {
			if(_vastController != null) {
        		if(_vastController.streamSequence != null) {        			
					var nextStream:Stream = _vastController.streamSequence.streamAt(getActiveStreamIndex() + 1);
					if(nextStream != null) {
						return !(nextStream is AdSlot);
					}
        		}
			}
			return false;
		}
		
		protected function activeStreamIsLinearAd():Boolean {
			if(_vastController != null) {
        		if(_vastController.streamSequence != null) {        			
					var currentStream:Stream = _vastController.streamSequence.streamAt(getActiveStreamIndex());
					if(currentStream != null) {
						if(currentStream is AdSlot) {
							return AdSlot(currentStream).isLinear();
						}				
					}
        		}
			}
			return false;
		}
        
        protected function activeClipIsVPAIDLinearAd():Boolean {
        	if(_vastController != null) {
        		if(_vastController.streamSequence != null) {        			
					var currentStream:Stream = _vastController.streamSequence.streamAt(getActiveStreamIndex());
					if(currentStream != null) {
						if(currentStream is AdSlot) {
							return AdSlot(currentStream).isLinear() && AdSlot(currentStream).isInteractive();
						}				
					}        		
        		}
        	}
			return false;
        }
        
        protected function isActiveLinearClipOverlay():Boolean {
        	if(_player.currentClip != null) {
        		if(_player.currentClip is ScheduledClip) {
					return ScheduledClip(_player.currentClip).isOverlayLinear;        		
        		}
        	}
        	return false;
        }
        
        protected function getActiveStream():Stream {
        	if(_vastController != null) {
        		if(_vastController.streamSequence != null) {
		        	return _vastController.streamSequence.streamAt(getActiveStreamIndex());			
        		}
        	}
        	return null;
        }

		protected function playVPAIDAdSlot(adSlot:AdSlot):void {
			if(_vastController != null) {
				CONFIG::debugging { doLog("Active clip is a VPAID ad - triggering the playback - mute state is " + _player.muted, Debuggable.DEBUG_VPAID); }
				if(_player.isPlaying()) pausePlayback();				
				_vastController.playVPAIDAd(adSlot, _player.muted, false, getPlayerVolume()); 				
			}
		}
		
		protected function attemptCurrentStreamDurationAdjustment(theStream:Stream, newDuration:Number, modifyExistingCuepoints:Boolean=false):Boolean {
			var currentDuration:int = theStream.getDurationAsInt();
			var roundedNewDuration:int = Math.floor(newDuration);			
			if(currentDuration != newDuration && newDuration > 0) {
	   			CONFIG::debugging { doLog(((theStream is AdSlot) ? "Ad" : "Show") + " stream duration requires adjustment - original duration: " + currentDuration + ", metadata duration: " + newDuration, Debuggable.DEBUG_CONFIG); }
	   			if(_player.currentClip != null) {
					_player.currentClip.duration = newDuration;				
					theStream.duration = String(roundedNewDuration);
					if(modifyExistingCuepoints) {
						modifyTrackingCuepoints(_player.currentClip, theStream.getTrackingTable(), getActiveStreamIndex());
					}
					else setupTrackingCuepoints(_player.currentClip, theStream.getTrackingTable(), getActiveStreamIndex());
					CONFIG::debugging { doLog("Active stream duration and tracking points updated to reflect new clip duration of " + _player.currentClip.duration, Debuggable.DEBUG_CONFIG); }
					return true;
	   			}				
		 		else {
		 			CONFIG::debugging { doLog("Not changing " + ((theStream is AdSlot) ? "Ad" : "Show") + " stream duration - cannot get a handle to the 'current' stream in the playlist", Debuggable.DEBUG_CONFIG); }
		 		}
			}							
			else {
				CONFIG::debugging { doLog("Not adjusting the " + ((theStream is AdSlot) ? "Ad" : "Show") + " stream duration based on metadata (" + newDuration + ") - it is either zero or the same as currently set on the clip (" + currentDuration + " == " + newDuration + ")", Debuggable.DEBUG_CONFIG); }
			}
			return false;
		}
        
		protected function onMetaDataEvent(event:ClipEvent):void {
			if(_player.currentClip is HoldingClip) { 
				// added for 3.2.8 because HoldingClips have streams that have metadata causing the player to resume playback when it shouldn't
				return;
			}
			var newDuration:Number = Number(_player.currentClip.durationFromMetadata);
			CONFIG::debugging { doLog("MetaData received for active clip - metadata duration is " + newDuration, Debuggable.DEBUG_CONFIG); }
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
					if((_player.currentClip.isInStream && theScheduledStream.isRTMP() && AdSlot(theScheduledStream).isMidRoll()) == false) {
						// There seems to be a defect in the Flowplayer API - if we try to change the duration on an RTMP instream clip
						// it causes the player cuepoints to go crazy and results in the control bar ceasing to work and the play button
						// showing up when the ad stream has finished playing and the parent stream resumes - so the work around right now
						// is to not adjust the clip duration based on the meta data value and to use the default VAST duration

						if(theScheduledStream.hasZeroDuration()) {
							attemptCurrentStreamDurationAdjustment(theScheduledStream, newDuration);
						}
						else if(_vastController.deriveAdDurationFromMetaData()) {
							attemptCurrentStreamDurationAdjustment(theScheduledStream, newDuration);
						}
						else {
							CONFIG::debugging { doLog("Not adjusting the ad stream metadata - deriveAdDurationFromMetaData == false", Debuggable.DEBUG_CONFIG);	}
						}												
					}
					else {
						CONFIG::debugging { 
							doLog("Not adjusting Ad clip duration because a) it is a mid-roll using the FP Instream API and b) it is an RTMP stream which hits a bug in Flowplayer.", Debuggable.DEBUG_CONFIG);
							doLog("For more information on this issue, see http://www.longtailvideo.com/support/forums/open-video-ads/ova-for-flowplayer/15759/play-button-after-midroll", Debuggable.DEBUG_CONFIG);
						}
					}
				} 
				else if(theScheduledStream is Stream) {
					if(_vastController.deriveShowDurationFromMetaData()) {
						attemptCurrentStreamDurationAdjustment(theScheduledStream, newDuration, true);
					}	
					else { 
						var currentDurationString:String = String(Math.floor(_player.currentClip.duration));
						if(theScheduledStream.duration != currentDurationString) {
							CONFIG::debugging { doLog("Not adjusting the show stream metadata - 'deriveShowDurationFromMetaData' == false, but resetting stream duration (" + theScheduledStream.duration + ") to match clip (" + currentDurationString + "), and updating tracking points accordingly", Debuggable.DEBUG_CONFIG); }
							theScheduledStream.duration = currentDurationString;
							modifyTrackingCuepoints(_player.currentClip, theScheduledStream.getTrackingTable(), getActiveStreamIndex());
						}
						else {
							CONFIG::debugging { doLog("Not adjusting the show stream metadata - 'deriveShowDurationFromMetaData' == false and stream and clip duration match", Debuggable.DEBUG_CONFIG); }
						}
					}		
				}
				else {
					CONFIG::debugging { doLog("Not adjusting the stream duration based on the metadata - the clip is of an unknown type", Debuggable.DEBUG_CONFIG); }
				}				
			} 
			
			// The following is quite a bad hack, but it gets around the problem with on-demand ad slots that are empty after loading
			// causing autoPlay to break - the player just stops playing for some reason on receipt of the onMetaData event post the moveToNextClip() 

			if(_player.isPlaying() == false && _vastController.autoPlay()) {
				CONFIG::debugging { doLog("Forcibly triggering playback after onMetaData because the player is not playing and autoPlay='true'", Debuggable.DEBUG_CONFIG); }
				startPlayback();
			}
  		}

		protected function verifyPlayerMuteState():void {
			// Added for 3.2.8 where multiple onBeforeBegin events firing triggered an onMute to fire muting the player
			if(_forceMuteOfPlayer) {
				doLog("Forcibly muting on the player - a VPAID ad must have been muted", Debuggable.DEBUG_CONFIG);				
				_player.muted = true;
				_badMuteEventFired = false;
				_forceUnmuteOfPlayer = false;
				_forceMuteOfPlayer = false;
			}
			else if(_forceUnmuteOfPlayer) {
				doLog("Forcibly unmuting the player - a VPAID ad must have been unmuted", Debuggable.DEBUG_CONFIG);				
				_player.muted = false;
				_badMuteEventFired = false;
				_forceUnmuteOfPlayer = false;
				_forceMuteOfPlayer = false;
			}
			else if(_badMuteEventFired && (_playerShouldBeMuted == false)) {
				doLog("Forcibly unmuting the player - mute invalidly set by bad onMuteEvents", Debuggable.DEBUG_CONFIG);				
				_player.muted = false;
				_badMuteEventFired = false;
			}
		}
		
		protected function onStreamBegin(event:ClipEvent):void {
            _streamBeforeBegin = false;
			verifyPlayerMuteState();			
			_duplicateBeforeBeginEventCount = 0;
			// Added for 3.2.8
			if(_player.currentClip is HoldingClip) { 
				pausePlayback();
			}
			else {
				if(activeStreamIsShowStream()) {
					// Additional safety value to ensure that ad messages are always cleared out when show streams play
					resetPlayerDisplay();
				}
			}
		}

		protected function onStreamBeforeBegin(event:ClipEvent):void {
			if(_streamBeforeBegin) {
				// We have received another onBeforeBegin event before the onStreamBegin event fired and cleared the flag so ignore this extra event
			}
			
            _streamBeforeBegin = true;
			if(_lastOnBeforeBeginEvent != null) {
				if(_player.playlist.currentIndex == _lastOnBeforeBeginEvent.clipIndex) {
					// it's a duplicate event so ignore it
					CONFIG::debugging { doLog("Ignoring duplicate onBeforeBegin event for clip @ index " + _player.playlist.currentIndex, Debuggable.DEBUG_PLAYLIST); }
					_duplicateBeforeBeginEventCount++;
					verifyPlayerMuteState();			
					return;
				}
			}
			_lastOnBeforeBeginEvent = { clipIndex: _player.playlist.currentIndex, event: event };

			resetPlayerDisplay();
			
			if(_vastController != null) {
				if(_player.playlist.currentIndex == 0) {
					_vastController.processImpressionFiringForEmptyAdSlots();
				}
				var activeStream:Stream = getActiveStream();
				if(activeStream != null) {
					if(activeStream is AdSlot) {
						if(AdSlot(activeStream).loadOnDemand && AdSlot(activeStream).loading) {
							CONFIG::debugging { doLog("Ignoring onStreamBeforeBegin() - ad slot is in the process of loading", Debuggable.DEBUG_PLAYLIST); }
							return;
						}
						else if(AdSlot(activeStream).loadOnDemand && AdSlot(activeStream).requiresLoading()) {
							CONFIG::debugging { doLog("Linear ad clip @ index " + _player.playlist.currentIndex + " is about to be loaded (on demand)", Debuggable.DEBUG_PLAYLIST); }
							loadAdSlot(activeStream as AdSlot);
						}
						else if(AdSlot(activeStream).isInteractive()) {
							CONFIG::debugging { doLog("VPAID ad clip @ index " + _player.playlist.currentIndex + " is about to start playback", Debuggable.DEBUG_PLAYLIST); }
							playVPAIDAdSlot(AdSlot(getActiveStream()));
						}
						else if(AdSlot(activeStream).isMidRoll()) {
							CONFIG::debugging { doLog("Resetting the mid-roll AdSlot duration to 0 to force reset of the tracking events when the meta-data is received", Debuggable.DEBUG_PLAYLIST); }
							activeStream.duration = 0;
						}
						else if(_player.playlist.getClip(_player.playlist.currentIndex) is HoldingClip) {
							// The holding clip is still active, but the ad hasn't loaded so skip this clip
							CONFIG::debugging { doLog("Linear ad clip @ index " + _player.playlist.currentIndex + " does not appear to have successfully loaded - skipping this clip completely", Debuggable.DEBUG_PLAYLIST); }
							moveToNextClip();
						}
						else {
							CONFIG::debugging { doLog("Linear ad clip @ index " + _player.playlist.currentIndex + " is about to start playback - loadOnDemand=" + AdSlot(activeStream).loadOnDemand + ", requiresLoading=" + AdSlot(activeStream).requiresLoading(), Debuggable.DEBUG_PLAYLIST); }
						}
					}
					else {
						CONFIG::debugging { doLog("Show clip @ index " + _player.playlist.currentIndex + " is about to start playback", Debuggable.DEBUG_PLAYLIST);	}
					}					
				}
				else {
					CONFIG::debugging { doLog("FATAL: Cannot play NULL clip @ index " + _player.playlist.currentIndex, Debuggable.DEBUG_PLAYLIST);	}
				}	
			}
		}

		protected function onStreamFinish(event:ClipEvent):void {
			_vastController.closeActiveVPAIDAds();
			_lastOnBeforeBeginEvent = null;
			if(activeStreamIsLinearAd() == false && _player.playlist.currentIndex == (_player.playlist.length-1)) {
				dispatchEndPlaybackCallback({ type: "finish" });
			}
		}

		protected function dispatchEndPlaybackCallback(args:Object):void {
			_vastController.fireAPICall(
				"onOVAEndPlayback",
				args
			);
		}
		
		protected function onClipError(errorEvent:*):void {
			if(_vastController.config.playerConfig.processErrors) {
				CONFIG::debugging { doLog("Clip error " + errorEvent.error.code + ": " + errorEvent.error.message, Debuggable.DEBUG_PLAYLIST); }
				var activeStream:Stream = getActiveStream();

				_vastController.fireAPICall(
					"onLinearAdError", 
					{ 
						code: errorEvent.error.code, 
						message: errorEvent.error.message
					},
					((activeStream != null) ? activeStream.toJSObject() : null),
					_player.playlist.current 
				);

	        	if(activeStreamIsLinearAd()) {  
					_vastController.fireAdPlaybackAnalytics(AnalyticsProcessor.ERROR, AdSlot(activeStream), AdSlot(activeStream).videoAd);
					AdSlot(activeStream).fireErrorUrls("401");
	        		if(AdSlot(activeStream).shouldFailoverOnStreamError("Stream not found")) {
		        		CONFIG::debugging {
		        			doLog("Attempting to failover to the next ad tag after a stream error event - re-inserting HoldingClip", Debuggable.DEBUG_VAST_TEMPLATE);
		        			insertHoldingClipAtCurrentIndex(AdSlot(activeStream));
		        		}
						if(_vastController.attemptAdSlotFailoverOnDemand(AdSlot(activeStream)) == false) {
			        		CONFIG::debugging { 
			        			doLog("Cannot failover to another ad tag - all ad tag options have been explored - moving on..", Debuggable.DEBUG_VAST_TEMPLATE);
			        		}
						}
						else {
							return;
						}
	        		}
	        	}
				
				onLinearAdSkipped(null);				
			}
			else {
				CONFIG::debugging { doLog("Ignoring clip error " + errorEvent.error.code + ": " + errorEvent.error.message, Debuggable.DEBUG_ALWAYS); }
			}
		}

		protected function onPauseEvent(playlistEvent:ClipEvent):void {
        	if(_vastController != null) {
        		_vastController.onPlayerPause(getActiveStreamIndex(), isActiveLinearClipOverlay(), Timestamp.millisecondsToTimestamp(_player.currentClip.currentTime));
        	}
		}

		protected function onResumeEvent(playlistEvent:ClipEvent):void {
        	if(_vastController != null) {
        		_vastController.onPlayerResume(getActiveStreamIndex(), isActiveLinearClipOverlay(), Timestamp.millisecondsToTimestamp(_player.currentClip.currentTime));		
        	}	
		}

		protected function onBeforeSeekEvent(clipEvent:ClipEvent):void {
			if(_timeBeforeSeek < 0) {
				_timeBeforeSeek = _player.playlist.current.getNetStream().time;
			}
		}

        protected function onSeekEvent(clipEvent:ClipEvent):void {
        	if(_timeBeforeSeek > -1) {
				if(_vastController.config.adsConfig.enforceMidRollPlayback) {
					if(clipEvent.info < _player.playlist.current.duration) {
			    		if(activeStreamIsShowStream()) {
	    		   			var skippedMidRolls:Array = _vastController.getMidrollsForStreamBetween(getActiveStream().originatingStreamIndex, _timeBeforeSeek, Number(clipEvent.info));
		  					if(skippedMidRolls.length > 0) {
		    		   			CONFIG::debugging { doLog(skippedMidRolls.length + " mid-rolls skipped during this seek - triggering the playback of the first mid-roll", Debuggable.DEBUG_PLAYLIST); }
		  						playInstreamAd(skippedMidRolls[0], false);
				        		_timeBeforeSeek = -1;
		  						return;
	    					}				
	    				}
					}
				}
        		_timeBeforeSeek = -1;
        	}
        	if(_vastController != null) {
        		_vastController.onPlayerSeek(getActiveStreamIndex(), isActiveLinearClipOverlay(), int(clipEvent.info) * 1000);
        	}
        }

		protected function onMuteEvent(playerEvent:PlayerEvent):void {
			if(_wasZeroVolume == false && _playbackStarted == false && activeStreamIsLinearAd()) {
				// Deals with a specific case where two empty onDemand loaded pre-rolls result in a non-muted player 
				// muting when the show stream plays
				var activeStream:Stream = getActiveStream();
				if(AdSlot(activeStream).loadOnDemand && AdSlot(activeStream).loading) {
					doLog("Bad onMuteEvent fired during onDemand ad slot loading - ignoring", Debuggable.DEBUG_CONFIG);
					_badMuteEventFired = true;
					return;
				}
			}
			if(_wasZeroVolume == false && _playbackStarted) {
				// Check for bad mute cases
				
				if(_duplicateBeforeBeginEventCount > 0) {
					doLog("Bad onMuteEvent fired immediately after a duplicate onBeforeBegin event - this is a bad flowplayer bug", Debuggable.DEBUG_CONFIG);
					_badMuteEventFired = true;
					return;
				}
				
				if(_player.currentClip is HoldingClip) {
					doLog("Bad onMuteEvent fired on HoldingClip - looks to be a flowplayer bug - marking as a bad event", Debuggable.DEBUG_CONFIG);
					_badMuteEventFired = true;
					return;
				}
				
				if(_player.currentClip.startDispatched == false) {
					doLog("Bad onMuteEvent fired on clip before it's started - ignoring", Debuggable.DEBUG_CONFIG);
					_badMuteEventFired = true;
					return;
				}
				
				if(activeStreamIsShowStream() && _streamBeforeBegin) {
					doLog("Bad onMuteEvent fired on show clip before it's begun - ignoring", Debuggable.DEBUG_CONFIG);
					_badMuteEventFired = true;
					return;
				}				
			}		
			
			// Ok, all seems to be ok - this is a valid mute event so process it
			
			_playerShouldBeMuted = true;
        	
        	if(_vastController != null) {
        		_vastController.playerVolume = 0;
        		if(_vastController.isVPAIDAdPlaying()) {
        			var vpaidAd:IVPAID = _vastController.getActiveVPAIDAd();
        			if(vpaidAd != null) {
        				vpaidAd.adVolume = 0;
        			}
        		}
        		else {
	        		_vastController.onPlayerMute(getActiveStreamIndex(), isActiveLinearClipOverlay());
	        	}
        	}
		}

		protected function onStart(clipEvent:ClipEvent):void {
			_playbackStarted = true;
		}

		protected function onUnmuteEvent(playerEvent:PlayerEvent):void {
			if(_badMuteEventFired) {
				doLog("Ignoring unMute event - firing because mute has been reset after a bad mute event from Flowplayer 3.2.8 or greater", Debuggable.DEBUG_ALWAYS);
				return;
			}
			_playerShouldBeMuted = false;
        	if(_vastController != null) {
        		_vastController.playerVolume = getPlayerVolume(); 
        		if(_vastController.isVPAIDAdPlaying()) {
        			var vpaidAd:IVPAID = _vastController.getActiveVPAIDAd();
        			if(vpaidAd != null) {
        				vpaidAd.adVolume = getPlayerVolume(); 
        			}
        		}
        		else {
	        		_vastController.onPlayerUnmute(getActiveStreamIndex(), isActiveLinearClipOverlay());    			
        		}
        	}
		}
		
		protected function onPlayEvent(playerEvent:PlayerEvent):void {
        	if(_vastController != null) _vastController.onPlayerPlay(getActiveStreamIndex(), isActiveLinearClipOverlay());			
		}

		protected function onStopEvent(playerEvent:PlayerEvent):void {
        	if(_vastController != null) _vastController.onPlayerStop(getActiveStreamIndex(), isActiveLinearClipOverlay());
		}
		
		protected function onFullScreen(playerEvent:PlayerEvent):void {
        	if(_vastController != null) _vastController.onPlayerFullscreenEntry(getActiveStreamIndex(), isActiveLinearClipOverlay());
		}

		protected function onFullScreenExit(playerEvent:PlayerEvent):void {
        	if(_vastController != null) _vastController.onPlayerFullscreenExit(getActiveStreamIndex(), isActiveLinearClipOverlay());
		}

        protected function setActiveVPAIDAdVolume(volume:Number):void {
			var vpaidAd:IVPAID = _vastController.getActiveVPAIDAd();
			if(vpaidAd != null) {
	        	doLog("Setting the active VPAID ad volume to " + (volume / 100), Debuggable.DEBUG_VPAID);
				vpaidAd.adVolume = (volume / 100);
				_vastController.playerVolume = (volume / 100);
			}
        }
        
        protected function getPlayerVolume():Number {
        	return (_player.volume / 100);
        }
        
        protected function onProcessVolumeEvent(playerEvent:PlayerEvent):void {
        	if(_vastController != null) {
	        	if(_player.volume == 0) {
	        		_wasZeroVolume = true;
	        		onMuteEvent(playerEvent);
	        	}
	        	else {
	        		if(_wasZeroVolume) {
	        			onUnmuteEvent(playerEvent);
		        		_wasZeroVolume = false;
	        		}
	        		else {
		        		if(_vastController.isVPAIDAdPlaying()) {
		        			if(_player.muted == false) {
			        			var vpaidAd:IVPAID = _vastController.getActiveVPAIDAd();
			        			if(vpaidAd != null) {
			        				vpaidAd.adVolume = getPlayerVolume();
			        			}
		        			}
		        		}
	        		}
	        	}
        	}
        }

        /**
         * EXTERNAL JAVASCRIPT API
         * 
         **/ 
		
		[External]
	   	protected function getOVAPluginVersion():String {
	   		return "OVA for Flowplayer - " + OVA_VERSION;
	   	}

		[External]
		public function getVASTResponseAsString():* {	
			CONFIG::debugging { doLog("API call received to get VAST template as string", Debuggable.DEBUG_API); }
			return _vastController.getVASTResponseAsString();
		}

		[External]
		public function enableAds():* {
			CONFIG::debugging { doLog("not implemented", Debuggable.DEBUG_API);	}		
			return false
		}

		[External]
		public function disableAds():* {
			CONFIG::debugging { doLog("not implemented", Debuggable.DEBUG_API);	}		
			return false
		}

		[External]
		public function play():* {
			CONFIG::debugging { doLog("API call to start playback", Debuggable.DEBUG_API); }
	   		startPlayback();
			return true;	   		
		}

		[External]
		public function rewind():* {
			CONFIG::debugging { doLog("API call to rewind playlist", Debuggable.DEBUG_API); }
	   		this.resetPlayback();
			return true;	   		
		}

		[External]
		public function stop():* {
			if(_vastController != null) {
	   			if(activeClipIsVPAIDLinearAd()) {
	   				CONFIG::debugging { doLog("Stop VPAID ad", Debuggable.DEBUG_API); }
	   				_vastController.overlayController.getActiveVPAIDAd().stopAd();
	   				return true;
	   			}
	   			else if(activeStreamIsLinearAd()) {
	   				CONFIG::debugging { doLog("Stop Linear ad", Debuggable.DEBUG_API); }
	   				stopPlayback();
	   				return true;
	   			}
	   			else if(activeStreamIsShowStream()) {
	   				CONFIG::debugging { doLog("Stop show stream", Debuggable.DEBUG_API); }
	   				stopPlayback();
	   				return true;	   				
	   			}
	  		}
			return false
		}
	   	
		[External]
		public function pause():* {
	   		if(_vastController != null) {
	   			if(activeClipIsVPAIDLinearAd()) {
	   				CONFIG::debugging { doLog("Pausing VPAID ad", Debuggable.DEBUG_API); }
	   				_vastController.overlayController.getActiveVPAIDAd().pauseAd();
	   				return true;
	   			}
	   			else if(activeStreamIsLinearAd()) {
	   				CONFIG::debugging { doLog("Pausing Linear ad", Debuggable.DEBUG_API); }
	   				_player.pause();
	   				return true;
	   			}
	   			else if(activeStreamIsShowStream()) {
	   				CONFIG::debugging { doLog("Pausing show stream", Debuggable.DEBUG_API); }
	   				_player.pause();
	   				return true;	   				
	   			}
	   		}
			return false
		}

		[External]
		public function resume():* {
			if(_vastController != null) {
	   			if(activeClipIsVPAIDLinearAd()) {
	   				CONFIG::debugging { doLog("Resuming VPAID ad", Debuggable.DEBUG_API); }
	   				_vastController.overlayController.getActiveVPAIDAd().resumeAd();
	   				return true;
	   			}
	   			else if(activeStreamIsLinearAd()) {
	   				CONFIG::debugging { doLog("Resuming Linear ad", Debuggable.DEBUG_API); }
	   				_player.resume();
	   				return true;
	   			}
	   			else if(activeStreamIsShowStream()) {
	   				CONFIG::debugging { doLog("Resuming show stream", Debuggable.DEBUG_API); }
	   				_player.resume();
	   				return true;	   				
	   			}
	  		}
			return false
		}

		[External]
		public function getActiveAdDescriptor():* {
			if(_vastController != null) {
				if(activeStreamIsLinearAd()) {
					var activeStream:Stream = this.getActiveStream();
					if(activeStream != null) {
						if(activeStream is AdSlot) {
							if(AdSlot(activeStream).hasVideoAd()) {
								return AdSlot(activeStream).videoAd.toJSObject();
							}
						}				
					}
				}
			}
			return null;
		}
		
		[External]
		public function scheduleAds(playlist:*=null, newConfig:*=null):* {
			CONFIG::debugging { doLog("API call to reschedule playlist and ads...", Debuggable.DEBUG_API); }
			
			var previousShowsConfig:ShowsConfigGroup = null;
			if(playlist != null) {
				if(playlist is Array) {
					var formedPlaylist:Array = PlaylistConstructor.create(playlist, _player.playlist.commonClip);
					if(formedPlaylist != null) {
						CONFIG::debugging { doLog("Loading a new playlist (" + formedPlaylist.length + " clips) into the player before re-scheduling", Debuggable.DEBUG_API); }
						if(formedPlaylist.length > 0) {
							_player.playlist.replaceClips2(formedPlaylist);
						}
						else _player.playlist.replaceClips2(new Array());
					}
				}
	   			else {
	   				CONFIG::debugging { doLog("Cannot reschedule - the playlist provided is not in the correct format", Debuggable.DEBUG_API); }
	   				return false;
	   			}
			}
			else {
				CONFIG::debugging { doLog("Restoring the original playlist before re-scheduling", Debuggable.DEBUG_API); }
			    restoreOriginalPlaylist();
			}

			var config:Object=null;
			if(newConfig != null) {
		   		if(newConfig is String) {
		   			CONFIG::debugging { doLog("Loading new config data as String: " + newConfig, Debuggable.DEBUG_API); }
					try {
						config = com.adobe.serialization.json.JSON.decode(newConfig);
					}
					catch(e:Error) {
						CONFIG::debugging { doLog("OVA Configuration parsing exception on " + _player.version + " - " + e.message, Debuggable.DEBUG_API); }
						return false;
					}
		   		}
		   		else if(newConfig is Object) {
		   			CONFIG::debugging { doLog("Loading new config data as Object", Debuggable.DEBUG_API); }	
					config = newConfig;
		   		}
		   		else {
		   			CONFIG::debugging { doLog("Cannot initialise OVA with the provided config - it is not a String or Object", Debuggable.DEBUG_API); }
		   			return false;
		   		}
			}
			else config = _model.config;

			_vastController.closeActiveAdNotice();
			_vastController.closeActiveOverlaysAndCompanions();
			_vastController.closeActiveVPAIDAds();
			_vastController.hideAllRegions();

	   		initialiseVASTFramework(config);
			
			CONFIG::debugging { doLog("Rescheduling complete", Debuggable.DEBUG_JAVASCRIPT); }
			return true;
		}

		[External]
		public function loadPlaylist(playlist:Array, reschedule:Boolean=true):* {	
			CONFIG::debugging { doLog("Loading a new playlist...", Debuggable.DEBUG_API); }
			if(reschedule) {
				scheduleAds(playlist);
			}
			else _player.setPlaylist(playlist);
			return true;
		}

		[External]
		public function getAdSchedule():* {
			return _vastController.adSchedule.toJSObject();
		}

		[External]
		public function getStreamSequence():* {
			return _vastController.streamSequence.toJSObject();
		}

		[External]
		public function setDebugLevel(debugLevel:String):* {
			CONFIG::debugging { doLog("API call to set debug level to: " + debugLevel, Debuggable.DEBUG_API); }
			Debuggable.getInstance().setLevelFromString(debugLevel);
			return true;
		}

		[External]
		public function getDebugLevel():String {
			return _vastController.config.debugLevel;
		}

		[External]
		public function skipAd():* {
			if(_vastController != null) {
				CONFIG::debugging { doLog("API call to skip the ad", Debuggable.DEBUG_API); }
		   		onLinearAdSkipped(null);
			}
			return false;	   		
		}
		
		[External]
		public function clearOverlays():* {
   			CONFIG::debugging { doLog("Not implemented", Debuggable.DEBUG_API); }
			return false;	   		
		}
		
		[External]
		public function showOverlay(duration:int=-1, regionId:String="auto:bottom", adTag:String=null):* {
   			CONFIG::debugging { doLog("Not implemented", Debuggable.DEBUG_API); }
			return false;	   		
		}

		[External]
		public function hideOverlay(id:String):* {
   			CONFIG::debugging { doLog("Not implemented", Debuggable.DEBUG_API); }
			return false;	   		
		}		

		[External]
		public function enableJavascriptCallbacks():* {
   			CONFIG::debugging { doLog("Not implemented", Debuggable.DEBUG_API); }
			return false;	   		
		}

		[External]
		public function disableJavascriptCallbacks():* {
   			CONFIG::debugging { doLog("Not implemented", Debuggable.DEBUG_API); }
			return false;	   		
		}

        [External]
	   	public function setActiveLinearAdVolume(volume:Number):* {
	   		if(_vastController != null) {
	   			if(_vastController.isVPAIDAdPlaying()) {
	   				CONFIG::debugging { doLog("API call made to set the active VPAID ad volume to '" + volume + "'", Debuggable.DEBUG_API); }
	   				setActiveVPAIDAdVolume(volume);
	   				return true;
	   			}
	   			else if(activeStreamIsLinearAd()) {
	   				CONFIG::debugging { doLog("API call made to set the active linear ad volume to '" + volume + "'", Debuggable.DEBUG_API); }
	   				_player.volume = volume;
	   				_vastController.playerVolume = getPlayerVolume();
	   				return true;
	   			}
	   		}
	   		return false;
	   	}
	   	
	   	
        /**
         * DEBUG METHODS
         * 
         **/ 
	
		CONFIG::debugging
		protected function doLog(data:String, level:int=1):void {
			Debuggable.getInstance().doLog(data, level);
		}
		
		CONFIG::debugging
		protected function doTrace(o:Object, level:int=1):void {
			Debuggable.getInstance().doTrace(o, level);
		}
	}
}
