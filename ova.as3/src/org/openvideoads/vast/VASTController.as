/*    
 *    Copyright (c) 2010 LongTail AdSolutions, Inc
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
 */
package org.openvideoads.vast {
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.external.ExternalInterface;
	import flash.system.Capabilities;
	import flash.utils.Timer;
	
	import org.openvideoads.base.Debuggable;
	import org.openvideoads.base.EventController;
	import org.openvideoads.util.BrowserUtils;
	import org.openvideoads.util.DisplayProperties;
	import org.openvideoads.util.DisplaySpecification;
	import org.openvideoads.util.PopupWindow;
	import org.openvideoads.util.StringUtils;
	import org.openvideoads.vast.analytics.AnalyticsProcessor;
	import org.openvideoads.vast.config.Config;
	import org.openvideoads.vast.config.ConfigLoadListener;
	import org.openvideoads.vast.config.ConfigPreConverter;
	import org.openvideoads.vast.config.groupings.PlayerConfigGroup;
	import org.openvideoads.vast.config.groupings.ProvidersConfigGroup;
	import org.openvideoads.vast.events.AdNoticeDisplayEvent;
	import org.openvideoads.vast.events.AdSlotLoadEvent;
	import org.openvideoads.vast.events.AdTagEvent;
	import org.openvideoads.vast.events.CompanionAdDisplayEvent;
	import org.openvideoads.vast.events.LinearAdDisplayEvent;
	import org.openvideoads.vast.events.NonLinearAdDisplayEvent;
	import org.openvideoads.vast.events.NonLinearSchedulingEvent;
	import org.openvideoads.vast.events.OVAControlBarEvent;
	import org.openvideoads.vast.events.OverlayAdDisplayEvent;
	import org.openvideoads.vast.events.SeekerBarEvent;
	import org.openvideoads.vast.events.StreamSchedulingEvent;
	import org.openvideoads.vast.events.TrackingPointEvent;
	import org.openvideoads.vast.events.VPAIDAdDisplayEvent;
	import org.openvideoads.vast.model.CompanionAd;
	import org.openvideoads.vast.model.LinearVideoAd;
	import org.openvideoads.vast.model.NonLinearVideoAd;
	import org.openvideoads.vast.model.TrackingEvent;
	import org.openvideoads.vast.model.VideoAd;
	import org.openvideoads.vast.overlay.OverlayController;
	import org.openvideoads.vast.overlay.OverlayView;
	import org.openvideoads.vast.overlay.button.skip.SkipAdButtonDisplayEvent;
	import org.openvideoads.vast.schedule.DurationlessStreamSequence;
	import org.openvideoads.vast.schedule.Stream;
	import org.openvideoads.vast.schedule.StreamSequence;
	import org.openvideoads.vast.schedule.ads.AdSchedule;
	import org.openvideoads.vast.schedule.ads.AdSlot;
	import org.openvideoads.vast.schedule.ads.AdSlotOnDemandLoadListener;
	import org.openvideoads.vast.server.events.TemplateEvent;
	import org.openvideoads.vast.server.request.AdServerRequest;
	import org.openvideoads.vast.server.response.AdServerTemplate;
	import org.openvideoads.vast.server.response.TemplateLoadListener;
	import org.openvideoads.vast.tracking.TimeEvent;
	import org.openvideoads.vast.tracking.TrackingPoint;
	import org.openvideoads.vast.tracking.TrackingTable;
	import org.openvideoads.vpaid.IVPAID;
	import org.openvideoads.vpaid.VPAIDEvent;		
	
	/**
	 * @author Paul Schulz
	 */
	public class VASTController extends EventController implements TemplateLoadListener, AdSlotOnDemandLoadListener, ConfigLoadListener {
		public static const RELATIVE_TO_CLIP:String = "relative-to-clip";
		public static const CONTINUOUS:String = "continuous";
		public static const VERSION:String = "v1.3.0 RC1 (Build 37)";
		
		public static const USE_EMBEDDED_JAVASCRIPT:Boolean = false;  // Temporary option to enable "experimental" embedded Javascript code
		
		protected var _streamSequence:StreamSequence = null;
		protected var _adSchedule:AdSchedule = null;
		protected var _overlayLinearVideoAdSlot:AdSlot = null;
		protected var _template:AdServerTemplate = null;
		protected var _overlayController:OverlayController = null;
		protected var _config:Config = new Config();
		protected var _timeBaseline:String = VASTController.RELATIVE_TO_CLIP;
		protected var _trackStreamSlices:Boolean = false; // changed from default of true as this "slicing" is being depreciated
		protected var _visuallyCueingLinearAdClickthroughs:Boolean = true;
		protected var _startStreamSafetyMargin:int = 0;
		protected var _endStreamSafetyMargin:int = 0;	
		protected var _configLoadListener:ConfigLoadListener = null;
		protected var _loadDataOnConfigLoaded:Boolean = false;
		protected var _isLoadingConfig:Boolean = false;		
		protected var _controllingDisplayOfCompanionContent:Boolean = true;
        protected var _companionDisplayRegister:Object = new Object();
        protected var _surveyDisplayRegister:Object = new Object();
        protected var _initialised:Boolean = false;
        protected var _playerVolume:Number = 1; // value between 0 and 1 used for VPAID non-linear ads
        protected var _additionalMetricsParams:String = null;
        protected var _loading:Boolean = false;
		protected var _defaultPlayerConfigGroup:PlayerConfigGroup = null;
		protected var _jsCallbackScopingPrefix:String = "";

        protected static var _analyticsProcessor:AnalyticsProcessor = null;

		CONFIG::javascript {
			[Embed("../../../js/ova.js", mimeType="application/octet-stream")]
			/** OVA JavaScript **/
			protected static const OVAJS:Class;			
		}
		
		public function VASTController(config:Config=null, endStreamSafetyMargin:int=0) {
			super();
			if(config != null) initialise(config);
			_endStreamSafetyMargin = endStreamSafetyMargin;
		}
		
		public function initialise(config:Object, loadData:Boolean=false, configLoadListener:ConfigLoadListener=null, defaultConfigObject:Config=null):void {
			_initialised = true;

			_configLoadListener = configLoadListener;
			_loadDataOnConfigLoaded = loadData;

			// Load up the config
			if(config is Config) {
				this.config = config as Config;
			}
            else {
            	if(defaultConfigObject != null) {
            		defaultConfigObject.initialise(preProcessDepreciatedConfig(config));
            		this.config = defaultConfigObject;
            	}
            	else this.config = new Config(preProcessDepreciatedConfig(config));
            }
            
			if(this.config.outputingDebug()) {
				CONFIG::debugging { doLog("Using OVA for AS3 " + VERSION + " - Flash version is " + Capabilities.version, Debuggable.DEBUG_CONFIG); }
			}
			this.config.setLoadedListener(this);
		}
		
		public function preProcessDepreciatedConfig(config:Object):Object {
			return ConfigPreConverter.convert(config);
		}
						
		public function get loading():Boolean {
			return _loading;
		}

		public function setDefaultPlayerConfigGroup(config:Object=null):void {
			_defaultPlayerConfigGroup = new PlayerConfigGroup(config);
		}

		public function getActiveDisplaySpecification(playingShow:Boolean):DisplaySpecification {
			if(playingShow) {
				return _config.playerConfig.getDisplaySpecification(DisplaySpecification.NON_LINEAR);
			}
			else return _config.playerConfig.getDisplaySpecification(DisplaySpecification.LINEAR);
		}		

		public function getDefaultPlayerConfig():PlayerConfigGroup {
			if(_defaultPlayerConfigGroup == null) {
				setDefaultPlayerConfigGroup();
			}	
			return _defaultPlayerConfigGroup;
		}

		public function get analyticsProcessor():AnalyticsProcessor {
			return _analyticsProcessor;
		}

		public function fireAdPlaybackAnalytics(type:String, adSlot:AdSlot, ad:*):void {
			if(_analyticsProcessor != null) {
				_analyticsProcessor.fireAdPlaybackTracking(type, adSlot, ad, getAdditionalMetricsParams());
			}
		}

		public function set playerVolume(playerVolume:Number):void {
			_playerVolume = playerVolume;
		}
		
		public function get playerVolume():Number {
			return _playerVolume;
		}
		
		// DEPRECIATING - replaced by initialised()
		public function isInitialised():Boolean {
			return this.initialised;
		}
		
		public function get initialised():Boolean {
			return _initialised;
		}
		
		public function isOVAConfigLoading():Boolean {
			return _isLoadingConfig;
		}
		
		public function onOVAConfigLoaded():void {
			CONFIG::javascript {
				if(USE_EMBEDDED_JAVASCRIPT) {
		        	if(processCompanionDisplayExternally() == false && processHTML5NonLinearDisplayExternally() == false) {
						if(ExternalInterface.available) {
							try {
								var ovajsInstance:Object = new OVAJS();
								var ovaType:String = ExternalInterface.call('function(){return typeof ova;}');
								if (ovaType == "undefined") {
									ExternalInterface.call('eval(decodeURIComponent("' + encodeURIComponent(ovajsInstance.toString()) + '"))');					
								}
							}
							catch(e:Error) {}
						}
		        	}
				}
			}			
			
   	    	_analyticsProcessor = new AnalyticsProcessor(this, _config.analytics);		

			if(this.config.operateWithoutStreamDuration()) {
				_streamSequence = new DurationlessStreamSequence();
				CONFIG::debugging { doLog("Scheduler instantiated - operating in duration-less mode for show streams", Debuggable.DEBUG_CONFIG); }
			}
			else {
				_streamSequence = new StreamSequence();
				CONFIG::debugging { doLog("Scheduler instantiated - expecting durations to be specified with the show streams", Debuggable.DEBUG_CONFIG); }
			}
            if(_loadDataOnConfigLoaded) load();
            if(_configLoadListener != null) _configLoadListener.onOVAConfigLoaded();
		}

		public function delayAdRequestUntilPlay():Boolean {
			if(_config != null) {
				return _config.delayAdRequestUntilPlay;				
			}
			return false;			
		}
		
		public function testingVPAID():Boolean {
			if(_config != null) {
				return _config.adsConfig.vpaidConfig.testing;
			}
			return false;
		}

		CONFIG::callbacks
		public function canFireAPICalls():Boolean {
			if(_config != null) {
				return _config.canFireAPICalls;				
			}
			return false;
		}

		CONFIG::callbacks
		public function canFireEventAPICalls():Boolean {
			if(_config != null) {
				return _config.canFireEventAPICalls;				
			}
			return false;
		}

		CONFIG::callbacks
		public function get useV2APICalls():Boolean {
			if(_config != null) {
				return _config.useV2APICalls;
			}
			return false;
		}

		CONFIG::callbacks
		public function set jsCallbackScopingPrefix(jsCallbackScopingPrefix:String):void {
			_jsCallbackScopingPrefix = jsCallbackScopingPrefix;
		}
		
		CONFIG::callbacks
		public function get jsCallbackScopingPrefix():String {
			return _jsCallbackScopingPrefix;
		}
		
		public function canSupportExternalPlaylistLoading():Boolean {
			if(_config != null) {
				return _config.supportExternalPlaylistLoading;				
			}
			return false;			
		}

		public function willAutoPlayOnExternalLoad():Boolean {
			if(_config != null) {
				return _config.autoPlayOnExternalLoad;				
			}
			return false;			
		}

		public function attemptAdSlotFailoverOnDemand(adSlot:AdSlot):Boolean {
			if(adSlot != null) {
				return adSlot.loadByFailover(this);
			}
			return false;
		}
		
		public function playbackStartsWithPreroll():Boolean {
			var prerollAdSlot:AdSlot = getFirstPreRollAdSlot();
			if(prerollAdSlot != null) {
				return prerollAdSlot.isPreRoll();
			}
			return false;
		}
		
		public function getFirstPreRollAdSlot():AdSlot {
			if(_streamSequence != null) {
				if(_streamSequence.length > 0) {
					// Test 1: is there a pre-roll scheduled at index 0
					if(_streamSequence.getStreamAtIndex(0) is AdSlot) {
						return _streamSequence.getStreamAtIndex(0) as AdSlot;
					}
					// Test 2: is there an image clip at index 0 - if so, check if there is a pre-roll 
					// following - this clip structure is used by players who use playlist items for 
					// splash images - e.g. Flowplayer
					if(_streamSequence.length >= 2) {
						if(_streamSequence.getStreamAtIndex(0).isSplashImage()) {
							if(_streamSequence.getStreamAtIndex(1) is AdSlot) {
								if(AdSlot(_streamSequence.getStreamAtIndex(1)).isPreRoll()) {
									return _streamSequence.getStreamAtIndex(1) as AdSlot;
								}
							}
						}
					}
				}
			}
			return null;			
		}
		
		public function set additionMetricsParams(additionalMetricsParams:String):void {
			_additionalMetricsParams = additionalMetricsParams;
		}
		
		protected function getAdditionalMetricsParams(extras:String=""):String {
			if(_additionalMetricsParams != null) {
				if(StringUtils.beginsWith(_additionalMetricsParams, "&")) {
					return _additionalMetricsParams + extras;
				}
				else return "&" + _additionalMetricsParams + extras;
			}
			return extras;
		}
		
		public function hideLogoOnLinearAdPlayback():Boolean {
			if(_config != null) {
				return _config.playerConfig.hideLogoOnLinearPlayback;
			}
			return false;
		}
		
		public function requiresStreamTimer():Boolean {
			if(_config != null) {
				return _config.showsConfig.requiresStreamTimer();
			}
			return false;
		}
		
		public function areProxiesEnabledForAdStreams():Boolean {
			if(_config != null) {
				return _config.areProxiesEnabledForAdStreams();
			}
			return false;
		}

		public function areProxiesEnabledForShowStreams():Boolean {
			if(_config != null) {
				return _config.areProxiesEnabledForShowStreams();
			}
			return false;
		}

		public function get controllingDisplayOfCompanionContent():Boolean {
			return _controllingDisplayOfCompanionContent;
		}
		
		public function set controllingDisplayOfCompanionContent(controllingDisplayOfCompanionContent:Boolean):void {
			_controllingDisplayOfCompanionContent = controllingDisplayOfCompanionContent;
		}

		public function set endStreamSafetyMargin(endStreamSafetyMargin:int):void {
			_endStreamSafetyMargin = endStreamSafetyMargin;
			CONFIG::debugging { doLog("Saftey margin for end of stream time tracking events set to " + _endStreamSafetyMargin + " milliseconds", Debuggable.DEBUG_CONFIG); }
		}
		
		public function get endStreamSafetyMargin():int {
			return _endStreamSafetyMargin;
		}

		public function set startStreamSafetyMargin(startStreamSafetyMargin:int):void {
			_startStreamSafetyMargin = startStreamSafetyMargin;
			CONFIG::debugging { doLog("Saftey margin for start of stream time tracking events set to " + _startStreamSafetyMargin + " milliseconds", Debuggable.DEBUG_CONFIG); }
		}
		
		public function get startStreamSafetyMargin():int {
			return _startStreamSafetyMargin;
		}
		
		public function set acceptedLinearAdMimeTypes(mimeTypes:Array):void {
			if(_config != null) {
				config.acceptedLinearAdMimeTypes = mimeTypes;					
			}
		}
		
		public function get acceptedLinearAdMimeTypes():Array {
			if(_config != null) {
				return _config.acceptedLinearAdMimeTypes;			
			}
			return new Array();
		}

		public function get playOnce():Boolean {
			return config.playOnce;
		}
		
		public function set trackStreamSlices(trackStreamSlices:Boolean):void {
			_trackStreamSlices = trackStreamSlices;
		}
		
		public function get trackStreamSlices():Boolean {
			return _trackStreamSlices;
		}

		public function autoPlay():Boolean {
			return _config.autoPlay;	
		}

		public function enableAutoPlay():void {
			CONFIG::debugging { doLog("Auto play has been turned on", Debuggable.DEBUG_CONFIG); }
			_config.autoPlay = true;
		}
		
		public function disableAutoPlay():void {
			CONFIG::debugging { doLog("Auto play has been turned off", Debuggable.DEBUG_CONFIG); }
			_config.autoPlay = false;
		}

        public function get allowPlaylistControl():Boolean {
        	return _config.allowPlaylistControl;
        }
        
        public function controlEnabledStateForLinearAdType(controlName:String, isVPAID:Boolean):Boolean {
        	return _config.controlEnabledForLinearAdType(controlName, isVPAID);
        }
        
		public function setTimeBaseline(timeBaseline:String):void {
			_timeBaseline = timeBaseline;
		}
		
		protected function timeRelativeToClip():Boolean {
			return (_timeBaseline == VASTController.RELATIVE_TO_CLIP);
		}
		
		public function getStreamSequenceIndexGivenOriginatingIndex(originalIndex:int, excludeSlices:Boolean=false, excludeMidRolls:Boolean=false):int {
			if(_streamSequence != null) {
				return _streamSequence.getStreamSequenceIndexGivenOriginatingIndex(originalIndex, excludeSlices, excludeMidRolls);
			}
			return -1;
		}
		
		public function getMidrollsForStreamBetween(streamIndex:int, startTime:Number, endTime:Number):Array {
			CONFIG::debugging { doLog("Searching for mid-rolls scheduled to playback between " + startTime + " and " + endTime + " - stream index is " + streamIndex, Debuggable.DEBUG_PLAYLIST); }
			var matches:Array = new Array();
			if(_adSchedule != null) {
				for(var i:int=0; i < _adSchedule.length; i++) {
					if(AdSlot(_adSchedule.getSlot(i)).associatedStreamIndex == streamIndex) {
						if(AdSlot(_adSchedule.getSlot(i)).isMidRoll() && (AdSlot(_adSchedule.getSlot(i)).isEmpty() == false)) {
							// ok this ad slot applies to the stream in question, now see if the timing fits
							if(AdSlot(_adSchedule.getSlot(i)).occursBetweenTimes(startTime, endTime)) {
								matches.push(_adSchedule.getSlot(i));
							}
						}
					}
				}
			}
			return matches;
		}
		
		public function load():void {
			_loading = true;
			this.config.ensureProvidersAreSet();
			if(_adSchedule.hasPreloadedAdSlots()) {
				_adSchedule.loadAdsFromAdServers(this);
			}
			else {
				onTemplateLoadDeferred(new TemplateEvent(TemplateEvent.LOAD_DEFERRED, "Not triggering ad server calls at this time as there are no pre-loaded ad slots declared"));				
			}
		}
		
		public function unload():void {
			CONFIG::debugging { doLog("OVA has been instructed to unload - closing any active ad and tracking calls etc.", Debuggable.DEBUG_CONFIG); }
			if(_adSchedule != null) {
				_adSchedule.unload();
			}
		}

		public function loadAdSlotOnDemand(adSlot:AdSlot):Boolean {
			if(adSlot != null) {
				return adSlot.load(this);
			}
			return false;
		}
		
		public function loadAdSlotAtIndexOnDemand(adSlotIndex:int):Boolean {
			if(_adSchedule != null) {
				if(_adSchedule.length < adSlotIndex) {
					if(AdSlot(_adSchedule[adSlotIndex]).loadOnDemand == true) {
						return AdSlot(_adSchedule[adSlotIndex]).load(this);
					}
				}
			}
			return false;
		}

		public function set playerWidth(playerWidth:int):void {
			if(_config != null) {
				_config.playerConfig.width = playerWidth;
			}
		}

		public function get playerWidth():int {
			if(_config != null) {
				return _config.playerConfig.width;
			}
			return -1;
		}

		public function set playerHeight(playerHeight:int):void {
			if(_config != null) {
				_config.playerConfig.height = playerHeight;
			}
		}
		
		public function get playerHeight():int {
			if(_config != null) {
				return _config.playerConfig.height;
			}
			return -1;
		}

		public function set config(config:Config):void {
			_config = config;

            // Configure the debug level
   			if(_config.debugLevelSpecified()) Debuggable.getInstance().setLevelFromString(_config.debugLevel);
   			if(_config.debuggersSpecified()) Debuggable.getInstance().activeDebuggers = _config.debugger;

            // Now formulate the ad schedule
			_adSchedule = new AdSchedule(this, _streamSequence, _config);
		}
		
		public function get config():Config {
			return _config;
		}

        public function get template():AdServerTemplate {
        	return _template;
        }		
        
		public function get adSchedule():AdSchedule {
			return _adSchedule;
		}
		
		public function get streamSequence():StreamSequence {
			return _streamSequence;
		}
		
		public function get overlayController():OverlayController {
			return _overlayController;
		}
		
		public function resetDurationForAdStreamAtIndex(streamIndex:int, newDuration:int):void {
			CONFIG::debugging { doLog("Setting new duration and resetting tracking table for stream at index " + streamIndex + " - new duration is: " + newDuration, Debuggable.DEBUG_CONFIG); }
			if(_streamSequence != null) {
				_streamSequence.resetDurationForAdStreamAtIndex(streamIndex, newDuration);
			}
			else {
				CONFIG::debugging { doLog("ERROR: Cannot reset duration and tracking table for stream at index " + streamIndex + " as the stream sequence is null", Debuggable.DEBUG_CONFIG); }
			}
		}
		
		public function get pauseOnClickThrough():Boolean {
			return _config.pauseOnClickThrough;	
		}

		public function canSkipOnLinearAd():Boolean {
			return _config.canSkipOnLinearAd();
		}
		
		public function enforceLinearInteractiveAdScaling():Boolean {
			return _config.adsConfig.enforceLinearInteractiveAdScaling;
		}
		
		public function enforceLinearVideoAdScaling():Boolean {
			return _config.adsConfig.enforceLinearVideoAdScaling;
		}
		
		public function deriveAdDurationFromMetaData():Boolean {
			return _config.deriveAdDurationFromMetaData();
		}

		public function deriveShowDurationFromMetaData():Boolean {
			return _config.deriveShowDurationFromMetaData();
		}
		
		public function disableRegionDisplay():void {
			_overlayController = null;	
		}
		
		public function enableRegionDisplay(displayProperties:DisplayProperties):void {
			// Load up the overlay controller and pass in the regions that have been defined
			_overlayController = new OverlayController(this, displayProperties, _config.regionsConfig);
			if(displayProperties.displayObjectContainer != null) {
				displayProperties.displayObjectContainer.addChild(_overlayController);
				displayProperties.displayObjectContainer.setChildIndex(_overlayController, displayProperties.displayObjectContainer.numChildren-1);
			}		
//            setupFlashContextMenu(displayProperties.displayObjectContainer);
		}
		
		public function resizeOverlays(resizedProperties:DisplayProperties):void {
			if(_overlayController != null) {
				_overlayController.resize(resizedProperties);
			}
		}
		
		public function handlingNonLinearAdDisplay():Boolean {
			return (_overlayController != null);
		}
		
		public function getTrackingTableForStream(streamIndex:int):TrackingTable {
			if(streamIndex < _streamSequence.length) {
				return _streamSequence.streamAt(streamIndex).getTrackingTable();
			}
			return null;
		}

		public function hideAllOverlays():void {
			if(_overlayController != null) {
				_overlayController.hideAllOverlays();
			}
		}
		
		public function hideAllRegions():void {
			if(_overlayController != null) {
				_overlayController.hideAllRegions();
			}
		}
		
		public function closeActiveAdNotice():void {
			if(_overlayController != null) {
				_overlayController.hideAdNotice();
			}				
		}	
		
		public function closeAllAdMessages():void {
			if(_overlayController != null) {
				_overlayController.hideAllAdMessages();
			}
		}
			
		public function closeActiveOverlaysAndCompanions():void {
			// used to clear up any active overlays or companions if the current stream is skipped
			if(_adSchedule != null) _adSchedule.closeActiveOverlaysAndCompanions(_config.adsConfig.resetTrackingOnReplay);
		}
		
		public function getProvider(providerType:String):String {
			return _config.getProvider(providerType);
		}
		
		public function getProviders():ProvidersConfigGroup {
			return _config.providersConfig;
		}

		// Overlay linear video ad playlist API

		public function getActiveOverlayStreamSequence():StreamSequence {
			if(!allowPlaylistControl) {
				if(_overlayLinearVideoAdSlot != null) {
					var adStreamSequence:StreamSequence = new StreamSequence(this);
					adStreamSequence.addStream(_overlayLinearVideoAdSlot, false);
					return adStreamSequence;
				}
				else {
					CONFIG::debugging { doLog("Cannot play the linear ad for this overlay - no adslot attached to the event - ignoring click", Debuggable.DEBUG_PLAYLIST); }
				}
			}
			else {
				CONFIG::debugging { doLog("NOTIFICATION: Overlay clicked event ignored as playlistControl is turned on - this feature is not possible", Debuggable.DEBUG_DISPLAY_EVENTS); }
			}

			return null;
		}
		
		public function set activeOverlayVideoPlaying(playState:Boolean):void {
			if(_overlayLinearVideoAdSlot != null) {
				_overlayLinearVideoAdSlot.overlayVideoPlaying = playState;
			}					
		}
		
		public function isActiveOverlayVideoPlaying():Boolean {
			if(_overlayLinearVideoAdSlot != null) {
				return _overlayLinearVideoAdSlot.isOverlayVideoPlaying();
			}
			return false;
		}

		// Linear Ad Skip button operations
		
		public function activateLinearAdSkipButton(onSkipCallbackMethod:Function):void {	
			if(_overlayController != null) {
				_overlayController.activateLinearAdSkipButton(new SkipAdButtonDisplayEvent(SkipAdButtonDisplayEvent.DISPLAY, "region", "image", onSkipCallbackMethod));
			}
		}

		public function deactivateLinearAdSkipButton():void {	
			if(_overlayController != null) {
				_overlayController.deactivateLinearAdSkipButton(new SkipAdButtonDisplayEvent(SkipAdButtonDisplayEvent.HIDE, "region"));			
			}
		}
		
		// Time Event Handlers
		
		public function processTimeEvent(associatedStreamIndex:int, timeEvent:TimeEvent):void {	
			// we're dealing with an event on the mainline streams and ad slots
			if(_adSchedule != null) {
				_adSchedule.processTimeEvent(associatedStreamIndex, timeEvent, false);												
			}
			if(_streamSequence != null) { 
				_streamSequence.processTimeEvent(associatedStreamIndex, timeEvent, false);
			}
		}

		public function processOverlayLinearVideoAdTimeEvent(overlayAdSlotKey:int, timeEvent:TimeEvent, playingOverlayVideo:Boolean=false):void {
			if(overlayAdSlotKey != -1) {
				if(overlayAdSlotKey < _adSchedule.length) {
					_adSchedule.getSlot(overlayAdSlotKey).processTimeEvent(timeEvent, true);
				}
			}
		}

		public function resetAllAdTrackingPointsAssociatedWithStream(associatedStreamIndex:int):void {
			if(_adSchedule != null && associatedStreamIndex > -1) {
				_adSchedule.resetAllAdTrackingPointsAssociatedWithStream(associatedStreamIndex);
			} 
		}
		
		public function resetAllTrackingPointsAssociatedWithStream(associatedStreamIndex:int):void {
			if(_streamSequence != null && associatedStreamIndex > -1) {
				_streamSequence.resetAllTrackingPointsAssociatedWithStream(associatedStreamIndex);
			}			
		}
		
		public function resetRepeatableStreamTrackingPoints(streamIndex:int):void {
			if(_streamSequence != null && streamIndex > -1) {
				_streamSequence.resetRepeatableTrackingPoints(streamIndex);
			}
		}	
		
		// Regions API support
		
		public function setRegionStyle(regionID:String, cssText:String):String {
			if(_overlayController != null) {
				return _overlayController.setRegionStyle(regionID, cssText);
			}
			else return "-1, Overlay Controller is not active";
		}	
		
		// Javascript API support

		public function fireAPICall(... args):* {
			CONFIG::callbacks {
				if(ExternalInterface.available && _config.canFireAPICalls) {
					try {
						if(_config.useV2APICalls) {
							// These are the new V2 API callbacks
							CONFIG::debugging { doLog("Firing V2 API call " + args[0] + "()", Debuggable.DEBUG_JAVASCRIPT); }
							ExternalInterface.call(_jsCallbackScopingPrefix + "onOVAEventCallback", args);
						}
						else {
							// These are the old V1 API callbacks
							
							CONFIG::debugging { doLog("Firing V1 API call " + args[0] + "()", Debuggable.DEBUG_JAVASCRIPT); }
							switch (args.length) {
								case 1: 
									return ExternalInterface.call(args[0]);
								case 2: 
									return ExternalInterface.call(args[0],args[1]);
								case 3: 
									return ExternalInterface.call(args[0],args[1],args[2]);
								default: 
									return ExternalInterface.call(args[0],args[1],args[2],args[3]);
							}	
						}
					}
					catch(e:Error) {
						CONFIG::debugging { doLog("Exception making external call (" + args[0] + ") - " + e, Debuggable.DEBUG_JAVASCRIPT); }
					}	
				}
			}
			return null;
		}		

		// Scheduling callback
		
		public function onScheduleStream(scheduleIndex:int, stream:Stream):void {
			if((trackStreamSlices == false) && (stream.isSlicedStream()) && (!stream.isFirstSlice())) {
				// don't notify that this stream slice is to be scheduled
				CONFIG::debugging { doLog("Ignoring 'onScheduleStream' request for stream " + stream.url, Debuggable.DEBUG_SEGMENT_FORMATION); }
			}	
			else {
				dispatchEvent(new StreamSchedulingEvent(StreamSchedulingEvent.SCHEDULE, scheduleIndex, stream));
			}
		}

		public function onScheduleNonLinear(adSlot:AdSlot, onDemandAdSlot:Boolean=false):void {
			dispatchEvent(new NonLinearSchedulingEvent(NonLinearSchedulingEvent.SCHEDULE, adSlot));
		}
		
		// Tracking Point callbacks
		
		public function onSetTrackingPoint(trackingPoint:TrackingPoint):void {
			if(trackingPoint != null) {
				dispatchEvent(new TrackingPointEvent(TrackingPointEvent.SET, trackingPoint));			
			}
		}

		public function onProcessTrackingPoint(trackingPoint:TrackingPoint):void {
			if(trackingPoint != null) {
				dispatchEvent(new TrackingPointEvent(TrackingPointEvent.FIRED, trackingPoint));
			}
		}
		
		// VPAID Ad methods & events

		public function isVPAIDAdPlaying():Boolean {
			if(_overlayController != null) {
				return _overlayController.isVPAIDAdPlaying();
			}
			return false;	
		}
		
		public function closeActiveVPAIDAds():void {
			if(_overlayController != null) {
				_overlayController.closeActiveVPAIDAds();
			}	
		}
		
		public function playVPAIDAd(adSlot:AdSlot, muteOnStartup:Boolean=false, reduceVPAIDAdHeightByControlbarHeight:Boolean=false, playerVolume:Number=-1):void { 
			if(adSlot != null) {
				adSlot.markAsPlayed();
				if(_overlayController != null) {
	               	if(adSlot.isLinear() && _config.adsConfig.resetTrackingOnReplay) {
	               		adSlot.resetAllTrackingPoints();
	               	}
	               	var ad:* = (adSlot.isLinear() ? adSlot.getLinearVideoAd() : adSlot.getNonLinearVideoAd());
					_overlayController.playVPAIDAd(
					    adSlot,
					    {
					    	onLoading: function(event:VPAIDEvent=null):void {
				    			dispatchEvent(new VPAIDAdDisplayEvent(VPAIDAdDisplayEvent.LINEAR_LOADING, adSlot));
					    	},
							onLoaded: function(event:VPAIDEvent=null):void { 
								if(_analyticsProcessor != null && ad != null) {
									_analyticsProcessor.fireVPAIDPlaybackTracking(AnalyticsProcessor.LOADED, adSlot, ad, getAdditionalMetricsParams());
								}
								dispatchEvent(new VPAIDAdDisplayEvent(((adSlot.isLinear()) ? VPAIDAdDisplayEvent.LINEAR_LOADED : VPAIDAdDisplayEvent.NON_LINEAR_LOADED), adSlot, event.data, event.bubbles, event.cancelable));		
							},
							onImpression: function(event:VPAIDEvent=null):void { 
								if(_analyticsProcessor != null) {
									_analyticsProcessor.fireImpressionTracking(((adSlot.isLinear()) ? AnalyticsProcessor.LINEAR : AnalyticsProcessor.NON_LINEAR), adSlot, ad, getAdditionalMetricsParams()); 
								}
								dispatchEvent(new VPAIDAdDisplayEvent(((adSlot.isLinear()) ? VPAIDAdDisplayEvent.LINEAR_IMPRESSION : VPAIDAdDisplayEvent.NON_LINEAR_IMPRESSION), adSlot, event.data, event.bubbles, event.cancelable));		
							},
							onStart: function(event:VPAIDEvent=null):void { 
								if(_analyticsProcessor != null && ad != null) {
									_analyticsProcessor.fireVPAIDPlaybackTracking(AnalyticsProcessor.STARTED, adSlot, ad, getAdditionalMetricsParams());
								}
								dispatchEvent(new VPAIDAdDisplayEvent(((adSlot.isLinear()) ? VPAIDAdDisplayEvent.LINEAR_START : VPAIDAdDisplayEvent.NON_LINEAR_START), adSlot, event.data, event.bubbles, event.cancelable));		
							}, 
							onComplete: function(event:VPAIDEvent=null):void { 
								if(_analyticsProcessor != null && ad != null) {
									_analyticsProcessor.fireVPAIDPlaybackTracking(AnalyticsProcessor.COMPLETE, adSlot, ad, getAdditionalMetricsParams());
								}
								dispatchEvent(new VPAIDAdDisplayEvent(((adSlot.isLinear()) ? VPAIDAdDisplayEvent.LINEAR_COMPLETE : VPAIDAdDisplayEvent.NON_LINEAR_COMPLETE), adSlot, event.data, event.bubbles, event.cancelable));		
							},
							onPaused: function(event:VPAIDEvent=null):void {
								if(_analyticsProcessor != null) {
									_analyticsProcessor.fireVPAIDPlaybackTracking(AnalyticsProcessor.PAUSED, adSlot, ad, getAdditionalMetricsParams());
								}
							},
							onPlaying: function(event:VPAIDEvent=null):void {
								if(_analyticsProcessor != null) {
									_analyticsProcessor.fireVPAIDPlaybackTracking(AnalyticsProcessor.PLAYING, adSlot, ad, getAdditionalMetricsParams());
								}								
							},
							onError: function(event:VPAIDEvent=null):void { 
								if(adSlot != null) {
									adSlot.fireErrorUrls("901");
								}
								if(_analyticsProcessor != null && ad != null) {
									_analyticsProcessor.fireVPAIDPlaybackTracking(AnalyticsProcessor.ERROR, adSlot, ad, getAdditionalMetricsParams("ova_error=" + event.data));
								}
								dispatchEvent(new VPAIDAdDisplayEvent(((adSlot.isLinear()) ? VPAIDAdDisplayEvent.LINEAR_ERROR : VPAIDAdDisplayEvent.NON_LINEAR_ERROR), adSlot, event.data, event.bubbles, event.cancelable));	
							},
							onLog: function(event:VPAIDEvent=null):void { 
								dispatchEvent(new VPAIDAdDisplayEvent(VPAIDAdDisplayEvent.AD_LOG, adSlot, event.data, event.bubbles, event.cancelable));	
							},
							onExpandedChange: function(event:VPAIDEvent=null):void { 
								if(_analyticsProcessor != null && ad != null) {
									_analyticsProcessor.fireVPAIDPlaybackTracking(AnalyticsProcessor.EXPANDED_CHANGE, adSlot, ad, getAdditionalMetricsParams());
								}
								dispatchEvent(new VPAIDAdDisplayEvent(((adSlot.isLinear()) ? VPAIDAdDisplayEvent.LINEAR_EXPANDED_CHANGE : VPAIDAdDisplayEvent.NON_LINEAR_EXPANDED_CHANGE), adSlot, event.data, event.bubbles, event.cancelable));		
							},
							onLinearChange: function(event:VPAIDEvent=null):void { 
								if(_analyticsProcessor != null && ad != null) {
									_analyticsProcessor.fireVPAIDPlaybackTracking(AnalyticsProcessor.LINEAR_CHANGE, adSlot, ad, getAdditionalMetricsParams());
								}
								dispatchEvent(new VPAIDAdDisplayEvent(((adSlot.isLinear()) ? VPAIDAdDisplayEvent.LINEAR_LINEAR_CHANGE : VPAIDAdDisplayEvent.NON_LINEAR_LINEAR_CHANGE), adSlot, event.data, event.bubbles, event.cancelable));		
							},
							onRemainingTimeChange: function(event:VPAIDEvent=null):void { 
								dispatchEvent(new VPAIDAdDisplayEvent(((adSlot.isLinear()) ? VPAIDAdDisplayEvent.LINEAR_TIME_CHANGE : VPAIDAdDisplayEvent.NON_LINEAR_TIME_CHANGE), adSlot, event.data, event.bubbles, event.cancelable));		
							},
							onClickThru: function(event:VPAIDEvent=null):void { 
								if(_analyticsProcessor != null && ad != null) {
									_analyticsProcessor.fireAdClickTracking(AnalyticsProcessor.VPAID, adSlot, ad, getAdditionalMetricsParams());
								}
								dispatchEvent(new VPAIDAdDisplayEvent(((adSlot.isLinear()) ? VPAIDAdDisplayEvent.LINEAR_CLICK_THRU : VPAIDAdDisplayEvent.NON_LINEAR_CLICK_THRU), adSlot, event.data, event.bubbles, event.cancelable));		
							},
							onUserAcceptInvitation: function(event:VPAIDEvent=null):void { 
								if(_analyticsProcessor != null && ad != null) {
									_analyticsProcessor.fireVPAIDPlaybackTracking(AnalyticsProcessor.USER_ACCEPT_INVITATION, adSlot, ad, getAdditionalMetricsParams());
								}
								dispatchEvent(new VPAIDAdDisplayEvent(((adSlot.isLinear()) ? VPAIDAdDisplayEvent.LINEAR_USER_ACCEPT_INVITATION : VPAIDAdDisplayEvent.NON_LINEAR_USER_ACCEPT_INVITATION), adSlot, event.data, event.bubbles, event.cancelable));		
							},
							onVolumeChange: function(event:VPAIDEvent=null):void {								
								dispatchEvent(new VPAIDAdDisplayEvent(((adSlot.isLinear()) ? VPAIDAdDisplayEvent.LINEAR_VOLUME_CHANGE : VPAIDAdDisplayEvent.NON_LINEAR_VOLUME_CHANGE), adSlot, event.data, event.bubbles, event.cancelable));	
							},
							onUserMinimize: function(event:VPAIDEvent=null):void { 
								if(_analyticsProcessor != null && ad != null) {
									_analyticsProcessor.fireVPAIDPlaybackTracking(AnalyticsProcessor.COLLAPSE, adSlot, ad, getAdditionalMetricsParams());
								}
								dispatchEvent(new VPAIDAdDisplayEvent(((adSlot.isLinear()) ? VPAIDAdDisplayEvent.LINEAR_USER_MINIMIZE : VPAIDAdDisplayEvent.NON_LINEAR_USER_MINIMIZE), adSlot, event.data, event.bubbles, event.cancelable));		
							},
							onUserClose: function(event:VPAIDEvent=null):void { 
								if(_analyticsProcessor != null && ad != null) {
									_analyticsProcessor.fireVPAIDPlaybackTracking(AnalyticsProcessor.CLOSE, adSlot, ad, getAdditionalMetricsParams());
								}
								dispatchEvent(new VPAIDAdDisplayEvent(((adSlot.isLinear()) ? VPAIDAdDisplayEvent.LINEAR_USER_CLOSE : VPAIDAdDisplayEvent.NON_LINEAR_USER_CLOSE), adSlot, event.data, event.bubbles, event.cancelable));		
							},
							onVideoAdStart: function(event:VPAIDEvent=null):void { 
								if(_analyticsProcessor != null && ad != null) {
									_analyticsProcessor.fireVPAIDPlaybackTracking(AnalyticsProcessor.VIDEO_START, adSlot, ad, getAdditionalMetricsParams());
								}
								dispatchEvent(new VPAIDAdDisplayEvent(VPAIDAdDisplayEvent.VIDEO_AD_START, adSlot, event.data, event.bubbles, event.cancelable));		
							},
							onVideoAdFirstQuartile: function(event:VPAIDEvent=null):void { 
								if(_analyticsProcessor != null && ad != null) {
									_analyticsProcessor.fireVPAIDPlaybackTracking(AnalyticsProcessor.VIDEO_FIRST_QUARTILE, adSlot, ad, getAdditionalMetricsParams());
								}
								dispatchEvent(new VPAIDAdDisplayEvent(VPAIDAdDisplayEvent.VIDEO_AD_FIRST_QUARTILE, adSlot, event.data, event.bubbles, event.cancelable));		
							},
							onVideoAdMidpoint: function(event:VPAIDEvent=null):void { 
								if(_analyticsProcessor != null && ad != null) {
									_analyticsProcessor.fireVPAIDPlaybackTracking(AnalyticsProcessor.VIDEO_MIDPOINT, adSlot, ad, getAdditionalMetricsParams());
								}
								dispatchEvent(new VPAIDAdDisplayEvent(VPAIDAdDisplayEvent.VIDEO_AD_MIDPOINT, adSlot, event.data, event.bubbles, event.cancelable));		
							},
							onVideoAdThirdQuartile: function(event:VPAIDEvent=null):void { 
								if(_analyticsProcessor != null && ad != null) {
									_analyticsProcessor.fireVPAIDPlaybackTracking(AnalyticsProcessor.VIDEO_THIRD_QUARTILE, adSlot, ad, getAdditionalMetricsParams());
								}
								dispatchEvent(new VPAIDAdDisplayEvent(VPAIDAdDisplayEvent.VIDEO_AD_THIRD_QUARTILE, adSlot, event.data, event.bubbles, event.cancelable));		
							},
							onVideoAdComplete: function(event:VPAIDEvent=null):void { 
								if(_analyticsProcessor != null && ad != null) {
									_analyticsProcessor.fireVPAIDPlaybackTracking(AnalyticsProcessor.VIDEO_COMPLETE, adSlot, ad, getAdditionalMetricsParams());
								}
								dispatchEvent(new VPAIDAdDisplayEvent(VPAIDAdDisplayEvent.VIDEO_AD_COMPLETE, adSlot, event.data, event.bubbles, event.cancelable));		
							},
							onVPAIDAdSkipped: function(event:VPAIDEvent=null):void {
								if(_analyticsProcessor != null && ad != null) {
									_analyticsProcessor.fireVPAIDPlaybackTracking(AnalyticsProcessor.SKIPPED, adSlot, ad, getAdditionalMetricsParams());
								}
								dispatchEvent(new VPAIDAdDisplayEvent(VPAIDAdDisplayEvent.SKIPPED, adSlot, event.data, event.bubbles, event.cancelable));		
							},
							onVPAIDAdSkippableStateChange: function(event:VPAIDEvent=null):void {
								if(_analyticsProcessor != null && ad != null) {
									_analyticsProcessor.fireVPAIDPlaybackTracking(AnalyticsProcessor.SKIPPABLE_STATE_CHANGE, adSlot, ad, getAdditionalMetricsParams());
								}
								dispatchEvent(new VPAIDAdDisplayEvent(VPAIDAdDisplayEvent.SKIPPABLE_STATE_CHANGE, adSlot, event.data, event.bubbles, event.cancelable));		
							},
							onVPAIDAdSizeChange: function(event:VPAIDEvent=null):void {
								if(_analyticsProcessor != null && ad != null) {
									_analyticsProcessor.fireVPAIDPlaybackTracking(AnalyticsProcessor.SIZE_CHANGE, adSlot, ad, getAdditionalMetricsParams());
								}
								dispatchEvent(new VPAIDAdDisplayEvent(VPAIDAdDisplayEvent.SIZE_CHANGE, adSlot, event.data, event.bubbles, event.cancelable));		
							},
							onVPAIDAdDurationChange: function(event:VPAIDEvent=null):void {
								if(_analyticsProcessor != null && ad != null) {
									_analyticsProcessor.fireVPAIDPlaybackTracking(AnalyticsProcessor.DURATION_CHANGE, adSlot, ad, getAdditionalMetricsParams());
								}
								dispatchEvent(new VPAIDAdDisplayEvent(VPAIDAdDisplayEvent.DURATION_CHANGE, adSlot, event.data, event.bubbles, event.cancelable));		
							},
							onVPAIDAdInteraction: function(event:VPAIDEvent=null):void {
								if(_analyticsProcessor != null && ad != null) {
									_analyticsProcessor.fireVPAIDPlaybackTracking(AnalyticsProcessor.AD_INTERACTION, adSlot, ad, getAdditionalMetricsParams());
								}
								dispatchEvent(new VPAIDAdDisplayEvent(VPAIDAdDisplayEvent.AD_INTERACTION, adSlot, event.data, event.bubbles, event.cancelable));		
							}
					    },
						muteOnStartup,
						playerVolume,
						reduceVPAIDAdHeightByControlbarHeight
					);
				}
			}
		}
		
		public function getActiveVPAIDAd():IVPAID {
			if(_overlayController != null) {
				return _overlayController.getActiveVPAIDAd();
			}
			return null;
		}
		
		public function hideControlbarDuringVPAIDLinearPlayback():Boolean {
			if(_config != null) {
				return (_config.playerConfig.shouldHideControlsOnLinearPlayback(true)); 		
			}
			return true;
		}
		
		// Linear Ad events
		
		public function onLinearAdStart(adSlot:AdSlot):void {
			if(adSlot != null) {
				if(adSlot.videoAd != null) {
					if(_analyticsProcessor != null) {
						_analyticsProcessor.fireImpressionTracking(AnalyticsProcessor.LINEAR, adSlot, adSlot.videoAd.linearVideoAd, getAdditionalMetricsParams());
					}
					dispatchEvent(new LinearAdDisplayEvent(LinearAdDisplayEvent.STARTED, adSlot));	
				}	
			}
		}

		public function onLinearAdComplete(adSlot:AdSlot):void {
			if(adSlot != null) {
				dispatchEvent(new LinearAdDisplayEvent(LinearAdDisplayEvent.COMPLETE, adSlot));
			}
		}
		
		public function onLinearAdSkip(adSlot:AdSlot):void {
			if(adSlot != null) {
				adSlot.triggerTrackingEvent(TrackingEvent.EVENT_CLOSE);
				adSlot.triggerTrackingEvent(TrackingEvent.EVENT_CLOSE_LINEAR);
				adSlot.triggerTrackingEvent(TrackingEvent.EVENT_SKIP);
				dispatchEvent(new LinearAdDisplayEvent(LinearAdDisplayEvent.SKIPPED, adSlot));
				CONFIG::callbacks {
					fireAPICall("onLinearAdSkipped", ((adSlot.videoAd != null) ? adSlot.videoAd.toJSObject() : {}));
				}
			}
		}
		
		public function enableVisualLinearAdClickThroughCue(adSlot:AdSlot):void {
			if(_config.visuallyCueLinearAdClickThrough && adSlot.hasLinearClickThroughs() && overlayController != null) {
				overlayController.enableLinearAdMouseOverRegion(adSlot);
			}			
		}
		
		public function disableVisualLinearAdClickThroughCue(adSlot:AdSlot=null):void {
			if(_config.visuallyCueLinearAdClickThrough && overlayController != null) overlayController.disableLinearAdMouseOverRegion();			
		}
		
		// Ad Tag callbacks

		public function onAdCallStarted(request:AdServerRequest):void {
			dispatchEvent(new AdTagEvent(AdTagEvent.CALL_STARTED, { masterTag: request }));
			CONFIG::callbacks {
				fireAPICall("onAdCallStarted", request.toJSObject());
			}
		}

		public function onAdCallFailover(masterRequest:AdServerRequest, failoverRequest:AdServerRequest):void {
			dispatchEvent(new AdTagEvent(AdTagEvent.CALL_FAILOVER, { masterTag: masterRequest, failoverTag: failoverRequest }));
			CONFIG::callbacks {
				fireAPICall("onAdCallFailover", masterRequest.toJSObject(), failoverRequest.toJSObject());
			}
		}
		
		public function onAdCallComplete(request:AdServerRequest, hasAds:Boolean):void {
			dispatchEvent(new AdTagEvent(AdTagEvent.CALL_COMPLETE, { masterTag: request, hasAds: hasAds }));
			CONFIG::callbacks {
				fireAPICall("onAdCallComplete", ((request != null) ? request.toJSObject() : {}), hasAds);
			}
		}
		
		// TemplateLoadListener callbacks
		
		public function onTemplateLoaded(template:AdServerTemplate):void {
			CONFIG::debugging { doLog("VAST response has been fully loaded - has non-empty ads == '" + template.hasAds() + "'", Debuggable.DEBUG_VAST_TEMPLATE); }
			_template = template;
			CONFIG::callbacks {
				fireAPICall("onTemplateLoadSuccess", escape(template.getRawTemplateData()));
			}
			validateAndFireRequiredErrorUrls(_template);
			if(_template.hasAds(_template.forceImpressionServing)) {
				_adSchedule.schedule(_template);
				_streamSequence.initialise(this, _config.streams, _adSchedule, _config.bitrate, _config.baseURL, 100, _config.previewImage);
				_adSchedule.addNonLinearAdTrackingPoints(timeRelativeToClip(), true);
				_adSchedule.fireNonLinearSchedulingEvents();
			}
			else {
				_adSchedule.schedule(); // ensure that the start/end scheduling events still fire although no ads are scheduled
				_streamSequence.initialise(this, _config.streams, _adSchedule, _config.bitrate, _config.baseURL, 100, _config.previewImage);
				
			}
			_loading = false;
			dispatchEvent(new TemplateEvent(TemplateEvent.LOADED, _template));
			if(_analyticsProcessor != null) {
				_analyticsProcessor.fireTemplateLoadTracking(AnalyticsProcessor.LOADED, getAdditionalMetricsParams("&ova_ad_count=" + _template.getAdCount()));
			}
		}
		
		public function onTemplateLoadError(event:Event):void {
			CONFIG::debugging { doLog("FAILURE loading ad template - " + TemplateEvent(event).toString(), Debuggable.DEBUG_VAST_TEMPLATE); }
			_adSchedule.schedule(); // ensure that the start/end scheduling events still fire although no ads are scheduled
			_streamSequence.initialise(this, _config.streams, _adSchedule, _config.bitrate, _config.baseURL, 100, _config.previewImage);
			_loading = false;
			dispatchEvent(new TemplateEvent(TemplateEvent.LOAD_FAILED, event));
			CONFIG::callbacks {
				fireAPICall("onTemplateLoadFailure", event.toString());
			}
			if(_analyticsProcessor != null) {
				_analyticsProcessor.fireTemplateLoadTracking(AnalyticsProcessor.ERROR, getAdditionalMetricsParams("&ova_error=" + escape(event.toString())));
			}
		}

		public function onTemplateLoadTimeout(event:Event):void {
			CONFIG::debugging { doLog("TIMEOUT loading ad template - " + TemplateEvent(event).toString(), Debuggable.DEBUG_VAST_TEMPLATE); }
			_adSchedule.schedule(); // ensure that the start/end scheduling events still fire although no ads are scheduled
			_streamSequence.initialise(this, _config.streams, _adSchedule, _config.bitrate, _config.baseURL, 100, _config.previewImage);
			_loading = false;
			dispatchEvent(new TemplateEvent(TemplateEvent.LOAD_TIMEOUT, event));
			CONFIG::callbacks {
				fireAPICall("onTemplateLoadTimeout", event.toString());
			}
			if(_analyticsProcessor != null) {
				_analyticsProcessor.fireTemplateLoadTracking(AnalyticsProcessor.TIMED_OUT, getAdditionalMetricsParams());
			}
		}

		public function onTemplateLoadDeferred(event:Event):void {
			CONFIG::debugging { doLog("DEFERRED loading ad template - " + event.toString(), Debuggable.DEBUG_VAST_TEMPLATE); }
			_adSchedule.schedule(); // ensure that the start/end scheduling events still fire although no ads are scheduled
			_streamSequence.initialise(this, _config.streams, _adSchedule, _config.bitrate, _config.baseURL, 100, _config.previewImage);
			if(_adSchedule.hasNonLinearAds()) {
	            // we still need to set the tracking points for on-demand loaded overlays so do that now
				CONFIG::debugging { doLog("Scheduling non-linear tracking points to support on-demand loading", Debuggable.DEBUG_VAST_TEMPLATE); }
				_adSchedule.addNonLinearAdTrackingPoints(timeRelativeToClip(), true);
				_adSchedule.fireNonLinearSchedulingEvents();
			}
			_loading = false;
			dispatchEvent(new TemplateEvent(TemplateEvent.LOAD_DEFERRED, event));
			CONFIG::callbacks {
				fireAPICall("onTemplateLoadDeferred", event.toString());
			}
			if(_analyticsProcessor != null) {
				_analyticsProcessor.fireTemplateLoadTracking(AnalyticsProcessor.DEFERRED, getAdditionalMetricsParams());
			}
		}
		
		// AdSlotOnDemandLoadListener callbacks
		
		public function onAdSlotLoaded(event:AdSlotLoadEvent):void {
			if(event != null) {
				if(event.adSlot.hasVideoAd()) {
					if(event.adSlot.videoAd.isEmpty()) {
						if(event.adSlot.shouldForceFireImpressions()) {
							CONFIG::debugging { doLog("Ad slot " + event.adSlot.id + " at index " + event.adSlot.index + " dynamically LOADED - has an empty video ad - expecting to force fire impressions", Debuggable.DEBUG_VAST_TEMPLATE);	}
							event.adSlot.processForcedImpression();
						}
						else {
							CONFIG::debugging { doLog("Ad slot " + event.adSlot.id + " at index " + event.adSlot.index + " dynamically LOADED - has an empty video ad - not force firing impressions", Debuggable.DEBUG_VAST_TEMPLATE); }
						}
					}
					else {
						CONFIG::debugging { doLog("Ad slot " + event.adSlot.id + " at index " + event.adSlot.index + " dynamically LOADED - has a " + (event.adSlot.isInteractive() ? "VPAID" : "non-interactive") + " video ad", Debuggable.DEBUG_VAST_TEMPLATE); }
					}
				}
				else {
					CONFIG::debugging { doLog("Ad slot " + event.adSlot.id + " at index " + event.adSlot.index + " dynamically LOADED - no video ad recorded", Debuggable.DEBUG_VAST_TEMPLATE); }
				}

				dispatchEvent(event);
				CONFIG::callbacks {
					fireAPICall("onAdSlotLoaded", event.adSlot.toJSObject());
				}
				if(_analyticsProcessor != null) {
					_analyticsProcessor.fireAdSlotTracking(AnalyticsProcessor.LOADED, event.adSlot, getAdditionalMetricsParams());
				}
			}
		}

		public function onAdSlotLoadError(event:AdSlotLoadEvent):void {
			CONFIG::debugging { doLog("Ad slot " + event.adSlot.id + " at index " + event.adSlot.index + " dynamic load ERROR - " + event.toString(), Debuggable.DEBUG_VAST_TEMPLATE); }
			dispatchEvent(event);
			CONFIG::callbacks {
				fireAPICall("onAdSlotLoadError", event.toString());
			}
			if(_analyticsProcessor != null) {
				_analyticsProcessor.fireAdSlotTracking(AnalyticsProcessor.ERROR, event.adSlot, getAdditionalMetricsParams("&ova_error=" + escape(event.toString())));
			}
		}

		public function onAdSlotLoadTimeout(event:AdSlotLoadEvent):void {
			CONFIG::debugging { doLog("Ad slot " + event.adSlot.id + " at index " + event.adSlot.index + " dynamic load TIMEOUT - " + event.toString(), Debuggable.DEBUG_VAST_TEMPLATE); }
			dispatchEvent(event);
			CONFIG::callbacks {
				fireAPICall("onAdSlotLoadTimeout", event.toString());
			}
			if(_analyticsProcessor != null) {
				_analyticsProcessor.fireAdSlotTracking(AnalyticsProcessor.TIMED_OUT, event.adSlot, getAdditionalMetricsParams());
			}
		}

		public function onAdSlotLoadDeferred(event:AdSlotLoadEvent):void {
			CONFIG::debugging { doLog("Ad slot " + event.adSlot.id + " at index " + event.adSlot.index + " dynamic load DEFERRED - " + event.toString(), Debuggable.DEBUG_VAST_TEMPLATE); }
			dispatchEvent(event);
			CONFIG::callbacks {
				fireAPICall("onAdSlotLoadDeferred", event.toString());
			}
			if(_analyticsProcessor != null) {
				_analyticsProcessor.fireAdSlotTracking(AnalyticsProcessor.DEFERRED, event.adSlot, getAdditionalMetricsParams());
			}
		}
		
		// Player tracking control API
		
		public function onPlayerSeek(activeStreamIndex:int=-1, isAdSlotKey:Boolean = false, newTimePoint:Number=0):void {
			if(_adSchedule != null) {
				// step 1 - close down any active ad slots that are now out of date given the new time
				_adSchedule.closeOutdatedOverlaysAndCompanionsForThisStream(activeStreamIndex, newTimePoint, _config.adsConfig.resetTrackingOnReplay);
				// step 2 - process the new time event
				processTimeEvent(activeStreamIndex, new TimeEvent(newTimePoint, 0));
			}
		}

		public function onPlayerMute(activeStreamIndex:int=-1, isAdSlotKey:Boolean = false, contentPlayhead:String=null):void {
			if(isAdSlotKey) {
				if(activeStreamIndex > -1 && activeStreamIndex < _adSchedule.length) {
					_adSchedule.getSlot(activeStreamIndex).processMuteEvent(contentPlayhead);					
				}
			}
			else if(_streamSequence != null) _streamSequence.processMuteEventForStream(activeStreamIndex);
		}

		public function onPlayerUnmute(activeStreamIndex:int=-1, isAdSlotKey:Boolean = false, contentPlayhead:String=null):void {			
			if(isAdSlotKey) {
				if(activeStreamIndex > -1 && activeStreamIndex < _adSchedule.length) {
					_adSchedule.getSlot(activeStreamIndex).processUnmuteEvent(contentPlayhead);					
				}				
			}
			else if(_streamSequence != null) _streamSequence.processUnmuteEventForStream(activeStreamIndex);
		}

		public function onPlayerPlay(activeStreamIndex:int=-1, isAdSlotKey:Boolean = false):void {
			// TO IMPLEMENT
		}

		public function onPlayerStop(activeStreamIndex:int=-1, isAdSlotKey:Boolean = false, contentPlayhead:String=null):void {
			if(isAdSlotKey) {
				if(activeStreamIndex > -1 && activeStreamIndex < _adSchedule.length) {
					_adSchedule.getSlot(activeStreamIndex).processStopStream(contentPlayhead);					
				}																
			}
			else {
				if(_streamSequence != null) _streamSequence.processStopEventForStream(activeStreamIndex);
				if(handlingNonLinearAdDisplay()) _overlayController.hideAllOverlays();		
			}
		}

		public function onPlayerResize(activeStreamIndex:int=-1, isAdSlotKey:Boolean = false):void {
			if(isAdSlotKey) {
				if(activeStreamIndex > -1 && activeStreamIndex < _adSchedule.length) {
					_adSchedule.getSlot(activeStreamIndex).processFullScreenEvent();					
				}								
			}
			else if(_streamSequence != null) _streamSequence.processFullScreenEventForStream(activeStreamIndex);
		}

		public function onPlayerFullscreenEntry(activeStreamIndex:int=-1, isAdSlotKey:Boolean = false, contentPlayhead:String=null):void {
			if(isAdSlotKey) {
				if(activeStreamIndex > -1 && activeStreamIndex < _adSchedule.length) {
					_adSchedule.getSlot(activeStreamIndex).processFullScreenEvent(contentPlayhead);					
				}								
			}
			else if(_streamSequence != null) _streamSequence.processFullScreenEventForStream(activeStreamIndex);
		}

		public function onPlayerFullscreenExit(activeStreamIndex:int=-1, isAdSlotKey:Boolean = false, contentPlayhead:String=null):void {
			if(isAdSlotKey) {
				if(activeStreamIndex > -1 && activeStreamIndex < _adSchedule.length) {
					_adSchedule.getSlot(activeStreamIndex).processFullScreenExitEvent(contentPlayhead);					
				}								
			}
			else if(_streamSequence != null) _streamSequence.processFullScreenExitEventForStream(activeStreamIndex);
		}

		public function onPlayerPause(activeStreamIndex:int=-1, isAdSlotKey:Boolean = false, contentPlayhead:String=null):void {	
			var stream:Stream = null;
			if(isAdSlotKey) {
				if(_adSchedule != null) {
					stream = _adSchedule.getSlot(activeStreamIndex);				
				}
			}
			else {
				if(_streamSequence != null) {
					stream = _streamSequence.getStreamAtIndex(activeStreamIndex);
				}
			}

			if(stream != null) {
				if(stream is AdSlot) {
					if(_overlayController != null) {
						if(AdSlot(stream).isLinear() && AdSlot(stream).isInteractive()) {
							if(_overlayController.isVPAIDAdPlaying()) {
								_overlayController.pauseActiveVPAIDAd();	
							}
							_overlayController.pauseLinearAdRegions();
							return;
						} 
						_overlayController.pauseLinearAdRegions();
					}
				}
				stream.processPauseStream(contentPlayhead);
			}
		}

		public function onPlayerResume(activeStreamIndex:int=-1, isAdSlotKey:Boolean = false, contentPlayhead:String=null):void {
			var stream:Stream = null;
			if(isAdSlotKey) {
				if(_adSchedule != null) {
					stream = _adSchedule.getSlot(activeStreamIndex);				
				}
			}
			else {
				if(_streamSequence != null) {
					stream = _streamSequence.getStreamAtIndex(activeStreamIndex);
				}
			}

			if(stream != null) {
				if(stream is AdSlot) {
					if(_overlayController != null) {
						if(AdSlot(stream).isLinear() && AdSlot(stream).isInteractive() && _overlayController.isVPAIDAdPlaying()) {
							_overlayController.resumeActiveVPAIDAd();
						}						
						_overlayController.resumeLinearAdRegions();
					}
				}
				stream.processResumeStream(contentPlayhead);
			}
		}

		public function onPlayerReplay(activeStreamIndex:int=-1, isAdSlotKey:Boolean = false):void {			
			// TO IMPLEMENT
		}

        // SeekerBarDisplayController callbacks
        
		public function onToggleSeekerBar(enable:Boolean):void {
			if(_config.playerConfig.shouldDisableControlsDuringLinearAds()) { 
	 			CONFIG::debugging { doLog("Request received to change the control bar state to " + ((!enable) ? "BLOCKED" : "ON"), Debuggable.DEBUG_DISPLAY_EVENTS); }
			    dispatchEvent(new SeekerBarEvent(SeekerBarEvent.TOGGLE, enable)); // SeekerBarEvent has been depreciated - replaced by OVAControlBarEvent			
			    dispatchEvent(new OVAControlBarEvent((enable) ? OVAControlBarEvent.ENABLE :  OVAControlBarEvent.DISABLE));			
			}
			else {
				CONFIG::debugging { doLog("Ignoring request to change control bar state", Debuggable.DEBUG_DISPLAY_EVENTS); }
			}
		}        
        		
        // Analytics
        
        public function registerAnalytics(defaults:Array):void {
        	if(_config != null) {
	        	_config.analytics.update(defaults);
        	}
        }
        
		// VideoAdDisplayController callbacks 

		public function onDisplayNonLinearAd(overlayAdDisplayEvent:OverlayAdDisplayEvent):void {
			if(overlayAdDisplayEvent != null) {
				if(overlayAdDisplayEvent.adSlot != null) {
					if(overlayAdDisplayEvent.displayMode == OverlayAdDisplayEvent.DISPLAY_MODE_HTML5) {
						if(overlayAdDisplayEvent.isVPAIDAd() == false) {
							if(ExternalInterface.available) {
								displayNonLinearAdExternally(overlayAdDisplayEvent);
							}
						}
					}
					else displayNonLinearAdInternally(overlayAdDisplayEvent);
				}
			}
		}
		
		public function onHideNonLinearAd(overlayAdDisplayEvent:OverlayAdDisplayEvent):void {
			if((overlayAdDisplayEvent.displayMode == OverlayAdDisplayEvent.DISPLAY_MODE_HTML5) && (overlayAdDisplayEvent.isVPAIDAd() == false) && ExternalInterface.available) {
				hideNonLinearAdExternally(overlayAdDisplayEvent);
			}
			else hideNonLinearAdInternally(overlayAdDisplayEvent);
		}

		protected function displayNonLinearAdInternally(overlayAdDisplayEvent:OverlayAdDisplayEvent):void {			
			if(handlingNonLinearAdDisplay() && overlayAdDisplayEvent != null) {
				var adSlot:AdSlot = overlayAdDisplayEvent.adSlot;

				// if the overlay ad has a linear video ad stream attached, create it and have to ready to 
				// go if the overlay is clicked
				if(overlayAdDisplayEvent.nonLinearVideoAd.hasAccompanyingVideoAd()) {
					_overlayLinearVideoAdSlot = adSlot; 
				}

				if(NonLinearVideoAd(overlayAdDisplayEvent.nonLinearVideoAd).isInteractive()) {
					_overlayController.playVPAIDAd(adSlot,
					    {
					    	onLoading: function(event:VPAIDEvent=null):void {
				    			dispatchEvent(new VPAIDAdDisplayEvent(VPAIDAdDisplayEvent.NON_LINEAR_LOADING, adSlot));
					    	},
							onLoaded: function(event:VPAIDEvent=null):void { 
								if(_analyticsProcessor != null) {
									_analyticsProcessor.fireVPAIDPlaybackTracking(AnalyticsProcessor.LOADED, adSlot, overlayAdDisplayEvent.nonLinearVideoAd, getAdditionalMetricsParams());
								}
								dispatchEvent(new VPAIDAdDisplayEvent(VPAIDAdDisplayEvent.NON_LINEAR_LOADED, adSlot, event.data, event.bubbles, event.cancelable));		
							},
							onImpression: function(event:VPAIDEvent=null):void { 
								if(_analyticsProcessor != null) {
									_analyticsProcessor.fireImpressionTracking(AnalyticsProcessor.NON_LINEAR, adSlot, overlayAdDisplayEvent.nonLinearVideoAd, getAdditionalMetricsParams()); 
								}
								dispatchEvent(new VPAIDAdDisplayEvent(VPAIDAdDisplayEvent.NON_LINEAR_IMPRESSION, adSlot, event.data, event.bubbles, event.cancelable));		
							},
							onStart: function(event:VPAIDEvent=null):void { 
								if(_analyticsProcessor != null) {
									_analyticsProcessor.fireVPAIDPlaybackTracking(AnalyticsProcessor.STARTED, adSlot, overlayAdDisplayEvent.nonLinearVideoAd, getAdditionalMetricsParams());
								}
								dispatchEvent(new VPAIDAdDisplayEvent(VPAIDAdDisplayEvent.NON_LINEAR_START, adSlot, event.data, event.bubbles, event.cancelable));		
							}, 
							onPaused: function(event:VPAIDEvent=null):void {
								if(_analyticsProcessor != null) {
									_analyticsProcessor.fireVPAIDPlaybackTracking(AnalyticsProcessor.PAUSED, adSlot, overlayAdDisplayEvent.nonLinearVideoAd, getAdditionalMetricsParams());
								}
							},
							onPlaying: function(event:VPAIDEvent=null):void {
								if(_analyticsProcessor != null) {
									_analyticsProcessor.fireVPAIDPlaybackTracking(AnalyticsProcessor.PLAYING, adSlot, overlayAdDisplayEvent.nonLinearVideoAd, getAdditionalMetricsParams());
								}								
							},
							onComplete: function(event:VPAIDEvent=null):void { 
								if(_analyticsProcessor != null) {
									_analyticsProcessor.fireVPAIDPlaybackTracking(AnalyticsProcessor.COMPLETE, adSlot, overlayAdDisplayEvent.nonLinearVideoAd, getAdditionalMetricsParams());
								}
								dispatchEvent(new VPAIDAdDisplayEvent(VPAIDAdDisplayEvent.NON_LINEAR_COMPLETE, adSlot, event.data, event.bubbles, event.cancelable));		
							},
							onError: function(event:VPAIDEvent=null):void { 
								if(adSlot != null) {
									adSlot.fireErrorUrls("901");
								}
								if(_analyticsProcessor != null) {
									_analyticsProcessor.fireVPAIDPlaybackTracking(AnalyticsProcessor.ERROR, adSlot, overlayAdDisplayEvent.nonLinearVideoAd, getAdditionalMetricsParams("&ova_error=" + event.data));
								}
								dispatchEvent(new VPAIDAdDisplayEvent(VPAIDAdDisplayEvent.NON_LINEAR_ERROR, adSlot, event.data, event.bubbles, event.cancelable));		
							},
							onLog: function(event:VPAIDEvent=null):void { 
								dispatchEvent(new VPAIDAdDisplayEvent(VPAIDAdDisplayEvent.AD_LOG, adSlot, event.data, event.bubbles, event.cancelable));	
							},
							onExpandedChange: function(event:VPAIDEvent=null):void { 
								if(_analyticsProcessor != null) {
									_analyticsProcessor.fireVPAIDPlaybackTracking(AnalyticsProcessor.EXPANDED_CHANGE, adSlot, overlayAdDisplayEvent.nonLinearVideoAd, getAdditionalMetricsParams());
								}
								dispatchEvent(new VPAIDAdDisplayEvent(VPAIDAdDisplayEvent.NON_LINEAR_EXPANDED_CHANGE, adSlot, event.data, event.bubbles, event.cancelable));		
							},
							onLinearChange: function(event:VPAIDEvent=null):void { 
								if(_analyticsProcessor != null) {
									_analyticsProcessor.fireVPAIDPlaybackTracking(AnalyticsProcessor.LINEAR_CHANGE, adSlot, overlayAdDisplayEvent.nonLinearVideoAd, getAdditionalMetricsParams());
								}
								dispatchEvent(new VPAIDAdDisplayEvent(VPAIDAdDisplayEvent.NON_LINEAR_LINEAR_CHANGE, adSlot, event.data, event.bubbles, event.cancelable));		
							},
							onRemainingTimeChange: function(event:VPAIDEvent=null):void { 
								dispatchEvent(new VPAIDAdDisplayEvent(VPAIDAdDisplayEvent.NON_LINEAR_TIME_CHANGE, adSlot, event.data, event.bubbles, event.cancelable));		
							},
							onVolumeChange: function(event:VPAIDEvent=null):void {								
								dispatchEvent(new VPAIDAdDisplayEvent(((adSlot.isLinear()) ? VPAIDAdDisplayEvent.LINEAR_VOLUME_CHANGE : VPAIDAdDisplayEvent.NON_LINEAR_VOLUME_CHANGE), adSlot, event.data, event.bubbles, event.cancelable));		
							},
							onClickThru: function(event:VPAIDEvent=null):void { 
								if(_analyticsProcessor != null) {
									_analyticsProcessor.fireAdClickTracking(AnalyticsProcessor.VPAID, adSlot, overlayAdDisplayEvent.nonLinearVideoAd, getAdditionalMetricsParams());
								}
								dispatchEvent(new VPAIDAdDisplayEvent(VPAIDAdDisplayEvent.NON_LINEAR_CLICK_THRU, adSlot, event.data, event.bubbles, event.cancelable));		
							},
							onUserAcceptInvitation: function(event:VPAIDEvent=null):void { 
								if(_analyticsProcessor != null) {
									_analyticsProcessor.fireVPAIDPlaybackTracking(AnalyticsProcessor.USER_ACCEPT_INVITATION, adSlot, overlayAdDisplayEvent.nonLinearVideoAd, getAdditionalMetricsParams());
								}
								dispatchEvent(new VPAIDAdDisplayEvent(VPAIDAdDisplayEvent.NON_LINEAR_USER_ACCEPT_INVITATION, adSlot, event.data, event.bubbles, event.cancelable));		
							},
							onUserMinimize: function(event:VPAIDEvent=null):void { 
								if(_analyticsProcessor != null) {
									_analyticsProcessor.fireVPAIDPlaybackTracking(AnalyticsProcessor.COLLAPSE, adSlot, overlayAdDisplayEvent.nonLinearVideoAd, getAdditionalMetricsParams());
								}
								dispatchEvent(new VPAIDAdDisplayEvent(VPAIDAdDisplayEvent.NON_LINEAR_USER_MINIMIZE, adSlot, event.data, event.bubbles, event.cancelable));		
							},
							onUserClose: function(event:VPAIDEvent=null):void { 
								if(_analyticsProcessor != null) {
									_analyticsProcessor.fireVPAIDPlaybackTracking(AnalyticsProcessor.CLOSE, adSlot, overlayAdDisplayEvent.nonLinearVideoAd, getAdditionalMetricsParams());
								}
								dispatchEvent(new VPAIDAdDisplayEvent(VPAIDAdDisplayEvent.NON_LINEAR_USER_CLOSE, adSlot, event.data, event.bubbles, event.cancelable));		
							},
							onVideoAdStart: function(event:VPAIDEvent=null):void { 
								if(_analyticsProcessor != null) {
									_analyticsProcessor.fireVPAIDPlaybackTracking(AnalyticsProcessor.VIDEO_START, adSlot, overlayAdDisplayEvent.nonLinearVideoAd, getAdditionalMetricsParams());
								}
								dispatchEvent(new VPAIDAdDisplayEvent(VPAIDAdDisplayEvent.VIDEO_AD_START, adSlot, event.data, event.bubbles, event.cancelable));		
							},
							onVideoAdFirstQuartile: function(event:VPAIDEvent=null):void { 
								if(_analyticsProcessor != null) {
									_analyticsProcessor.fireVPAIDPlaybackTracking(AnalyticsProcessor.VIDEO_FIRST_QUARTILE, adSlot, overlayAdDisplayEvent.nonLinearVideoAd, getAdditionalMetricsParams());
								}
								dispatchEvent(new VPAIDAdDisplayEvent(VPAIDAdDisplayEvent.VIDEO_AD_FIRST_QUARTILE, adSlot, event.data, event.bubbles, event.cancelable));		
							},
							onVideoAdMidpoint: function(event:VPAIDEvent=null):void { 
								if(_analyticsProcessor != null) {
									_analyticsProcessor.fireVPAIDPlaybackTracking(AnalyticsProcessor.VIDEO_MIDPOINT, adSlot, overlayAdDisplayEvent.nonLinearVideoAd, getAdditionalMetricsParams());
								}
								dispatchEvent(new VPAIDAdDisplayEvent(VPAIDAdDisplayEvent.VIDEO_AD_MIDPOINT, adSlot, event.data, event.bubbles, event.cancelable));		
							},
							onVideoAdThirdQuartile: function(event:VPAIDEvent=null):void { 
								if(_analyticsProcessor != null) {
									_analyticsProcessor.fireVPAIDPlaybackTracking(AnalyticsProcessor.VIDEO_THIRD_QUARTILE, adSlot, overlayAdDisplayEvent.nonLinearVideoAd, getAdditionalMetricsParams());
								}
								dispatchEvent(new VPAIDAdDisplayEvent(VPAIDAdDisplayEvent.VIDEO_AD_THIRD_QUARTILE, adSlot, event.data, event.bubbles, event.cancelable));		
							},
							onVideoAdComplete: function(event:VPAIDEvent=null):void { 
								if(_analyticsProcessor != null) {
									_analyticsProcessor.fireVPAIDPlaybackTracking(AnalyticsProcessor.VIDEO_COMPLETE, adSlot, overlayAdDisplayEvent.nonLinearVideoAd, getAdditionalMetricsParams());
								}
								dispatchEvent(new VPAIDAdDisplayEvent(VPAIDAdDisplayEvent.VIDEO_AD_COMPLETE, adSlot, event.data, event.bubbles, event.cancelable));		
							},
							onSkipped: function(event:VPAIDEvent=null):void {
								if(_analyticsProcessor != null) {
									_analyticsProcessor.fireVPAIDPlaybackTracking(AnalyticsProcessor.SKIPPED, adSlot, overlayAdDisplayEvent.nonLinearVideoAd, getAdditionalMetricsParams());
								}
								dispatchEvent(new VPAIDAdDisplayEvent(VPAIDAdDisplayEvent.SKIPPED, adSlot, event.data, event.bubbles, event.cancelable));		
							},
							onSkippableStateChange: function(event:VPAIDEvent=null):void {
								if(_analyticsProcessor != null) {
									_analyticsProcessor.fireVPAIDPlaybackTracking(AnalyticsProcessor.SKIPPABLE_STATE_CHANGE, adSlot, overlayAdDisplayEvent.nonLinearVideoAd, getAdditionalMetricsParams());
								}
								dispatchEvent(new VPAIDAdDisplayEvent(VPAIDAdDisplayEvent.SKIPPABLE_STATE_CHANGE, adSlot, event.data, event.bubbles, event.cancelable));		
							},
							onSizeChange: function(event:VPAIDEvent=null):void {
								if(_analyticsProcessor != null) {
									_analyticsProcessor.fireVPAIDPlaybackTracking(AnalyticsProcessor.SIZE_CHANGE, adSlot, overlayAdDisplayEvent.nonLinearVideoAd, getAdditionalMetricsParams());
								}
								dispatchEvent(new VPAIDAdDisplayEvent(VPAIDAdDisplayEvent.SIZE_CHANGE, adSlot, event.data, event.bubbles, event.cancelable));		
							},
							onDurationChange: function(event:VPAIDEvent=null):void {
								if(_analyticsProcessor != null) {
									_analyticsProcessor.fireVPAIDPlaybackTracking(AnalyticsProcessor.DURATION_CHANGE, adSlot, overlayAdDisplayEvent.nonLinearVideoAd, getAdditionalMetricsParams());
								}
								dispatchEvent(new VPAIDAdDisplayEvent(VPAIDAdDisplayEvent.DURATION_CHANGE, adSlot, event.data, event.bubbles, event.cancelable));		
							},
							onAdInteraction: function(event:VPAIDEvent=null):void {
								if(_analyticsProcessor != null) {
									_analyticsProcessor.fireVPAIDPlaybackTracking(AnalyticsProcessor.AD_INTERACTION, adSlot, overlayAdDisplayEvent.nonLinearVideoAd, getAdditionalMetricsParams());
								}
								dispatchEvent(new VPAIDAdDisplayEvent(VPAIDAdDisplayEvent.AD_INTERACTION, adSlot, event.data, event.bubbles, event.cancelable));		
							}
					    },
						(playerVolume == 0),
						playerVolume,
						false,
						overlayAdDisplayEvent.region.enableScaling
					);
				}
				else {
					if(overlayAdDisplayEvent.nonLinearVideoAd.isIFrame() || overlayAdDisplayEvent.nonLinearVideoAd.isScript()) {
						CONFIG::debugging { doLog("iFrame and javascript based non-linear ads cannot be internally displayed via Flash - ignoring the request", Debuggable.DEBUG_DISPLAY_EVENTS); }
						return;							
					}
					else {
						_overlayController.displayNonLinearAd(overlayAdDisplayEvent);				
						if(_analyticsProcessor != null) {
							_analyticsProcessor.fireImpressionTracking(AnalyticsProcessor.NON_LINEAR, adSlot, overlayAdDisplayEvent.nonLinearVideoAd, getAdditionalMetricsParams());
						}
						dispatchEvent(overlayAdDisplayEvent);
					}
				}				
				CONFIG::callbacks {
					fireAPICall("onNonLinearAdShow", overlayAdDisplayEvent.nonLinearVideoAd.toJSObject());
				}
			}
		}

		protected function hideNonLinearAdInternally(overlayAdDisplayEvent:OverlayAdDisplayEvent):void {
			if(handlingNonLinearAdDisplay()) {
				var adSlot:AdSlot = overlayAdDisplayEvent.adSlot;
				if(overlayAdDisplayEvent.nonLinearVideoAd.isInteractive()) {
					_overlayController.closeActiveVPAIDAds();
				}
				else _overlayController.hideNonLinearAd(overlayAdDisplayEvent);
			}
			dispatchEvent(overlayAdDisplayEvent);			
			CONFIG::callbacks {
				fireAPICall("onNonLinearAdHide", overlayAdDisplayEvent.nonLinearVideoAd.toJSObject());
			}
		}

		protected function displayNonLinearAdExternally(overlayAdDisplayEvent:OverlayAdDisplayEvent):void {
			if(overlayAdDisplayEvent != null) {
				if(overlayAdDisplayEvent.nonLinearVideoAd.isInteractive()) {
					CONFIG::debugging { doLog("Non-linear VPAID ads cannot be displayed via HTML5 - ignoring the display request", Debuggable.DEBUG_DISPLAY_EVENTS); }
					return;
				}
				else {
					try {
						var regionID:String = overlayAdDisplayEvent.nonLinearVideoAd.getActiveDisplayRegionID();
						CONFIG::debugging { doLog("Displaying non-linear ad using the external jQuery library - region: '" + regionID + "', content type: '" + overlayAdDisplayEvent.nonLinearVideoAd.contentType() + "'", Debuggable.DEBUG_DISPLAY_EVENTS); }
						ExternalInterface.call(
							"ova.displayNonLinearAd", 
					        {
					        	regionID: regionID,
					        	content: {
					        		type: overlayAdDisplayEvent.nonLinearVideoAd.contentType(),
					        		format: overlayAdDisplayEvent.nonLinearVideoAd.getContentFormat(),
					        		raw: overlayAdDisplayEvent.nonLinearVideoAd.getRawContent(),
					        		formed: overlayAdDisplayEvent.nonLinearVideoAd.getContent()
					        	},
								clickThroughURL: overlayAdDisplayEvent.nonLinearVideoAd.getClickThroughURLString(),
								impressions: overlayAdDisplayEvent.nonLinearVideoAd.parentAdContainer.getImpressionList(),
								trackingEvents: overlayAdDisplayEvent.nonLinearVideoAd.getTrackingEventList(),
					        	region: overlayAdDisplayEvent.nonLinearVideoAd.activeDisplayRegion,
					        	closeButton: overlayAdDisplayEvent.nonLinearVideoAd.activeDisplayRegion.buttonConfig,
								nonLinearVideoAd: overlayAdDisplayEvent.nonLinearVideoAd.toJSObject(),
								adSlot: overlayAdDisplayEvent.adSlot.toJSObject()						        	
					        }
						);
					}
					catch(e:Error) {
						CONFIG::debugging { doLog("Exception attempting to execute ova.displayNonLinearAd() - " + e.message, Debuggable.DEBUG_FATAL);	}				
					}
				}
			}
		}	

		protected function hideNonLinearAdExternally(overlayAdDisplayEvent:OverlayAdDisplayEvent):void {
			if(overlayAdDisplayEvent != null) {
				if(overlayAdDisplayEvent.nonLinearVideoAd.isInteractive()) {
					CONFIG::debugging { doLog("Non-linear VPAID ads cannot be displayed via HTML5 - ignoring the hide request", Debuggable.DEBUG_DISPLAY_EVENTS); }
					return;
				}
				else {
					try {
						var regionID:String = overlayAdDisplayEvent.nonLinearVideoAd.getActiveDisplayRegionID();
						CONFIG::debugging { doLog("Hiding non-linear ad using the external jQuery library - region: '" + regionID + "', content type: '" + overlayAdDisplayEvent.nonLinearVideoAd.contentType() + "'", Debuggable.DEBUG_DISPLAY_EVENTS); }
						ExternalInterface.call(
							"ova.hideNonLinearAd", 
					        {
					        	regionID: regionID,
					        	content: {
					        		type: overlayAdDisplayEvent.nonLinearVideoAd.contentType(),
					        		format: overlayAdDisplayEvent.nonLinearVideoAd.getContentFormat()
					        	},
					        	region: overlayAdDisplayEvent.nonLinearVideoAd.activeDisplayRegion,
					        	closeButton: overlayAdDisplayEvent.nonLinearVideoAd.activeDisplayRegion.buttonConfig,
								nonLinearVideoAd: overlayAdDisplayEvent.nonLinearVideoAd.toJSObject(),
								adSlot: overlayAdDisplayEvent.adSlot.toJSObject()						        	
					        }
						);
					}
					catch(e:Error) {
						CONFIG::debugging { doLog("Exception attempting to execute ova.hideNonLinearAd() - " + e.message, Debuggable.DEBUG_FATAL); }					
					}
				}
			}
		}		

		public function onShowAdNotice(adNoticeDisplayEvent:AdNoticeDisplayEvent):void {
			if(handlingNonLinearAdDisplay()) _overlayController.showAdNotice(adNoticeDisplayEvent);
			dispatchEvent(adNoticeDisplayEvent);				
			CONFIG::callbacks {
				fireAPICall("onAdNoticeShow");
			}
		}
		
		public function onTickAdNotice(adNoticeDisplayEvent:AdNoticeDisplayEvent):void {
			if(handlingNonLinearAdDisplay()) _overlayController.showAdNotice(adNoticeDisplayEvent);
			dispatchEvent(adNoticeDisplayEvent);			
			CONFIG::callbacks {
				fireAPICall("onAdNoticeTick", adNoticeDisplayEvent.duration);			
			}
		}
		
		public function onHideAdNotice(adNoticeDisplayEvent:AdNoticeDisplayEvent):void {
			if(handlingNonLinearAdDisplay()) _overlayController.hideAdNotice(adNoticeDisplayEvent);
			dispatchEvent(adNoticeDisplayEvent);			
			CONFIG::callbacks {
				fireAPICall("onAdNoticeHide");
			}
		}

		public function onOverlayCloseClicked(overlayView:OverlayView):void {
			if(overlayView.activeAdSlot != null) {
				var adSlot:AdSlot = overlayView.activeAdSlot;
				if(adSlot != null) {
					var nonLinearVideoAd:NonLinearVideoAd = adSlot.getNonLinearVideoAd();
					nonLinearVideoAd.close();
					var event:NonLinearAdDisplayEvent = new OverlayAdDisplayEvent(
										OverlayAdDisplayEvent.CLOSE_CLICKED, 
										nonLinearVideoAd, 
										adSlot);
					dispatchEvent(event);					
					CONFIG::callbacks {
						fireAPICall("onNonLinearAdCloseClicked", adSlot.videoAd.toJSObject());
					}
				}
			}
		}

		public function onOverlayClicked(overlayView:OverlayView, originalMouseEvent:MouseEvent):void {
			if(overlayView.activeAdSlot != null) {
				var adSlot:AdSlot = overlayView.activeAdSlot;
				var nonLinearVideoAd:NonLinearVideoAd = adSlot.getNonLinearVideoAd();
				nonLinearVideoAd.clicked();
				var event:NonLinearAdDisplayEvent = 
						new OverlayAdDisplayEvent(
								OverlayAdDisplayEvent.CLICKED, 
								nonLinearVideoAd, 
								adSlot,
								null,
								originalMouseEvent
						);

				if(adSlot.hasLinearAd()) {
					CONFIG::debugging { doLog("Non-linear click is triggering the start of a 'click-to-play' linear ad attached to the overlay - forcing overlay to hide", Debuggable.DEBUG_CLICKTHROUGH_EVENTS); }
					overlayView.hide();
					dispatchEvent(event);					
				}
				else {
					if(nonLinearVideoAd.hasClickThroughs() && (nonLinearVideoAd.isInteractive() == false)) {
						var clickThroughURL:String = nonLinearVideoAd.firstClickThrough();
						CONFIG::debugging { doLog("Non-linear click is triggering a click-through to " + clickThroughURL , Debuggable.DEBUG_CLICKTHROUGH_EVENTS); }
						PopupWindow.openWindow(clickThroughURL, _config.adsConfig.clickSignConfig.target);
					}
					else {
						CONFIG::debugging { doLog("No action taken on non-linear click - no click-through specified", Debuggable.DEBUG_CLICKTHROUGH_EVENTS); }
					}
					dispatchEvent(event);
				}			
				CONFIG::callbacks {
					fireAPICall("onNonLinearAdClicked", adSlot.videoAd.toJSObject());
				}
				if(_analyticsProcessor != null) {
					_analyticsProcessor.fireAdClickTracking(AnalyticsProcessor.NON_LINEAR, adSlot, nonLinearVideoAd, getAdditionalMetricsParams());
				}
			}
		}
		
		public function onLinearAdClickThroughCallToActionViewClicked(adSlot:AdSlot):void { 
			if(adSlot != null) {
				var ad:LinearVideoAd = adSlot.getLinearVideoAd();
				if(ad != null && ad.hasClickThroughs()) {
					ad.clicked();
					PopupWindow.openWindow(ad.firstClickThrough(), _config.adsConfig.clickSignConfig.target);
					dispatchEvent(new LinearAdDisplayEvent(
										LinearAdDisplayEvent.CLICK_THROUGH, 
										adSlot)
					);
					CONFIG::callbacks {		
						fireAPICall("onLinearAdClick", adSlot.videoAd.toJSObject());
					}
					if(_analyticsProcessor != null) {
						_analyticsProcessor.fireAdClickTracking(AnalyticsProcessor.LINEAR, adSlot, ad, getAdditionalMetricsParams());
					}
				}
			}
		}
		
		// Fire off an error tracking event for a particular Ad
		
		public function fireErrorTrackingEvent(videoAd:VideoAd, errorCode:String="900"):void {
			if(videoAd != null) {
				videoAd.fireErrorUrls(errorCode);
			}
		}
		
		protected function validateAndFireRequiredErrorUrls(template:AdServerTemplate):void {
			if(template != null) {
				var _emptyVideoAds:Array = template.getEmptyVideoAdsWithErrorUrls();
				if(_emptyVideoAds.length > 0) {
					for each(var ad:VideoAd in _emptyVideoAds) {
						fireErrorTrackingEvent(ad, "303");
					}
				}
			}
		}
		
		// Forced Impression Firing for blank VAST Ad Responses
		
		public function processImpressionFiringForEmptyAdSlots(overrideIfAlreadyFired:Boolean=false):void {
			if(_adSchedule != null) {
				_adSchedule.processImpressionFiringForEmptyAdSlots(overrideIfAlreadyFired);
			}
		}	
			
		// CompanionDisplayController APIs

		protected function registerCompanionBeingDisplayed(companionAd:NonLinearVideoAd, divID:String, parentAdUID:String=null):void {
			if(companionAd != null) {
				_companionDisplayRegister[divID] = { companionAd: companionAd, parentAdUID: parentAdUID };
			}
			else _companionDisplayRegister[divID] = null;
		}

		protected function deregisterCompanionBeingDisplayed(divID:String):void {
			registerCompanionBeingDisplayed(null, divID);
		}
		
		protected function companionIsCurrentlyDisplayed(companionAd:NonLinearVideoAd, divID:String, parentAdUID:String):Boolean {
			if(_companionDisplayRegister[divID] != undefined && _companionDisplayRegister[divID] != null) {
				if(StringUtils.matchesIgnoreCase(_companionDisplayRegister[divID].parentAdUID, parentAdUID)) {
					return CompanionAd(companionAd).matches(_companionDisplayRegister[divID]);
				}
			}
			return false;
		}
		
		protected function anyCompanionIsCurrentlyDisplayed(divID:String, parentAdUID:String):Boolean {
			if(_companionDisplayRegister[divID] != undefined && _companionDisplayRegister[divID] != null) {
				return StringUtils.matchesIgnoreCase(_companionDisplayRegister[divID].parentAdUID, parentAdUID);
			}
			return false;
		}		

		protected function companionOfSameSizeNotDisplayed(companionAd:NonLinearVideoAd, divID:String, parentAdUID:String):Boolean {
			if(_companionDisplayRegister[divID] != undefined && _companionDisplayRegister[divID] != null) {
				return !CompanionAd(companionAd).matchesSize(_companionDisplayRegister[divID].width, _companionDisplayRegister[divID].height);
			}
			return true;
		}
		
		public function displayCompanionAd(companionEvent:CompanionAdDisplayEvent):void {	
			var companionAd:CompanionAd = companionEvent.companionAd;
			var previousContent:String;
        	if(processCompanionDisplayExternally()) {
		     	if(companionEvent.contentIsHTML()) {
	     	   		if(companionEvent.content != null) {
	        			if(companionEvent.content.length > 0) {
							if(anyCompanionIsCurrentlyDisplayed(companionEvent.divID, companionAd.getParentAdUID()) == false && companionOfSameSizeNotDisplayed(companionEvent.companionAd, companionEvent.divID, companionAd.getParentAdUID())) {
								try {
									CONFIG::debugging { doLog("Calling external javascript to insert companion - " + companionAd.width + "x" + companionAd.height + " creativeType: " + companionAd.creativeType + " resourceType: " + companionAd.resourceType, Debuggable.DEBUG_DISPLAY_EVENTS); }
									previousContent = ExternalInterface.call("ova.readHTML", companionEvent.divID);
									companionAd.registerDisplay(companionEvent.divID, previousContent);
									registerCompanionBeingDisplayed(companionEvent.companionAd, companionEvent.divID, companionAd.getParentAdUID());
									ExternalInterface.call("ova.writeElement", companionEvent.divID, companionEvent.content);								
									CONFIG::debugging { doLog("Companion has been written to the page via ova.writeElement() jQuery javascript function", Debuggable.DEBUG_DISPLAY_EVENTS); }
								}
								catch(e:Error) {
									CONFIG::debugging { doLog("Exception attempting to insert the companion code - " + e.message, Debuggable.DEBUG_FATAL);	}				
								}
							}
							else {
								CONFIG::debugging { doLog("Not writing companion content - it's already active or one of the same size is active in the DIV", Debuggable.DEBUG_DISPLAY_EVENTS); }
							}
	       				}
	       				else {
	       					CONFIG::debugging { doLog("No displaying companion - 0 length", Debuggable.DEBUG_DISPLAY_EVENTS); }
	       				}
	      			}
        			else {
        				CONFIG::debugging { doLog("No displaying companion - null length", Debuggable.DEBUG_DISPLAY_EVENTS); }
        			}      				
      			}
       			else if(companionEvent.contentIsSWF()) {
       				CONFIG::debugging { doLog("SWF content type not supported - should always be output as HTML - if this error comes up, something serious is wrong", Debuggable.DEBUG_FATAL); }
       			}
	        	else {
	        		CONFIG::debugging { doLog("Companion content type not supported", Debuggable.DEBUG_FATAL); }
	        	}
        	}
        	else {
	        	if(companionEvent.contentIsHTML()) {
	        		if(companionEvent.content != null) {
	        			if(companionEvent.content.length > 0) {
							if(anyCompanionIsCurrentlyDisplayed(companionEvent.divID, companionAd.getParentAdUID()) == false && companionOfSameSizeNotDisplayed(companionEvent.companionAd, companionEvent.divID, companionAd.getParentAdUID())) {
								try {
									previousContent = ExternalInterface.call("function() {return document.getElementById('" + companionEvent.divID + "').innerHTML; }");
									companionAd.registerDisplay(companionEvent.divID, previousContent);
									if(companionEvent.companionAd.isSWFCreativeType() && (companionEvent.companionAd.hasCode() == false) && BrowserUtils.isIE6()) {
										// Handle SWF creation differently because of an IE6 bug showing SWFs via innerHTML
										// The SWF Companion content is a Javascript function that creates the SWF object in the page
										ExternalInterface.call(companionEvent.content);	
										CONFIG::debugging { doLog("IE6: SWF Companion has been written to the page directly from OVA using SWF Object element creation", Debuggable.DEBUG_DISPLAY_EVENTS); }
									}
									else {
										// Use innerHTML to insert the companion markup
										ExternalInterface.call("function(){ document.getElementById('" + 
						                        companionEvent.divID + 
						                        "').innerHTML='" + 
						                        StringUtils.doubleEscapeSingleQuotes(StringUtils.removeNewlines(companionEvent.content)) + 
						                        "'; }");
										CONFIG::debugging { doLog("Companion has been written to the page directly from OVA SWF using 'innerHTML'", Debuggable.DEBUG_DISPLAY_EVENTS); }
									}
									registerCompanionBeingDisplayed(companionEvent.companionAd, companionEvent.divID, companionAd.getParentAdUID());
								}
								catch(e:Error) {
									CONFIG::debugging { doLog("Exception attempting to insert the companion code - " + e.message, Debuggable.DEBUG_FATAL);	}				
								}
							}
							else {
								CONFIG::debugging { doLog("Not writing companion content - it's already active or one of the same size is active in the DIV", Debuggable.DEBUG_DISPLAY_EVENTS); }
							}
	        			}
	        			else {
	        				CONFIG::debugging { doLog("No displaying companion - 0 length", Debuggable.DEBUG_DISPLAY_EVENTS); }
	        			}
	        		}
        			else {
        				CONFIG::debugging { doLog("No displaying companion - null length", Debuggable.DEBUG_DISPLAY_EVENTS); }
        			}
	        	}
	        	else {	
	        		CONFIG::debugging { doLog("Companion content type not supported", Debuggable.DEBUG_DISPLAY_EVENTS); }
	        	}
        	}
		}

		public function restoreCompanionDivs(companionEvent:CompanionAdDisplayEvent):Boolean {
			var companionAd:CompanionAd = companionEvent.companionAd;
			if(companionAd.isDisplayed()) {
	        	if(processCompanionDisplayExternally()) {
					CONFIG::debugging { doLog("Calling external javascript to hide companion ad: " + companionAd.id, Debuggable.DEBUG_DISPLAY_EVENTS); }
			    	try {
					    ExternalInterface.call("ova.writeHTML", companionAd.activeDivID, companionAd.previousDivContent);
				    	deregisterCompanionBeingDisplayed(companionAd.activeDivID);
				    	companionAd.deregisterDisplay();
					}
					catch(e:Error) {
						CONFIG::debugging { doLog("Exception attempting to restore the companion code - " + e.message, Debuggable.DEBUG_FATAL);	}				
					}
	        	}
	        	else {
					CONFIG::debugging { doLog("Event trigger received to hide the companion Ad with ID " + companionAd.id, Debuggable.DEBUG_DISPLAY_EVENTS); }
					try {
						ExternalInterface.call("function(){ document.getElementById('" + companionAd.activeDivID + "').innerHTML='" + StringUtils.removeControlChars(companionAd.previousDivContent) + "'; }");				
				    	deregisterCompanionBeingDisplayed(companionAd.activeDivID);
				    	companionAd.deregisterDisplay();
					}
					catch(e:Error) {
						CONFIG::debugging { doLog("Exception attempting to restore the companion code - " + e.message, Debuggable.DEBUG_DISPLAY_EVENTS);	}				
					}
	        	}	
	        	return true;			
			}
			return false;
		}		
		
		public function displayingCompanions():Boolean {
			return _config.displayCompanions;
		}
		
		public function processCompanionDisplayExternally():Boolean {
			return _config.processCompanionDisplayExternally;
		}

		public function processHTML5NonLinearDisplayExternally():Boolean {
			return _config.processHTML5NonLinearDisplayExternally;
		}

		protected function matchAndDisplayCompanion(companionAd:CompanionAd, companionDivID:Object):Boolean {
			if(anyCompanionIsCurrentlyDisplayed(companionDivID.id, companionAd.getParentAdUID())) {
				CONFIG::debugging { doLog("DIV " + companionDivID.id + " is busy with companion '" + _companionDisplayRegister[companionDivID.id].id + "'", Debuggable.DEBUG_DISPLAY_EVENTS); }
				return false;
			}
			var matchFound:Boolean = false;
			var matched:Boolean = false;			
			if(companionDivID.resourceType != undefined && companionDivID.creativeType == undefined) {
				CONFIG::debugging { doLog("Refining companion matching to " + companionDivID.width + "x" + companionDivID.height + " and resourceType:" + companionDivID.resourceType, Debuggable.DEBUG_DISPLAY_EVENTS); }
				matched = companionAd.matchesSizeAndResourceType(companionDivID.width, companionDivID.height, companionDivID.resourceType);							
			}
			else if(companionDivID.index != undefined) {
				CONFIG::debugging { doLog("Refining companion matching to " + companionDivID.width + "x" + companionDivID.height + " and index:" + companionDivID.index, Debuggable.DEBUG_DISPLAY_EVENTS); }
				matched = companionAd.matchesSizeAndIndex(companionDivID.width, companionDivID.height, companionDivID.index);
			}
			else if(companionDivID.creativeType != undefined && companionDivID.resoruceType != undefined) {
				CONFIG::debugging { doLog("Refining companion matching to " + companionDivID.width + "x" + companionDivID.height + " and creativeType: " + companionDivID.creativeType + " resourceType:" + companionDivID.resourceType, Debuggable.DEBUG_DISPLAY_EVENTS); }
				matched = companionAd.matchesSizeAndTypes(companionDivID.width, companionDivID.height, companionDivID.creativeType, companionDivID.resourceType);						
			}
			else {
				matched = companionAd.matchesSize(companionDivID.width, companionDivID.height);
			}

			if(matched) {
				matchFound = true;
				CONFIG::debugging { doLog("Found a match for " + companionDivID.width + "," + companionDivID.height + " - id of matching DIV is " + companionDivID.id, Debuggable.DEBUG_DISPLAY_EVENTS); }
				var code:String = companionAd.getDisplayCode(this.config.adsConfig.additionalParamsForSWFCompanions, processCompanionDisplayExternally(), companionDivID.id, BrowserUtils.isIE6());
				if(code != null) {
					var cde:CompanionAdDisplayEvent = new CompanionAdDisplayEvent(CompanionAdDisplayEvent.DISPLAY, companionAd);
					cde.divID = companionDivID.id;
					cde.content = code;
					companionDivID.activeAdID = companionAd.parentAdContainer.id;
					if(this.controllingDisplayOfCompanionContent) {
						displayCompanionAd(cde);
					}
					dispatchEvent(cde);
					CONFIG::callbacks {
						fireAPICall("onCompanionAdShow", companionAd.toJSObject());
					}
				}
			}	
			else {
				// No companion found
			}		
			return matchFound;
		}
		
		protected function displayCompanionsWithDelay(companionAd:CompanionAd, companionDivIDs:Array, delay:int):Boolean {
			CONFIG::debugging { doLog("Displaying companions with a " + delay + " millisecond delay", Debuggable.DEBUG_DISPLAY_EVENTS);		}	
			var matchFound:Boolean = false;
			var displayTimer:Timer = new Timer(delay, companionDivIDs.length);
			var tickCounter:int = 0;
		    displayTimer.addEventListener(TimerEvent.TIMER, function(e:TimerEvent):void {
				if(matchAndDisplayCompanion(companionAd, companionDivIDs[tickCounter])) {
					matchFound = true;
				}
				++tickCounter;
		    });
		    displayTimer.start();			
			if(!matchFound) {
				CONFIG::debugging { doLog("No DIV match found for sizing (" + companionAd.width + "," + companionAd.height + ")", Debuggable.DEBUG_DISPLAY_EVENTS);	}
			} 
			return matchFound;			
		}

		protected function displayCompanionsWithoutDelay(companionAd:CompanionAd, companionDivIDs:Array):Boolean {
			CONFIG::debugging { doLog("Displaying companions without a delay", Debuggable.DEBUG_DISPLAY_EVENTS); }
			var matchFound:Boolean = false;
			for(var i:int=0; i < companionDivIDs.length; i++) {
				if(matchAndDisplayCompanion(companionAd, companionDivIDs[i])) {
					matchFound = true;
				}
			}
			if(!matchFound) {
				CONFIG::debugging { doLog("No DIV match found for sizing (" + companionAd.width + "," + companionAd.height + ")", Debuggable.DEBUG_DISPLAY_EVENTS); }				
			}
			return matchFound;			
		}

		public function onDisplayCompanionAd(companionEvent:CompanionAdDisplayEvent):Boolean {
            CONFIG::debugging { doLog("Request received to display companion ad", Debuggable.DEBUG_DISPLAY_EVENTS); }
			var companionAd:CompanionAd = companionEvent.companionAd;
			if(_config.hasCompanionDivs()) {
				var companionDivIDs:Array = _config.companionDivIDs;
				CONFIG::debugging { doLog("Event trigger received by companion Ad with ID " + companionAd.id + " - looking for a div to match the sizing (" + companionAd.width + "," + companionAd.height + ")", Debuggable.DEBUG_DISPLAY_EVENTS); }
				if(_config.delayingCompanionInjection()) {
					return displayCompanionsWithDelay(companionAd, companionDivIDs, _config.millisecondDelayOnCompanionInjection);
				}
				else return displayCompanionsWithoutDelay(companionAd, companionDivIDs);
			}
			else {
				CONFIG::debugging { doLog("No DIVS specified for companion ads to be displayed", Debuggable.DEBUG_DISPLAY_EVENTS); }
			}
			return false;           				
		}
				
		public function onHideCompanionAd(companionEvent:CompanionAdDisplayEvent):Boolean {
			var result:Boolean = false;
			if(_config.restoreCompanions) {
				if(this.controllingDisplayOfCompanionContent) {
					result = restoreCompanionDivs(companionEvent);
				}
				dispatchEvent(new CompanionAdDisplayEvent(CompanionAdDisplayEvent.HIDE, companionEvent.companionAd));	
				CONFIG::callbacks {
	  				fireAPICall("onCompanionAdHide", companionEvent.companionAd.toJSObject());
	  			}
			}
			return result;
		}
		
		// Survey display/hide 
		
		protected function registerSurveyBeingDisplayed(divID:String, content:String=null):void {
			if(divID != null) {
				_surveyDisplayRegister[divID] = content;
			}
			else _surveyDisplayRegister[divID] = null;
		}

		protected function deregisterSurveyBeingDisplayed(divID:String):void {
			registerSurveyBeingDisplayed(divID, null);
		}
		
		protected function getSurveyPreviousDivContent(divID:String):String {
			return _surveyDisplayRegister[divID];
		}
		
		public function onSurveyDisplay(surveyUrl:String):void {
			if(_config.adsConfig.surveyConfig.declared()) {
				try {
					CONFIG::debugging { doLog("Calling external javascript to insert survey into DIV '" + _config.adsConfig.surveyConfig.id + "'", Debuggable.DEBUG_DISPLAY_EVENTS); }
					var previousContent:String = ExternalInterface.call("ova.readHTML", _config.adsConfig.surveyConfig.id);
					registerSurveyBeingDisplayed(_config.adsConfig.surveyConfig.id, previousContent);
					var surveyMarkup:String = "<iframe frameborder=0 src='" + surveyUrl + "'></iframe>";
					ExternalInterface.call("ova.writeElement", _config.adsConfig.surveyConfig.id, surveyMarkup);								
					CONFIG::debugging { doLog("Survey has been written to the page via ova.writeElement() jQuery javascript function", Debuggable.DEBUG_DISPLAY_EVENTS); }
				}
				catch(e:Error) {
					CONFIG::debugging { doLog("Exception attempting to insert the survey code - " + e.message, Debuggable.DEBUG_FATAL);	}				
				}				
			}
			CONFIG::callbacks {
  				fireAPICall("onSurveyStart", surveyUrl);
  			}
		}
		
		public function onSurveyHide():void {
			if(_config.adsConfig.surveyConfig.declared() && _config.adsConfig.surveyConfig.restore) {
		    	try {
				    ExternalInterface.call("ova.writeHTML", _config.adsConfig.surveyConfig.id, getSurveyPreviousDivContent(_config.adsConfig.surveyConfig.id));
			    	deregisterSurveyBeingDisplayed(_config.adsConfig.surveyConfig.id);
				}
				catch(e:Error) {
					CONFIG::debugging { doLog("Exception attempting to restore the survey div code - " + e.message, Debuggable.DEBUG_FATAL);	}				
				}
			}
			CONFIG::callbacks {
  				fireAPICall("onSurveyHide");
  			}
		}
		
		// Event registration - region based events must be registered with the overlay(region) controller
		
        public override function addEventListener(type:String, listener:Function, useCapture:Boolean = false, priority:int = 0, useWeakReference:Boolean = false):void {
        	if(type.indexOf("region-") > -1) {
        		if(_overlayController != null) {
        			_overlayController.addEventListener(type, listener, useCapture, priority, useWeakReference);
        		}
        	}
        	else super.addEventListener(type, listener, useCapture, priority, useWeakReference);
        }
        
        public override function removeEventListener(type:String, listener:Function, useCapture:Boolean = false):void {
        	if(type.indexOf("region-") > -1) {
        		if(_overlayController != null) {
        			_overlayController.addEventListener(type, listener, useCapture);
        		}
        	}
        	else super.removeEventListener(type, listener, useCapture);
        }		
        
        public function getVASTResponseAsString():String {
        	if(_template != null) {
        		return _template.getRawTemplateData();
        	}
        	else return "No VAST response available";
        }
	}
}