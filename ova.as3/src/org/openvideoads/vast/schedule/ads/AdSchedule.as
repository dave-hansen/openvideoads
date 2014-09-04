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
package org.openvideoads.vast.schedule.ads {
	import flash.events.Event;
	
	import org.openvideoads.base.Debuggable;
	import org.openvideoads.util.StringUtils;
	import org.openvideoads.vast.VASTController;
	import org.openvideoads.vast.analytics.AnalyticsProcessor;
	import org.openvideoads.vast.config.Config;
	import org.openvideoads.vast.model.CompanionAd;
	import org.openvideoads.vast.schedule.StreamConfig;
	import org.openvideoads.vast.schedule.StreamSequence;
	import org.openvideoads.vast.server.request.AdServerRequest;
	import org.openvideoads.vast.server.request.AdServerRequestProcessor;
	import org.openvideoads.vast.server.response.AdServerTemplate;
	import org.openvideoads.vast.server.response.TemplateLoadListener;
	import org.openvideoads.vast.tracking.TimeEvent;
	
	/**
	 * @author Paul Schulz
	 */
	public class AdSchedule extends Debuggable implements TemplateLoadListener {
		protected var _adSlots:Array = new Array(); 
		protected var _vastController:VASTController = null;
		protected var _lastTrackedStreamIndex:int = -1;
		protected var _adServerRequestProcessor:AdServerRequestProcessor = null;
		protected var _templateLoadListener:TemplateLoadListener = null;
		protected var _loadingOnDemand:Boolean = false;
		
		public function AdSchedule(vastController:VASTController, relatedStreamSequence:StreamSequence, config:Config=null, vastData:AdServerTemplate=null) {
			super();
			_vastController = vastController;
			if(config != null) {
				build(config, relatedStreamSequence, -1, true);
				if(vastData) {
					schedule(vastData);
				}
			}
		}

		public function unload():void {
			if(_adServerRequestProcessor != null) {
				_adServerRequestProcessor.unload();
				if(hasAdSlots()) {
					for(var i:int=0; i < _adSlots.length; i++) {
						_adSlots[i].unload();
					}
				}
			}
		}
		
		public function loadingOnDemand():Boolean {
			return _loadingOnDemand;
		}
		
		CONFIG::callbacks
		public function canFireAPICalls():Boolean {
			if(_vastController != null) {
				return _vastController.canFireAPICalls();				
			}
			return false;
		}
	
		CONFIG::callbacks
		public function canFireEventAPICalls():Boolean {
			if(_vastController != null) {
				return _vastController.canFireEventAPICalls();				
			}
			return false;
		}

		CONFIG::callbacks
		public function get useV2APICalls():Boolean {
			if(_vastController != null) {
				return _vastController.useV2APICalls;				
			}
			return false;
		}

		CONFIG::callbacks
		public function get jsCallbackScopingPrefix():String {
			if(_vastController != null) {
				return _vastController.jsCallbackScopingPrefix;				
			}
			return "";
		}

		public function get analyticsProcessor():AnalyticsProcessor {
			if(_vastController != null) {
				return _vastController.analyticsProcessor;				
			}
			return null;
		}

		protected function calculateShowStreamCount(streams:Array):int {
			// exclude everything that isn't a stream
			var count:int = 0;
			for(var i:int=0; i < streams.length; i++) {
				if(streams[i].isStream()) ++count;
			}
			return count;
		}
		
		public function get adSlots():Array {
			return _adSlots;
		}
		
		public function set adSlots(adSlots:Array):void {
			_adSlots = adSlots;
		}
		
		public function addAdSlot(adSlot:AdSlot):void {
			_adSlots.push(adSlot);
		}
		
		public function hasAdSlots():Boolean {
			return (_adSlots && _adSlots.length > 0);
		}
		
		public function haveAdSlotsToSchedule():Boolean {
			return (_adSlots.length > 0);
		}
		
		public function resetAllAdTrackingPointsAssociatedWithStream(associatedStreamIndex:int):void {
			if(hasAdSlots()) {
				for each(var adSlot:AdSlot in _adSlots) {
					if(adSlot.associatedStreamIndex == associatedStreamIndex) {
						adSlot.resetAllTrackingPoints();
					}
				}
			}
		}		
		
		public function hasLinearAds():Boolean {
			if(haveAdSlotsToSchedule()) {
				for(var i:int = 0; i < _adSlots.length; i++) {
					if(_adSlots[i].isLinear()) {
						if(_loadingOnDemand) return true;
						if(!AdSlot(_adSlots[i]).videoAd.isEmpty()) {
							return true;						
						}
					}
				}
			}	
			return false;	
		}

		public function hasNonLinearAds():Boolean {
			if(haveAdSlotsToSchedule()) {
				for(var i:int = 0; i < _adSlots.length; i++) {
					if(_adSlots[i].isNonLinear()) {
						if(_loadingOnDemand) return true;
						if(AdSlot(_adSlots[i]).isEmpty() == false) {
							return true;						
						}
					}
				}
			}	
			return false;	
		}

		public function hasSlot(index:int):Boolean {
			return (index < length);	
		}
		
		public function getSlot(index:int):AdSlot {
			if(hasSlot(index)) {
				return _adSlots[index];
			}
			return null; 
		}
		
		public function setAdSlotIDAtIndex(index:int, id:String):void {
			if(hasAdSlots() && index < _adSlots.length) {
				_adSlots[index].id = id;
			}
		}
		
		public function get length():int {
			return _adSlots.length;
		}
		
		private function getNoticeConfig(defaultNoticeConfig:Object, overridingConfig:Object):Object {
			var result:Object = new Object();
			if(defaultNoticeConfig != null) {
				if(defaultNoticeConfig.hasOwnProperty("show")) result.show = defaultNoticeConfig.show;
				if(defaultNoticeConfig.hasOwnProperty("region")) result.region = defaultNoticeConfig.region;
				if(defaultNoticeConfig.hasOwnProperty("message")) result.message = defaultNoticeConfig.message;
				if(defaultNoticeConfig.hasOwnProperty("type")) result.type = defaultNoticeConfig.type;
			}
			if(overridingConfig != null) {
				if(overridingConfig.hasOwnProperty("show")) result.show = overridingConfig.show;
				if(overridingConfig.hasOwnProperty("region")) result.region = overridingConfig.region;
				if(overridingConfig.hasOwnProperty("message")) result.message = overridingConfig.message;
				if(overridingConfig.hasOwnProperty("type")) result.type = overridingConfig.type;
			}
			return result;
		}
		
		private function getDisableControls(defaultSetting:*, overridingSetting:*):Boolean {
			if(overridingSetting != undefined) {
				return overridingSetting;
			}
			else if(defaultSetting != undefined) {
				return defaultSetting;
			}
			return false;
		}
		
		// Forced Impression Firing for blank VAST Ad Responses
		
		public function processImpressionFiringForEmptyAdSlots(overrideIfAlreadyFired:Boolean=false):void {
			if(haveAdSlotsToSchedule()) {
				CONFIG::debugging { doLog("Assessing forced impression firing for " + _adSlots.length + " ad slots", Debuggable.DEBUG_TRACKING_EVENTS); }
				for(var i:int = 0; i < _adSlots.length; i++) {
					if((AdSlot(_adSlots[i]).isEmpty() && AdSlot(_adSlots[i]).loadOnDemand == false) ||
					   (AdSlot(_adSlots[i]).isEmpty() && AdSlot(_adSlots[i]).loadOnDemand == true && AdSlot(_adSlots[i]).loadPreviouslyAttempted())) {
						_adSlots[i].processForcedImpression(overrideIfAlreadyFired);
					}
				}
			}
		}	

		public function getLastProcessedPreloadedAdTagIndex():int {
			if(_adServerRequestProcessor != null) {
				return _adServerRequestProcessor.getLastProcessedAdTagIndex();		
			}
			return 0;
		}
		
		private function checkApplicability(adSpot:Object, currentPart:int, excludePopupPosition:Boolean=false, streamCount:int=1, relatedStream:StreamConfig=null):Boolean {
			if(relatedStream != null) {
				if(!relatedStream.isStream()) return false;
			}
			if(adSpot.applyToParts != undefined) {
				if(adSpot.applyToParts is String) {
					if(adSpot.applyToParts.toUpperCase() == "LAST") {
						return ((currentPart + 1) == streamCount);
					}
					else return false;
				}
				else if(adSpot.applyToParts is Array) {
					return (adSpot.applyToParts.indexOf(currentPart) > -1);
				}
				else return false;
			}
			else return true;
		}
		
		public function createAdSpotID(overridingID:String, position:String, uniqueTag:int, streamIndex:int):String {
			if(overridingID != null) {
				return overridingID;
			}	
			else {
				if(position == null) {
					return "overlay" + ":" + uniqueTag + "." + streamIndex;					
				}
				return position + ":" + uniqueTag + "." + streamIndex;
			}
		}
		
		//-----------------------------------------------------------------------------------------------------------------
		
		public function hasPreloadedAdSlots():Boolean {
			if(_adSlots != null) {
				for(var i:int=0; i < _adSlots.length; i++) {
					if(AdSlot(_adSlots[i]).loadOnDemand == false) {
						return true;
					}
				}					
			}
			return false;
		}
		
		public function loadAdsFromAdServers(templateLoadListener:TemplateLoadListener):void {
			_templateLoadListener = templateLoadListener;
			if(_vastController.config.scheduleAds) {
				_adServerRequestProcessor = new AdServerRequestProcessor(this, _adSlots);
				_adServerRequestProcessor.start();			
			}
			else {
				CONFIG::debugging { doLog("Not scheduling ads for playback - ad scheduling has been explicitly turned off via the 'activelySchedule' configuration property", Debuggable.DEBUG_CONFIG);	}
				if(_templateLoadListener) _templateLoadListener.onTemplateLoaded(new AdServerTemplate());
			}		
		}
		
		public function onTemplateLoaded(template:AdServerTemplate):void {
			CONFIG::debugging { doLog("Notified that template has been loaded", Debuggable.DEBUG_VAST_TEMPLATE); }
			if(_templateLoadListener) _templateLoadListener.onTemplateLoaded(template);
		}
		
		public function onTemplateLoadError(event:Event):void {
			CONFIG::debugging { doLog("ERROR loading VAST template - " + event.toString(), Debuggable.DEBUG_FATAL); }
			if(_templateLoadListener) _templateLoadListener.onTemplateLoadError(event);
		}

		public function onTemplateLoadTimeout(event:Event):void {
			CONFIG::debugging { doLog("TIMEOUT loading VAST template - " + event.toString(), Debuggable.DEBUG_FATAL); }
			if(_templateLoadListener) _templateLoadListener.onTemplateLoadTimeout(event);
		}

		public function onTemplateLoadDeferred(event:Event):void {
			CONFIG::debugging { doLog("DEFERRED loading VAST template - " + event.toString(), Debuggable.DEBUG_FATAL); }
			if(_templateLoadListener) _templateLoadListener.onTemplateLoadDeferred(event);
		}
		
		public function onAdCallStarted(request:AdServerRequest):void {
			if(_templateLoadListener) _templateLoadListener.onAdCallStarted(request);
		}

		public function onAdCallFailover(masterRequest:AdServerRequest, failoverRequest:AdServerRequest):void { 
			if(_templateLoadListener) _templateLoadListener.onAdCallFailover(masterRequest, failoverRequest); 
		}
		
		public function onAdCallComplete(request:AdServerRequest, hasAds:Boolean):void {
			if(_templateLoadListener) _templateLoadListener.onAdCallComplete(request, hasAds);
		}
		
		//-----------------------------------------------------------------------------------------------------------------
				
		public function build(config:Config, relatedStreamSequence:StreamSequence, maxSpots:int=-1, excludePopupPosition:Boolean=false):void {
			if(config.adSchedule) {
				var numberOfStreams:int = ((config.streams.length == 0) ? 1 : config.streams.length);
				CONFIG::debugging { doLog("Building the ad schedule - " + config.adSchedule.length + " ad slots defined, stream count is " + config.streams.length + ", maxspots " + maxSpots, Debuggable.DEBUG_CONFIG); }
				for(var j:int = 0; j < numberOfStreams; j++) {
					if(maxSpots == -1) maxSpots = config.adSchedule.length;
					for(var i:int = 0; i < config.adSchedule.length && i <= maxSpots; i++) {
						var relatedStream:StreamConfig = ((j < config.streams.length) ? config.streams[j] : null);
						if(checkApplicability(config.adSchedule[i], j, excludePopupPosition, numberOfStreams, relatedStream)) {
							var adSpot:Object = config.adSchedule[i];
							var originalAdSlot:AdSlot;
							if((adSpot.zone is String) == false) {
								adSpot.zone = new String(adSpot.zone);
							}
							if(adSpot.zone && adSpot.zone.toUpperCase() == "STATIC") {
								originalAdSlot = new StaticAdSlot(relatedStreamSequence,
								                         this,
								                         _vastController,
														 _adSlots.length,
														 j,
														 createAdSpotID(adSpot.id, adSpot.position, i, j),
														 adSpot.zone,
													  	 adSpot.position,
													  	 ((adSpot.applyToParts == undefined) ? null : adSpot.applyToParts),
														 adSpot.duration, 
														 ((adSpot.startTime == undefined) ? "00:00:00" : adSpot.startTime),
														 getNoticeConfig(config.notice, adSpot.notice),
														 getDisableControls(config.playerConfig.shouldDisableControlsDuringLinearAds(), adSpot.disableControls),
														 new Array(),	
														 ((adSpot.companionDivIDs == undefined) ? 
													 			config.companionDivIDs : 
										  					    adSpot.companionDivIDs),
											  	 		 ((adSpot.startPoint == undefined) ? null : adSpot.startPoint),
											  	 		 ((adSpot.html == undefined) ? null : adSpot.html));
							}
							else {
								var adSpotID:String = createAdSpotID(adSpot.id, adSpot.position, i, j);
								originalAdSlot = new AdSlot(relatedStreamSequence,
								                     this,
								                     _vastController,
													 _adSlots.length,
													 j,
												     adSpotID,
													 adSpot.zone,
												  	 adSpot.position,
												  	 ((adSpot.applyToParts == undefined) ? null : adSpot.applyToParts),
													 adSpot.duration, 
													 adSpot.duration,
													 ((adSpot.startTime == undefined) ? "00:00:00" : adSpot.startTime),
													 getNoticeConfig(config.notice, adSpot.notice),
													 getDisableControls(config.playerConfig.shouldDisableControlsDuringLinearAds(), adSpot.disableControls),	
													 new Array(), 	
													 ((adSpot.companionDivIDs == undefined) ? 
												 			config.companionDivIDs : 
									  					    adSpot.companionDivIDs),
										  	 		 ((adSpot.streamType != undefined) ? adSpot.streamType : config.streamType),
										  	 		 ((adSpot.deliveryType != undefined) ? adSpot.deliveryType : config.deliveryType),
										  	 		 ((adSpot.bitrate != undefined) ? adSpot.bitrate : config.bitrate),
										  	 		 ((adSpot.playOnce != undefined) ? adSpot.playOnce : config.playOnce),
										  	 		 config.metaData,
										  	 		 ((adSpot.autoPlay != undefined) ? adSpot.autoPlay : config.autoPlay),
										  	 		 ((adSpot.regions != undefined) ? adSpot.regions : null),
										  	 		 ((adSpot.player != undefined) ? adSpot.player : config.adsConfig.player),
										  	 		 config.clickSignEnabled,
										  	 		 ((adSpot.server != undefined) ? adSpot.server : null),
										  	 		 null,
										  	 		 ((adSpot.loadOnDemand != undefined) ? StringUtils.validateAsBoolean(adSpot.loadOnDemand) : false),
										  	 		 ((adSpot.refreshOnReplay != undefined) ? StringUtils.validateAsBoolean(adSpot.refreshOnReplay) : false),
										  	 		 ((adSpot.hasOwnProperty("maxDisplayCount")) ? StringUtils.validateAsNumber(adSpot.maxDisplayCount) : -1)
										  	 	);
								CONFIG::debugging { 
									doLog("Created new ad slot " + i + 
								          " with ID: " + adSpotID + 
								          " tied to stream index " + j + 
								          (originalAdSlot.loadOnDemand ? " - loading on demand" : "") + 
								          (originalAdSlot.refreshOnReplay ? " - refreshing on replay" : ""), 
								          Debuggable.DEBUG_CONFIG);
								}
							}
							var repeatCount:int = ((adSpot.repeat == undefined) ? 1 : adSpot.repeat);
							if(repeatCount > 1) {
								var adSlot:AdSlot = originalAdSlot;
								for(var r:int=0; r < repeatCount; r++) {
									addAdSlot(adSlot);
									adSlot = adSlot.clone();
									adSlot.key = _adSlots.length;
								}								
							}
							else addAdSlot(originalAdSlot);
							if(originalAdSlot.loadOnDemand) {
								_loadingOnDemand = true;
							}
						}
					}		
				}
				CONFIG::debugging { doLog("Ad schedule constructed - " + _adSlots.length + " ad positions created and slotted", Debuggable.DEBUG_CONFIG); }
				if(_loadingOnDemand) {
					CONFIG::debugging { doLog("Parts of the Ad Schedule will be loaded 'on demand'", Debuggable.DEBUG_CONFIG); }
				}
				else {
					CONFIG::debugging { doLog("The entire ad schedule will be pre-loaded", Debuggable.DEBUG_CONFIG); }
				} 		
			}
		}

        public function fireNonLinearSchedulingEvents():void {
        	if(_vastController != null) {
				for(var i:int = 0; i < _adSlots.length; i++) {
					if(AdSlot(_adSlots[i]).loadOnDemand) {
						_vastController.onScheduleNonLinear(_adSlots[i], true);									
					}
					else {
						if(!_adSlots[i].isLinear() && _adSlots[i].hasNonLinearAds()) {
							_vastController.onScheduleNonLinear(_adSlots[i], false);			
						}
					}
	   			}
        	}
        }
        
		public function addNonLinearAdTrackingPoints(zeroStartTime:Boolean=true, overrideSetFlag:Boolean=false):void {
			CONFIG::debugging { doLog("Setting up non-linear cuepoints", Debuggable.DEBUG_CUEPOINT_FORMATION); }
			if(hasAdSlots()) {
				for(var i:int; i < _adSlots.length; i++) {
					if(_adSlots[i].isNonLinear()) {
						_adSlots[i].addNonLinearAdTrackingPoints(i, zeroStartTime, true, overrideSetFlag); 							
					}
				}
			}
		}
		
		public function getAdIds():Array {
			var result:Array = new Array();
			for(var i:int = 0; i < _adSlots.length; i++) {
				if(_adSlots[i].id && _adSlots[i].id != "popup") {
					result.push(_adSlots[i].id + "-" + _adSlots[i].associatedStreamIndex);
				}
			}
			return result;
		}
		
		public function get zones():Array {
			var zones:Array = new Array();
			for(var i:int = 0; i < _adSlots.length; i++) {
				if(_adSlots[i].id && _adSlots[i].id != "popup") {
					var zone:Object = new Object();
					zone.id = _adSlots[i].id + "-" + _adSlots[i].associatedStreamIndex;
					zone.zone = _adSlots[i].zone;
					zones.push(zone);
				}
			}		
			return zones;	
		}
		
		CONFIG::callbacks
		public function fireAPICall(... args):* {
			if(_vastController != null) {
				_vastController.fireAPICall(args);
			}
		}
		
		public function schedule(template:AdServerTemplate=null):void {
			CONFIG::callbacks {
				if(_vastController.canFireAPICalls()) _vastController.fireAPICall("onAdSchedulingStarted");
				var adSet:Array = new Array();
			}
			if(hasAdSlots()) {
				adLoop: for(var i:int = 0; i < _adSlots.length; i++) {
					if(_adSlots[i].id != null) { 
						if(template != null) {
							_adSlots[i].videoAd = template.getVideoAdWithID(_adSlots[i].id + "-" + _adSlots[i].associatedStreamIndex);
							CONFIG::callbacks {
								if(_adSlots[i].videoAd != null) {
									if(_vastController.canFireAPICalls()) {
										var ad:Object = null;
										if(AdSlot(_adSlots[i]).isLinear() && AdSlot(_adSlots[i]).hasLinearAd()) {
											ad = AdSlot(_adSlots[i]).videoAd.toJSObject();
											_vastController.fireAPICall("onLinearAdScheduled", ad);
											_vastController.analyticsProcessor.fireAdSchedulingTracking(AnalyticsProcessor.SCHEDULED, AdSlot(_adSlots[i]));
											adSet.push(ad); 
										}
										else if(AdSlot(_adSlots[i]).isNonLinear() && AdSlot(_adSlots[i]).hasNonLinearAds()) {
											ad = AdSlot(_adSlots[i]).videoAd.toJSObject();
											_vastController.fireAPICall("onNonLinearAdScheduled", ad); 					
											_vastController.analyticsProcessor.fireAdSchedulingTracking(AnalyticsProcessor.SCHEDULED, AdSlot(_adSlots[i]));
											adSet.push(ad); 
										}
										if((AdSlot(_adSlots[i]).videoAd.isCompanionOnlyAd() == false) && AdSlot(_adSlots[i]).hasCompanionAds()) {
											var matchedCompanions:Array = AdSlot(_adSlots[i]).videoAd.getMatchingCompanions(_vastController.config.companionDivIDs);
											for(var j:int=0; j < matchedCompanions.length; j++) {
												_vastController.fireAPICall("onCompanionAdScheduled", matchedCompanions[j].div, CompanionAd(matchedCompanions[j].companion).toJSObject(), AdSlot(_adSlots[i]).videoAd.toJSObject());								
											}
										}
										if(ad == null) {
											// No ad was found so this ad slot is empty
											_vastController.analyticsProcessor.fireAdSlotTracking(AnalyticsProcessor.EMPTY, AdSlot(_adSlots[i]));										
										}
									}
								}
								else {
									if(_vastController.canFireAPICalls()) {		
										_vastController.fireAPICall("onScheduleError", "No video ad available to schedule", AdSlot(_adSlots[i]).toJSObject());
										_vastController.analyticsProcessor.fireAdSlotTracking(AnalyticsProcessor.EMPTY, AdSlot(_adSlots[i]));
									}
								}
							}
							continue adLoop;
						}
						else {
							_vastController.analyticsProcessor.fireAdSlotTracking(AnalyticsProcessor.EMPTY, AdSlot(_adSlots[i]));										
						}						

						CONFIG::callbacks {
							// No template - could be load on demand ad slots - if so, fire the appropriate API calls
							if(AdSlot(_adSlots[i]).loadOnDemand) {
								if(_vastController.canFireAPICalls()) {		
									_vastController.fireAPICall("onLoadOnDemandAdSlotScheduled", AdSlot(_adSlots[i]).toJSObject());																																			
								}
							}
						}
					}
				}
			}
			CONFIG::callbacks {
			    if(_vastController.canFireAPICalls()) _vastController.fireAPICall("onAdSchedulingComplete", adSet);
			}
		}
		
		public function recordCompanionClickThrough(adSlotIndex:int, companionID:int):void {
			if(_adSlots.length < adSlotIndex) {
				_adSlots[adSlotIndex].registerCompanionClickThrough(companionID);
			}
		}
		
        public function processTimeEvent(associatedStreamIndex:int, timeEvent:TimeEvent, includeChildLinearPoints:Boolean=true):void {
        	// for every non-stream ad slot attached to the active stream, fire off the time event
			if(hasAdSlots()) {
				for(var i:int = 0; i < _adSlots.length; i++) {
					if(_adSlots[i].associatedStreamIndex == associatedStreamIndex && !_adSlots[i].isLinear()) {
						_adSlots[i].processTimeEvent(timeEvent, includeChildLinearPoints, _vastController.config.adsConfig.resetTrackingOnReplay);					
					}
				}
				_lastTrackedStreamIndex = associatedStreamIndex;
			}	
        }
        
		public function closeActiveOverlaysAndCompanions(resetTrackingOnReplay:Boolean=false):void {
			// used to clear up any active overlays or companions if the current stream is skipped
			if(hasAdSlots()) {
				for(var i:int = 0; i < _adSlots.length; i++) {
					if(_adSlots[i].isPlaying()) _adSlots[i].closeActiveOverlaysAndCompanions(resetTrackingOnReplay);
				}
			}
		}        

		public function closeOutdatedOverlaysAndCompanionsForThisStream(streamIndex:int, milliseconds:Number, resetTrackingOnReplay:Boolean=false):void {
			// used to clear up any active overlays or companions if the current stream is skipped
			if(hasAdSlots()) {
				for(var i:int = 0; i < _adSlots.length; i++) {
					if(_adSlots[i].associatedStreamIndex == streamIndex && (_adSlots[i].isLinear() == false)) {
						if(_adSlots[i].isPlaying() && (_adSlots[i].shouldBePlaying(milliseconds) == false)) {
							_adSlots[i].closeActiveOverlaysAndCompanions(resetTrackingOnReplay);
						} 					
					}
				}
			}
		} 
	}
}