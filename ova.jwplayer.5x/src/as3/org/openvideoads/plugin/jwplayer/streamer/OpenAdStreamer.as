/*
 *    Copyright (c) 2010 LongTail AdSolutions, Inc
 *
 *    This file is part of the OVA for JW5x plugin.
 *
 *    The OVA for JW5x plugin is commercial software: you can redistribute it
 *    and/or modify it under the terms of the OVA Commercial License.
 *
 *    You should have received a copy of the OVA Commercial License along with
 *    the source code.  If not, see <http://www.openvideoads.org/licenses>.
 */
package org.openvideoads.plugin.jwplayer.streamer {
	import com.adobe.serialization.json.JSON;
	import com.longtailvideo.jwplayer.events.*;
	import com.longtailvideo.jwplayer.model.*;
	import com.longtailvideo.jwplayer.player.*;
	import com.longtailvideo.jwplayer.plugins.*;
	import com.longtailvideo.jwplayer.utils.RootReference;
	import com.longtailvideo.jwplayer.view.components.*;
	import com.longtailvideo.jwplayer.view.interfaces.*;
	
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.TimerEvent;
	import flash.external.ExternalInterface;
	import flash.system.Security;
	import flash.utils.Timer;
	import flash.utils.getQualifiedClassName;
	
	import org.openvideoads.base.Debuggable;
	import org.openvideoads.plugin.jwplayer.streamer.playlist.*;
	import org.openvideoads.util.ControlsSpecification;
	import org.openvideoads.util.DisplayProperties;
	import org.openvideoads.util.StringUtils;
	import org.openvideoads.util.Timestamp;
	import org.openvideoads.vast.VASTController;
	import org.openvideoads.vast.config.Config;
	import org.openvideoads.vast.config.ConfigLoadListener;
	import org.openvideoads.vast.config.groupings.VPAIDConfig;
	import org.openvideoads.vast.config.groupings.analytics.AnalyticsConfigGroup;
	import org.openvideoads.vast.config.groupings.analytics.google.GoogleAnalyticsConfigGroup;
	import org.openvideoads.vast.analytics.AnalyticsProcessor;
	import org.openvideoads.vast.events.AdNoticeDisplayEvent;
	import org.openvideoads.vast.events.AdSlotLoadEvent;
	import org.openvideoads.vast.events.AdTagEvent;
	import org.openvideoads.vast.events.CompanionAdDisplayEvent;
	import org.openvideoads.vast.events.LinearAdDisplayEvent;
	import org.openvideoads.vast.events.OVAControlBarEvent;
	import org.openvideoads.vast.events.OverlayAdDisplayEvent;
	import org.openvideoads.vast.events.TrackingPointEvent;
	import org.openvideoads.vast.events.VPAIDAdDisplayEvent;
	import org.openvideoads.vast.overlay.OverlayView;
	import org.openvideoads.vast.schedule.Stream;
	import org.openvideoads.vast.schedule.StreamSequence;
	import org.openvideoads.vast.schedule.ads.AdSlot;
	import org.openvideoads.vast.server.events.TemplateEvent;
	import org.openvideoads.vast.tracking.TimeEvent;
	import org.openvideoads.vpaid.IVPAID;
	    
	public class OpenAdStreamer extends Sprite implements IPlugin, ConfigLoadListener {
	    protected var _config:PluginConfig;	
    	protected var _player:IPlayer;		
		
        protected var _lastActiveStreamIndex:int = -2;
        protected var _lastPlayerPlaybackEvent:String = null;
        protected var _vastController:VASTController;
        protected var _playlist:JWPlaylist;
        protected var _resumingMainStreamPlayback:Boolean = false;
        protected var _timeOverlayLinearVideoAdTriggered:int = -1;
        protected var _activeOverlayAdSlotKey:int = -1;
        protected var _lastTimeTick:Number = 0;
	    protected var _forcedStop:Boolean = false;
	    protected var _needToDoStartPreProcessing:Boolean = true;
		protected var _playTimer:Timer = null;
		protected var _originalStretchingConfig:String = null;
		protected var _playerPaused:Boolean = false;
		protected var _splashImage:String = null;
		protected var _delayedInitialisation:Boolean = false;
		protected var _pendingVPAIDAdSlot:AdSlot = null;
		protected var _lastVisibilityStateForControls:Boolean = true;
		protected var _rawConfig:Object;
		protected var _streamTimer:Timer = null; 
		protected var _inFullscreenMode:Boolean = false;
		protected var _customLogoOriginalWidth:Number = -1;
		protected var _customLogoOriginalHeight:Number = -1;
		protected var _customLogoHandle:MovieClip = null;
		protected var _ovaLoadedPlaylistInTransit:Array = null;
		protected var _initialiseCount:int = 0;
		protected var _lockCounter:int = 0;
		protected var _ovaLastModifiedPlaylist:Boolean = false;
		protected var _lastPlaylistClipComplete:int = -1;
		protected var _startupClipIndex:int = -1;
		protected var _lastMetaDataDurationEvent:Object = { duration: 0, file: null };
		protected var _playerReportedControlBarHeight:Number = -1;
		protected var _instreamEnabled:Boolean = false;
		protected var _showingBusyState:Boolean = false;
		protected var _repeatPlaybackContinuously:Boolean = false;
		protected var _v4ControlBarLocked:Boolean = false;

		protected static const OVA_JW5_DEFAULT_GA_ACCOUNT_ID:String = "UA-4011032-6";

		protected static const OVA_INDEX_AT_STARTUP:int = -2;
	    
	    public static const OVA_VERSION:String = "v1.3.0 RC1 (Build 37)";

	    CONFIG::debugging { 
		    public static const _buildVersion:String = "OVA for JW5 - " + OVA_VERSION + " [Debug Version]";
	    }
	    CONFIG::release { 
		    public static const _buildVersion:String = "OVA for JW5 - " + OVA_VERSION + " [Release Version]";
	    }

		public function OpenAdStreamer():void {
			super();
		}
		
	    public function initPlugin(player:IPlayer, conf:PluginConfig):void {
	    	Security.allowDomain("*");

	        _player = player;
    	    _config = conf;

			lockTimelineOnControlBar();
			_instreamEnabled = isAtLeastJW59();
			_repeatPlaybackContinuously = (_player.config.repeat == "always");

    	    if(((StringUtils.isEmpty(_player.config.file) == false) || (StringUtils.isEmpty(_player.config.playlistfile) == false) || _player.config.playlist.length > 0) && _config.blockuntiloriginalplaylistloaded == true) {
    	    	try {
	    	    	ExternalInterface.call("console.log", "Blocking until the PLAYLIST_LOADED event has been received");
	    	    }
	    	    catch(e:Error) {}
				_player.addEventListener(PlaylistEvent.JWPLAYER_PLAYLIST_LOADED, onOriginalPlaylistLoaded);
    	    }
    	    else {
    	    	initialise();
    	    }

			registerExternalAPI();
	    }

	   	public function get id():String { return (_config != null) ? _config.id : "ova-jw"; }

		protected function abortOVAStartup():void {
			CONFIG::debugging { doLog("OVA startup aborted.", Debuggable.DEBUG_CONFIG); }
			unlockPlayer();
		}

		public function initialised():Boolean {
			return false;
		}
		
		protected function playlistHasSplashImage():Boolean {
			if(!StringUtils.isEmpty(_player.config.image)) {	
				return true;	
			}
			else if(_player.playlist.length > 0) {
				if(!StringUtils.isEmpty(com.longtailvideo.jwplayer.model.PlaylistItem(_player.playlist.getItemAt(0)).image)) {
					return true;
				}
			}
			
			return false;
		}
		
		protected function setDefaultPlayerConfigGroup(anchorNonLinearToBottom:Boolean=false):void {
			var controlBarHeight:Number = getPlayerReportedControlBarHeight();
			var controlBarYPosition:Number = getControlBarYPosition();
			var controlBarIsSkinned:Boolean = controlBarIsSkinned();
			_vastController.setDefaultPlayerConfigGroup(
				{
					width: _player.config.width, 
					height: _player.config.height, 
					controls: { 
						height: controlBarHeight
					},
					modes: {
					   linear: {
                         hideLogo: false,
	                     margins: {
	                        normal: {
	                           withControls: (controlBarIsAtOverPosition() ? (_player.config.height - controlBarYPosition) : 0),
	                           withControlsOverride: (controlBarIsSkinned ? (_player.config.height - controlBarYPosition) : 0),
	                           withoutControls: 0,
	                           withoutControlsOverride: 0
	                        },
	                        fullscreen: {
	                           withControls: (controlBarIsSkinned ? controlBarHeight : 0),
	                           withControlsOverride: (controlBarIsSkinned ? controlBarHeight : 0),
	                           withoutControls: 0,
	                           withoutControlsOverride: 0
	                        }
 	                     },
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
 	                     	normal: {
	                           withControls: ((anchorNonLinearToBottom) ? 0 : (controlBarIsAtOverPosition() ? (_player.config.height - controlBarYPosition) : 0)),
	                           withControlsOverride: ((anchorNonLinearToBottom) ? 0 : (controlBarIsSkinned ? (_player.config.height - controlBarYPosition) : 0)),
	                           withoutControls: 0,
	                           withoutControlsOverride: 0
 	                     	},
	                        fullscreen: {
	                           withControls: ((anchorNonLinearToBottom) ? 0 : (controlBarIsSkinned ? controlBarHeight : 46)),
	                           withControlsOverride: ((anchorNonLinearToBottom) ? 0 : (controlBarIsSkinned ? controlBarHeight : 0)),
	                           withoutControls: 0,
	                           withoutControlsOverride: 0
	                        }
	                     }
                      }
				   }
				}
			);
		}
		
		protected function getNewEmptyConfigWithDefaults():Config {
			var newConfig:Config = new Config();
			newConfig.playerConfig = _vastController.getDefaultPlayerConfig();
            newConfig.analytics.update(
        		[
        			{ 
        				type: AnalyticsConfigGroup.GOOGLE_ANALYTICS,
        				element: GoogleAnalyticsConfigGroup.OVA,
        				displayObject: this,
            			analyticsId: OVA_JW5_DEFAULT_GA_ACCOUNT_ID,
						impressions: {
							enable: true,
							linear: "/ova/impression/jw5?ova_format=linear",
							nonLinear: "/ova/impression/jw5?ova_format=non-linear",
							companion: "/ova/impression/jw5?ova_format=companion"
						},
						adCalls: {
							enable: false,
							fired: "/ova/ad-call/jw5?ova_action=fired",
							complete: "/ova/ad-call/jw5?ova_action=complete",
							failover: "/ova/ad-call/jw5?ova_action=failover",
							error: "/ova/ad-call/jw5?ova_action=error",
							timeout: "/ova/ad-call/jw5?ova_action=timeout",
							deferred: "/ova/ad-call/jw5?ova_action=deferred"
						},
						template: {
							enable: false,
							loaded: "/ova/template/jw5?ova_action=loaded",
							error: "/ova/template/jw5?ova_action=error",
							timeout: "/ova/template/jw5?ova_action=timeout",
							deferred: "/ova/template/jw5?ova_action=deferred"
						},
						adSlot: {
							enable: false,
							loaded: "/ova/ad-slot/jw5?ova_action=loaded",
							error: "/ova/ad-slot/jw5?ova_action=error",
							timeout: "/ova/ad-slot/jw5?ova_action=timeout",
							deferred: "/ova/ad-slot/jw5?ova_action=deferred"
						},
						progress: {
							enable: false,
							start: "/ova/progress/jw5?ova_action=start",
							stop: "/ova/progress/jw5?ova_action=stop",
							firstQuartile: "/ova/progress/jw5?ova_action=firstQuartile",
							midpoint: "/ova/progress/jw5?ova_action=midpoint",
							thirdQuartile: "/ova/progress/jw5?ova_action=thirdQuartile",
							complete: "/ova/progress/jw5?ova_action=complete",
							pause: "/ova/progress/jw5?ova_action=pause",
							resume: "/ova/progress/jw5?ova_action=resume",
							fullscreen: "/ova/progress/jw5?ova_action=fullscreen",
							mute: "/ova/progress/jw5?ova_action=mute",
							unmute: "/ova/progress/jw5?ova_action=unmute",
							expand: "/ova/progress/jw5?ova_action=expand",
							collapse: "/ova/progress/jw5?ova_action=collapse",
							userAcceptInvitation: "/ova/progress/jw5?ova_action=userAcceptInvitation",
							close: "/ova/progress/jw5?ova_action=close"
						},
						clicks: {
							enable: false,
							linear: "/ova/clicks/jw5?ova_action=linear",
							nonLinear: "/ova/clicks/jw5?ova_action=nonLinear",
							vpaid: "/ova/clicks/jw5?ova_action=vpaid"
						},
						vpaid: {
							enable: false,
							loaded: "/ova/vpaid/jw5?ova_action=loaded",
							started: "/ova/vpaid/jw5?ova_action=started",
							complete: "/ova/vpaid/jw5?ova_action=complete",
							stopped: "/ova/vpaid/jw5?ova_action=stopped",
							linearChange: "/ova/vpaid/jw5?ova_action=linearChange",
							expandedChange: "/ova/vpaid/jw5?ova_action=expandedChange",
							remainingTimeChange: "/ova/vpaid/jw5?ova_action=remainingTimeChange",
							volumeChange: "/ova/vpaid/jw5?ova_action=volumeChange",
							videoStart: "/ova/vpaid/jw5?ova_action=videoStart",
							videoFirstQuartile: "/ova/vpaid/jw5?ova_action=videoFirstQuartile",
							videoMidpoint: "/ova/vpaid/jw5?ova_action=videoMidpoint",
							videoThirdQuartile: "/ova/vpaid/jw5?ova_action=videoThirdQuartile",
							videoComplete: "/ova/vpaid/jw5?ova_action=videoComplete",
							userAcceptInvitation: "/ova/vpaid/jw5?ova_action=userAcceptInvitation",
							userClose: "/ova/vpaid/jw5?ova_action=userClose",
							paused: "/ova/vpaid/jw5?ova_action=paused",
							playing: "/ova/vpaid/jw5?ova_action=playing",
							error: "/ova/vpaid/jw5?ova_action=error",
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
  
		public function initialise(predefinedPlaylist:*=null, overrideDelayAdRequestConfig:Boolean=false):void {
			removeAllPlayerEventListeners();
			
			_rawConfig = null;
		    _ovaLastModifiedPlaylist = false;
		    _lastPlaylistClipComplete = -1;

			if(_config.json == null && _config.tag != null) {
				// Minimal setup of a VAST ad tag via the "tag" variable
				_config.json = '{' +
					             ' "ads": { ' +
					             '     "companions": {' +
					             '        "regions": [' + 
					             '           { "id":"companion-300x250", "width":"300", "height":"250" }' +
					             '        ]' +
					             '     },' +
					             '     "restoreCompanions": false,' +
					             '     "schedule": [' +
				                 '         {' +
				                 '            "position": "pre-roll",' +
				                 '            "server": {' +
				                 '                "type": "direct",' +
				                 '                "tag": "' + _config.tag + '"' +
				                 '            }' +
					             '         }' +
					             '     ]' +   
					             ' }';
				if(_config.debug != null) {
					_config.json += ', "debug": { "levels": "' + _config.debug + '" }';
				}
				else _config.json += ', "debug": { "levels": "fatal, config, vast_template, vpaid" }';
				if(_config.delayadrequestuntilplay != null) _config.json += ', "delayAdRequestUntilPlay": ' + _config.delayadrequestuntilplay;				
				if(_config.autoplay != null) _config.json += ', "autoPlay": ' + _config.autoplay;
				if(_config.clearplaylist != null) {
					_config.json += ', "clearPlaylist": ' + _config.clearplaylist;
				}
				else if((_config.delayadrequestuntilplay == true) && playlistHasSplashImage()) {
					// if nothing has been specified in terms of clearing the playlist and we are delaying the ad request, and there
					// is a splash image make sure that the original playlist is not cleared (removing the splash image)
					_config.json += ', "clearPlaylist": false';
				}
				if(_config.allowplaylistcontrol != null) _config.json += ', "allowPlaylistControl": ' + _config.allowplaylistcontrol; 
				_config.json += '}';
				_config.tag = null;
			}
			if(_config.json == null && _config.vast != null) {
				// Direct injection of the VAST data via the "vast" variable - assume pre-roll configuration
				_config.json = '{' +
					             ' "ads": { ' +
					             '     "schedule": [' +
				                 '         {' +
				                 '            "position": "pre-roll",' +
				                 '            "server": {' +
				                 '                "type": "inject",' +
				                 '                "tag": "' + _config.vast + '"' +
				                 '            }' +
					             '         }' +
					             '     ]' +   
					             ' }';
				if(_config.debug != null) _config.json += ', "debug": { "debugger": "firebug", "levels": "' + _config.debug + '" }';
				if(_config.delayadrequestuntilplay != null) _config.json += ', "delayAdRequestUntilPlay": ' + _config.delayadrequestuntilplay;
				if(_config.autoplay != null) _config.json += ', "autoPlay": ' + _config.autoplay;
				if(_config.clearplaylist != null) {
					_config.json += ', "clearPlaylist": ' + _config.clearplaylist;
				}
				else if((_config.delayadrequestuntilplay == true) && playlistHasSplashImage()) {
					// if nothing has been specified in terms of clearing the playlist and we are delaying the ad request, and there
					// is a splash image make sure that the original playlist is not cleared (removing the splash image)
					_config.json += ', "delayAdRequestUntilPlay": false';
				}
				if(_config.allowplaylistcontrol != null) _config.json += ', "allowPlaylistControl": ' + _config.allowplaylistcontrol; 
				_config.json += '}';
				_config.vast = null;
			}
			if(_config.json != undefined) {			
				// Load up the config which is defined as a json string
				try {
					_rawConfig = com.adobe.serialization.json.JSON.decode(_config.json, false);		
				}
				catch(e:Error) {
					CONFIG::debugging { doLog("OVA Configuration parsing exception on " + _player.version + " - " + e.message, Debuggable.DEBUG_ALWAYS); }
					abortOVAStartup();
					return;
				}
				if(_config.tag != null) {
					if(_rawConfig == null) {
						_rawConfig = { tag: _config.tag };	
					}
					else _rawConfig.tag = _config.tag;
				}
			}
			else if(_config.ads != undefined || _config.debug != undefined) {
				if(StringUtils.convertStringToNumber(getCleanPlayerVersionNumber(), 1000) > 560000) {
					_rawConfig = _config;
					CONFIG::debugging { doLog("Successfully loaded config as an embedded JSON object (player is JW " + _player.version + ")", Debuggable.DEBUG_CONFIG); }
				}
				else {
					CONFIG::debugging { doLog("Sorry, direct configuration of the OVA data as an object is not currently supported in JW " + _player.version, Debuggable.DEBUG_CONFIG); }
					abortOVAStartup();
				}
			}
						
			if(_rawConfig != null) {
				// check case sensitivity - JW5.6 converts top level variables names to lower case so this section
				// converts them back to the right case sensitivity so they are picked up below
				if(_rawConfig.supportexternalplaylistloading != undefined) _rawConfig.supportExternalPlaylistLoading = _rawConfig.supportexternalplaylistloading;
				if(_rawConfig.autoplayonexternalload != undefined) _rawConfig.autoPlayOnExternalLoad = _rawConfig.autoplayonexternalload;				
				if(_rawConfig.ignoredefaultsplashimage != undefined) _rawConfig.ignoreDefaultSplashImage = _rawConfig.ignoredefaultsplashimage;
				if(_rawConfig.delayadrequestuntilplay != undefined) _rawConfig.delayAdRequestUntilPlay = _rawConfig.delayadrequestuntilplay;
				if(_rawConfig.autoplay != undefined) _rawConfig.autoPlay = _rawConfig.autoplay;
				if(_rawConfig.clearplaylist != undefined) _rawConfig.clearPlaylist = _rawConfig.clearplaylist;
				if(_rawConfig.allowplaylistcontrol != undefined) _rawConfig.allowPlaylistControl = _rawConfig.allowplaylistcontrol;
				if(_rawConfig.canfireapicalls != undefined) _rawConfig.canFireAPICalls = _rawConfig.canfireapicalls;
				if(_rawConfig.canfireeventapicalls != undefined) _rawConfig.canFireEventAPICalls = _rawConfig.canfireeventapicalls;
				if(_rawConfig.removefileextension != undefined) _rawConfig.removeFileExtension = _rawConfig.removefileextension;
				if(_rawConfig.usev2apicalls != undefined) _rawConfig.useV2APICalls = _rawConfig.usev2apicalls;
				
				// now set any defaults if not configured manually within OVA config
				
				if(_rawConfig.debug == undefined) _rawConfig.debug = { "levels": "fatal, config" };
				Debuggable.getInstance().configure(_rawConfig.debug);
				if(_rawConfig.ignoreDefaultSplashImage == undefined) {
					_rawConfig.ignoreDefaultSplashImage = false;
				}
				else if(_rawConfig.ignoreDefaultSplashImage is String) {
					_rawConfig.ignoreDefaultSplashImage = (_rawConfig.ignoreDefaultSplashImage.toUpperCase() == "TRUE");
				}
				if(_rawConfig.delayAdRequestUntilPlay == undefined) {
					_rawConfig.delayAdRequestUntilPlay = false;
				}
				else if(_rawConfig.delayAdRequestUntilPlay is String) {
					_rawConfig.delayAdRequestUntilPlay = (_rawConfig.delayAdRequestUntilPlay.toUpperCase() == "TRUE");
				}
				if((_rawConfig.clearPlaylist || (_rawConfig.clearPlaylist == undefined)) && _rawConfig.allowPlaylistControl) {
					// overriding clear playlist because allowPlaylistControl is turned on - these conflict
					_rawConfig.clearPlaylist = false;
					CONFIG::debugging { doLog("Have overridden 'clearPlaylist: true' (default) option because 'allowPlaylistControl' is turned on", Debuggable.DEBUG_CONFIG); }
				}
				if((_rawConfig.clearPlaylist || (_rawConfig.clearPlaylist == undefined)) && _rawConfig.delayAdRequestUntilPlay == true && playlistHasSplashImage()) {
					// if nothing has been specified in terms of clearing the playlist and we are delaying the ad request, and there
					// is a splash image make sure that the original playlist is not cleared (removing the splash image)
					_rawConfig.clearPlaylist = false;
					CONFIG::debugging { doLog("Have overridden 'clearPlaylist: true' (default) option because the ad request is delayed and there is a splash image", Debuggable.DEBUG_CONFIG); }
				}
				if(_rawConfig.autoPlay == undefined) {
					_rawConfig.autoPlay = false;
				}
				else if(_rawConfig.autoPlay is String) {
					_rawConfig.autoPlay = (_rawConfig.autoPlay.toUpperCase() == "TRUE");
				}
				if(_player.config.autostart) {
					_rawConfig.autoPlay = true;
					_player.config.autostart = (_player.config.repeat == "always");
					CONFIG::debugging { doLog("autoPlay set to true as 'autostart' flashvar specified - endless looping = " + _player.config.autostart, Debuggable.DEBUG_CONFIG); }
				}
				CONFIG::debugging { doLog(_buildVersion + " - player is " + _player.version, Debuggable.DEBUG_ALL); }
				CONFIG::release { 
					try {
						if(Debuggable.getInstance().printing()) ExternalInterface.call("console.log", _buildVersion + " - player is " + _player.version); 
					}
					catch(e:Error) {}
				}
				if(_config.json != undefined) {
					CONFIG::debugging { doLog("Config loaded from 'json' string as " + _config.json, Debuggable.DEBUG_CONFIG); }
				}
				else {
					CONFIG::debugging { doLog("Config loaded directly from config object - trace follows:", Debuggable.DEBUG_CONFIG); }
					CONFIG::debugging { doTrace(_rawConfig, Debuggable.DEBUG_ALL); }
				}
			}
			else {
				_rawConfig = {
					json: null,
					tag: null,
					debug: null
				};
				Debuggable.getInstance().configure({"levels":"fatal, config"});
				CONFIG::debugging { doLog(_buildVersion + " - player is " + _player.version, Debuggable.DEBUG_ALL); }
				CONFIG::release { 
					try {
						ExternalInterface.call("console.log", _buildVersion + " - player is " + _player.version); 
					}
					catch(e:Error) {}
				}
				CONFIG::debugging { doLog("No OVA configuration provided - ad streamer will not be capable of playing any ads", Debuggable.DEBUG_CONFIG); }
				abortOVAStartup();
				return;
			}

			if(_config.tagparams != undefined && _config.tagparams != null) {
				// tag properties allow the "customProperties" element of an ad server configuration to be passed through
				_rawConfig.tagParams = StringUtils.convertStringToObject(_config.tagparams, ",", ":");
				CONFIG::debugging { doLog("Additional Ad Tag Parameters have been specified - they will be added to the ad request(s)", Debuggable.DEBUG_CONFIG);	}			
			}
			
			_vastController = new VASTController();
			_vastController.startStreamSafetyMargin = 100;
			_vastController.endStreamSafetyMargin = 300;
			_vastController.playerVolume = (_player.config["mute"]) ? 0 : getPlayerVolume();
			_vastController.additionMetricsParams = "ova_plugin_version=" + OVA_VERSION + "&ova_player_version=" + _player.version;
			_vastController.jsCallbackScopingPrefix = "jwplayer('" + _player.config.id + "').getPlugin('ova').";

			var anchorNonLinearToBottom:Boolean = false;
			if(_rawConfig.hasOwnProperty("player")) {
				if(_rawConfig.player.hasOwnProperty("controls")) {
					if(_rawConfig.player.controls.hasOwnProperty("vpaid")) {
						if(_rawConfig.player.controls.vpaid.hasOwnProperty("anchorNonLinearToBottom")) {
							anchorNonLinearToBottom = StringUtils.validateAsBoolean(_rawConfig.player.controls.vpaid.anchorNonLinearToBottom);
						}
					}
				}
			}
			setDefaultPlayerConfigGroup(anchorNonLinearToBottom); 

			if(_rawConfig.ads != undefined) {
				// set the default mime types allowed - can be overridden in config with "acceptedLinearAdMimeTypes" and "filterOnLinearAdMimeTypes"
				if(_rawConfig.ads.filterOnLinearAdMimeTypes == undefined) {
					CONFIG::debugging { doLog("Setting accepted Linear Ad mime types to default list - swf, mp4 and flv", Debuggable.DEBUG_CONFIG); }
					_rawConfig.ads.acceptedLinearAdMimeTypes = [ "video/flv", "video/mp4", "video/x-flv", "video/x-mp4", "application/x-shockwave-flash", "flv", "mp4", "swf" ];
					_rawConfig.ads.filterOnLinearAdMimeTypes = true;
				}
				else {
					CONFIG::debugging { doLog("Setting accepted Linear Ad mime types and enabled state = " + _rawConfig.ads.filterOnLinearAdMimeTypes, Debuggable.DEBUG_CONFIG); }
				}
			}

            _splashImage = null;
            
            if(predefinedPlaylist == null) {
				loadExistingPlaylist(_rawConfig);	
            }
            else {
            	CONFIG::debugging { doLog("Configuring OVA with a previously declared playlist - " + predefinedPlaylist.length, Debuggable.DEBUG_CONFIG); }
            	_rawConfig.shows = predefinedPlaylist;
            }
			
			if(playlistHasSplashImage() && _splashImage == null) {
				if(_player.playlist.getItemAt(0) != null) {
					_splashImage = com.longtailvideo.jwplayer.model.PlaylistItem(_player.playlist.getItemAt(0)).image;
					CONFIG::debugging { doLog("The splash image has been derived from the first playlist clip - '" + _splashImage + "'", Debuggable.DEBUG_CONFIG);	}				
				}
				else {
					if(StringUtils.isEmpty(_player.config.image) == false) {
						_splashImage = _player.config.image;
						CONFIG::debugging { doLog("The splash image has been set from the config to '" + _splashImage + "'", Debuggable.DEBUG_CONFIG); }
					}
				}
			}

			if(_rawConfig.allowPlaylistControl) {
				CONFIG::debugging { 
					doLog("Playlist control has been turned on via 'allowPlaylistControl:true'", Debuggable.DEBUG_CONFIG); 
					if(_repeatPlaybackContinuously) {
						doLog("Continuous repeat has been enabled via 'repeat':'always'", Debuggable.DEBUG_CONFIG);
					}				
				}
			}

			if(_rawConfig.delayAdRequestUntilPlay && !_rawConfig.autoPlay && !overrideDelayAdRequestConfig) {
				setupPlayerToDelayInitialisation();
			}
			else {
				_vastController.initialise(_rawConfig, false, this, getNewEmptyConfigWithDefaults());
			}				
		}

        /**
         * DELAYED LOAD PLAYER EVENT HANDLERS
         * 
         **/ 

		protected function setupPlayerToDelayInitialisation():void {
			CONFIG::debugging { doLog("Holding on initialising the VASTController until the Play button is pressed", Debuggable.DEBUG_CONFIG); }
			addDelayedPlayerEventListeners();
		}

		protected function addDelayedPlayerEventListeners():void {
			_delayedInitialisation = true;
			_player.addEventListener(ViewEvent.JWPLAYER_VIEW_ITEM, onPlaylistItemSelectWithDelayedInitialisation);
			_player.addEventListener(ViewEvent.JWPLAYER_VIEW_PLAY, onPlayEventWithDelayedInitialisation);
			_player.addEventListener(ViewEvent.JWPLAYER_VIEW_NEXT, onNextPlaylistItemWithDelayedInitialisation);
			_player.addEventListener(ViewEvent.JWPLAYER_VIEW_PREV, onPreviousPlaylistItemWithDelayedInitialisation);
			_player.addEventListener(PlayerStateEvent.JWPLAYER_PLAYER_STATE, onPlayerStateChangeEventWithDelayedInitialisation);			
			_player.addEventListener(MediaEvent.JWPLAYER_MEDIA_TIME, timeHandlerWithDelayedInitialisation);
			_player.addEventListener(PlaylistEvent.JWPLAYER_PLAYLIST_LOADED, onPlaylistLoadedWithDelayedInitialisationEvent);
			CONFIG::debugging { doLog("Delayed ad request player event handlers configured", Debuggable.DEBUG_PLAYLIST); }
		}
			
		protected function removeDelayedPlayerEventListeners():void {
			_player.removeEventListener(ViewEvent.JWPLAYER_VIEW_ITEM, onPlaylistItemSelectWithDelayedInitialisation);
			_player.removeEventListener(ViewEvent.JWPLAYER_VIEW_PLAY, onPlayEventWithDelayedInitialisation);
			_player.removeEventListener(ViewEvent.JWPLAYER_VIEW_NEXT, onNextPlaylistItemWithDelayedInitialisation);
			_player.removeEventListener(ViewEvent.JWPLAYER_VIEW_PREV, onPreviousPlaylistItemWithDelayedInitialisation);
			_player.removeEventListener(PlayerStateEvent.JWPLAYER_PLAYER_STATE, onPlayerStateChangeEventWithDelayedInitialisation);
			_player.removeEventListener(MediaEvent.JWPLAYER_MEDIA_TIME, timeHandlerWithDelayedInitialisation);
			CONFIG::debugging { doLog("Delayed ad request player event handlers removed", Debuggable.DEBUG_PLAYLIST); }
		}

        protected function onPlaylistItemSelectWithDelayedInitialisation(evt:ViewEvent):void {
        	CONFIG::debugging { doLog("User has selected a specific playlist item @ index '" + evt.data + "' during delayed initialisation - current playlist index is '" + _player.playlist.currentIndex + "'", Debuggable.DEBUG_PLAYLIST); }
			onPlayEventWithDelayedInitialisation(evt);
        }
        
		protected function onPlayEventWithDelayedInitialisation(evt:ViewEvent):void {
			if(evt != null) {
				CONFIG::debugging { doLog("Play event ('" + evt.type + "') triggered during delayed initialisation - requesting playback of clip '" + evt.data + "', current playlist index is '" + _player.playlist.currentIndex + "'", Debuggable.DEBUG_PLAYLIST); }
				recordLastPlayerPlaybackEvent(ViewEvent.JWPLAYER_VIEW_ITEM);
				if(evt.data != _player.playlist.currentIndex) {
					setDelayedStartupClipIndex(evt.data);
				}
			}
			else {
				CONFIG::debugging { doLog("Play event triggered during delayed initialisation - current playlist index is '" + _player.playlist.currentIndex + "'", Debuggable.DEBUG_PLAYLIST); }
			}
			
			signalDelayedInitialisationOver();
			
			// clear out the playlist if we are operating in clip-by-clip loading mode
			if(justStarted() &&
			   (_player.playlist.length > 0) &&
			   ((_rawConfig.allowplaylistcontrol == undefined && _rawConfig.allowPlaylistControl == undefined) ||
			   (_rawConfig.allowplaylistcontrol == false || _rawConfig.allowPlaylistControl == false))) {
			   	CONFIG::debugging { doLog("Forcibly clearing the loaded on delayed startup because we are not in 'clip-by-clip' load mode but have a playlist in the player", Debuggable.DEBUG_PLAYLIST); }
				clearPlaylist();
			} 
			
			var _loadListener:ConfigLoadListener = this;
			lockPlayer( 
				"Player lock requested - triggering deferred initialisation of the VASTController",
				function():void {
					_player.removeEventListener(ViewEvent.JWPLAYER_VIEW_PLAY, onPlayEventWithDelayedInitialisation);
					_vastController.initialise(_rawConfig, false, _loadListener, getNewEmptyConfigWithDefaults());
				}
			);
		}

		protected function setDelayedStartupClipIndex(newIndex:int):void {
			if(_rawConfig.allowPlaylistControl && newIndex > 0) {  
				_startupClipIndex = newIndex;
				CONFIG::debugging { doLog("Delayed startup clip index has been set to '" + _startupClipIndex + "'", Debuggable.DEBUG_PLAYLIST); }
			}
			else resetDelayedStartupClipIndex();
		}
		
		protected function getDelayedStartupClipIndex():int {
			return _startupClipIndex;
		}

		protected function hasDelayedStartupClipIndex():Boolean {
			return (_startupClipIndex > -1);
		}

        protected function getMappedDelayStartupClipIndex():int {
        	if(hasDelayedStartupClipIndex() && _playlist != null) {
        		if(_playlist.length > 0) {
        			// Find the clip in the OVA generated playlist that maps to the original clip that was selected
        			var clipCounter:int = 0;
        			for(var i:int=0; i < _playlist.length; i++) {
        				if(_playlist.getTrackAtIndex(i).isAd()) {
        					// we are not interested in it
        				}
        				else {
        					if(clipCounter == _startupClipIndex) {
        						CONFIG::debugging { doLog("Have identified the stream at OVA playlist index '" + i + "' as a match for original player playlist index '" + _startupClipIndex + "'", Debuggable.DEBUG_PLAYLIST); }
        						return i;
        					}
        					++clipCounter;
        				}
        			}
        		}
	        	CONFIG::debugging { doLog("Cannot map the startup clip index '" + _startupClipIndex + "' to an item in the OVA scheduled playlist", Debuggable.DEBUG_PLAYLIST); }
        	}
			else {
				CONFIG::debugging { doLog("Cannot map the startup clip index '" + _startupClipIndex + "' to an item in the OVA scheduled playlist - is _playlist null?", Debuggable.DEBUG_PLAYLIST); }
			}

        	return 0;
        }
        
        protected function resetDelayedStartupClipIndex():void {
        	_startupClipIndex = -1;
        }

		protected function onPlayerStateChangeEventWithDelayedInitialisation(evt:PlayerStateEvent):void {
			CONFIG::debugging { doLog("Player state change event received during delayed initialisation - " + evt.oldstate + " to " + evt.newstate + " playlist index is " + _player.playlist.currentIndex, Debuggable.DEBUG_PLAYLIST); }
			if(evt.oldstate == "IDLE" && evt.newstate == "BUFFERING") {
				// going from not-playing to playing so act as though the play button has been pressed
				onPlayEventWithDelayedInitialisation(new ViewEvent(ViewEvent.JWPLAYER_VIEW_PLAY));
			}
		}

		protected function onNextPlaylistItemWithDelayedInitialisation(evt:ViewEvent):void {
			CONFIG::debugging { doLog("Next playlist item event received during delayed initialisation - playlist index is " + _player.playlist.currentIndex, Debuggable.DEBUG_PLAYLIST); }
			onPlayEventWithDelayedInitialisation(evt);
		}

		protected function onPreviousPlaylistItemWithDelayedInitialisation(evt:ViewEvent):void {
			CONFIG::debugging { doLog("Previous playlist item event received during delayed initialisation - playlist index is " + _player.playlist.currentIndex, Debuggable.DEBUG_PLAYLIST); }
			onPlayEventWithDelayedInitialisation(evt);
		}
		
		protected function timeHandlerWithDelayedInitialisation(evt:MediaEvent, manualTimer:Boolean=false):void {
			CONFIG::debugging { doLog("Time handler event received during delayed initialisation", Debuggable.DEBUG_PLAYLIST); }
		}

        /**
         * PLAYLIST OPERATIONS
         * 
         **/ 
		
		protected function createPlaylist():JWPlaylist {
			var result:JWPlaylist = new JWPlaylist(_vastController.streamSequence, 
			                       		  _vastController.config.showsConfig.providersConfig, 
					                      _vastController.config.adsConfig.providersConfig,
					                      _vastController.config.adsConfig.holdingClipUrl);
			CONFIG::debugging { 
				doLog("JW playlist created (" + result.length + " items) : " + 
			             "\n" + ((result.length > 0) ? result.toShortString(true) : "(empty)"), 
			            Debuggable.DEBUG_PLAYLIST);
			}
			return result;
		}
		
		protected function clearPlaylist():void {
			if(_player.playlist != null) {
				var originalPlaylistLength:int = _player.playlist.length;
				for(var i:int=0; i < originalPlaylistLength; i++) {
					_player.playlist.removeItemAt(0);			
				}
				CONFIG::debugging { doLog("Playlist cleared - length is now " + _player.playlist.length, Debuggable.DEBUG_CONFIG);	}			
			}
		}

 		protected function loadExistingPlaylist(rawConfig:Object):void {
			if(_player.playlist.length > 0) {
				if(_player.playlist.getItemAt(0).image != null) {
					if(_player.playlist.getItemAt(0).image.length > 0) {
						_splashImage = _player.playlist.getItemAt(0).image;
						if(rawConfig.ignoreDefaultSplashImage) {
 	               		   _player.playlist.getItemAt(0).image = null;
						}
						CONFIG::debugging { doLog("Splash image has been configured as " + _splashImage, Debuggable.DEBUG_CONFIG);	}				
					}
				}
				CONFIG::debugging { doLog("Importing pre-defined playlist - number of show clips is " + _player.playlist.length, Debuggable.DEBUG_CONFIG); }
				var newStreams:Array = new Array();
				for(var i:int=0; i < _player.playlist.length; i++) {
					var item:com.longtailvideo.jwplayer.model.PlaylistItem = _player.playlist.getItemAt(i);
					var newShow:Object = new Object();
					newShow = { 
						"file": item.file,
						"duration": Timestamp.secondsToTimestamp(item.duration),
						"startTime": Timestamp.secondsToTimestamp(item.start),
						"provider": item.provider,
						"customProperties": {
							"originalPlaylistItem": item
						}
					}					
					newStreams.push(newShow);
					CONFIG::debugging { 
						doLog("+ Imported clip: " + newShow.file +
					      ", startTime: " + newShow.startTime + 
					      ", duration: " + newShow.duration + 
					      ", provider: " + newShow.provider, Debuggable.DEBUG_CONFIG);
					}
				}
				if(rawConfig.shows == undefined) {
					rawConfig.shows = { "streams" : newStreams };				
				}
				else rawConfig.shows.streams = newStreams;

				// Ok, clear out the original playlist
				if(rawConfig.clearPlaylist != undefined) {
					if(rawConfig.clearPlaylist == true) {
						clearPlaylist();			
					}
				}
				else clearPlaylist();
			}
			else {
				if(_player.config.singleItem != null) {
					if(_player.config.singleItem.levels.length > 0) {
						CONFIG::debugging { doLog("NOT-IMPLEMENTED: Bit-rate switched clip - " + _player.config.singleItem.levels.length + " 'levels' have been declared - processing as a single item playlist with bit-rate levels...", Debuggable.DEBUG_CONFIG); }
					}
					else {
						CONFIG::debugging { doLog("No pre-defined playlist clips to import before scheduling", Debuggable.DEBUG_CONFIG); }
					}
				}
				else {
					CONFIG::debugging { doLog("No pre-defined playlist clips to import before scheduling", Debuggable.DEBUG_CONFIG); }
				}
			}
		}

		protected function haveOVALoadedPlaylistInTransit():Boolean {
			return (ovaLoadedPlaylistInTransit != null);
		}
		
		protected function clearOVALoadedPlaylistInTransit():void {
			ovaLoadedPlaylistInTransit = null;
		}
		
		protected function set ovaLoadedPlaylistInTransit(playlist:*):void {
			if(playlist is com.longtailvideo.jwplayer.model.PlaylistItem) {
				// since it's a single clip being loaded up, package it so it's consistent with a multi-clip playlist 
				// being loaded as an array into the Player
				var asPlaylist:Array = new Array();
				asPlaylist.push(playlist);
				_ovaLoadedPlaylistInTransit = asPlaylist;
			}
			else _ovaLoadedPlaylistInTransit = playlist;
		}

		protected function get ovaLoadedPlaylistInTransit():Array {
			return _ovaLoadedPlaylistInTransit;
		}
				
		protected function loadedPlaylistMatchesOVALoadedPlaylistInTransit():Boolean {
			if(haveOVALoadedPlaylistInTransit()) {
				if(_player.playlist != null) {
					if(_player.playlist.length == _ovaLoadedPlaylistInTransit.length) {
						for(var i:int=0; i < _player.playlist.length; i++) {
							if(_player.playlist.getItemAt(i)["ovaUID"] != null && (_player.playlist.getItemAt(i)["ovaUID"] == _ovaLoadedPlaylistInTransit[i]["ovaUID"])) {
							   	// matching so far - let's continue
							}
							else {
								// doesn't match
								return false;
							}
						}
                        return true;
					}
				}
			}
			return false;
		}		
		
		protected function loadPlaylistIntoPlayer(playlist:*):void {
			ovaLoadedPlaylistInTransit = playlist;
			if(ovaHasLock()) unlockPlayer();
			_player.load(playlist);
		}
		
		protected function setCurrentPlaylistIndex(index:int):void {
			_ovaLastModifiedPlaylist = true;
			_player.playlist.currentIndex = index;
		}

		protected function moveFromVPAIDLinearToNextPlaylistItem(activeAdSlot:AdSlot):void {
			turnOnControlBar();
			if(_vastController.allowPlaylistControl) {
				if((_player.playlist.currentIndex == (_player.playlist.length-1)) && _vastController.autoPlay() && ((JWPlaylistItem(_playlist.getTrackAtIndex(0)).stream is AdSlot) == false)) {
					// PLAYER BUG WORK-AROUND: Case - fully loaded playlist, VPAID post-roll, stream at clip 0, autostart true
					// we are at the end of the playlist, the first item in the playlist is a stream and autoplay is set
					// do not do a "playlistNext()" call because that results in a bug where the player loops and loops and loop endlessly, never stopping
					CONFIG::debugging { doLog("VPAID Linear ad ended - at the end of the playlist, not doing a playlistNext() because autoplay is true and playlistItem(0) is a stream", Debuggable.DEBUG_PLAYLIST); }
					_vastController.closeActiveVPAIDAds();
					turnOnControlBar();
					setCurrentPlaylistIndex(0);
				}
				else {
					_lastPlaylistClipComplete = _player.playlist.currentIndex;
					CONFIG::debugging { doLog("VPAID Linear ad ended - using player.playlistNext() to move forward because of allowPlaylistControl:true - lastPlaylistClipComplete has been set to '" + _lastPlaylistClipComplete + "'", Debuggable.DEBUG_PLAYLIST); }
					_player.playlistNext();
				}
			}
			else {
				CONFIG::debugging { doLog("VPAID Linear ad ended - triggering move to next item in the playlist - loading clip-at-a-time via streamCompleteStateHandler()", Debuggable.DEBUG_PLAYLIST); }
				streamCompleteStateHandler(null, true, false);
			}
		}

		protected function loadRuntimePlaylistAfterTemplateLoadEvent():void {
			if(_needToDoStartPreProcessing) {
				// used to enforce impression sending where needed for empty Ad slots
				_vastController.processImpressionFiringForEmptyAdSlots();				
				_needToDoStartPreProcessing = false;
			}

			unlockPlayer();
			_playlist = createPlaylist();

			if(_vastController.allowPlaylistControl) {
				// load up the full playlist and play as a list
				CONFIG::debugging { doLog("Playlist control is turned on - full playlist (" + _playlist.length + " items) will be loaded", Debuggable.DEBUG_PLAYLIST); }
				_player.config.repeat="list";				
				loadPlaylistIntoPlayer(
						_playlist.toJWPlaylistItemArray(
								true,
								_vastController.config.adsConfig.metaDataConfig, 
								_vastController.config.adsConfig.holdingClipUrl 
						)
				);
				if(_vastController.delayAdRequestUntilPlay()) {
					// do nothing
				}
				else {
					// Check to see if the first item in the playlist is a VPAID ad - if so, make sure it's stored
					// as pending ready to go
					if(_playlist.isFirstTrackIsInteractive()) {
						CONFIG::debugging { doLog("First track in the loaded playlist is a VPAID ad - pending to play...", Debuggable.DEBUG_PLAYLIST); }
						setPendingVPAIDAdSlot(JWPlaylistItem(_playlist.getTrackAtIndex(0)).stream as AdSlot);
						if(haveSplashImage() && _player.playlist.getItemAt(0) != null) {
							CONFIG::debugging { doLog("Have set the splash image on the first VPAID ad track in the playlist", Debuggable.DEBUG_PLAYLIST); }
							_player.playlist.getItemAt(0).image = _splashImage;
						}
					}
					else if(_playlist.isFirstTrackIsHoldingClip()) {
						if(haveSplashImage() && _player.playlist.getItemAt(0) != null) {
							CONFIG::debugging { doLog("Have set the splash image on the first track playlist as it is a Holding clip", Debuggable.DEBUG_PLAYLIST); }
							_player.playlist.getItemAt(0).image = _splashImage;
						}
					}
				}
			}
			else { 
				// iterate through the playlist one clip at time, so just up the first
                var item:JWPlaylistItem = _playlist.nextTrackAsPlaylistItem() as JWPlaylistItem;
                if(item != null) {
                	loadJWClip(item);
                }
                else {
                	CONFIG::debugging { doLog("No clips available in the playlist to load into the player", Debuggable.DEBUG_PLAYLIST); }
                }
			}
			
			CONFIG::debugging { doLog("OVA is ready to begin playback - plugin initialise count is " + _initialiseCount + ", playlist size is " + _player.playlist.length + ", active playlist index is " + _player.playlist.currentIndex + ", player lock count is " + _lockCounter + ", delayAdRequestUntilPlay == '" + _vastController.delayAdRequestUntilPlay() + "', justStarted == '" + justStarted() + "'", Debuggable.DEBUG_CONFIG); }
			_vastController.fireAPICall("onOVAReadyToPlay", _initialiseCount);

			if(_initialiseCount > 0 && _vastController.canSupportExternalPlaylistLoading()) {
				// OVA has been reinitialised at least once, so check the "autoPlayOnExternalLoad" setting
				// to see if we need to start playback automatically
				if(_vastController.willAutoPlayOnExternalLoad()) {
					CONFIG::debugging { doLog("Automatically starting playback as OVA has been reinitialised on external player.load() and autoPlayOnExternalLoad == true", Debuggable.DEBUG_PLAYLIST); }
					startPlayback();
				}
			}	
			else if(_vastController.allowPlaylistControl == false && _vastController.autoPlay()) {
				CONFIG::debugging { doLog("OVA is processing the playlist 'clip-by-clip' and autoPlay is true - so starting playback", Debuggable.DEBUG_PLAYLIST); }
				startPlayback();
			}
			else if(_initialiseCount == 0 && _vastController.delayAdRequestUntilPlay()) {
				CONFIG::debugging { doLog("Starting playback as a 'delayed' initialisation OVA has just initialised and loaded a playlist post a template load event", Debuggable.DEBUG_PLAYLIST); }
				startPlayback();
			}	
			else if(justStarted() && _vastController.autoPlay() && _vastController.allowPlaylistControl) {
				CONFIG::debugging { doLog("Starting playback as autoPlay == true and OVA is in full playlist control mode and has just started", Debuggable.DEBUG_PLAYLIST); }
				startPlayback();
			}
			else {
				// NOT USED
			}
		}		

        /**
         * CONFIGURATION HANDLERS
         * 
         **/ 

        protected function createPluginConfig(config:Object):PluginConfig {
        	var pluginConfig:PluginConfig = new PluginConfig("ova");
			for(var idx:String in config) {
				pluginConfig[idx] = config[idx];
			}  
			return pluginConfig;      		
        }
        		
        protected function removeAllPlayerEventListeners():void {
        	CONFIG::debugging { doLog("Clearing all player event listeners", Debuggable.DEBUG_CONFIG); }
			_player.removeEventListener(PlaylistEvent.JWPLAYER_PLAYLIST_LOADED, onOriginalPlaylistLoaded);
			removeDelayedPlayerEventListeners();
			_player.removeEventListener(MediaEvent.JWPLAYER_MEDIA_COMPLETE, playlistStreamCompleteStateHandler);        	
			_player.removeEventListener(PlaylistEvent.JWPLAYER_PLAYLIST_ITEM, playlistSelectionHandler);
			_player.removeEventListener(PlaylistEvent.JWPLAYER_PLAYLIST_LOADED, crossReferencePlayerAndOVAPlaylists);
			_player.removeEventListener(ViewEvent.JWPLAYER_VIEW_ITEM, onPlaylistItemSelect);
			_player.removeEventListener(ViewEvent.JWPLAYER_VIEW_NEXT, onNextPlaylistItem);
			_player.removeEventListener(ViewEvent.JWPLAYER_VIEW_PREV, onPreviousPlaylistItem);
			_player.removeEventListener(MediaEvent.JWPLAYER_MEDIA_COMPLETE, streamCompleteStateHandler); 				
			_player.removeEventListener(PlaylistEvent.JWPLAYER_PLAYLIST_LOADED, onPlaylistLoadedAtStartupEvent);
			_player.removeEventListener(MediaEvent.JWPLAYER_MEDIA_TIME, timeHandler);
			_player.removeEventListener(MediaEvent.JWPLAYER_MEDIA_META, onMetaData);
			_player.removeEventListener(MediaEvent.JWPLAYER_MEDIA_MUTE, onMuteEvent);
			_player.removeEventListener(MediaEvent.JWPLAYER_MEDIA_VOLUME, onVolumeChangeEvent);
			_player.removeEventListener(PlayerStateEvent.JWPLAYER_PLAYER_STATE, onPlayerStateChange);
			_player.removeEventListener(ViewEvent.JWPLAYER_VIEW_STOP, onStopEvent);		
			_player.removeEventListener(ViewEvent.JWPLAYER_VIEW_PAUSE, onPauseEvent);
			_player.removeEventListener(ViewEvent.JWPLAYER_VIEW_PLAY, onPlayEvent);
			_player.removeEventListener(ViewEvent.JWPLAYER_VIEW_FULLSCREEN, onFullscreenEvent);
			_player.removeEventListener(MediaEvent.JWPLAYER_MEDIA_LOADED, onMediaLoaded);
        }
        
		public function isOVAConfigLoading():Boolean { return true; }
						
		public function onOVAConfigLoaded():void {	
			CONFIG::debugging { doLog("Player display config has been set to: (trace follows)", Debuggable.DEBUG_CONFIG); }
			CONFIG::debugging { doTrace(_vastController.getDefaultPlayerConfig(), Debuggable.DEBUG_CONFIG);	}		

			if(_vastController.config.adsConfig.vpaidConfig.hasLinearRegionSpecified() == false) {
				if(controlBarIsAtBottomPosition()) {
					if(_vastController.config.playerConfig.shouldHideControlsOnLinearPlayback(true)) { 
						_vastController.config.adsConfig.vpaidConfig.linearRegion = VPAIDConfig.RESERVED_FULLSCREEN_BLACK_WITH_CB_HEIGHT;						
					}
					else {
						_vastController.config.adsConfig.vpaidConfig.linearRegion = VPAIDConfig.RESERVED_FULLSCREEN_BLACK_WITH_MINIMIZE_RULES; 
					}
				}
				else {
					_vastController.config.adsConfig.vpaidConfig.linearRegion = VPAIDConfig.RESERVED_FULLSCREEN_BLACK_WITH_MINIMIZE_RULES;
				}
			}	
			if(_vastController.config.adsConfig.vpaidConfig.hasNonLinearRegionSpecified() == false) {
				if(this.controlBarIsAtOverPosition() && ControlsSpecification(_vastController.config.playerConfig.nonLinearControls.vpaid).anchorNonLinearToBottom) {
					_vastController.config.adsConfig.vpaidConfig.nonLinearRegion = VPAIDConfig.RESERVED_FULLSCREEN_TRANSPARENT;						
				}
				else {
					_vastController.config.adsConfig.vpaidConfig.nonLinearRegion = VPAIDConfig.RESERVED_FULLSCREEN_TRANSPARENT_BOTTOM_MARGIN_ADJUSTED;
				}
			}
			
			if(!_vastController.config.hasProviders()) {
				CONFIG::debugging { doLog("Some missing providers - automatically setting the defaults to http(video) and rtmp(rtmp)", Debuggable.DEBUG_CONFIG); }
				_vastController.config.setMissingProviders("video", "rtmp"); // was previously 'http' instead of 'video'
			}

			if(_vastController.delayAdRequestUntilPlay()) {
				removeDelayedPlayerEventListeners();
			}

            // Setup the playlist tracking events
            if(_vastController.allowPlaylistControl) {
            	CONFIG::debugging { doLog("Have registered the PLAYLIST SELECTION and PLAYLIST LOADED handlers to process 'full playlist' control", Debuggable.DEBUG_CONFIG); }
				_player.addEventListener(MediaEvent.JWPLAYER_MEDIA_COMPLETE, playlistStreamCompleteStateHandler);        	
				_player.addEventListener(PlaylistEvent.JWPLAYER_PLAYLIST_ITEM, playlistSelectionHandler);
				_player.addEventListener(PlaylistEvent.JWPLAYER_PLAYLIST_LOADED, crossReferencePlayerAndOVAPlaylists);
				_player.addEventListener(ViewEvent.JWPLAYER_VIEW_ITEM, onPlaylistItemSelect);
				_player.addEventListener(ViewEvent.JWPLAYER_VIEW_NEXT, onNextPlaylistItem);
				_player.addEventListener(ViewEvent.JWPLAYER_VIEW_PREV, onPreviousPlaylistItem);
            }
            else {
            	CONFIG::debugging { doLog("Have registered the STREAM COMPLETE and PLAYLIST LOADED handlers to process 'clip-by-clip' loading", Debuggable.DEBUG_CONFIG); }
				_player.addEventListener(MediaEvent.JWPLAYER_MEDIA_COMPLETE, streamCompleteStateHandler); 				
            }

			_player.addEventListener(PlaylistEvent.JWPLAYER_PLAYLIST_LOADED, onPlaylistLoadedAtStartupEvent);
			_player.addEventListener(MediaEvent.JWPLAYER_MEDIA_TIME, timeHandler);
			_player.addEventListener(MediaEvent.JWPLAYER_MEDIA_META, onMetaData);
			_player.addEventListener(MediaEvent.JWPLAYER_MEDIA_MUTE, onMuteEvent);
			_player.addEventListener(MediaEvent.JWPLAYER_MEDIA_VOLUME, onVolumeChangeEvent);
			_player.addEventListener(MediaEvent.JWPLAYER_MEDIA_LOADED, onMediaLoaded);
			_player.addEventListener(MediaEvent.JWPLAYER_MEDIA_ERROR, onMediaError);

			if(isAtLeastJW59()) {
				try {
					_player.addEventListener(MediaEvent.JWPLAYER_MEDIA_BEFOREPLAY, onBeforePlay);		
				}
				catch(e:Error) {}
			}

			// Setup the player state tracking events
			_player.addEventListener(PlayerStateEvent.JWPLAYER_PLAYER_STATE, onPlayerStateChange);
			_player.addEventListener(PlayerEvent.JWPLAYER_ERROR, onPlayerError);

			// Setup the player tracking events
			_player.addEventListener(ViewEvent.JWPLAYER_VIEW_STOP, onStopEvent);		
			_player.addEventListener(ViewEvent.JWPLAYER_VIEW_PAUSE, onPauseEvent);
			_player.addEventListener(ViewEvent.JWPLAYER_VIEW_PLAY, onPlayEvent);
			_player.addEventListener(ViewEvent.JWPLAYER_VIEW_FULLSCREEN, onFullscreenEvent);
            
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
          
            // Setup the companion display listeners
            _vastController.addEventListener(CompanionAdDisplayEvent.DISPLAY, onDisplayCompanionAd);
            _vastController.addEventListener(CompanionAdDisplayEvent.HIDE, onHideCompanionAd);

            // Decide how to handle overlay displays - if through the framework, turn it on, otherwise register the event callbacks

            _vastController.enableRegionDisplay(
            	new DisplayProperties(
            			this, 
            			getPlayerWidth(), 
            			getPlayerHeight(),
            			getDisplayMode(),
            			_vastController.getActiveDisplaySpecification(activeStreamIsShowStream()),
            			controlBarVisibleAtBottom(),
            			getControlBarHeight(),
            			getControlBarYPosition()
            	)
            );
			CONFIG::debugging { doLog("Player dimensions set to " + _vastController.config.playerWidth + " wide by " + _vastController.config.playerHeight + " high", Debuggable.DEBUG_CONFIG); }
		            
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
            _vastController.addEventListener(VPAIDAdDisplayEvent.LINEAR_LOADING, onVPAIDLinearAdLoading);
            _vastController.addEventListener(VPAIDAdDisplayEvent.LINEAR_LOADED, onVPAIDLinearAdLoaded);            
            _vastController.addEventListener(VPAIDAdDisplayEvent.NON_LINEAR_LOADING, onVPAIDUnusedEvent);
            _vastController.addEventListener(VPAIDAdDisplayEvent.NON_LINEAR_LOADED, onVPAIDUnusedEvent);
            _vastController.addEventListener(VPAIDAdDisplayEvent.LINEAR_START, onVPAIDLinearAdStart); 
            _vastController.addEventListener(VPAIDAdDisplayEvent.LINEAR_COMPLETE, onVPAIDLinearAdComplete); 
            _vastController.addEventListener(VPAIDAdDisplayEvent.LINEAR_ERROR, onVPAIDLinearAdError); 
            _vastController.addEventListener(VPAIDAdDisplayEvent.LINEAR_LINEAR_CHANGE, onVPAIDLinearAdLinearChange); 
            _vastController.addEventListener(VPAIDAdDisplayEvent.LINEAR_EXPANDED_CHANGE, onVPAIDLinearAdExpandedChange); 
            _vastController.addEventListener(VPAIDAdDisplayEvent.LINEAR_TIME_CHANGE, onVPAIDLinearAdTimeChange); 
            _vastController.addEventListener(VPAIDAdDisplayEvent.NON_LINEAR_START, onVPAIDNonLinearAdStart); 
            _vastController.addEventListener(VPAIDAdDisplayEvent.NON_LINEAR_COMPLETE, onVPAIDNonLinearAdComplete); 
            _vastController.addEventListener(VPAIDAdDisplayEvent.NON_LINEAR_ERROR, onVPAIDNonLinearAdError); 
            _vastController.addEventListener(VPAIDAdDisplayEvent.AD_LOG, onVPAIDAdLog); 
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
            
            // Setup linear tracking events
            _vastController.addEventListener(LinearAdDisplayEvent.SKIPPED, onLinearAdSkipped);
            _vastController.addEventListener(LinearAdDisplayEvent.CLICK_THROUGH, onLinearAdClickThrough);           
            
            // Setup the hander for tracking point set events
            _vastController.addEventListener(TrackingPointEvent.SET, onSetTrackingPoint);
            _vastController.addEventListener(TrackingPointEvent.FIRED, onTrackingPointFired);
            
            // Setup the hander for display events on the seeker bar
            _vastController.addEventListener(OVAControlBarEvent.ENABLE, onControlBarEnable);
            _vastController.addEventListener(OVAControlBarEvent.DISABLE, onControlBarDisable);

			if(_vastController.canSupportExternalPlaylistLoading()) {
				CONFIG::debugging { 
					doLog("Support for external triggering of playlist changes via player.load() has been turned on - " + 
					      ((_vastController.willAutoPlayOnExternalLoad()) 
					         ? "autoPlay is on"
					         : "autoPlay is off"),
					      Debuggable.DEBUG_CONFIG);
				}
			}
			CONFIG::debugging { doLog("OVA initialisation complete. Triggering load of Ads...", Debuggable.DEBUG_ALL); }

            // Ok, let's load up the VAST data from our Ad Server
            _vastController.load();
		}
		
		public function reinitialise(overrideDelayAdRequestConfig:Boolean=false):void {
			_initialiseCount++;
			CONFIG::debugging { doLog("Re-initialising the OVA plugin - initialisation count is now " + _initialiseCount + " ...", Debuggable.DEBUG_CONFIG); }
			resetPlayer(true);
			initialise(null, overrideDelayAdRequestConfig);
		}


        /**
         * DISPLAY METHODS
         * 
         **/ 

		protected function getPlayerWidth():int {
			if(_vastController != null) {
				if(_vastController.initialised) {
					if((_player.fullscreen == false) && _vastController.config.hasPlayerWidth()) {
						return _vastController.config.playerWidth;
					}
				}				
			}
			if(_player != null) {
				return _player.config["width"];			
			}
			return -1;
		}
		
		protected function getPlayerHeight(takePlayerStateIntoAccount:Boolean=true):int {
			if(_vastController != null) {
				if(_vastController.initialised) {
					if((_player.fullscreen == false) && _vastController.config.hasPlayerHeight()) {
						return _vastController.config.playerHeight;
					}				
				}				
			}
			if(_player != null) {
				return _player.config["height"];			
			}
			return -1;
		}

		protected function getDisplayMode():String {
			if(_player != null) {
				if(_player.config.fullscreen) {
					return DisplayProperties.DISPLAY_FULLSCREEN;
				}			
			}
			return DisplayProperties.DISPLAY_NORMAL;
		}
		
		protected function getPlayerVolume():Number {
			return (_player.config.volume / 100);			
		}
		
   		public function resize(width:Number, height:Number):void {
            if(getDisplayMode() != DisplayProperties.DISPLAY_FULLSCREEN) {
            	_vastController.config.playerWidth = width;
            	_vastController.config.playerHeight = height;
            	CONFIG::debugging { doLog("Player has been dynamically resized - new dimensions are " + _vastController.config.playerWidth + " wide by " + _vastController.config.playerHeight + " high", Debuggable.DEBUG_CONFIG); }
            }
            resizeWithControls(width, height);
   		}		

   		protected function resizeWithControls(width:Number, height:Number):void {
			if(_vastController != null) {
				if(currentlyActiveStreamIsAd()) {
					if(_vastController.config.adsConfig.vpaidConfig.callResizeOnControlbarShowHide == false) {
						doLog("Aborting resize of VPAID region when controlbar appears - config has turned it off", Debuggable.DEBUG_CONFIG);				
						return;
					}
				}
				_vastController.resizeOverlays(
						new DisplayProperties(
								this,
								getPlayerWidth(),
								getPlayerHeight(),
								getDisplayMode(),
								_vastController.getActiveDisplaySpecification(activeStreamIsShowStream()),
        						controlBarVisibleAtBottom(),
                    			getControlBarHeight(),
             						getControlBarYPosition()
						)
				);					
			}			
   		}		

		protected function resizeWithHiddenControls():void {
			if(_vastController != null) {
				if(currentlyActiveStreamIsAd()) {
					if(_vastController.config.adsConfig.vpaidConfig.callResizeOnControlbarShowHide == false) {
						doLog("Aborting resize of VPAID region when controlbar disappears - config has turned it off", Debuggable.DEBUG_CONFIG);				
						return;
					}
				}
				_vastController.resizeOverlays(
						new DisplayProperties(
								this, 
								getPlayerWidth(), 
								getPlayerHeight(), 
		        				getDisplayMode(),
		        				_vastController.getActiveDisplaySpecification(activeStreamIsShowStream()),
		            			false,
                     			getControlBarHeight(),
           						getControlBarYPosition()
						)
				);				
			}
		}   		

        /**
         * OVA OPERATING STATE METHODS
         * 
         **/ 

        protected function isPlayerPlaying():Boolean {
        	return StringUtils.matchesIgnoreCase(_player.state, "PLAYING");
        }
        
        protected function initialisationDelayed():Boolean {
        	return _delayedInitialisation;
        }
        
        protected function signalDelayedInitialisationOver():void {
        	_delayedInitialisation = false;
        }
        
		protected function justStarted():Boolean {
			if(_initialiseCount > 0) { // we've been reinitialised, so we haven't just started
				return false;
			}
			if(_vastController.delayAdRequestUntilPlay()) {
				if(initialisationDelayed()) {
					if((_player.playlist.currentIndex == 0) && (_lastActiveStreamIndex == OVA_INDEX_AT_STARTUP)) {
						return true;
					}
				}
				return false;
			}
			else {
			    return (
			          (_player.playlist.length == 0) || 
			          ((_player.playlist.currentIndex == 0) && (_lastActiveStreamIndex == OVA_INDEX_AT_STARTUP))
		        );
			}
		}

		protected function getCleanPlayerVersionNumber():String {
			var version:String = StringUtils.trim(_player.version);
			if(version.indexOf(" ") > -1) {
				version = version.substr(0, version.indexOf(" "));
			}
			return version;
		}
		
		protected function isAtLeastJW59():Boolean {
			var cleanVersion:String = getCleanPlayerVersionNumber();
			if(cleanVersion != null) {
				var elements:Array = cleanVersion.split(".");
				if(elements.length >= 2) {
					if(parseInt(elements[0]) >= 5) {
						if(parseInt(elements[1]) >= 9) {
							return true;
						}
					}
				}
			}
			return false;
		}
				
		protected function haveSplashImage():Boolean {
			return _splashImage != null;
		}

		protected function playerIsLicensed():Boolean {
			return (_player.version.toUpperCase().indexOf("LICENSE") > -1);
		}
		
		protected function getActiveStreamIndex():int {
			return (_vastController.allowPlaylistControl) 
			          ? _player.playlist.currentIndex 
			          : ((_playlist != null) ? _playlist.playingTrackIndex : 0);
		}

		protected function currentlyActiveStreamIsAd():Boolean {
			var activeStreamIndex:int = getActiveStreamIndex();
			if(activeStreamIndex > -1 && _vastController != null) {
				return (_vastController.streamSequence.getStreamAtIndex(activeStreamIndex) is AdSlot); 
			}
			return false;
		}
		
		protected function activeStreamIsShowStream():Boolean {
			return !activeStreamIsLinearAd();
		}

		protected function activeStreamIsLinearAd():Boolean {
			return (_vastController.streamSequence.streamAt(getActiveStreamIndex()) is AdSlot);
		}
		
		protected function activeClipIsLinearVPAIDAd():Boolean {
			var currentClip:Stream = _vastController.streamSequence.streamAt(getActiveStreamIndex());
			if(currentClip is AdSlot) {
				return AdSlot(currentClip).isLinear() && AdSlot(currentClip).isInteractive();
			}
			return false;
		}

        /**
         * BUFFERING ICON
         * 
         **/

        protected function showOVABusy():void {
        	if(_vastController != null) {
        		if(_vastController.config.playerConfig.showBusyIcon) {
		        	if(_showingBusyState == false) {
		        		try {
							_player.controls.display.forceState(PlayerState.BUFFERING);
				        	_showingBusyState = true
				        }
				        catch(e:Error) {}
		        	}
		        }
        	}
        }  
        
        protected function showOVAReady():void {
        	if(_vastController != null) {
        		if(_vastController.config.playerConfig.showBusyIcon) {
		        	if(_showingBusyState) {
		        		try {
							_player.controls.display.releaseState();        	
		    	    		_showingBusyState = false;
				        }
				        catch(e:Error) {}
		        	}
		        }
        	}
        }

        /**
         * PLAYER LOCKING
         * 
         **/ 
		
		protected function ovaHasLock():Boolean {
			return (_lockCounter >= 1);
		}
		
		protected function lockPlayer(message:String, process:Function):void {
			if(ovaHasLock() && _player.locked) {
				CONFIG::debugging { doLog(message + " - player already locked on clip @ index " + _player.playlist.currentIndex + ". Lock counter is " + _lockCounter, Debuggable.DEBUG_CONFIG); }
				process();
			}
			else {
				_player.lock(
					this,
					function():void {
		    			_lockCounter++
				    	CONFIG::debugging { doLog(message + " - lock acquired on clip @ index " + _player.playlist.currentIndex + ". Lock counter is " + _lockCounter, Debuggable.DEBUG_CONFIG); }
						process();
					}
				);				
			}
		}
		
		protected function unlockPlayer():void {
			if(ovaHasLock() && _player.locked) {
				if(_player.unlock(this)) {
					_lockCounter--;
					CONFIG::debugging { doLog("Player has been unlocked at clip " + _player.playlist.currentIndex + ". Lock counter is " + _lockCounter, Debuggable.DEBUG_CONFIG); }
				}
				else {
					CONFIG::debugging { doLog("Unable to unlock player at clip " + _player.playlist.currentIndex + ". Lock counter is " + _lockCounter, Debuggable.DEBUG_CONFIG);	}	
				}		
			}
			else {
				CONFIG::debugging { doLog("Unlock called, but OVA does not have the player locked - lock count is " + _lockCounter, Debuggable.DEBUG_CONFIG); }
			}
		}
		
        /**
         * PLAYBACK OPERATIONS
         * 
         **/ 

		protected function startPlayFromTimer(e:TimerEvent):void {
			if(_playlist != null && _player != null) {
				clearOVALoadedPlaylistInTransit();
				if(_playTimer != null) {
					CONFIG::debugging { doLog("Play start timer stopped", Debuggable.DEBUG_PLAYLIST); }
					_playTimer.stop();
					_playTimer = null;
				}
				if(_playlist.rewound()) {
					// we've just rewound the playlist so don't play until forced too
				}
				else if(_delayedInitialisation) {
					signalDelayedInitialisationOver();
					startPlayback();
				}
				else if(_playlist.currentTrackIndex == 1) {
					if(_vastController.isActiveOverlayVideoPlaying() || _resumingMainStreamPlayback || _vastController.autoPlay()) {
						_resumingMainStreamPlayback = false;
						startPlayback();
					}
				}
				else {
					if(_vastController.allowPlaylistControl) {
						if(_vastController.streamSequence.length > _playlist.currentTrackIndex) {
							var stream:Stream = _vastController.streamSequence.streamAt(_playlist.currentTrackIndex);
							if(stream is AdSlot) {
								if(AdSlot(stream).loadOnDemand) {
									lockPlayer( 
									    "Player lock requested to process on-demand ad tag before playback can begin",
									    function():void {
											if(_vastController.loadAdSlotOnDemand(stream as AdSlot)) {
												// Ok, we've triggered the "on-demand" load - when that's complete, the AdSlotLoadEvent.LOADED event will be fired. 
											}
											else {
												CONFIG::debugging { doLog("FATAL: Cannot 'on-demand' load Ad Slot '" + AdSlot(stream).id + "' at index " + AdSlot(stream).index + " - skipping", Debuggable.DEBUG_CONFIG); }
												unlockPlayer();
												streamCompleteStateHandler();
											}						
			   	    	                }
			    	   	            );
								}
								else if(_vastController.autoPlay()) {
									_resumingMainStreamPlayback = false;
									startPlayback();									
								}
							}
							else if(_vastController.autoPlay()) {
								_resumingMainStreamPlayback = false;
								startPlayback();
							}					
						}						
					}
					else {
						_resumingMainStreamPlayback = false;
						startPlayback();
					}
				}				
			}
			else {
				CONFIG::debugging { doLog("Oops, either the playlist or player is null - can't start playback from the timer", Debuggable.DEBUG_FATAL); }
			}
		}		

		protected function startPlayback():void {
			if(ovaHasLock()) unlockPlayer();
			updateCustomLogoState();
			if(_player.playlist.currentIndex < 0 && _player.playlist.length > 0) {
				CONFIG::debugging { doLog("_player.playlist.currentIndex is -1, so forcibly setting it to 0 before calling _player.play()", Debuggable.DEBUG_PLAYLIST); }
                setCurrentPlaylistIndex(0);
			}
			if(_vastController.allowPlaylistControl) {
				var activeStreamIndex:int = getActiveStreamIndex();
				if(activeStreamIndex > -1) {
					if(_vastController.streamSequence.streamAt(activeStreamIndex) != null) {
						if(_vastController.streamSequence.streamAt(activeStreamIndex) is AdSlot) {
							if(AdSlot(_vastController.streamSequence.streamAt(activeStreamIndex)).isInteractive()) {
								if(havePendingVPAIDAdSlot() == false) {
									setPendingVPAIDAdSlot(AdSlot(_vastController.streamSequence.streamAt(activeStreamIndex)));
								}	
								if(havePendingVPAIDAdSlot() && (isPendingVPAIDAdSlotRunning() == false)) {
									CONFIG::debugging { doLog("The current playlist item is a VPAID ad that is not running - starting it", Debuggable.DEBUG_PLAYLIST); }
									playPendingVPAIDAdSlot();
								}
							} 
						}						
					}
				}
			}
			if(isPlayerPlaying() == false) {
				if(_player.playlist.currentItem != null) {
					if(_player.playlist.currentItem.file == null) {
						CONFIG::debugging { doLog("FATAL: Triggering clip playback via player.play() @ index " + _player.playlist.currentIndex + " but the file is NULL - is the OVA config option 'holdingClipUrl' set?", Debuggable.DEBUG_PLAYLIST); }				
					}
					else {
						CONFIG::debugging { doLog("Triggering clip playback via player.play() @ index " + _player.playlist.currentIndex + " - '" + _player.playlist.currentItem.file + "' via player.play()", Debuggable.DEBUG_PLAYLIST); }
					}
				}
				CONFIG::debugging { doLog("Starting playback at clip " + _player.playlist.currentIndex, Debuggable.DEBUG_PLAYLIST); }
				_player.play();				
			}
		}
				
		protected function stopPlayback():void {
			CONFIG::debugging { doLog("Playback stopped at clip " + _player.playlist.currentIndex, Debuggable.DEBUG_PLAYLIST); }
			if(ovaHasLock()) unlockPlayer();
			_player.stop();
		}

		protected function pausePlayback():void {
			CONFIG::debugging { doLog("Playback paused at clip " + _player.playlist.currentIndex, Debuggable.DEBUG_PLAYLIST); }
			_playerPaused = true;
			_player.pause();
		}
		
		protected function resumePlayback():void {
			CONFIG::debugging { doLog("Playback resumed at clip " + _player.playlist.currentIndex, Debuggable.DEBUG_PLAYLIST); }
			_playerPaused = false;
			startPlayback();
		}

		protected function playerPaused():Boolean {
			CONFIG::debugging { doLog("Playback paused at clip " + _player.playlist.currentIndex, Debuggable.DEBUG_PLAYLIST); }
			return _playerPaused;
		}
		
		protected function playerNext():void {
			CONFIG::debugging { doLog("Player.next from clip " + _player.playlist.currentIndex, Debuggable.DEBUG_PLAYLIST); }
			_player.playlistNext();
		}

        protected function playClipAtIndex(index:int=-1, absolutePosition:Boolean=false):Boolean {
   			if(moveToClipAtIndex(index, absolutePosition)) {
	   			startPlayback();
	   			return true;
	   		}
   			return false;
        }
				
        /**
         * CUSTOM LOGO MANIPULATION
         * 
         **/ 

		protected function getCustomLogo():MovieClip {
			try {
				if(_customLogoHandle == null) {
					if(RootReference.stage.getChildAt(0) != null) {
						for(var i:int=0; i < MovieClip(RootReference.stage.getChildAt(0)).numChildren; i++) {
							var components:MovieClip = MovieClip(RootReference.stage.getChildAt(0)).getChildAt(i) as MovieClip;
							if(components.name == "components") {
								for(var j:int=0; j < components.numChildren; j++) {
									if(getQualifiedClassName(components.getChildAt(j)) == "com.longtailvideo.jwplayer.view::LogoLicensed") {
										if(_customLogoOriginalWidth < 0) _customLogoOriginalWidth = components.getChildAt(j).width;
										if(_customLogoOriginalHeight < 0) _customLogoOriginalHeight = components.getChildAt(j).height;
										_customLogoHandle = components.getChildAt(j) as MovieClip;
										return _customLogoHandle;
									}
								}
							}
						}				
					}					
				}
				else return _customLogoHandle;
			}
			catch(e:Error) {
				CONFIG::debugging { doLog("Unable to get a handle to the logo object", Debuggable.DEBUG_DISPLAY_EVENTS); }
			}
			return null;
		}
		
		protected function hideCustomLogo():void {
			var customLogo:MovieClip = getCustomLogo();
			if(customLogo != null && playerIsLicensed()) {	
				CONFIG::debugging { doLog("Hiding the custom logo", Debuggable.DEBUG_DISPLAY_EVENTS); }
				customLogo.height = 0;
				customLogo.width = 0;
			}
			else {
				CONFIG::debugging { doLog("Unable to hide the custom logo", Debuggable.DEBUG_DISPLAY_EVENTS); }
			}
		}
		
		protected function customLogoIsHidden():Boolean {
			if(_customLogoHandle != null) {
				return (_customLogoHandle.width + _customLogoHandle.height == 0);
			}
			return false;
		}
		
		protected function restoreCustomLogo():void {
			if(customLogoIsHidden()) {
				var customLogo:MovieClip = getCustomLogo();
				if(customLogo != null && playerIsLicensed()) {				
					CONFIG::debugging { doLog("Restoring the custom logo", Debuggable.DEBUG_DISPLAY_EVENTS); }
					customLogo.width = _customLogoOriginalWidth;
					customLogo.height = _customLogoOriginalHeight;
				}
				else {
					CONFIG::debugging { doLog("Unable to restore the custom logo", Debuggable.DEBUG_DISPLAY_EVENTS); }	
				}			
			}
		}
		
		protected function updateCustomLogoState(determineState:Boolean=true, hide:Boolean=false):void {
			if(_vastController.hideLogoOnLinearAdPlayback()) {
				if((determineState == false && hide) || (determineState && currentlyActiveStreamIsAd())) {
					hideCustomLogo();
					return;
				}
			}
			restoreCustomLogo();
		}
		
        /**
         * VPAID CALLBACK HANDLERS
         * 
         **/ 
		
		protected function onVPAIDLinearAdLoading(event:VPAIDAdDisplayEvent):void {
        	CONFIG::debugging { doLog("PLUGIN NOTIFICATION: VPAID ad loading", Debuggable.DEBUG_VPAID); }
			showOVABusy();
		}

		protected function onVPAIDLinearAdLoaded(event:VPAIDAdDisplayEvent):void {
        	CONFIG::debugging { doLog("PLUGIN NOTIFICATION: VPAID ad loaded", Debuggable.DEBUG_VPAID); }
			showOVAReady();
		}
		
        protected function onVPAIDLinearAdStart(event:VPAIDAdDisplayEvent):void {
        	CONFIG::debugging { doLog("PLUGIN NOTIFICATION: VPAID Linear Ad started", Debuggable.DEBUG_VPAID); }
			turnOffControlBar(true);
			lockControlBar(true);
			showOVAReady();
        }
        
        protected function onVPAIDLinearAdComplete(event:VPAIDAdDisplayEvent):void {
			showOVAReady();
	    	if(event.data.terminated == false) {
	        	if(activeStreamIsLinearAd()) {
		        	CONFIG::debugging { doLog("PLUGIN NOTIFICATION: VPAID Linear Ad complete - proceeding to next playlist item", Debuggable.DEBUG_VPAID); }
		        	moveFromVPAIDLinearToNextPlaylistItem(event.adSlot);
		        }
		        else {
		        	if(playerPaused()) {
			        	CONFIG::debugging { doLog("PLUGIN NOTIFICATION: VPAID Linear Ad complete - show stream is already active - resuming playback", Debuggable.DEBUG_VPAID); }
						unlockControlBar();
		        		resumePlayback();
		        	}
			        else {
			        	CONFIG::debugging { doLog("PLUGIN NOTIFICATION: VPAID Linear Ad complete - show stream is already active - no additional action required", Debuggable.DEBUG_VPAID); }
			        }
		        }
	    	}
	    	else {
	    		CONFIG::debugging { doLog("PLUGIN NOTIFICATION: VPAID Linear Ad complete because the ad was forcibly terminated by OVA via vpaid.stop()", Debuggable.DEBUG_VPAID); }
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
        	if(_vastController.testingVPAID() == false) {
				showOVAReady();
	        	if(activeStreamIsLinearAd() || error.adSlot.isMidRoll()) {
	        		if(error.adSlot.shouldFailoverOnVPAIDError((error.data != null) ? error.data.message : null)) {
		        		CONFIG::debugging { 
		        			doLog("Attempting to failover to the next ad tag after a VPAID error event", Debuggable.DEBUG_VAST_TEMPLATE);
		        		}
						if(_vastController.attemptAdSlotFailoverOnDemand(error.adSlot) == false) {
			        		CONFIG::debugging { 
			        			doLog("Cannot failover to another ad tag - all ad tag options have been explored - moving on..", Debuggable.DEBUG_VAST_TEMPLATE);
			        		}
			        		moveFromVPAIDLinearToNextPlaylistItem(error.adSlot);
						}
	        		}
	        		else {
		        		CONFIG::debugging { 
				        	doLog((error != null) 
		    	    	         ? "PLUGIN NOTIFICATION: VPAID Linear Ad error ('" + ((error.data != null) ? error.data.message : "") + "') proceeding to next playlist item"
		        		         : "PLUGIN NOTIFICATION: VPAID Linear Ad error proceeding to next playlist item", Debuggable.DEBUG_VPAID);
		        		}
		        		moveFromVPAIDLinearToNextPlaylistItem(error.adSlot);
	        		}
	        	}
	        	else {
	        		if(playerPaused()) {
			        	CONFIG::debugging { doLog("PLUGIN NOTIFICATION: VPAID Linear Ad error ('" + ((error.data != null) ? error.data.message : "") + "') - Active stream is a show stream - resuming playback", Debuggable.DEBUG_VPAID); }
						unlockControlBar();
	        			resumePlayback();			
	        		}
	        		else {
	        			CONFIG::debugging { doLog("PLUGIN NOTIFICATION: VPAID Linear Ad error ('" + ((error.data != null) ? error.data.message : "") + "') - Active stream is a show stream - no additional action required", Debuggable.DEBUG_VPAID); }
	        		}
	        	} 
        	}
        	else {
       			CONFIG::debugging { doLog("PLUGIN NOTIFICATION (TEST MODE): VPAID Linear Ad error ('" + ((error.data != null) ? error.data.message : "") + "')", Debuggable.DEBUG_VPAID); }
        	}
		}

		protected function onVPAIDLinearAdLinearChange(event:VPAIDAdDisplayEvent):void {
			showOVAReady();			
			CONFIG::debugging { doLog("PLUGIN NOTIFICATION: VPAID Linear Ad linear change - linear state == " + ((event != null) ? event.data : "'not provided'"), Debuggable.DEBUG_VPAID); }
			if(event.data == false) { 
				// event.data represents the "adLinear" value - in this case adLinear == false so ad is no longer in linear state
			}
		}

		protected function onVPAIDLinearAdExpandedChange(event:VPAIDAdDisplayEvent):void {
        	if(_vastController.testingVPAID() == false) {
				CONFIG::debugging { doLog("PLUGIN NOTIFICATION: VPAID Linear Ad expanded change - expanded state == " + ((event != null) ? event.data.expanded : "'not provided'") + ", linear playback underway == " + event.data.linearPlayback + ", player paused == " + playerPaused(), Debuggable.DEBUG_VPAID); }
				if(event.data.expanded == false && event.data.linearPlayback == false) {
				    // VPAID ad has been minimised as the "adExpanded" state == false (event.data represents the "adExpanded" state
				    if(activeStreamIsLinearAd()) {
						moveFromVPAIDLinearToNextPlaylistItem(event.adSlot);				
					}
					else {
						// We have a show stream as the active stream
						if(_playerPaused) {
							unlockControlBar();
							resumePlayback();
						}
					}
				}
				else if(event.data.expanded && event.data.linearPlayback == false) { 
					// VPAID ad has been expanded as the "adExpanded" state == true and it's not still playing in linear mode so make sure playback is paused
					lockControlBar(true);
					pausePlayback();
				}
				else if((event.data.expanded && event.data.linearPlayback) && activeStreamIsShowStream()) {
					// VPAID ad has been expanded as the "adExpanded" state == true
					lockControlBar(true);
					pausePlayback();
				}
        	}
        	else {
				CONFIG::debugging { doLog("PLUGIN NOTIFICATION (TEST MODE): VPAID Linear Ad expanded change - expanded state == " + ((event != null) ? event.data.expanded : "'not provided'") + ", linear playback underway == " + event.data.linearPlayback + ", player paused == " + playerPaused(), Debuggable.DEBUG_VPAID); }
        	}
		}

		protected function onVPAIDLinearAdTimeChange(event:VPAIDAdDisplayEvent):void {
			CONFIG::debugging { doLog("PLUGIN NOTIFICATION: VPAID Linear Ad time change - time == " + ((event != null) ? event.data : "'not provided'"), Debuggable.DEBUG_VPAID); }
		}          
		
		protected function onVPAIDLinearAdVolumeChange(event:VPAIDAdDisplayEvent):void {
			CONFIG::debugging { doLog("PLUGIN NOTIFICATION: VPAID Linear Ad volume change " + ((event != null) ? event.data : "'volume level not provided'"), Debuggable.DEBUG_VPAID); }
		}

		protected function onVPAIDNonLinearAdVolumeChange(event:VPAIDAdDisplayEvent):void {
			CONFIG::debugging { doLog("PLUGIN NOTIFICATION: VPAID Non-Linear Ad volume change " + ((event != null) ? event.data : "'volume level not provided'"), Debuggable.DEBUG_VPAID); }
		}
		
		protected function onVPAIDNonLinearAdStart(event:VPAIDAdDisplayEvent):void {
			CONFIG::debugging { doLog("PLUGIN NOTIFICATION: VPAID Non-Linear Ad start", Debuggable.DEBUG_VPAID); }
		}
		
		protected function onVPAIDNonLinearAdComplete(event:VPAIDAdDisplayEvent):void {
			unlockControlBar();
			if(playerPaused()) {
				CONFIG::debugging { doLog("PLUGIN NOTIFICATION: VPAID Non-Linear Ad complete - resuming playback", Debuggable.DEBUG_VPAID); }
				resumePlayback();
			}
			else {
				CONFIG::debugging { doLog("PLUGIN NOTIFICATION: VPAID Non-Linear Ad complete - no action required", Debuggable.DEBUG_VPAID); }
			}
		}
		
		protected function onVPAIDNonLinearAdError(event:VPAIDAdDisplayEvent):void {
        	if(_vastController.testingVPAID() == false) {
				unlockControlBar();
				if(playerPaused()) {
					CONFIG::debugging { doLog("PLUGIN NOTIFICATION: VPAID Non-Linear Ad error ('" + ((event.data != null) ? event.data.message : "") + "') - resuming playback", Debuggable.DEBUG_VPAID); }
					resumePlayback();
				}
	        	else {
	        		CONFIG::debugging { doLog("PLUGIN NOTIFICATION: VPAID Non-Linear Ad error ('" + ((event.data != null) ? event.data.message : "") + "')", Debuggable.DEBUG_VPAID); }
	        	}        		
        	}
        	else {
				CONFIG::debugging { doLog("PLUGIN NOTIFICATION (TEST MODE): VPAID Non-Linear Ad error ('" + ((event.data != null) ? event.data.message : "") + "')", Debuggable.DEBUG_VPAID); }
        	}
		}
		
		protected function onVPAIDNonLinearAdLinearChange(event:VPAIDAdDisplayEvent):void {
        	if(_vastController.testingVPAID() == false) {
				CONFIG::debugging { doLog("PLUGIN NOTIFICATION: VPAID Non-Linear Ad linear change - linear state == " + ((event != null) ? event.data : "'not provided'"), Debuggable.DEBUG_VPAID); }
				if(event.data == false) {
				    // VPAID is not in linear playback mode
					unlockControlBar();
					if(_playerPaused) {
						resumePlayback();
					}
				}
				else { 
				    // VPAID is in linear playback mode
					lockControlBar(true);
					pausePlayback();
				}        		
        	}
        	else {
				CONFIG::debugging { doLog("PLUGIN NOTIFICATION (TEST MODE): VPAID Non-Linear Ad linear change - linear state == " + ((event != null) ? event.data : "'not provided'"), Debuggable.DEBUG_VPAID); }
        	}
		}
		
		protected function onVPAIDNonLinearAdExpandedChange(event:VPAIDAdDisplayEvent):void {
        	if(_vastController.testingVPAID() == false) {
				CONFIG::debugging { doLog("PLUGIN NOTIFICATION: VPAID Non-Linear Ad expanded change - expanded state == " + ((event != null) ? event.data.expanded : "'not provided'") + ", linear playback underway == " + event.data.linearPlayback + ", player paused == " + playerPaused(), Debuggable.DEBUG_VPAID); }
				if(event.data.expanded == false && event.data.linearPlayback == false) {
					if(_vastController.config.adsConfig.vpaidConfig.resumeOnCollapse) {
						// pause was forced on expand, so force resume on contract
						if(_playerPaused) {
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
        	else {
				CONFIG::debugging { doLog("PLUGIN NOTIFICATION (TEST MODE): VPAID Non-Linear Ad expanded change - expanded state == " + ((event != null) ? event.data.expanded : "'not provided'") + ", linear playback underway == " + event.data.linearPlayback + ", player paused == " + playerPaused(), Debuggable.DEBUG_VPAID); }
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
         * STREAM META DATA HANDLER
         * 
         **/ 
		
		protected function attemptCurrentClipDurationAdjustment(theStream:Stream, newDuration:Number):Boolean {
			var currentDuration:int = theStream.getDurationAsInt();
			var roundedNewDuration:int = Math.floor(newDuration);
			if(currentDuration != roundedNewDuration && roundedNewDuration > 0) {
	   			CONFIG::debugging { doLog(((theStream is AdSlot) ? "Ad" : "Show") + " stream duration requires adjustment - original duration: " + currentDuration + ", metadata duration: " + newDuration + " rounded: " + roundedNewDuration, Debuggable.DEBUG_CONFIG); }
	   			if(_player.playlist.currentItem != null) {
					_player.playlist.currentItem.duration = newDuration;
					CONFIG::debugging { doLog("Active playlist clip duration updated to " + _player.playlist.currentItem.duration, Debuggable.DEBUG_CONFIG); }
					return true;
	   			}				
		 		else {
		 			CONFIG::debugging { doLog("Not changing " + ((theStream is AdSlot) ? "Ad" : "Show") + " stream duration - cannot get a handle to the 'current' stream in the playlist", Debuggable.DEBUG_CONFIG); }
		 		}
			}							
			else {
				CONFIG::debugging { doLog("Not adjusting the " + ((theStream is AdSlot) ? "Ad" : "Show") + " stream duration based on metadata (" + newDuration + ") - it is either zero or the same as currently set on the clip (" + currentDuration + " == " + roundedNewDuration + ")", Debuggable.DEBUG_CONFIG); }
			}

			return false;
		}

		protected function onMediaLoaded(evt:MediaEvent):void {
			// Set the scaling for the clip that is about to play
			setPlayerScalingForCurrentClip();
			
			// Hide the control bar if we are playing a linear ad and the OVA config declares that it should be hidden for linear playback
			if(activeStreamIsLinearAd() && _vastController.config.playerConfig.shouldHideControlsOnLinearPlayback()) {
				setControlBarVisibility(false);
			}
			else {
				setControlBarVisibility(true);
				if(activeStreamIsShowStream()) {
					// safety valve to make sure that the control bar is enabled and ad notices not shown during shows
					_vastController.closeAllAdMessages();
					unlockControlBar();
				}
			}
		}

		protected function onMediaError(evt:PlayerEvent):void {
			if(activeStreamIsLinearAd()) {
				CONFIG::debugging { doLog("Media error detected on ad clip - " + evt.message, Debuggable.DEBUG_PLAYLIST); }
				var linearAdSlot:AdSlot = _vastController.streamSequence.streamAt(getActiveStreamIndex()) as AdSlot;

				_vastController.fireAdPlaybackAnalytics(AnalyticsProcessor.ERROR, linearAdSlot, linearAdSlot.videoAd);
				linearAdSlot.fireErrorUrls("401");

				_vastController.fireAPICall(
					"onLinearAdError", 
					{ 
						code: "401", 
						message: evt.message
					},
					linearAdSlot.toJSObject()
				);

        		if(linearAdSlot.shouldFailoverOnStreamError(evt.message)) {
	        		CONFIG::debugging { 
	        			doLog("Attempting to failover to the next ad tag after an ad stream error event", Debuggable.DEBUG_VAST_TEMPLATE);
	        		}
					if(_vastController.attemptAdSlotFailoverOnDemand(linearAdSlot) != false) {
						_lastActiveStreamIndex = 0;
						return;
					}
					else {
		        		CONFIG::debugging { 
		        			doLog("Cannot failover to another ad tag - all ad tag options have been explored - skipping clip ...", Debuggable.DEBUG_VAST_TEMPLATE);
		        		}
					}
        		}
        		else {
        			doLog("Runtime failover is disabled - skipping ad clip ...", Debuggable.DEBUG_VAST_TEMPLATE);
        		}
				
				// Move on - skip the ad clip
				
				var errorClipIndex:int = _player.playlist.currentIndex;
				if(_vastController.allowPlaylistControl) {
	                if(_player.playlist.currentIndex == (_player.playlist.length-1)) {
						stopPlayback();
						_player.playlist.currentIndex = 0;
	                }
	                else {
						playerNext();
	                }
				}
				else {
					stopPlayback();
				    moveToNextPlaylistItem();

					// Timed approach required to starting the player after loading the new playlist item because
					// of an issue with JW in Chome where the player is left hanging in a "buffering" state if the
					// playback is not slightly delayed
					
					var timer:Timer = new Timer(500, 1);
				    timer.addEventListener(TimerEvent.TIMER, function(event:TimerEvent):void {
				    	_player.play();
				    	timer.stop();
				    	timer = null;
				    });
				    timer.start();
				}				
			}			
		}
		
		protected function onBeforePlay(evt:MediaEvent):void {
			CONFIG::debugging { doLog("On before play triggered - player must be at least 5.9", Debuggable.DEBUG_PLAYLIST); }
			if(activeStreamIsShowStream()) {
				// Safety mechanism to ensure that all ad regions are cleaned up before the show stream is started
				turnOnControlBar();
				_vastController.hideAllOverlays();
				_vastController.closeActiveOverlaysAndCompanions();
				CONFIG::debugging { doLog("Have reset the control bar and cleared out any visible regions - show stream is playing.", Debuggable.DEBUG_PLAYLIST); }
			}
		}
		
		protected function onMetaData(evt:MediaEvent):void {
			if(evt.metadata != null) {
				if(StringUtils.matchesIgnoreCase(evt.metadata.type, "metadata") && evt.metadata.duration != undefined) {
					var newDuration:Number = Number(evt.metadata.duration);
					var theScheduledStream:Stream = _vastController.streamSequence.streamAt(getActiveStreamIndex());
					if(newDuration != _lastMetaDataDurationEvent.duration || StringUtils.matchesIgnoreCase(_lastMetaDataDurationEvent.file, evt.currentTarget.config.file) == false) {
						_lastMetaDataDurationEvent = { duration: newDuration, file: evt.currentTarget.config.file };
						CONFIG::debugging { doLog("Duration metadata received for active clip - metadata duration is " + newDuration, Debuggable.DEBUG_CONFIG); }
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
									if(attemptCurrentClipDurationAdjustment(theScheduledStream, newDuration)) {
										_vastController.resetDurationForAdStreamAtIndex(getActiveStreamIndex(), Math.floor(newDuration));					   				
									}
								}
								else if(_vastController.deriveAdDurationFromMetaData()) {
									if(attemptCurrentClipDurationAdjustment(theScheduledStream, newDuration)) {
										_vastController.resetDurationForAdStreamAtIndex(getActiveStreamIndex(), Math.floor(newDuration));										
									}								
								}
								else {	
									CONFIG::debugging { doLog("Not adjusting the ad stream metadata - deriveAdDurationFromMetaData == false", Debuggable.DEBUG_CONFIG); }
								}	
							} 
							else if(theScheduledStream is Stream) {
								if(_vastController.deriveShowDurationFromMetaData() || theScheduledStream.hasZeroDuration()) {
									attemptCurrentClipDurationAdjustment(theScheduledStream, newDuration);
									theScheduledStream.duration = Math.floor(newDuration);
									CONFIG::debugging { doLog("Show stream duration adjusted to " + theScheduledStream.duration, Debuggable.DEBUG_CONFIG); }
								}	
								else {
									CONFIG::debugging { doLog("Not adjusting the ad stream metadata - deriveShowDurationFromMetaData == false", Debuggable.DEBUG_CONFIG); }
								}							
							}
							else {
								CONFIG::debugging { doLog("Not adjusting the stream duration based on the metadata - the clip is of an unknown type", Debuggable.DEBUG_CONFIG); }
							} 
						}
					}
					else 
					{	
						CONFIG::debugging { doLog("Metadata duration event ignored - duration has not changed since last event", Debuggable.DEBUG_CONFIG); }
					}
				}				
			}
		}

        /**
         * MANUAL STREAM TIMER METHODS (USED WITH LIVE STREAMS)
         * 
         **/ 

		protected function startStreamTimer():void {
			if(_streamTimer == null) {
				_streamTimer = new Timer(_vastController.config.showsConfig.streamTimerConfig.tickRate, _vastController.config.showsConfig.streamTimerConfig.cycles);
			    _streamTimer.addEventListener(TimerEvent.TIMER, streamTimerEventHandler);
			}
		    _streamTimer.start();
		    CONFIG::debugging { doLog("Stream timer started", Debuggable.DEBUG_CONFIG); }
		}		

		protected function stopStreamTimer():void {
			if(_streamTimer != null) {
				_streamTimer.stop();
			    CONFIG::debugging { doLog("Stream timer stopped", Debuggable.DEBUG_CONFIG); }
			}
		}	
		
		protected function resetStreamTimer():void {
			if(_streamTimer != null) {
				_streamTimer.stop();
				_streamTimer = null;
				CONFIG::debugging { doLog("Stream timer reset", Debuggable.DEBUG_CONFIG); }		
			}
		}	
		
		/**
         * TRACKING POINT CALLBACKS AND TIME HANDLERS
         * 
         **/ 

		protected function streamTimerEventHandler(e:TimerEvent):void {
			var me:MediaEvent = new MediaEvent(MediaEvent.JWPLAYER_MEDIA_TIME);
			me.position = (e.currentTarget.delay / 1000)  * e.currentTarget.currentCount-1;
			timeHandler(me, true);
		}
		
		protected function timeHandler(evt:MediaEvent, manualTimer:Boolean=false):void {
			if(activeClipIsLinearVPAIDAd()) {
				CONFIG::debugging { doLog("The active ad slot is a VPAID linear ad - but a stream seems to be playing (based on a timeEvent being generated) - stopping the player", Debuggable.DEBUG_VPAID); }
				stopPlayback();
			}
			else {
				if(evt.position > 0) {
					if(controlBarIsAtOverPosition()) {
						assessControlBarState();
					}
					if(!_vastController.isActiveOverlayVideoPlaying()) {
						_lastTimeTick = evt.position;
						_vastController.processTimeEvent(getActiveStreamIndex(), new TimeEvent(evt.position * 1000, evt.duration));		
					}
					else {
						_vastController.processOverlayLinearVideoAdTimeEvent(_activeOverlayAdSlotKey, new TimeEvent(evt.position * 1000, evt.duration));
					}
				}					
			}
		}
		
		protected function onSetTrackingPoint(event:TrackingPointEvent):void {
			// Not required for JW Player because we are constantly checking the 1/10th second timed events
			// by firing them directly through to the stream sequence to process.
			CONFIG::debugging { doLog("PLUGIN NOTIFICATION: Request received to set a tracking point (" + event.trackingPoint.label + ") at " + event.trackingPoint.milliseconds + " milliseconds", Debuggable.DEBUG_TRACKING_EVENTS); }
		}

		protected function onTrackingPointFired(event:TrackingPointEvent):void {
			// Not required for JW Player because we are constantly checking the 1/10th second timed events
			// by firing them directly through to the stream sequence to process.
			CONFIG::debugging { doLog("PLUGIN NOTIFICATION: Request received that a tracking point was fired (" + event.trackingPoint.label + ") at " + event.trackingPoint.milliseconds + " milliseconds", Debuggable.DEBUG_TRACKING_EVENTS); }
		}
		
        /**
         * VAST TEMPLATE LOAD CALLBACKS
         * 
         **/ 
		
		protected function onTemplateLoaded(event:TemplateEvent):void {
        	showOVAReady();
			if(event.template != null) {
				if(event.template.hasAds()) {
					CONFIG::debugging { doLog("PLUGIN NOTIFICATION: VAST template loaded - " + event.template.ads.length + " ads retrieved", Debuggable.DEBUG_VAST_TEMPLATE); }
				}
				else {	
					CONFIG::debugging { doLog("PLUGIN NOTIFICATION: No ads to be scheduled - only show streams will be played", Debuggable.DEBUG_VAST_TEMPLATE); }
				}
			}
			else {
				CONFIG::debugging { doLog("PLUGIN NOTIFICATION: No ads to be scheduled - only show streams will be played", Debuggable.DEBUG_PLAYLIST); }
			}
			loadRuntimePlaylistAfterTemplateLoadEvent();        
		}
		
		protected function onTemplateLoadError(event:TemplateEvent):void {
			CONFIG::debugging { doLog("PLUGIN NOTIFICATION: FAILURE loading VAST template - " + event.toString(), Debuggable.DEBUG_FATAL); }
        	showOVAReady();
			if(_vastController.delayAdRequestUntilPlay() && _vastController.allowPlaylistControl) {
				loadDelayedStartHoldingPlaylist();
			}
			else loadRuntimePlaylistAfterTemplateLoadEvent();
		}

		protected function onTemplateLoadTimeout(event:TemplateEvent):void {
			CONFIG::debugging { doLog("PLUGIN NOTIFICATION: TIMEOUT loading VAST template - " + event.toString(), Debuggable.DEBUG_FATAL); }
        	showOVAReady();
			if(_vastController.delayAdRequestUntilPlay() && _vastController.allowPlaylistControl) {
				loadDelayedStartHoldingPlaylist();
			}
			else loadRuntimePlaylistAfterTemplateLoadEvent();
		}

		protected function onTemplateLoadDeferred(event:TemplateEvent):void {
			CONFIG::debugging { doLog("PLUGIN NOTIFICATION: DEFERRED loading VAST template - " + event.toString(), Debuggable.DEBUG_FATAL); }
        	showOVAReady();
			if(_vastController.delayAdRequestUntilPlay() && _vastController.allowPlaylistControl) {
				loadDelayedStartHoldingPlaylist();
			}
			else loadRuntimePlaylistAfterTemplateLoadEvent();
		}
        
        /**
         * ON DEMAND LOADING CALLBACK HANDLERS AND METHODS
         * 
         **/ 

		protected function onAdSlotLoaded(event:AdSlotLoadEvent):void {
        	showOVAReady();
        	if(event != null) {
				if(event.adSlot != null) {
					if(event.adSlot.isNonLinear()) {
						// don't action on demand non-linears here - the VASTController will take care of the display automatically
						return; 
					}
				}
			}
			if(event.adSlotHasLinearAds()) {
				if(_vastController.allowPlaylistControl) {
					if(event.adSlot != null) {
						CONFIG::debugging { doLog("PLUGIN NOTIFICATION: Ad Slot loaded - this Ad Slot provides an Ad for the clip at index " + JWPlaylistItem(event.adSlot.relatedPlaylistItem).playerPlaylistIndex, Debuggable.DEBUG_PLAYLIST); }
						loadAdSlotIntoPlayerPlaylistClip(event.adSlot);
						if(event.adSlot.isInteractive()) {
							setPendingVPAIDAdSlot(event.adSlot);
						}
						if(_player.playlist.currentIndex != JWPlaylistItem(event.adSlot.relatedPlaylistItem).playerPlaylistIndex) {
							CONFIG::debugging { doLog("The current clip index (" + _player.playlist.currentIndex + ") does not match the index for the updated ad slot (" + JWPlaylistItem(event.adSlot.relatedPlaylistItem).playerPlaylistIndex + ") - forwarding to the ad slot clip to start playback", Debuggable.DEBUG_PLAYLIST); }
							setCurrentPlaylistIndex(JWPlaylistItem(event.adSlot.relatedPlaylistItem).playerPlaylistIndex);
							CONFIG::debugging { doLog("The current clip index is now " + _player.playlist.currentIndex, Debuggable.DEBUG_PLAYLIST); }
	   	                    startPlayback();
						}
						else if(justStarted()) {
						    if(_vastController.autoPlay()) {
								CONFIG::debugging { doLog("Autostart on and the player has just started so begin playback", Debuggable.DEBUG_PLAYLIST); }
	    	                    startPlayback();
	    	    			}
	    	    			else if(_vastController.delayAdRequestUntilPlay()) {
	    	                    startPlayback();
	    	    			}
	    	    			else {
	    	    				unlockPlayer();
	    	    			}
						}
						else {
							CONFIG::debugging { doLog("Triggering playback to start for loaded ad slot because we are in the middle of playback when the on-demand load happened", Debuggable.DEBUG_PLAYLIST); }
	                        startPlayback();
						}
					}
					else {	
						CONFIG::debugging { doLog("PLUGIN NOTIFICATION: Ad Slot loaded - this Ad Slot is null - not loading", Debuggable.DEBUG_PLAYLIST); }
					}
				}	
				else {	
					// loading mode is 'clip at a time'
					var ovaJustStarted:Boolean = justStarted();
					CONFIG::debugging { doLog("PLUGIN NOTIFICATION: Ad Slot loaded - has a linear video ad so loading it up.. justStarted() == '" + ovaJustStarted + "' autoPlay=='" + _vastController.autoPlay() + "'", Debuggable.DEBUG_PLAYLIST); }
					loadJWClip(_playlist.currentTrackAsPlaylistItem() as JWPlaylistItem, ((ovaJustStarted && _vastController.autoPlay()) ? true : !ovaJustStarted), true);
				}
			}
			else {
				// We don't have an ad to play so move on in the playlist 
				if(_vastController.allowPlaylistControl) {
					if(isPlayerPlaying() == false && (justStarted() == false || _vastController.autoPlay())) {
						unlockPlayer();
                        if(_player.playlist.currentIndex == (_player.playlist.length-1)) {
							CONFIG::debugging { doLog("PLUGIN NOTIFICATION: Ad Slot loaded - no linear video ad found - slot is empty - at end of playlist - stopping", Debuggable.DEBUG_PLAYLIST); }
							stopPlayback();
							_player.playlist.currentIndex = 0;
                        }
                        else {
							CONFIG::debugging { doLog("PLUGIN NOTIFICATION: Ad Slot loaded - no linear video ad found - slot is empty - skipping to next playlist item", Debuggable.DEBUG_PLAYLIST); }
							playerNext();
						}
					}
					else {
						CONFIG::debugging { doLog("PLUGIN NOTIFICATION: Ad Slot loaded - no linear video ad found - doing nothing at this stage", Debuggable.DEBUG_PLAYLIST); }
   					    unlockPlayer();
					}
				}
				else { 
				    // clip-by-clip loading mode
					unlockPlayer();
					if(justStarted() && _vastController.autoPlay() == false) {
						CONFIG::debugging { doLog("PLUGIN NOTIFICATION: Ad Slot loaded - no linear video ad found - just started and not auto-playing - now trying to move forward", Debuggable.DEBUG_PLAYLIST); }
   					    moveToNextPlaylistItem(false);
					}
					else {
						CONFIG::debugging { doLog("PLUGIN NOTIFICATION: Ad Slot loaded - no linear video ad found - skipping to next playlist item", Debuggable.DEBUG_PLAYLIST); }
						streamCompleteStateHandler(null, true);			
					}
				}
			}
		}
		
		protected function onAdSlotLoadError(event:AdSlotLoadEvent):void {
        	showOVAReady();
			if(event != null) {
				if(event.adSlot != null) {
					if(event.adSlot.isNonLinear()) {
						// no action required for on-demand non-linears
						return; 
					}
				}
				CONFIG::debugging { doLog("PLUGIN NOTIFICATION: Ad Slot load error (skipping) - " + event.toString(), Debuggable.DEBUG_PLAYLIST); }
			}
			unlockPlayer();
			streamCompleteStateHandler(null, true);				
		}

		protected function onAdSlotLoadTimeout(event:AdSlotLoadEvent):void {
        	showOVAReady();
			if(event != null) {
				if(event.adSlot != null) {
					if(event.adSlot.isNonLinear()) {
						// no action required for on-demand non-linears
						return; 
					}
				}
				CONFIG::debugging { doLog("PLUGIN NOTIFICATION: TIMEOUT loading Ad Slot (skipping) - " + event.toString(), Debuggable.DEBUG_FATAL); }
			}
			unlockPlayer();
			streamCompleteStateHandler(null, true);
		}

		protected function onAdSlotLoadDeferred(event:AdSlotLoadEvent):void {
        	showOVAReady();
			if(event != null) {
				if(event.adSlot != null) {
					if(event.adSlot.isNonLinear()) {
						// no action required for on-demand non-linears
						return; 
					}
				}
				CONFIG::debugging { doLog("PLUGIN NOTIFICATION: DEFERRED loading Ad Slot (skipping) - " + event.toString(), Debuggable.DEBUG_FATAL); }
			}
			unlockPlayer();
			streamCompleteStateHandler(null, true);
		}
		
		protected function loadAdSlot(adSlot:AdSlot):void {
			lockPlayer( 
			    "Player lock requested to process on-demand ad tag before playback can begin",
			    function():void {
			    	resetPlayer();
					if(_vastController.loadAdSlotOnDemand(adSlot)) {
						// Ok, we've triggered the "on-demand" load - when that's complete, the AdSlotLoadEvent.LOADED event will be fired. 
					}
					else {
						CONFIG::debugging { doLog("FATAL: Cannot 'on-demand' load Ad Slot '" + adSlot.id + "' at index " + adSlot.index + " - skipping", Debuggable.DEBUG_PLAYLIST); }
						unlockPlayer();
					}						
	            }
	        );
		}

		protected function loadAdSlotIntoPlayerPlaylistClip(adSlot:AdSlot):void {
			if(adSlot != null) {
				if(adSlot.relatedPlaylistItem != null) {
					CONFIG::debugging { doLog("Loading up the newly retrieved ad slot into the player playlist", Debuggable.DEBUG_PLAYLIST); }
					adSlot.relatedPlaylistItem.sync();
				}
				else {
					CONFIG::debugging { doLog("Cannot update the playlist - the ad slot does not have a related playlist item", Debuggable.DEBUG_PLAYLIST); }
				}
			}
			else {
				CONFIG::debugging { doLog("Not updating the playlist - no ad slot provided to updatePlaylist()", Debuggable.DEBUG_PLAYLIST); }
			}
		}
		
		protected function adSlotAtIndexRequiresLoading(index:int):Boolean {
			var stream:Stream = _vastController.streamSequence.getStreamAtIndex(index);
			if(stream != null) {
				if(stream is AdSlot) {
					return AdSlot(stream).requiresLoading();
				}
			}
			return false;
		}
		
		protected function havePendingVPAIDAdSlot():Boolean {
			return (_pendingVPAIDAdSlot != null);
		}
		
		protected function isPendingVPAIDAdSlotRunning():Boolean {
			if(havePendingVPAIDAdSlot()) {
				return _pendingVPAIDAdSlot.isPlaying();
			}
			return false;
		}
		
		protected function haveActiveVPAIDAd():Boolean {
			if(_vastController != null) {
				return _vastController.overlayController.hasActiveVPAIDAd();
			}
			return false;
		}
		
		protected function getPendingVPAIDAdSlot():AdSlot {
			return _pendingVPAIDAdSlot;
		}
		
		protected function setPendingVPAIDAdSlot(item:AdSlot):void {
			if(this.havePendingVPAIDAdSlot()) {
				clearPendingVPAIDAdSlot();
			}
			CONFIG::debugging { doLog("Have set the 'pending to play' VPAID item from Ad Slot '" + item.key + "'", Debuggable.DEBUG_PLAYLIST); }
			_pendingVPAIDAdSlot = item;
		}
		
		protected function clearPendingVPAIDAdSlot():void {
			if(_pendingVPAIDAdSlot != null) {
				CONFIG::debugging { doLog("Have cleared the previous 'pending to play' VPAID item from Ad Slot '" + _pendingVPAIDAdSlot.key + "'", Debuggable.DEBUG_PLAYLIST); }
				_pendingVPAIDAdSlot = null;
			}
		}		
		
		protected function playPendingVPAIDAdSlot():void {
			if(havePendingVPAIDAdSlot()) {
   				CONFIG::debugging { doLog("Starting playback of the 'pending to play' VPAID item from Ad Slot '" + getPendingVPAIDAdSlot().key + "'", Debuggable.DEBUG_PLAYLIST); }
				_vastController.playVPAIDAd(getPendingVPAIDAdSlot(), _player.config["mute"], false, getPlayerVolume());		
				clearPendingVPAIDAdSlot();
			}
		}

        /**
         * LINEAR AD SKIP/CLICK CALLBACK HANDLERS
         * 
         **/ 

		public function onLinearAdSkipped(linearAdDisplayEvent:LinearAdDisplayEvent):void {
			CONFIG::debugging { doLog("PLUGIN NOTIFICATION: Event received that linear ad has been skipped - forcing player to skip to next track", Debuggable.DEBUG_PLAYLIST); }
			if(this.activeClipIsLinearVPAIDAd()) {
				CONFIG::debugging { doLog("Closing the active VPAID ad before moving onto the next clip in the playlist", Debuggable.DEBUG_PLAYLIST); }
    			if(_vastController.allowPlaylistControl == false) {
					moveToNextPlaylistItem(true, true);
    			}
    			else {
					_vastController.closeActiveVPAIDAds();
    				playerNext();
    			}
			}
			else {
				_vastController.closeAllAdMessages();
				if(_vastController.allowPlaylistControl) {
					CONFIG::debugging { doLog("Skipping ad stream - OVA is in 'load full playlist' mode", Debuggable.DEBUG_PLAYLIST); }
					playerNext();
				}
				else {
					CONFIG::debugging { doLog("Skipping ad stream - OVA is in 'load single clips' mode", Debuggable.DEBUG_PLAYLIST); }
					streamCompleteStateHandler(null, true);
				}					
			}

		}	
        
		public function onLinearAdClickThrough(linearAdDisplayEvent:LinearAdDisplayEvent):void {
			CONFIG::debugging { doLog("PLUGIN NOTIFICATION: Event received that linear ad click through activated", Debuggable.DEBUG_DISPLAY_EVENTS);	}		
			if(_vastController.config.adsConfig.skipAdConfig.skipAdOnClickThrough) {
				externalSkipAd();
			}
			else if(_vastController.pauseOnClickThrough) {
				pausePlayback();
				onPauseEvent(null);
			}
		}

        /**
         * CONTROL BAR METHODS
         * 
         **/ 
		
		public function onControlBarDisable(event:OVAControlBarEvent):void {
 		    CONFIG::debugging { doLog("PLUGIN NOTIFICATION: Request received to DISABLE the control bar", Debuggable.DEBUG_DISPLAY_EVENTS); }
         	turnOffControlBar(false);
		}

		public function onControlBarEnable(event:OVAControlBarEvent):void {
 		    CONFIG::debugging { doLog("PLUGIN NOTIFICATION: Request received to ENABLE the control bar", Debuggable.DEBUG_DISPLAY_EVENTS); }
 		    turnOnControlBar();
		}
		
		protected function controlBarIsTurnedOff():Boolean {
			if(controlBarIsAtBottomPosition() || controlBarIsAtOverPosition() || controlBarIsAtTopPosition()) {
				return false;
			}
			return true;
		}

		protected function controlBarIsAtBottomPosition():Boolean {
			return StringUtils.matchesIgnoreCase(_player.config.controlbar, "BOTTOM");
		}

		protected function controlBarIsAtOverPosition():Boolean {
			return StringUtils.matchesIgnoreCase(_player.config.controlbar, "OVER");
		}

		protected function controlBarIsAtTopPosition():Boolean {
			return StringUtils.matchesIgnoreCase(_player.config.controlbar, "TOP");
		}
		
		protected function controlBarVisibleAtBottom():Boolean {
			return (controlBarIsAtBottomPosition() || 
			       controlBarIsAtOverPosition() || 
			       (_player.config.fullscreen && controlBarIsAtTopPosition()));
		}
		
		protected function controlBarIsSkinned():Boolean {
			return (_player.config.skin != null);
		}

		protected function getControlBarYPosition():Number {
			if(controlBarIsTurnedOff() || (_player.fullscreen == false && controlBarIsAtTopPosition())) {
				return -1;
			}
			else {
			    var cb:IControlbarComponent = _player.controls.controlbar;
				if(cb != null) {
				    if(cb is ControlbarComponentV4) {
				    	return ControlbarComponentV4(cb).y;
				    }
					else if(cb is ControlbarComponent) {
			    		return ControlbarComponent(cb).y;
					}
				}
				return -1;				
			}
		}

		protected function getControlBarHeight():Number {
			if(_vastController != null) {
				if(_vastController.config.playerConfig.hasControlBarHeightSpecified()) {
					return _vastController.config.playerConfig.getControlBarHeight();
				}
			}
			return getPlayerReportedControlBarHeight();
		}

		protected function getPlayerReportedControlBarHeight():Number {
			if(_playerReportedControlBarHeight < 0) {
			    var cb:IControlbarComponent = _player.controls.controlbar;
	
			    if(cb is ControlbarComponentV4) {
			    	_playerReportedControlBarHeight = ControlbarComponentV4(cb).height;
			    }
				else if(cb is ControlbarComponent) {
			    	_playerReportedControlBarHeight = ControlbarComponent(cb).height;
				}
				else _playerReportedControlBarHeight = 0;			
			}
			return _playerReportedControlBarHeight;
		}			

		protected function getControlBarVisibilityState():Boolean {
		    var cb:IControlbarComponent = _player.controls.controlbar;
		    
		    if(cb is ControlbarComponentV4) {
		    	return ControlbarComponentV4(cb).visible;
		    }
			else if(cb is ControlbarComponent) {
		    	return ControlbarComponent(cb).visible;
			}
			return true;			
		}
		
		protected function assessControlBarState():void {
		    var cb:IControlbarComponent = _player.controls.controlbar;
		    var visibilityState:Boolean = _lastVisibilityStateForControls;
		    
		    visibilityState = getControlBarVisibilityState();

	        if(visibilityState != _lastVisibilityStateForControls) {
        		if(visibilityState) {
        			resizeWithControls(width, height);
        		}
        		else {
        			resizeWithHiddenControls();
        		}

			    if(cb is ControlbarComponentV4) {
    	    		_lastVisibilityStateForControls = ControlbarComponentV4(cb).visible;
			    }
				else if(cb is ControlbarComponent) {
    	    		_lastVisibilityStateForControls = ControlbarComponent(cb).visible;
    	  		}
			}
		}
		
		protected function setControlBarVisibility(visible:Boolean):void {
		    var cb:IControlbarComponent = _player.controls.controlbar;
		    
		    if(cb is ControlbarComponentV4) {
				CONFIG::debugging { doLog("Setting V4 controlbar visibility to " + visible, Debuggable.DEBUG_DISPLAY_EVENTS); }
		    	ControlbarComponentV4(cb).visible = visible;
		    }
			else if(cb is ControlbarComponent) {
				CONFIG::debugging { doLog("Setting V5 controlbar visibility to " + visible, Debuggable.DEBUG_DISPLAY_EVENTS); }
		    	ControlbarComponent(cb).visible = visible;
			}			
			assessControlBarState();
		}
		
		protected function turnOffControlBar(isVPAID:Boolean):void {
			if(_vastController != null) {
				if(_vastController.config.playerConfig.shouldManageControlsDuringLinearAds(isVPAID)) { 
					if(_vastController.config.playerConfig.shouldHideControlsOnLinearPlayback(isVPAID)) {
						setControlBarVisibility(false);
					}
					else if(_vastController.config.playerConfig.shouldDisableControlsDuringLinearAds(isVPAID)) {
						lockControlBar(isVPAID);
					}
					else {
						CONFIG::debugging { doLog("Ignored request to disable the control bar - disableControls == false", Debuggable.DEBUG_DISPLAY_EVENTS); }
					} 
				}
			}
		}
		
		protected function turnOnControlBar():void {
			setControlBarVisibility(true);
			unlockControlBar();
		}

		protected function lockControlBar(isVPAID:Boolean):void {
			if(_vastController != null) {
				if(_vastController.config.playerConfig.shouldManageControlsDuringLinearAds(isVPAID)) { 			
				    var cb:IControlbarComponent = _player.controls.controlbar;
				    if(cb is ControlbarComponentV4) {
				    	if(_v4ControlBarLocked == false) {
					        ControlbarComponentV4(cb).block(true);
					        _v4ControlBarLocked = true;
					    	CONFIG::debugging { doLog("V4 control bar locked - fine grained control not available", Debuggable.DEBUG_DISPLAY_EVENTS); }
					    }
				    }
				    if(cb is ControlbarComponent) {
				    	CONFIG::debugging { doLog("Disabling a V5 control bar - fine grained control is available", Debuggable.DEBUG_DISPLAY_EVENTS); }
				        if(cb.getButton('play') != null) {
				        	if(cb.getButton('play') is ComponentButton) {
						        ComponentButton(cb.getButton('play')).enabled = _vastController.controlEnabledStateForLinearAdType(ControlsSpecification.PLAY, isVPAID); 
				        	}
				        }
				        if(cb.getButton('pause') != null) {
				        	if(cb.getButton('pause') is ComponentButton) {
						        ComponentButton(cb.getButton('pause')).enabled = _vastController.controlEnabledStateForLinearAdType(ControlsSpecification.PAUSE, isVPAID);
				        	}
				        }
				        if(cb.getButton('mute') != null) {
				        	if(cb.getButton('mute') is ComponentButton) {
						        ComponentButton(cb.getButton('mute')).enabled = _vastController.controlEnabledStateForLinearAdType(ControlsSpecification.MUTE, isVPAID);
				        	}
				        }
				        if(cb.getButton('unmute') != null) {
				        	if(cb.getButton('unmute') is ComponentButton) {
						        ComponentButton(cb.getButton('unmute')).enabled = _vastController.controlEnabledStateForLinearAdType(ControlsSpecification.MUTE, isVPAID);
				        	}
				        }
				        if(cb.getButton('fullscreen') != null) {
				        	if(cb.getButton('fullscreen') is ComponentButton) {
						        ComponentButton(cb.getButton('fullscreen')).enabled = _vastController.controlEnabledStateForLinearAdType(ControlsSpecification.FULLSCREEN, isVPAID);
				        	}
				        }
				        if(cb.getButton('normalscreen') != null) {
				        	if(cb.getButton('normalscreen') is ComponentButton) {
						        ComponentButton(cb.getButton('normalscreen')).enabled = _vastController.controlEnabledStateForLinearAdType(ControlsSpecification.FULLSCREEN, isVPAID);
				        	}
				        }
				        if(cb.getButton('next') != null) {
				        	if(cb.getButton('next') is ComponentButton) {
						        ComponentButton(cb.getButton('next')).enabled = _vastController.controlEnabledStateForLinearAdType(ControlsSpecification.PLAYLIST, isVPAID);
				        	}
				        }
				        if(cb.getButton('prev') != null) {
				        	if(cb.getButton('prev') is ComponentButton) {
						        ComponentButton(cb.getButton('prev')).enabled = _vastController.controlEnabledStateForLinearAdType(ControlsSpecification.PLAYLIST, isVPAID);
				        	}
				        }
				        if(cb.getButton('volume') != null) {
				        	if(cb.getButton('volume') is ComponentButton) {
						        ComponentButton(cb.getButton('volume')).enabled = _vastController.controlEnabledStateForLinearAdType(ControlsSpecification.VOLUME, isVPAID); 		        	
				        	}
				        	else if(cb.getButton('volume') is Slider) {
				        		if(_vastController.controlEnabledStateForLinearAdType(ControlsSpecification.VOLUME, isVPAID) == false) {
							        Slider(cb.getButton('volume')).lock();		        			
				        		}
				        	}
				        } 
				        lockTimelineOnControlBar(cb, false);
				    }
				    CONFIG::debugging { doLog("Control bar has been disabled", Debuggable.DEBUG_DISPLAY_EVENTS); }					
				}
			}
		}
		
		protected function unlockControlBar():void {
		    var cb:IControlbarComponent = _player.controls.controlbar;
		    if(cb is ControlbarComponentV4) {
		    	if(_v4ControlBarLocked) {
			        ControlbarComponentV4(cb).block(false);
			        _v4ControlBarLocked = false;
				    CONFIG::debugging { doLog("V4 control bar has been unlocked", Debuggable.DEBUG_DISPLAY_EVENTS);	}				
			    }
		    }
		    if(cb is ControlbarComponent) {
		        if(cb.getButton('play') != null) {
		        	if(cb.getButton('play') is ComponentButton) {
				        ComponentButton(cb.getButton('play')).enabled = true;
		        	}
		        }
		        if(cb.getButton('pause') != null) {
		        	if(cb.getButton('pause') is ComponentButton) {
				        ComponentButton(cb.getButton('pause')).enabled = true;
		        	}
		        }
		        if(cb.getButton('mute') != null) {
		        	if(cb.getButton('mute') is ComponentButton) {
				        ComponentButton(cb.getButton('mute')).enabled = true;
		        	}
		        }
		        if(cb.getButton('unmute') != null) {
		        	if(cb.getButton('unmute') is ComponentButton) {
				        ComponentButton(cb.getButton('unmute')).enabled = true;
		        	}
		        }
		        if(cb.getButton('fullscreen') != null) {
		        	if(cb.getButton('fullscreen') is ComponentButton) {
				        ComponentButton(cb.getButton('fullscreen')).enabled = true;
		        	}
		        }
		        if(cb.getButton('normalscreen') != null) {
		        	if(cb.getButton('normalscreen') is ComponentButton) {
				        ComponentButton(cb.getButton('normalscreen')).enabled = true;
		        	}
		        }
		        if(cb.getButton('next') != null) {
		        	if(cb.getButton('next') is ComponentButton) {
				        ComponentButton(cb.getButton('next')).enabled = true;
		        	}
		        }
		        if(cb.getButton('prev') != null) {
		        	if(cb.getButton('prev') is ComponentButton) {
				        ComponentButton(cb.getButton('prev')).enabled = true;
		        	}
		        }
		        if(cb.getButton('volume') != null) {
		        	if(cb.getButton('volume') is ComponentButton) {
				        ComponentButton(cb.getButton('volume')).enabled = true;
		        	}
		        	else if(cb.getButton('volume') is Slider) {
				        Slider(cb.getButton('volume')).unlock();		        			
		        	}
		        } 	
		        unlockTimelineOnControlBar(cb, false);
			    CONFIG::debugging { doLog("Control bar has been enabled", Debuggable.DEBUG_DISPLAY_EVENTS);	}				
		    }
		}

		protected function lockTimelineOnControlBar(cb:IControlbarComponent=null, alwaysLock:Boolean=true, includeV4ControlBars:Boolean=true):void {
			if(_vastController != null) {
				if(_vastController.config.playerConfig.shouldManageControlsDuringLinearAds(false)) {	
			        if(_vastController.controlEnabledStateForLinearAdType(ControlsSpecification.TIME, false) == false) {
						try {
						    if(cb == null) cb = _player.controls.controlbar;
						    if(cb is ControlbarComponentV4) {
								if(includeV4ControlBars) {
									ControlbarComponentV4(cb).getChildAt(0)["timeSlider"].mouseEnabled = false;
								}
							    CONFIG::debugging { doLog("The V4 Timeline has been locked", Debuggable.DEBUG_DISPLAY_EVENTS); }						
						    }		    
						    else if(cb is ControlbarComponent) {
						        if(cb.getButton('time') != null) {
						        	if(cb.getButton('time') is ComponentButton) {
								        ComponentButton(cb.getButton('time')).enabled = 
								        		(alwaysLock) ? false 
								        		             : _vastController.controlEnabledStateForLinearAdType(ControlsSpecification.TIME, false); 		        	
						        	}
						        	else if(cb.getButton('time') is Slider) {
						        		if(alwaysLock) {
									        Slider(cb.getButton('time')).lock();
						        		}
						        		else if(_vastController.controlEnabledStateForLinearAdType(ControlsSpecification.TIME, false) == false) {
									        Slider(cb.getButton('time')).lock();		        			
						        		}
						        	}
						        } 	
							    CONFIG::debugging { doLog("The Timeline on the Control Bar has been locked", Debuggable.DEBUG_DISPLAY_EVENTS);	}						
						    }				
						}
						catch(e:Error) {
						    CONFIG::debugging { doLog("Exception attempting to lock the Timeline - " + e.message, Debuggable.DEBUG_DISPLAY_EVENTS);	}										
						}
			        }
			        else unlockTimelineOnControlBar(cb, false);
				}
		        else unlockTimelineOnControlBar(cb, false);
			}
		}

		protected function unlockTimelineOnControlBar(cb:IControlbarComponent=null, includeV4ControlBars:Boolean=true):void {
			if(_vastController != null) {
				if(_vastController.config.playerConfig.shouldManageControlsDuringLinearAds(false)) {					
					try {
					    if(cb == null) cb = _player.controls.controlbar;
					    if(cb is ControlbarComponentV4) {
							if(includeV4ControlBars) {
								ControlbarComponentV4(cb).getChildAt(0)["timeSlider"].mouseEnabled = true;
							}
						    CONFIG::debugging { doLog("The V4 Timeline has been unlocked", Debuggable.DEBUG_DISPLAY_EVENTS); }							
					    }		    
					    else if(cb is ControlbarComponent) {
					        if(cb.getButton('time') != null) {
					        	if(cb.getButton('time') is ComponentButton) {
							        ComponentButton(cb.getButton('time')).enabled = true;		        	
					        	}
					        	else if(cb.getButton('time') is Slider) {
							        Slider(cb.getButton('time')).unlock();
					        	}
					        }
						    CONFIG::debugging { doLog("The Timeline on the Control Bar has been unlocked", Debuggable.DEBUG_DISPLAY_EVENTS); }							
					    }			
					}
					catch(e:Error) {
					    CONFIG::debugging { doLog("Exception attempting to unlock the Timeline - " + e.message, Debuggable.DEBUG_DISPLAY_EVENTS);	}														
					}					
				}
			}
		}		

        /**
         * AD DISPLAY RELATED CALLBACK HANDLERS
         * 
         **/ 

		public function onDisplayNotice(displayEvent:AdNoticeDisplayEvent):void {	
			CONFIG::debugging { doLog("PLUGIN NOTIFICATION: Event received to display ad notice", Debuggable.DEBUG_DISPLAY_EVENTS); }
		}
				
		public function onHideNotice(displayEvent:AdNoticeDisplayEvent):void {	
			CONFIG::debugging { doLog("PLUGIN NOTIFICATION: Event received to hide ad notice", Debuggable.DEBUG_DISPLAY_EVENTS); }
		}
				
		public function onDisplayOverlay(displayEvent:OverlayAdDisplayEvent):void {
			CONFIG::debugging { doLog("PLUGIN NOTIFICATION: Event received to display non-linear overlay ad (" + displayEvent.toString() + ")", Debuggable.DEBUG_DISPLAY_EVENTS); }
		}

		public function onOverlayCloseClicked(displayEvent:OverlayAdDisplayEvent):void {
			CONFIG::debugging { doLog("PLUGIN NOTIFICATION: Event received - overlay close has been clicked (" + displayEvent.toString() + ")", Debuggable.DEBUG_DISPLAY_EVENTS); }
		}

		public function onOverlayClicked(displayEvent:OverlayAdDisplayEvent):void {
			CONFIG::debugging { doLog("PLUGIN NOTIFICATION: Event received - overlay has been clicked (" + displayEvent.toString() + ") - time is " + _lastTimeTick, Debuggable.DEBUG_DISPLAY_EVENTS); }

            if(displayEvent.nonLinearVideoAd.hasAccompanyingVideoAd()) {
            	var overlayStreamSequence:StreamSequence = _vastController.getActiveOverlayStreamSequence();
            	if(overlayStreamSequence != null) {
	            	var playlist:JWPlaylist = 
	            			new JWPlaylist(
	            	              overlayStreamSequence, 
	            	              _vastController.config.showsConfig.providersConfig, 
			                      _vastController.config.adsConfig.providersConfig
			                );
			                
	            	if(playlist.length > 0) {            		
						CONFIG::debugging { doLog("Loading the overlay linear ad track as playlist " + playlist, Debuggable.DEBUG_PLAYLIST); }
		                var item:JWPlaylistItem = playlist.nextTrackAsPlaylistItem() as JWPlaylistItem;
		                if(item != null) {
		                	stopPlayback();
							_vastController.activeOverlayVideoPlaying = true;
		                	loadJWClip(item);
							startPlayback();
		                }
		                else {	
		                	CONFIG::debugging { doLog("No clip available in the overlay linear playlist to load into the player", Debuggable.DEBUG_PLAYLIST);	}	
		                }				
						_activeOverlayAdSlotKey = displayEvent.adSlot.key; 
	            	}
					else {
						CONFIG::debugging { doLog("Cannot play the linear ad - playlist is empty: " + playlist, Debuggable.DEBUG_PLAYLIST); }
					}            		
            	}
            	else {
					_vastController.activeOverlayVideoPlaying = false;
					_activeOverlayAdSlotKey = -1;					
					CONFIG::debugging { doLog("Cannot play the linear ad - playlist is empty: " + playlist, Debuggable.DEBUG_PLAYLIST); }           		
            	}
            }
			else {
				if(displayEvent.nonLinearVideoAd.isInteractive()) {
					// for VPAID ads, we push the click events back into the player because they don't seem to bubble in there themselves for some reason
					if(displayEvent.originalMouseEvent.target is OverlayView) {	
						CONFIG::debugging { doLog("Sending mouse click event to player as it happened around the VPAID ad display area", Debuggable.DEBUG_VPAID); }				
						_player.controls.display.dispatchEvent(displayEvent.originalMouseEvent);
					}
				}
				else if(displayEvent.nonLinearVideoAd.hasClickThroughURL() && _vastController.pauseOnClickThrough) {
					// it's a website click through overlay so stop the video stream
					pausePlayback();
			 	}
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
         * COMPANION AD CALLBACK HANDLERS
         * 
         **/ 
        
        public function onDisplayCompanionAd(companionEvent:CompanionAdDisplayEvent):void {
			CONFIG::debugging { doLog("PLUGIN NOTIFICATION: Event received to display companion ad (" + companionEvent.companionAd.width + "X" + companionEvent.companionAd.height + ")", Debuggable.DEBUG_DISPLAY_EVENTS); }
        }

		public function onHideCompanionAd(companionEvent:CompanionAdDisplayEvent):void {
			CONFIG::debugging { doLog("PLUGIN NOTIFICATION: Event received to hide companion ad (" + companionEvent.companionAd.width + "X" + companionEvent.companionAd.height + ")", Debuggable.DEBUG_DISPLAY_EVENTS); }
		}

        /**
         * PLAYER STATE CHANGE CALLBACK HANDLERS
         * 
         **/ 

		protected function onPlayerStateChange(evt:PlayerStateEvent):void {
			if(evt.newstate == "PLAYING") {
				if(activeStreamIsShowStream()) {
					// safety valve to make sure that the control bar is shown and ad notices hidden for show streams
					_vastController.closeAllAdMessages();
					unlockControlBar();
				}
				if(_vastController.requiresStreamTimer()) {
					startStreamTimer();					
				}
				if(activeClipIsLinearVPAIDAd()) {
					CONFIG::debugging { doLog("A linear stream is playing (based on state change) but the active ad slot is a VPAID linear ad - stopping the player", Debuggable.DEBUG_PLAYLIST); }
					stopPlayback();
					if(haveActiveVPAIDAd() == false) {
						CONFIG::debugging { doLog("player.play() Javascript API must have been used to start playback - forcing active VPAID ad to start playing", Debuggable.DEBUG_PLAYLIST); }
						playPendingVPAIDAdSlot();
					}
				}
	            _lastActiveStreamIndex = getActiveStreamIndex();
			}
			else {
				if(activeStreamIsShowStream()) {
					// safety valve to make sure that the control bar is shown and ad notices hidden for show streams
					_vastController.closeAllAdMessages();
					unlockControlBar();
				}
				if(_vastController.requiresStreamTimer()) {
					stopStreamTimer();					
				}
			}

            // Special check to see if the dock has to be hidden - this helps plugin compatibility with OVA

			if(_vastController.config.playerConfig.linearControls.stream.hideDock) {
				if(activeStreamIsLinearAd()) {
					CONFIG::debugging { doLog("Hiding the dock - 'hideDock' set in player config", Debuggable.DEBUG_DISPLAY_EVENTS); }
					_player.controls.dock.hide();
				}
				else {
					CONFIG::debugging { doLog("Showing the dock - 'hideDock' set in player config", Debuggable.DEBUG_DISPLAY_EVENTS); }
					_player.controls.dock.show();
				}
			}
		}
		
		protected function onPlayerError(evt:PlayerEvent):void {
			//doLog("Player error: " + evt.message, Debuggable.DEBUG_ALWAYS);
		}

        protected function onSeekEvent(evt:ViewEvent):void {
        	if(_vastController != null) {
				if(_vastController.isActiveOverlayVideoPlaying()) {
        			_vastController.onPlayerSeek(_activeOverlayAdSlotKey, true);
        		}
        		else _vastController.onPlayerSeek(getActiveStreamIndex());
        	}
        }

		protected function setActiveVPAIDAdVolume(volume:Number):void {
			var vpaidAd:IVPAID = _vastController.getActiveVPAIDAd();
			if(vpaidAd != null) {
 				CONFIG::debugging { doLog("Setting VPAID Ad volume to " + (volume / 100), Debuggable.DEBUG_VPAID); }
				if(volume == 0) {
					vpaidAd.adVolume = 0;
				}
				else {
    				vpaidAd.adVolume = (volume / 100);    					
				}
			}
		}
		
		protected function onVolumeChangeEvent(evt:MediaEvent):void {
        	if(_vastController != null) {
        		if(_vastController.isVPAIDAdPlaying()) {
        			setActiveVPAIDAdVolume(evt.volume);
        		}
        		_vastController.playerVolume = getPlayerVolume();
        	}
  		}
  
		protected function onMuteEvent(evt:MediaEvent):void {
        	if(_vastController != null) {
				var vpaidAd:IVPAID;
				if(evt.mute) {
	        		if(_vastController.isVPAIDAdPlaying()) {
	        			vpaidAd = _vastController.getActiveVPAIDAd();
	        			if(vpaidAd != null) {
	        				CONFIG::debugging { doLog("Muting VPAID Ad", Debuggable.DEBUG_VPAID); }
	        				vpaidAd.adVolume = 0;
	        			}
	        		}
	        		else {
						if(_vastController.isActiveOverlayVideoPlaying()) {
		        			_vastController.onPlayerMute(_activeOverlayAdSlotKey, true, getLastTimeTickAsTimestamp());
		        		}
		        		else _vastController.onPlayerMute(getActiveStreamIndex(), false, getLastTimeTickAsTimestamp());	        			
	        		}
	        		_vastController.playerVolume = 0;
	        	}
				else {
	        		if(_vastController.isVPAIDAdPlaying()) {
	        			setActiveVPAIDAdVolume(_player.config.volume);
	        		}
	        		else {
						if(_vastController.isActiveOverlayVideoPlaying()) {
		        			_vastController.onPlayerUnmute(_activeOverlayAdSlotKey, true, getLastTimeTickAsTimestamp());
		        		}
		        		else _vastController.onPlayerUnmute(getActiveStreamIndex(), false, getLastTimeTickAsTimestamp());	        			
	        		}
	        		_vastController.playerVolume = getPlayerVolume();
	        	}				
			}
		}

		protected function onStopEvent(evt:ViewEvent):void {
			if(!_forcedStop) {
		       	if(_vastController != null) {
					recordLastPlayerPlaybackEvent(ViewEvent.JWPLAYER_VIEW_STOP);
 					if(_vastController.isActiveOverlayVideoPlaying()) {
		       			_vastController.onPlayerStop(_activeOverlayAdSlotKey, true, getLastTimeTickAsTimestamp());
		       		}
		       		else _vastController.onPlayerStop(getActiveStreamIndex(), false, getLastTimeTickAsTimestamp());
		       	}			
			}
			_forcedStop = false;
		}

		protected function onPauseEvent(evt:ViewEvent):void {
	       	if(_vastController != null) {
				recordLastPlayerPlaybackEvent(ViewEvent.JWPLAYER_VIEW_PAUSE);
				if(_vastController.isActiveOverlayVideoPlaying()) {
	       			_vastController.onPlayerPause(_activeOverlayAdSlotKey, true, getLastTimeTickAsTimestamp());
	       		}
	       		else _vastController.onPlayerPause(getActiveStreamIndex(), false, getLastTimeTickAsTimestamp());
	       	}
	       	_playerPaused = true;
		}

		protected function getLastTimeTickAsTimestamp():String {
			return Timestamp.millisecondsToTimestamp(_lastTimeTick * 1000);
		}
		
		protected function onPlayEvent(evt:ViewEvent):void {
			if(_vastController != null) {
				recordLastPlayerPlaybackEvent(ViewEvent.JWPLAYER_VIEW_PLAY);

       			var activeStreamIndex:int = getActiveStreamIndex();
				var activeStream:Stream = _vastController.streamSequence.getStreamAtIndex(activeStreamIndex);

				if((activeStream is AdSlot) && havePendingVPAIDAdSlot()) {
					if(_vastController.allowPlaylistControl && AdSlot(activeStream).loadOnDemand && AdSlot(activeStream).requiresLoading()) {
						// Needs to reload - action will be taken below 
					}
					else {
						updateCustomLogoState(false, true);
						resizeWithControls(width, height);
						playPendingVPAIDAdSlot();
						_playerPaused = false;
						return;
					}
				}
		       	else if(_playerPaused) {
					updateCustomLogoState();
					if(_vastController.isActiveOverlayVideoPlaying()) {
						_vastController.onPlayerResume(_activeOverlayAdSlotKey, true, getLastTimeTickAsTimestamp());
		       		}
		       		else {
		       			_vastController.onPlayerResume(getActiveStreamIndex(), false, getLastTimeTickAsTimestamp());
		       		}
		       	}
		       	else {
		       		updateCustomLogoState();
		       	}
		       	_playerPaused = false;				

				if(_vastController.allowPlaylistControl) {
	       			// is this an empty ad slot - if it is, then skip over it - this rule is only in play for fully loaded playlists
	       			if(activeStream is AdSlot) {
	       				if(AdSlot(activeStream).isLinear()) {
							if(AdSlot(activeStream).loadOnDemand && AdSlot(activeStream).requiresLoading()) {
								CONFIG::debugging { doLog("Triggering load of ad slot onPlayEvent() because it's 'loadOnDemand' and it 'requiresLoading'", Debuggable.DEBUG_PLAYLIST); }
                                _lastActiveStreamIndex = activeStreamIndex;
								loadAdSlot(activeStream as AdSlot);
							}
	       				}
	       			}
				}
			}
		}

		protected function onFullscreenEvent(evt:ViewEvent):void {
	       	if(_vastController != null) {
	       		if(evt.data) { // going into fullscreen mode
		       		if(_inFullscreenMode == false) {
		       			_vastController.onPlayerFullscreenEntry(getActiveStreamIndex(), _vastController.isActiveOverlayVideoPlaying(), getLastTimeTickAsTimestamp());
		       		}
		       		else {	
		       			CONFIG::debugging { doLog("Ignored redundant fullscreen player event - evt.data == " + evt.data + " _inFullscreenMode == " + _inFullscreenMode, Debuggable.DEBUG_TRACKING_EVENTS); }
		       		}
	       		}
	       		else {
		       		if(_inFullscreenMode) {
		       			_vastController.onPlayerFullscreenExit(getActiveStreamIndex(), _vastController.isActiveOverlayVideoPlaying(), getLastTimeTickAsTimestamp());
		       		}
		       		else {
		       			CONFIG::debugging { doLog("Ignored redundant fullscreen player event - evt.data == " + evt.data + " _inFullscreenMode == " + _inFullscreenMode, Debuggable.DEBUG_TRACKING_EVENTS); }
		       		}
	       		}
	       		_inFullscreenMode = evt.data;	       			
	       	}
		}
		
		protected function streamAtIndexHasPrerollsAttached(activeStreamIndex:int):Boolean {
			if(activeStreamIndex > -1) {
				var activeStream:Stream = _vastController.streamSequence.streamAt(activeStreamIndex);
				if(activeStream != null) {
					if(activeStream is AdSlot) {
						return false;
					}			
					else return (activeStream.associatedPrerollAdSlot != null);					
				}
			}
			return false;
		}

		protected function recordLastPlayerPlaybackEvent(eventType:String):void {
			_lastPlayerPlaybackEvent = eventType;	
		}
		
        protected function validatePlaylistItem(index:int):void {
			if(index > -1) {
				CONFIG::debugging { doLog("Validating playlist item at index " + index, Debuggable.DEBUG_PLAYLIST); }
			    var stream:Stream = _vastController.streamSequence.streamAt(index);
			    if(stream != null) {
			    	if(stream is AdSlot) {
				    	if(AdSlot(stream).requiresLoading()) {
				    		CONFIG::debugging { doLog("The playlist item at index " + index + " is an AdSlot that is to be loaded 'onDemand' - triggering the load call...", Debuggable.DEBUG_PLAYLIST); }
				    		loadAdSlot(AdSlot(stream));
			    			return;
			    		}
			    		else {
			    			CONFIG::debugging { doLog("The playlist item at index " + index + " is an AdSlot that is already loaded ready for playback", Debuggable.DEBUG_PLAYLIST); }
			    		}	
			    	}
			    	else {	
			    		CONFIG::debugging { doLog("The playlist item at index " + index + " is a show stream - leaving untouched to playback", Debuggable.DEBUG_PLAYLIST); }
			    	}
			    }
			    else {
			    	CONFIG::debugging { doLog("Cannot get a handle to the playlist item at index " + index, Debuggable.DEBUG_PLAYLIST); }
			    }				
			}
			else {
				CONFIG::debugging { doLog("Active playlist index " + index + " is outside of playlist index range - cannot validate before playback", Debuggable.DEBUG_PLAYLIST); }
			}
        }		

		protected function onNextPlaylistItem(evt:ViewEvent):void {
			if(_vastController != null) {
				recordLastPlayerPlaybackEvent(ViewEvent.JWPLAYER_VIEW_NEXT);
				var activeStreamIndex:int = getActiveStreamIndex();
				if(activeStreamIndex > -1) {
					CONFIG::debugging { doLog("'Next' playlist item selected - active stream index at the moment is " + activeStreamIndex, Debuggable.DEBUG_PLAYLIST); }
					if(_vastController.isVPAIDAdPlaying()) {
						CONFIG::debugging { doLog("A VPAID ad is currently playing - close it down before moving onto the 'next' playlist item", Debuggable.DEBUG_PLAYLIST); }
						_vastController.closeActiveVPAIDAds();
					}
					if(activeStreamIndex + 1 < _player.playlist.length) {
						validatePlaylistItem(activeStreamIndex + 1);
					}
					else {
						validatePlaylistItem(0);
					}
				}
				else {
					CONFIG::debugging { doLog("Active playlist index " + activeStreamIndex + " is outside of playlist index range 0 to " + _player.playlist.length + " - cannot validate before playback", Debuggable.DEBUG_PLAYLIST); }
				}
			}
		}

		protected function onPreviousPlaylistItem(evt:ViewEvent):void {
			if(_vastController != null) {
				recordLastPlayerPlaybackEvent(ViewEvent.JWPLAYER_VIEW_PREV);
				var activeStreamIndex:int = getActiveStreamIndex();
				if(activeStreamIndex > -1) {
					CONFIG::debugging { doLog("'Previous' playlist item selected - active stream index at the moment is " + activeStreamIndex, Debuggable.DEBUG_PLAYLIST); }
					if(_vastController.isVPAIDAdPlaying()) {
						CONFIG::debugging { doLog("A VPAID ad is currently playing - close it down before moving onto the 'next' playlist item", Debuggable.DEBUG_PLAYLIST); }
						_vastController.closeActiveVPAIDAds();
					}
					if(activeStreamIndex-1 >= 0) {
						validatePlaylistItem(activeStreamIndex - 1);
					}
					else {
						validatePlaylistItem(_player.playlist.length - 1);
					}
				}
				else {
					CONFIG::debugging { doLog("Active playlist index " + activeStreamIndex + " is outside of playlist index range 0 to " + _player.playlist.length + " - cannot validate before playback", Debuggable.DEBUG_PLAYLIST); }
				}	
			}
		}
		
		protected function processPlaylistChangeToAdSlot(activeStreamIndex:int, startPlayback:Boolean=true):void {
			if(activeStreamIndex > -1) {
				if(_vastController.streamSequence.streamAt(activeStreamIndex) is AdSlot) {
					CONFIG::debugging { doLog("Processing change to ad slot clip at index " + activeStreamIndex + " - startPlayback == '" + startPlayback + "'", Debuggable.DEBUG_PLAYLIST); }
					var adSlot:AdSlot = _vastController.streamSequence.streamAt(activeStreamIndex) as AdSlot;
					if(adSlot != null) {
						if(adSlot.isInteractive()) {
							lockControlBar(true);
							CONFIG::debugging { doLog("AdSlot at index " + activeStreamIndex + " is a VPAID linear ad - expecting it to start playing now - startPlayback == '" + startPlayback + "'", Debuggable.DEBUG_PLAYLIST); }
			        		if(_vastController.isVPAIDAdPlaying() == false) {
				            	if(havePendingVPAIDAdSlot() == false) {
				            		CONFIG::debugging { doLog("There is no pending VPAID ad slot recorded. Setting this VPAID ad slot to pending " + ((startPlayback) ? "then playing" : ""), Debuggable.DEBUG_PLAYLIST); }
				            		setPendingVPAIDAdSlot(adSlot);
				            	}
				            	if(startPlayback) {
				            		if(adSlot.requiresLoading()) {
										CONFIG::debugging { doLog("Triggering a load on this ad slot - playback is suppose to start but it requires loading", Debuggable.DEBUG_PLAYLIST); }
										loadAdSlot(adSlot);
										return;
				            		}
				            		else playPendingVPAIDAdSlot();
				            	}
			            	}
			            	else {
			            		CONFIG::debugging { doLog("VPAID Ad reports that it is running already - leaving untouched", Debuggable.DEBUG_PLAYLIST); }
			            	}	
						}
						else {
							lockControlBar(false);
							if(adSlot.requiresLoading()) {
								if(startPlayback) {
									loadAdSlot(adSlot);
								}
								else {
									CONFIG::debugging { doLog("Holding on loading ad slot - 'play' is false in processPlaylistChangeToAdSlot()", Debuggable.DEBUG_PLAYLIST); }
								}
							}
							else {
								CONFIG::debugging { doLog("AdSlot at index " + activeStreamIndex + " is a linear ad stream that is already loaded - should just play as is - startPlayback == '" + startPlayback + "'", Debuggable.DEBUG_PLAYLIST); }
								if(startPlayback && isPlayerPlaying() == false) {
									this.startPlayback();
								}
							}
						}
					}
				}
				else {
					CONFIG::debugging { doLog("Unable to processPlaylistChangeToAdSlot() as the active stream @ index '" + activeStreamIndex + "' is not an ad slot", Debuggable.DEBUG_PLAYLIST); }
				}
			}
		}
		
        protected function moveToClipAtIndex(index:int=-1, absolutePosition:Boolean=false):Boolean {
	   		if(index > -1) {
	   			// we need to skip forward to a particular clip and start playback from there
	   			if(_vastController.allowPlaylistControl) {
	   				if(_vastController.delayAdRequestUntilPlay() && _delayedInitialisation) {
	   					// it's a delayed startup, so we don't have a full playlist including ads loaded up yet
	   					if(index < _player.playlist.length) {
		   					CONFIG::debugging { doLog("Attempting to commence delayed playback at original index '" + index + "'", Debuggable.DEBUG_API); }
		   					_player.playlist.currentIndex = index;
		   				}
		   				else {
		   					CONFIG::debugging { doLog("Cannot skip to and commence delayed playback at original index '" + index + "' - out of bounds (" + _player.playlist.length + ")", Debuggable.DEBUG_API); }
		   					return false;
		   				}
	   				}
	   				else {
		   				// we have the full playlist including ad slots loaded, so skip forward from there
    					CONFIG::debugging { doLog("Attempting to commence full playlist playback at index '" + index + "' - " + ((absolutePosition) ? "absolute index" : "relative index"), Debuggable.DEBUG_API); }
 		   				_player.playlist.currentIndex = 0;
	   				}
	   			}
	   			else {
	   				// we are loading clip by clip
	   				if(_vastController.delayAdRequestUntilPlay() && _delayedInitialisation) {
	   					CONFIG::debugging { doLog("Attempting to commence delayed clip-by-clip playback at index '" + index + "' - " + ((absolutePosition) ? "absolute index" : "relative index"), Debuggable.DEBUG_API);	}   					
	   					// NOT IMPEMENTED
	   					return false;
	   				}
	   				else {
	   					if(absolutePosition) {
	   						if(index < _vastController.streamSequence.length) {
			   					CONFIG::debugging { doLog("Attempting to commence clip-by-clip playback at index '" + index + "' - absolute index", Debuggable.DEBUG_API); }
				   				_player.playlist.currentIndex = index;
				   			}
				   			else {
			   					CONFIG::debugging { doLog("Cannot commence clip-by-clip playback at index '" + index + "' - absolute index out of bounds (" + _vastController.streamSequence.length + ")", Debuggable.DEBUG_API);	}			   				
				   			}
	   					}
	   					else {
		   					CONFIG::debugging { doLog("Attempting to commence clip-by-clip playback at index '" + index + "' - relative index", Debuggable.DEBUG_API); }
			   				_player.playlist.currentIndex = 0;
	   					}
		   			}
	   			}
	   		}
	   		return true;
        }
		
		protected function cleanupActiveAds():void {
			_vastController.closeActiveAdNotice();
			_vastController.closeActiveOverlaysAndCompanions();
			_vastController.closeActiveVPAIDAds();
			_vastController.hideAllRegions();
			showOVAReady();
			unlockControlBar();
		}

		protected function resetPlayer(closeActiveVPAIDAds:Boolean=false):void {
			if(_vastController.initialised) {
				CONFIG::debugging { doLog("Resetting the player - closing any active overlays, notices " + ((closeActiveVPAIDAds) ? "including VPAID Ads" : ""), Debuggable.DEBUG_CONFIG); }
				var activeStreamIndex:int = getActiveStreamIndex();
				if(closeActiveVPAIDAds) _vastController.closeActiveVPAIDAds();
				_vastController.hideAllOverlays();
	  			_vastController.closeActiveOverlaysAndCompanions();
				_vastController.disableVisualLinearAdClickThroughCue();
				_vastController.closeActiveAdNotice();
				if(!_vastController.isActiveOverlayVideoPlaying()) {
	       			_vastController.resetAllTrackingPointsAssociatedWithStream(activeStreamIndex);
				}
	            setPlayerScalingForCurrentClip();
	            
	            // Manipulate the custom logo if that is required
	            if(_vastController.streamSequence.streamAt(activeStreamIndex) is AdSlot) {
					if(_vastController.hideLogoOnLinearAdPlayback()) {
						if(justStarted() == false) {
							hideCustomLogo();
						}
						else restoreCustomLogo();
					}
	            }
	            else turnOnControlBar();
			}
		}
		
		protected function setPlayerScalingForCurrentClip():void {
			// Enact the scaling options for this clip
			if(_vastController.streamSequence != null) {
				var theScheduledStream:Stream = _vastController.streamSequence.streamAt(getActiveStreamIndex());

				if(_vastController.config.adsConfig.hasLinearScalingPreference() == false) {
					if(theScheduledStream is AdSlot) {
						// activate the appropriate scaling settings if the current stream is an ad
						if((theScheduledStream.isInteractive() && _vastController.enforceLinearInteractiveAdScaling()) ||
						   (theScheduledStream.isLinear() && _vastController.enforceLinearVideoAdScaling())) {
						   		if(_originalStretchingConfig == null) {
		                            // none (no stretching), exactfit (disproportionate), 
		                            // uniform (black borders), fill (uniform but completely fill)
						   			_originalStretchingConfig = _player.config.stretching;
						   		}
								if(theScheduledStream.canScale()) {
									if(theScheduledStream.shouldMaintainAspectRatio()) {	
										_player.config.stretching = "uniform";		
										CONFIG::debugging { doLog("Scaling set to (scale, maintain): UNIFORM", Debuggable.DEBUG_CONFIG); }
									}
									else {
										_player.config.stretching = "fill";
										CONFIG::debugging { doLog("Scaling set to (scale, don't maintain): FILL", Debuggable.DEBUG_CONFIG); }	
									}
								}
								else {
									if(!theScheduledStream.shouldMaintainAspectRatio()) {
										_player.config.stretching = "exactfit";
										CONFIG::debugging { doLog("Scaling set to (no scale, don't maintain): EXACT FIT", Debuggable.DEBUG_CONFIG);	}
									}
									else {
										_player.config.stretching = "none";		
										CONFIG::debugging { doLog("Scaling set to (no scale, maintain): NONE", Debuggable.DEBUG_CONFIG);	}
									}					
								}
						}	
					}
					else {
						// restore the scaling settings if the scaling has been changed in the player by OVA
						if(_originalStretchingConfig != null) {
							_player.config.stretching = _originalStretchingConfig;
							CONFIG::debugging { doLog("Scaling reset to original setting - " + _player.config.stretching, Debuggable.DEBUG_CONFIG); }
						}
					}
				}
				else {
					if(theScheduledStream is AdSlot) {
				   		if(_originalStretchingConfig == null) {
				   			_originalStretchingConfig = _player.config.stretching;
				   		}
						_player.config.stretching = _vastController.config.adsConfig.linearScaling;
						CONFIG::debugging { doLog("Linear ad scaling has been set to '" + _vastController.config.adsConfig.linearScaling + "'", Debuggable.DEBUG_CONFIG); }	
					}
					else {
						// restore the scaling settings if the scaling has been changed in the player by OVA
						if(_originalStretchingConfig != null) {
							_player.config.stretching = _originalStretchingConfig;
							CONFIG::debugging { doLog("Scaling reset to original setting - " + _player.config.stretching, Debuggable.DEBUG_CONFIG); }
						}
					}
				}
			}
		}
		
		/**
		 * 
		 * PLAYLIST LOAD EVENT HANDLERS
		 * 
		 **/
		
		protected function loadDelayedStartHoldingPlaylist():void {
			if(_needToDoStartPreProcessing) {
				// used to enforce impression sending where needed for empty Ad slots
				_vastController.processImpressionFiringForEmptyAdSlots();				
				_needToDoStartPreProcessing = false;
			}
			
			_playlist = createPlaylist();
			CONFIG::debugging { doLog("Playlist control is turned on - full playlist (" + _playlist.length + " items) have been loaded - all ad slots must be loading 'onDemand'", Debuggable.DEBUG_PLAYLIST); }
			_player.config.repeat="list";				
			loadPlaylistIntoPlayer(
					_playlist.toJWPlaylistItemArray(
							true,
							_vastController.config.adsConfig.metaDataConfig, 
							_vastController.config.adsConfig.holdingClipUrl 
					)
			);
		}

		protected function onOriginalPlaylistLoaded(evt:PlaylistEvent):void {
			if(ExternalInterface.available) {
				CONFIG::debugging { 
					try {
						ExternalInterface.call("console.log", "Block removed - original playlist has been loaded with " + _player.playlist.length + " items"); 
					}
					catch(e:Error) {}
				}
			}
			_player.removeEventListener(PlaylistEvent.JWPLAYER_PLAYLIST_LOADED, onOriginalPlaylistLoaded);
    	    lockPlayer(
    	        "Player lock requested for plugin initialisation",
    	    	function():void {
			   	    initialise();
    	    	}
    	    );
		}


		/**
		 * If we are operating in a mode where the full playlist is loaded in one go into the player mark the player index 
	     * on each clip in the loaded playlist so that it can be used as a cross-reference later during onDemandLoading
		 */
		protected function crossReferencePlayerAndOVAPlaylists(evt:PlaylistEvent):void {
			CONFIG::debugging { doLog("Cross-referencing the loaded player playlist (" + _player.playlist.length + " clips) with the OVA playlist (" + _vastController.streamSequence.length + " items) and marking indexes accordingly", Debuggable.DEBUG_PLAYLIST); }
			var count:int = 0;
			for(var i:int=0; i < _player.playlist.length; i++) {
				if(_player.playlist.getItemAt(i)["ovaRelatedPlaylistItemIndex"] != undefined) {
					if(_playlist.getTrackAtIndex(_player.playlist.getItemAt(i)["ovaRelatedPlaylistItemIndex"]) != null) {					
						if(_playlist.getTrackAtIndex(_player.playlist.getItemAt(i)["ovaRelatedPlaylistItemIndex"]) is JWPlaylistItem) {
							JWPlaylistItem(_playlist.getTrackAtIndex(_player.playlist.getItemAt(i)["ovaRelatedPlaylistItemIndex"])).playerPlaylistIndex = i;
							++count;
						}
						else {
							CONFIG::debugging { doLog("Player clip at index " + i + " is not an OVA JWPlaylistItem - ignoring", Debuggable.DEBUG_PLAYLIST); }
						}
					}
				}
				else {
					CONFIG::debugging { doLog("Player clip at index " + i + " is not an OVA JWPlaylistItem - ignoring", Debuggable.DEBUG_PLAYLIST); }
				}
			}
			CONFIG::debugging { doLog(count + " clips cross-referenced", Debuggable.DEBUG_PLAYLIST); }
		}
		
		protected function onPlaylistLoadedWithDelayedInitialisationEvent(evt:PlaylistEvent):void {
			CONFIG::debugging { doLog(_player.playlist.length + " clips have been loaded into the player playlist during delayed initialisation - removing startup playlist load listener", Debuggable.DEBUG_PLAYLIST); }
			_player.removeEventListener(PlaylistEvent.JWPLAYER_PLAYLIST_LOADED, onPlaylistLoadedWithDelayedInitialisationEvent);
			
			if(_rawConfig != null) {
				if(_rawConfig.supportExternalPlaylistLoading == true) {
					CONFIG::debugging { doLog("Registering external source playlist loaded event listener as 'canSupportExternalPlaylistLoading' is true - from onPlaylistLoadedWithDelayedInitialisationEvent()", Debuggable.DEBUG_PLAYLIST); }
					_player.addEventListener(PlaylistEvent.JWPLAYER_PLAYLIST_LOADED, onPlaylistLoadedExternallyEvent);			
				}
			}
		}
		
		protected function onPlaylistLoadedAtStartupEvent(evt:PlaylistEvent):void {
			CONFIG::debugging { doLog(_player.playlist.length + " clips have been loaded into the player playlist at startup - removing startup playlist load listener", Debuggable.DEBUG_PLAYLIST); }
			_player.removeEventListener(PlaylistEvent.JWPLAYER_PLAYLIST_LOADED, onPlaylistLoadedAtStartupEvent);

			if(_vastController.canSupportExternalPlaylistLoading()) {
				CONFIG::debugging { doLog("Registering external source playlist loaded event listener as 'canSupportExternalPlaylistLoading' is true - from onPlaylistLoadedAtStartup()", Debuggable.DEBUG_PLAYLIST); }
				_player.addEventListener(PlaylistEvent.JWPLAYER_PLAYLIST_LOADED, onPlaylistLoadedExternallyEvent);			
			}
			if(_vastController.delayAdRequestUntilPlay() && hasDelayedStartupClipIndex()) {
				setCurrentPlaylistIndex(getMappedDelayStartupClipIndex());
				resetDelayedStartupClipIndex();
			}
		}

		protected function onPlaylistLoadedExternallyEvent(evt:PlaylistEvent):void {
			if(initialisationDelayed() || _vastController.canSupportExternalPlaylistLoading()) {
				// determine if an external player.load() triggered this event
				if(haveOVALoadedPlaylistInTransit()) {
					if(loadedPlaylistMatchesOVALoadedPlaylistInTransit()) {
						// OVA triggered this event, so ignore it
						return;
					}
				}

				// OVA didn't trigger this event, so process it
				CONFIG::debugging { doLog("A new clip was loaded via an external player.load() call - triggering ad scheduling against the new playlist", Debuggable.DEBUG_PLAYLIST); }
                recordLastPlayerPlaybackEvent("ovaExternalPlaylistLoaded");
				reinitialise(true);
			}
		}
		
        /**
         * 
         * OVERLAY "CLICK TO PLAY" SUPPORT METHODS
         * 
         **/

		protected function resumeMainPlaylistPlayback():void {
			CONFIG::debugging { doLog("Restoring the last active main playlist clip	- seeking forward to time " + _lastTimeTick, Debuggable.DEBUG_PLAYLIST); }
			var item:JWPlaylistItem = _playlist.currentTrackAsPlaylistItem(_lastTimeTick, true) as JWPlaylistItem;
	        if(item != null) {
	            CONFIG::debugging { doLog("Reloading main playlist track at " + _lastTimeTick + " which was interrupted by an overlay linear video ad " + item.toShortString(), Debuggable.DEBUG_PLAYLIST); }
				_vastController.activeOverlayVideoPlaying = false;
				_resumingMainStreamPlayback = true;
				_activeOverlayAdSlotKey = -1;
				loadJWClip(item);
				startPlayback();
	        }
	        else {
	        	CONFIG::debugging { doLog("Oops, no main playlist stream in the playlist to load", Debuggable.DEBUG_FATAL); }
	        }
		}
 
        /**
         * 
         * "FULL PLAYLIST CONTROL" RUNTIME HANDLERS
         * 
         **/
        
        protected function onPlaylistItemSelect(evt:ViewEvent):void {
			CONFIG::debugging { doLog("User has selected playlist clip @ index '" + evt.data + "'", Debuggable.DEBUG_PLAYLIST); }
			recordLastPlayerPlaybackEvent(ViewEvent.JWPLAYER_VIEW_ITEM);
			if(_lastActiveStreamIndex == OVA_INDEX_AT_STARTUP) _lastActiveStreamIndex = -1;						
			if(_vastController.isVPAIDAdPlaying()) {
				CONFIG::debugging { doLog("Closing active VPAID Ads - new playlist item selected by user and there is a VPAID ad active", Debuggable.DEBUG_PLAYLIST); }
				_vastController.closeActiveVPAIDAds();					
			}     	

        }
        
        protected function triggerAttachedPreRollPlayback(activeStreamIndex:int):void {
			var newIndex:int = _vastController.streamSequence.streamAt(activeStreamIndex).associatedPrerollAdSlot.index;
			CONFIG::debugging { doLog("Stream at index " + activeStreamIndex + " has attached pre-roll(s) - setting index to first pre-roll to play - index is " + newIndex, Debuggable.DEBUG_PLAYLIST); }					
			activeStreamIndex = newIndex;
			setCurrentPlaylistIndex(activeStreamIndex);
        }
        
		protected function playlistSelectionHandler(evt:PlaylistEvent):void {	
			if(_vastController.allowPlaylistControl) {
				var activeStreamIndex:int = getActiveStreamIndex();
				
				/*
				 * CHECK 1 - Can we locate a Stream/AdSlot for the given activeStreamIndex - if not, do nothing
				 *
				 */
				var activeStream:Stream = null;
				if(activeStreamIndex == -1) {
					CONFIG::debugging { doLog("playlistSelectionHandler(): active playlist index is -1 - not processing this event", Debuggable.DEBUG_PLAYLIST); }
					return;
				}
				else activeStream = _vastController.streamSequence.streamAt(activeStreamIndex);

				CONFIG::debugging { 
					doLog("playlistSelectionHandler(): active playlist index changed to '" + activeStreamIndex + 
				      "' from '" + _lastActiveStreamIndex + 
				      "' lastPlayerPlaybackEvent='" + _lastPlayerPlaybackEvent + 
				      "' ovaLastModifiedPlaylist='" + _ovaLastModifiedPlaylist + 
				      "' isVPAIDPlaying()='" + _vastController.isVPAIDAdPlaying() + 
				      "' justStarted='" + justStarted() +
				      "' autoPlay='" + _vastController.autoPlay() + 
				      "' isPlayerPlaying='" + isPlayerPlaying() + 
				      "' lastPlaylistClipComplete='" + _lastPlaylistClipComplete + 
				      "' lastActiveStreamIndex='" + _lastActiveStreamIndex + "'", Debuggable.DEBUG_PLAYLIST);
				}

				// reset the tracking table for this stream if it is requested in the config
				if(activeStream != null) {
	               	if(_vastController.config.adsConfig.resetTrackingOnReplay) {
	               		activeStream.resetAllTrackingPoints();
	               	}
	               	else {
						activeStream.resetRepeatableTrackingPoints();
	               	}
				}

				/*
				 * CHECK 2 - Did we have the playlist selection event because a user manually selected a new clip from the 
				 * internal playlist control or via the control bar next clip button. If so, then check if we need to 
				 * always play any pre-rolls before the actual clip plays
				 *
				 */

				if((activeStream is AdSlot) == false) {
					if(_vastController.config.adsConfig.enforceLinearAdsOnPlaylistSelection) {
						if(_lastPlayerPlaybackEvent == ViewEvent.JWPLAYER_VIEW_ITEM || _lastPlayerPlaybackEvent == ViewEvent.JWPLAYER_VIEW_NEXT) { 
							recordLastPlayerPlaybackEvent(PlaylistEvent.JWPLAYER_PLAYLIST_ITEM);
							if(streamAtIndexHasPrerollsAttached(activeStreamIndex)) {
								// the last active clip was an ad, and the ad playback was cut short via manual selection of
								// the playlist item that is the parent of the pre-roll so go back and start playing the pre-roll
								_lastActiveStreamIndex = activeStreamIndex;
								triggerAttachedPreRollPlayback(activeStreamIndex);
								return;
							}
						}					
					}
				}

                /*
                 * CHECK 3 - Have we come to the end of the playlist? If so, rewind and reset to the start
                 *
                 */				
				if(evt != null && 
				   activeStreamIndex == 0 && 
				   _lastActiveStreamIndex == (_player.playlist.length-1) && 
				   _lastPlayerPlaybackEvent != ViewEvent.JWPLAYER_VIEW_ITEM &&
				   _lastPlayerPlaybackEvent != ViewEvent.JWPLAYER_VIEW_NEXT
				) { 
					CONFIG::debugging { doLog("Playlist has been rewound upon completion - active index is now 0", Debuggable.DEBUG_PLAYLIST); }
					if(_vastController.isVPAIDAdPlaying()) {
						_vastController.closeActiveVPAIDAds();
					}
					if(activeStream is AdSlot) {
						processPlaylistChangeToAdSlot(activeStreamIndex, false); 
					}
					else {
						this.turnOnControlBar();
						if(_vastController.autoPlay()) {
							CONFIG::debugging { doLog("Stopping playback - the first clip after rewinding is a show clip and autoPlay is true or player is playing - so force stop", Debuggable.DEBUG_PLAYLIST); }
							stopPlayback();
						}
					}
					return;
				}
	
	            /*
	             * CHECK 4 - Do we have an active VPAID ad when moving onto the next clip in the playlist? If so, and that
	             * next clip is an AdSlot, close down the active VPAID ad
	             */
				if(_vastController.isVPAIDAdPlaying()) {
					if(_vastController.streamSequence.streamAt(activeStreamIndex) is AdSlot) {
						CONFIG::debugging { doLog("Have moved onto the next item in the playlist which is an ad clip - closing the active VPAID ads", Debuggable.DEBUG_PLAYLIST); }
						_vastController.closeActiveVPAIDAds();
					}
				}
	
				resetPlayer();	  			  	    				
				if(justStarted() == false) updateCustomLogoState();

                /*
                 * CHECK 5 - If the newly active stream is an ad slot, assess the best way to play the ad slot and 
                 * process the change accordingly
                 * 
                 */
				if(activeStream is AdSlot) {
					processPlaylistChangeToAdSlot(activeStreamIndex, 
					    (
					       (justStarted() && _vastController.autoPlay()) ||
 					       (justStarted() && (_vastController.delayAdRequestUntilPlay() == false) && adSlotAtIndexRequiresLoading(0))
					    ) ? true 
					      : (((_lastPlayerPlaybackEvent == "ovaExternalPlaylistLoaded") && (_vastController.autoPlay() == false)) ? false : !justStarted())
					);
  			  	    _ovaLastModifiedPlaylist = false;
				    recordLastPlayerPlaybackEvent(PlaylistEvent.JWPLAYER_PLAYLIST_ITEM);
				}
				else {
					// it's a stream so it's already loaded 
					if(justStarted() == false && _vastController.autoPlay() && (activeStream.isSMIL() == false)) {
						// this case specifically exists for allowPlaylistControl:true, delayAdRequestUntilPlay:true, autostart:true, 
						// loadOnDemand:true, post-rolls with a show clip at (0)
						CONFIG::debugging { doLog("Forcibly starting playback because clip(0) is a show stream and autoplay is set", Debuggable.DEBUG_PLAYLIST); }
			  	        _ovaLastModifiedPlaylist = false;
				        recordLastPlayerPlaybackEvent(PlaylistEvent.JWPLAYER_PLAYLIST_ITEM);
						startPlayback();
					}
				}
			}
		}

		protected function playlistStreamCompleteStateHandler(evt:MediaEvent=null):void {
			_lastPlaylistClipComplete = _player.playlist.currentIndex;
			CONFIG::debugging { doLog("Playback of playlist clip @ index '" + _lastPlaylistClipComplete + "' is complete.", Debuggable.DEBUG_PLAYLIST); }
		}
		
        /**
         * 
         * "CLIP-BY-CLIP PLAYBACK" RUNTIME HANDLERS
         * 
         **/

        protected function rewindPlaylist():void {
            CONFIG::debugging { doLog("Rewinding and reloading the entire playlist", Debuggable.DEBUG_PLAYLIST); }
        	cleanupActiveAds();
        	_playlist.rewind();
        	_vastController.disableAutoPlay(); // stops the player continually replaying if autoPlay was true on first play through
        	if(_vastController.config.clearPlaylist) {
				this.clearPlaylist();
        	}
        	loadJWClip(_playlist.nextTrackAsPlaylistItem() as JWPlaylistItem, false, true, true, true); 
        	updateCustomLogoState(false, false);
        }
        
        protected function moveToNextPlaylistItem(play:Boolean=false, closeActiveVPAIDAds:Boolean=true):void {
        	if(_playlist != null) {
	            var item:JWPlaylistItem = _playlist.nextTrackAsPlaylistItem() as JWPlaylistItem;
	            if(item != null) {
	            	loadJWClip(item, false, closeActiveVPAIDAds);
	            	if(play) { 	
		            	startPlayback();
		            }
	            }
	            else {
	            	rewindPlaylist();
	            }
        	}
        }
        
		protected function streamCompleteStateHandler(evt:MediaEvent=null, forcePlay:Boolean=false, closeActiveVPAIDAds:Boolean=true):void {
			if(_vastController.allowPlaylistControl == false) {
				if(evt != null) {
					recordLastPlayerPlaybackEvent(MediaEvent.JWPLAYER_MEDIA_COMPLETE);
				}	
				if(_vastController.requiresStreamTimer()) {
					resetStreamTimer();
				}
			    if(_vastController.isActiveOverlayVideoPlaying() == false) {
			    	CONFIG::debugging { doLog("streamCompleteStateHandler() called - current playlist item index = " + _player.playlist.currentIndex + " player playlist has " + _player.playlist.length + " items loaded. allowPlaylistControl is '" + _vastController.allowPlaylistControl + "'", Debuggable.DEBUG_PLAYLIST); }
			    	moveToNextPlaylistItem(true, closeActiveVPAIDAds);
				}
				else {
					CONFIG::debugging { doLog("Overlay linear video ad complete - resuming normal stream", Debuggable.DEBUG_PLAYLIST); }
					resumeMainPlaylistPlayback();
				}
			}
		}

		protected function loadJWClip(item:JWPlaylistItem, forcePlay:Boolean=false, closeActiveVPAIDAds:Boolean=true, allowOnDemandAdSlotLoading:Boolean=true, justRewoundPlaylist:Boolean=false):void {		
			if(item != null) {
				CONFIG::debugging { doLog("loadJWClip() called - forcePlay='" + forcePlay + "', allowOnDemandAdSlotLoading='" + allowOnDemandAdSlotLoading + "'", Debuggable.DEBUG_PLAYLIST); }
				if(closeActiveVPAIDAds) {
					if(_vastController != null) _vastController.closeActiveVPAIDAds();
				}
			    if(item.isAd() && justRewoundPlaylist) {
					if(item.requiresLoading()) {
						if(_vastController.delayAdRequestUntilPlay()) {
							// we just rewound the playlist and the first item is an on-demand ad that requires loading, but we are operating
							// in "delayAdRequestUntilPlay" mode so register the delay play button handler and trigger the start of that load process
							setupPlayerToDelayInitialisation();
							return;
						}
						else {
							// this helps OVA determine that we have gone back to "justStarted" mode as a result of a rewind which is needed since this
							// ad slot requires a reload 
							_lastActiveStreamIndex = OVA_INDEX_AT_STARTUP; 
						}
					}
				}
				if(item.isAd() && item.requiresLoading() && allowOnDemandAdSlotLoading) { 
					CONFIG::debugging { doLog("Triggering load of 'onDemand' ad slot", Debuggable.DEBUG_PLAYLIST); }
					if(item.adSlot != null) {
						// It's an AdSlot that is either an "on demand" ad slot that is not already loaded, or is "on demand" with "refreshOnReplay==true"
						lockPlayer( 
						    "Player lock requested to process on-demand ad tag",
						    function():void {
								if(_vastController.loadAdSlotOnDemand(item.adSlot)) {
									// Ok, we've triggered the "on-demand" load - when that's complete, the AdSlotLoadEvent.LOADED event will be fired. At that
									// time, loadJWClip() will be called again and requiresLoading() will be false
								}
								else {
									CONFIG::debugging { doLog("FATAL: Cannot 'on-demand' load Ad Slot '" + item.adSlot.id + "' at index " + item.adSlot.index + " - skipping", Debuggable.DEBUG_PLAYLIST); }
									unlockPlayer();
									streamCompleteStateHandler();
								}						
   	    	                }
    	   	            );
					}
					else {
						CONFIG::debugging { doLog("FATAL: Item is an ad, but the AdSlot is null - skipping", Debuggable.DEBUG_PLAYLIST); }
						streamCompleteStateHandler();
					}
				}
				else if(item.isAd() && item.isInteractive()) {
					lockTimelineOnControlBar();
		            var holdingClip:com.longtailvideo.jwplayer.model.PlaylistItem = item.toJWPlaylistItemObject(true, _vastController.config.adsConfig.metaDataConfig, _vastController.config.adsConfig.holdingClipUrl);
		            if(holdingClip != null) {
						setPendingVPAIDAdSlot(AdSlot(item.stream));
						if((justStarted() && !_vastController.autoPlay() && !_vastController.delayAdRequestUntilPlay()) || _playlist.rewound()) {
							// If the player is just starting up, don't trigger the play of the VPAID ad just yet -
							// wait for the play button to be pressed first
							CONFIG::debugging { doLog("First stream is a VPAID ad, but autoPlay is false and play hasn't been hit yet, so wait for play before loading..", Debuggable.DEBUG_PLAYLIST); }
							if(haveSplashImage() && _vastController.config.clearPlaylist && _player.playlist.length == 0) {
								// If we have cleared out the playlist, and the first clip is a VPAID ad and there is a splash image
								// we need to compensate by putting in a holding clip to show the splash image otherwise it won't show
								// with an empty playlist
								holdingClip.image = _splashImage;
								holdingClip.file = _splashImage;
								holdingClip.type = "image";
								loadPlaylistIntoPlayer(holdingClip);
								CONFIG::debugging { doLog("Have loaded a holding clip to enable the splash image '" + _splashImage + "' to be displayed before a VPAID pre-roll - " + item.toShortString(), Debuggable.DEBUG_PLAYLIST);	}
							}
							else {
								loadPlaylistIntoPlayer(holdingClip);								
								CONFIG::debugging { doLog("Have loaded a holding clip to enable a VPAID pre-roll - " + item.toShortString(), Debuggable.DEBUG_PLAYLIST);	}	
							}
							setCurrentPlaylistIndex(0);
							unlockPlayer();
						}
						else {
							CONFIG::debugging { doLog("Loading VPAID linear playlist item (including a holding clip) - " + item.toShortString(), Debuggable.DEBUG_PLAYLIST); }
							updateCustomLogoState(false, true);
							resizeWithControls(width, height);
							loadPlaylistIntoPlayer(holdingClip);								
							playPendingVPAIDAdSlot();
						}
		            }
					else {
						CONFIG::debugging { doLog("FATAL: Unable to create a holding clip from the ad slot", Debuggable.DEBUG_PLAYLIST); }
					} 	
				}
				else {
		            var clip:com.longtailvideo.jwplayer.model.PlaylistItem = item.toJWPlaylistItemObject(true, _vastController.config.adsConfig.metaDataConfig, _vastController.config.adsConfig.holdingClipUrl);
		            if(clip != null) {
						var clipAlreadyLoaded:Boolean = (clip == _player.playlist.currentItem);
		                CONFIG::debugging { doLog("Loading playlist track " + item.toString(), Debuggable.DEBUG_PLAYLIST); }		                

		                turnOnControlBar();

						if(item.stream != null) {
		                	if(_vastController.config.adsConfig.resetTrackingOnReplay) {
		                		item.stream.resetAllTrackingPoints();
			                }
			                else {
								item.stream.resetRepeatableTrackingPoints();	                	
			                }
						}

		                if(item.isAd()) {
		                	item.markForRefresh();
							lockTimelineOnControlBar();
		                }
		                else unlockTimelineOnControlBar();

		                if(haveSplashImage()) {
		                	clip.image = _splashImage;
		                	CONFIG::debugging { doLog("Have set splash image on clip to " + clip.image, Debuggable.DEBUG_PLAYLIST); }
		                }
		                else {
		                	clip.image = null;
		                }
						loadPlaylistIntoPlayer(clip);
						if(_player.playlist.currentIndex < 0) {
							// This work-around was added because for some reason, if the original playlist is
							// cleared after being read in, the load of the first show clip after a pre-roll
							// results in the currentIndex remaining as -1 - this causes a problem playing the
							// loaded clip automatically after the pre-roll. Setting to 0 fixes the issue.
							setCurrentPlaylistIndex(0);
						}
			        	if(forcePlay && (isPlayerPlaying() == false)) {
			        		CONFIG::debugging { doLog("Forcing play - isAd == '" + item.isAd() + "' requiresLoad == '" + item.requiresLoading() + "' allowOnDemandAdSlotLoading == '" + allowOnDemandAdSlotLoading + "'", Debuggable.DEBUG_PLAYLIST); }
							startPlayback();
			        	}
						else {
			        		CONFIG::debugging { doLog("Not triggering play() - isAd == '" + item.isAd() + "' forcePlay == '" + forcePlay + "' requiresLoad == '" + item.requiresLoading() + "' allowOnDemandAdSlotLoading == '" + allowOnDemandAdSlotLoading + "'", Debuggable.DEBUG_PLAYLIST); }
						}
		    	    }
		        	else {
		        		CONFIG::debugging { doLog("Cannot convert the clip to a JW clip object - loading failed", Debuggable.DEBUG_FATAL); }
		        	}               								
				}
			}
			else {
				CONFIG::debugging { doLog("Cannot load JW clip from NULL JWPlaylistItem", Debuggable.DEBUG_PLAYLIST); }
			}
		}

        /**
         * 
         * EXTERNAL API
         * 
         **/

	   	protected function registerExternalAPI():void {
	   		try {
	   			if(ExternalInterface.available) {
	   				try {
						ExternalInterface.addCallback("ovaGetVersion", externalGetOVAPluginVersion);   			
						ExternalInterface.addCallback("ovaEnableAds", externalEnableAds);   			
						ExternalInterface.addCallback("ovaDisableAds", externalDisableAds);   			
						ExternalInterface.addCallback("ovaGetActiveAdDescriptor", externalGetActiveAdDescriptor); 
						ExternalInterface.addCallback("ovaPause", externalPause);   			
						ExternalInterface.addCallback("ovaResume", externalResume);   			
						ExternalInterface.addCallback("ovaStop", externalStop);   			
						ExternalInterface.addCallback("ovaScheduleAds", externalScheduleAds);   			
						ExternalInterface.addCallback("ovaLoadPlaylist", externalLoadPlaylist);   			
						ExternalInterface.addCallback("ovaGetAdSchedule", externalGetAdSchedule);   			
						ExternalInterface.addCallback("ovaGetStreamSequence", externalGetStreamSequence);   			
						ExternalInterface.addCallback("ovaSetDebugLevel", externalSetDebugLevel);   			
						ExternalInterface.addCallback("ovaGetDebugLevel", externalGetDebugLevel);   			
						ExternalInterface.addCallback("ovaSkipAd", externalSkipAd);   			
						ExternalInterface.addCallback("ovaClearOverlays", externalClearOverlays);   			
						ExternalInterface.addCallback("ovaShowOverlay", externalShowOverlay);   			
						ExternalInterface.addCallback("ovaHideOverlay", externalHideOverlay); 
						ExternalInterface.addCallback("ovaEnableAPI", externalEnableJavascriptCallbacks); 
						ExternalInterface.addCallback("ovaDisableAPI", externalDisableJavascriptCallbacks); 	
						ExternalInterface.addCallback("ovaSetActiveLinearAdVolume", externalSetActiveLinearAdVolume); 
						ExternalInterface.addCallback("ovaPlay", externalPlay); 	
		   				CONFIG::debugging { doLog("The External API has been registered", Debuggable.DEBUG_CONFIG); }
	   				}
	   				catch(e:Error) {}
	   			}
	   			else {
	   				CONFIG::debugging { doLog("Cannot register the External API - ExternalInterface is not available", Debuggable.DEBUG_CONFIG); }
	   			}	
	   		}
	   		catch(e:Error) {
	   			CONFIG::debugging { doLog("An exception has been thrown registering the External API - " + e.message, Debuggable.DEBUG_CONFIG); }
	   		}
	   	}

	   	protected function externalGetOVAPluginVersion():String {
	   		return _buildVersion;
	   	}
	   	
	   	protected function externalScheduleAds(playlist:*, newConfig:*):* {
			CONFIG::debugging { doLog("API call to reschedule playlist and ads...", Debuggable.DEBUG_API); }
	   		if(newConfig is String) {
	   			CONFIG::debugging { doLog("Loading new config data as String: " + newConfig, Debuggable.DEBUG_API); }
				try {
					_config = createPluginConfig(com.adobe.serialization.json.JSON.decode(newConfig, false));
				}
				catch(e:Error) {
					CONFIG::debugging { doLog("OVA Configuration parsing exception on " + _player.version + " - " + e.message, Debuggable.DEBUG_CONFIG); }
					return false;
				}
	   		}
	   		else if(newConfig is Object) {
	   			CONFIG::debugging { doLog("Loading new config data as Object", Debuggable.DEBUG_API); }	
	   			_config = createPluginConfig(newConfig);   			
	   		}
	   		else {
	   			CONFIG::debugging { doLog("Cannot initialise OVA with the provided config - it is not a String or Object", Debuggable.DEBUG_API); }
	   			return false;
	   		}
	   		
	   		if(playlist != null) {
	   			if(playlist is Array || playlist is Object) {
		   			CONFIG::debugging { doLog("A new playlist has been provided - loading it into the player before re-scheduling OVA", Debuggable.DEBUG_API); }
		   			cleanupActiveAds();
					removeAllPlayerEventListeners();
					_player.playlist.load(playlist);
					_player.playlist.currentIndex = 0;
					initialise();
	   			}
	   			else {
	   				CONFIG::debugging { doLog("Cannot reschedule - the playlist provided is not in the correct format", Debuggable.DEBUG_API); }
	   				return false;
	   			}
	   		}
	   		else {
	   			cleanupActiveAds();
	   			initialise(_rawConfig.shows);	
	   		}
			CONFIG::debugging { doLog("Rescheduling complete", Debuggable.DEBUG_JAVASCRIPT); }
	   		return true;
	   	}

	   	protected function externalSetActiveLinearAdVolume(volume:Number):* {
	   		if(_vastController != null) {
	   			if(_vastController.isVPAIDAdPlaying()) {
	   				CONFIG::debugging { doLog("API call made to set the active VPAID ad volume to '" + volume + "'", Debuggable.DEBUG_API); }
	   				setActiveVPAIDAdVolume(volume);
	   				return true;
	   			}
	   			else if(activeStreamIsLinearAd()) {
	   				CONFIG::debugging { doLog("API call made to set the active linear ad volume to '" + volume + "'", Debuggable.DEBUG_API); }
	   				_player.volume(volume);
	   				return true;
	   			}
	   			else {
	   				CONFIG::debugging { doLog("Unable to set the volume '" + volume + "' on the active linear ad - there doesn't seem to be one running at present", Debuggable.DEBUG_API); }
	   			}	
	   		}
	   		return false;
	   	}
	   	
	   	protected function externalLoadPlaylist(playlist:Array, reschedule:Boolean=true):* {
   			CONFIG::debugging { doLog("Not implemented", Debuggable.DEBUG_API); }
			return false;	   		
	   	}

	   	protected function externalEnableAds():* {
   			CONFIG::debugging { doLog("Not implemented", Debuggable.DEBUG_API); }
			return false;	   		
	   	}
	   	
	   	protected function externalDisableAds():* {
   			CONFIG::debugging { doLog("Not implemented", Debuggable.DEBUG_API); }
			return false;	   		
	   	}

		protected function externalGetActiveAdDescriptor():* {
			if(_vastController != null) {
				if(activeStreamIsLinearAd()) {
					var activeStream:Stream = _vastController.streamSequence.streamAt(getActiveStreamIndex())
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

	   	protected function externalPlay():* {
	   		CONFIG::debugging { doLog("API call received to start playback @ clip index " + _player.playlist.currentIndex, Debuggable.DEBUG_API); }
   			if(_delayedInitialisation) {
		   		_player.dispatchEvent(new ViewEvent(ViewEvent.JWPLAYER_VIEW_PLAY));
		   	}
	   		else if(activeStreamIsLinearAd()) {
			   	if(activeClipIsLinearVPAIDAd()) {
			   		_player.dispatchEvent(new ViewEvent(ViewEvent.JWPLAYER_VIEW_PLAY));			   		
			   	}
			   	else _player.play();
		   	}
		   	else _player.play();
	   		return true; 
	   	}

	   	protected function externalStop():* {
			if(_vastController != null) {
	   			if(activeClipIsLinearVPAIDAd()) {
	   				CONFIG::debugging { doLog("Stopping VPAID ad", Debuggable.DEBUG_API); }
	   				_vastController.overlayController.getActiveVPAIDAd().stopAd();
	   				return true;
	   			}
	   			else if(activeStreamIsLinearAd()) {
	   				CONFIG::debugging { doLog("Stopping Linear ad", Debuggable.DEBUG_API); }
	   				_player.stop();
	   				return true;
	   			}
	   			else if(activeStreamIsShowStream()) {
	   				CONFIG::debugging { doLog("Stopping show stream", Debuggable.DEBUG_API); }
	   				_player.stop();
	   				return true;	   				
	   			}
	  		}
			return false;	   		
	   	}

	   	protected function externalPause():* {
			if(_vastController != null) {
	   			if(activeClipIsLinearVPAIDAd()) {
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
			return false;	   		
	   	}
	   	
	   	protected function externalResume():* {
			if(_vastController != null) {
	   			if(activeClipIsLinearVPAIDAd()) {
	   				CONFIG::debugging { doLog("Resuming VPAID ad", Debuggable.DEBUG_API); }
	   				_vastController.overlayController.getActiveVPAIDAd().resumeAd();
	   				return true;
	   			}
	   			else if(activeStreamIsLinearAd()) {
	   				CONFIG::debugging { doLog("Resuming Linear ad", Debuggable.DEBUG_API); }
	   				_player.play();
	   				return true;
	   			}
	   			else if(activeStreamIsShowStream()) {
	   				CONFIG::debugging { doLog("Resuming show stream", Debuggable.DEBUG_API); }
	   				_player.play();
	   				return true;	   				
	   			}
	  		}
			return false;	   		
	   	}

	   	protected function externalSetDebugLevel(level:String):* {
   			CONFIG::debugging { doLog("Not implemented", Debuggable.DEBUG_API); }
			return false;	   		
	   	}

	   	protected function externalGetDebugLevel():* {
			return _vastController.config.debugLevel;	   		
	   	}

	   	protected function externalGetAdSchedule():* {
	   		return _vastController.adSchedule.toJSObject();
	   	}
	   	
	   	protected function externalGetStreamSequence():* {
	   		return _vastController.streamSequence.toJSObject();
	   	}

	   	protected function externalSkipAd():* {
			if(_vastController != null) {
				CONFIG::debugging { doLog("API call to skip the ad", Debuggable.DEBUG_API); }
		   		onLinearAdSkipped(null);
			}
			return false;	   		
	   	}

	   	protected function externalClearOverlays():* {
   			CONFIG::debugging { doLog("Not implemented", Debuggable.DEBUG_API); }
			return false;	   		
	   	}
	   	
	   	protected function externalShowOverlay(duration:int=-1, regionId:String="auto:bottom", adTag:String=null):* {
   			CONFIG::debugging { doLog("Not implemented", Debuggable.DEBUG_API); }
			return false;	   		
	   	}

	   	protected function externalHideOverlay(id:String):* {
   			CONFIG::debugging { doLog("Not implemented", Debuggable.DEBUG_API); }
			return false;	   		
	   	}

	   	protected function externalEnableJavascriptCallbacks():* {
   			CONFIG::debugging { doLog("Not implemented", Debuggable.DEBUG_API); }
			return false;	   		
	   	}

	   	protected function externalDisableJavascriptCallbacks():* {
   			CONFIG::debugging { doLog("Not implemented", Debuggable.DEBUG_API); }
			return false;	   		
	   	}
	   	
		// DEBUG METHODS
		
		CONFIG::debugging
		protected static function doLog(data:String, level:int=1):void {
			Debuggable.getInstance().doLog(data, level);
		}
		
		CONFIG::debugging
		protected static function doTrace(o:Object, level:int=1):void {
			Debuggable.getInstance().doTrace(o, level);
		}
	}
}