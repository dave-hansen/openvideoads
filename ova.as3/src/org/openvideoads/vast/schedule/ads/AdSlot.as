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
 */
package org.openvideoads.vast.schedule.ads {
	import flash.events.Event;
	
	import org.openvideoads.base.Debuggable;
	import org.openvideoads.regions.view.FlashMedia;
	import org.openvideoads.util.NetworkResource;
	import org.openvideoads.util.StringUtils;
	import org.openvideoads.vast.VASTController;
	import org.openvideoads.vast.analytics.AnalyticsProcessor;
	import org.openvideoads.vast.config.groupings.AdSlotRegionConfig;
	import org.openvideoads.vast.events.AdNoticeDisplayEvent;
	import org.openvideoads.vast.events.AdSlotLoadEvent;
	import org.openvideoads.vast.events.VideoAdDisplayEvent;
	import org.openvideoads.vast.model.AdNetworkResource;
	import org.openvideoads.vast.model.LinearVideoAd;
	import org.openvideoads.vast.model.NonLinearVideoAd;
	import org.openvideoads.vast.model.VideoAd;
	import org.openvideoads.vast.model.VideoAdV3;
	import org.openvideoads.vast.schedule.Stream;
	import org.openvideoads.vast.schedule.StreamSequence;
	import org.openvideoads.vast.schedule.ads.templates.*;
	import org.openvideoads.vast.server.config.AdServerConfig;
	import org.openvideoads.vast.server.request.AdServerRequest;
	import org.openvideoads.vast.server.request.AdServerRequestProcessor;
	import org.openvideoads.vast.server.response.AdServerTemplate;
	import org.openvideoads.vast.server.response.TemplateLoadListener;
	import org.openvideoads.vast.tracking.TimeEvent;
	import org.openvideoads.vast.tracking.TrackingPoint;
	import org.openvideoads.vast.tracking.TrackingTable;
	
	/**
	 * @author Paul Schulz
	 */
	public class AdSlot extends Stream implements TemplateLoadListener {
		protected var _zone:String;
		protected var _position:String = null;
		protected var _videoAd:VideoAd = null;
		protected var _notice:Object = null;
		protected var _disableControls:Boolean = false;
		protected var _companionDivIDs:Array = new Array({ id:'companion', width:300, height:250 });
		protected var _applyToParts:Object = null;
		protected var _originatingAssociatedStreamIndex:int = 0;
		protected var _associatedStreamStartTime:int = 0;
		protected var _originalAdSlot:AdSlot = null;
		protected var _owner:AdSchedule = null;
		protected var _clickSignEnabled:Boolean = true;
		protected var _adServerConfig:AdServerConfig = null;
		protected var _isPlaying:Boolean = false;
		protected var _companionsShowing:Boolean = false;
		protected var _played:Boolean = false;
		protected var _overlayVideoPlaying:Boolean = false;
		protected var _loadOnDemand:Boolean = false;
		protected var _refreshOnReplay:Boolean = false;
		protected var _needsRefresh:Boolean = false;
		protected var _activeAdServerRequestProcessor:AdServerRequestProcessor = null;
		protected var _onDemandLoadListener:AdSlotOnDemandLoadListener = null;
		protected var _regions:Object = null;
		protected var _maxDisplayCount:int = -1;
		protected var _template:AdServerTemplate = null;
		protected var _loading:Boolean = false;
		protected var _vpaidForciblyStopped:Boolean = false;
		protected var _loadingOnFailover:Boolean = false;
		protected var _adServerRequest:AdServerRequest = null;
		
		public static const AD_TYPE_LINEAR:String = "linear";
		public static const AD_TYPE_NON_LINEAR:String = "non-linear";
		public static const AD_TYPE_COMPANION:String = "companion";
		public static const AD_TYPE_UNKNOWN:String = "unknown";
		
		public static const SLOT_POSITION_PRE_ROLL:String = "pre-roll";
		public static const SLOT_POSITION_MID_ROLL:String = "mid-roll";
		public static const SLOT_POSITION_POST_ROLL:String = "post-roll";
		public static const SLOT_POSITION_COMPANION:String = "companion";
		public static const SLOT_POSITION_AUTO_BOTTOM:String = "auto:bottom";
		
		private const EVENT_DELAY:int = 500;
				
		public function AdSlot(parent:StreamSequence,
		                       owner:AdSchedule, 
		                       vastController:VASTController, 
		                       key:int=0, 
		                       associatedStreamIndex:int=0, 
		                       id:String=null, 
		                       zone:String=null, 
		                       position:String=null, 
		                       applyToParts:Object=null, 
		                       duration:String=null, 
		                       originalDuration:String=null,
		                       startTime:String="00:00:00", 
		                       notice:Object=null, 
		                       disableControls:Boolean=true, 
		                       defaultLinearRegions:Array=null, 
		                       companionDivIDs:Array=null, 
		                       streamType:String="any",
		                       deliveryType:String="streaming", 
		                       bitrate:*=-1, 
		                       playOnce:Boolean=false,
		                       metaData:Boolean=true,
		                       autoPlay:Boolean=true,
		                       regions:Object=null,
		                       playerConfig:Object=null,
		                       clickSignEnabled:Boolean=true,
		                       adServerConfig:AdServerConfig=null,
		                       previewImage:String = null,
		                       loadOnDemand:Boolean=false,
		                       refreshOnReplay:Boolean=false,
		                       maxDisplayCount:int=-1) {
			super(parent, vastController, key, id, null, startTime, duration, originalDuration, false, null, streamType, deliveryType, bitrate, playOnce, metaData, autoPlay, null, playerConfig, previewImage, associatedStreamIndex);
            _owner = owner;
			_associatedStreamIndex = associatedStreamIndex;
			_originatingAssociatedStreamIndex = associatedStreamIndex;
			_zone = zone;
			_position = position;
			_regions = constructRegions(regions),
			_applyToParts = applyToParts;
			if(notice != null) _notice = notice;
			_disableControls = disableControls;
			if(companionDivIDs != null) _companionDivIDs = companionDivIDs;
			_clickSignEnabled = clickSignEnabled;
			if(adServerConfig != null) {
				_adServerConfig = adServerConfig;
			}
			_loadOnDemand = loadOnDemand;
			_refreshOnReplay = refreshOnReplay;
			_maxDisplayCount = maxDisplayCount;
		}

		public override function unload():void {
			if(_activeAdServerRequestProcessor != null) {
				_activeAdServerRequestProcessor.unload();
			}			
			if(hasVideoAd()) {
				_videoAd.unload();
			}
		}

		protected function constructRegions(customConfig:Object):Object {
			return {
				"preferred": (customConfig != null) ? (customConfig.hasOwnProperty("preferred") ? customConfig.preferred : "flash") : "flash",
				"flash": 
					formRegionsConfig(
					    "flash",
						(customConfig != null) ? customConfig.flash : null,
						{
							"enable": true,
							"width": -1,
							"height": -1,
							"acceptedAdTypes": [ "image", "html", "text", "swf", "vpaid" ],
							"enableScaling": false,
							"enforceRecommendedSizing": true,
							"keepVisibleAfterClick": false,
							"overlay": true,
							"region": { 
								text: "reserved-bottom-w100pct-h78px-000000-o50", 
								html: "reserved-bottom-w100pct-h50px-000000-o50", 
								image: "auto:bottom", 
								swf: "auto:bottom", 
								vpaid: null, // cannot be customised - always "auto:bottom" 
								iframe: null,
								script: null
							},
							"templates": {
								text: new TextAdTemplate(),
								html: new HtmlAdTemplate(),
								image: new ImageAdTemplate(),
								script: null, // not supported in flash mode
								iframe: null, // not supported in flash mode
								swf: null,    // does not use a template
								vpaid: null   // does not use a template
							}
						}
					),
				"html5": 
					formRegionsConfig(
					    "html5",
						(customConfig != null) ? customConfig.html5 : null,
						{
				           	"enable": false,
		        		   	"width": -1,
		           			"height": -1,
		           			"acceptedAdTypes": [ "image", "html", "text", "swf", "iframe", "script" ],					
							"overlay": true,
							"region": {
								text: "bottom", 
								html: "bottom",
								image: "bottom", 
								swf: "bottom", 
								vpaid: null, 
								iframe: "bottom",
								script: "bottom"
							},
							"templates": {
								text: new TextAdTemplate(AdTemplate.DISPLAY_TYPE_HTML5),
								html: new HtmlAdTemplate(AdTemplate.DISPLAY_TYPE_HTML5),
								image: new ImageAdTemplate(AdTemplate.DISPLAY_TYPE_HTML5),
								swf: new FlashAdTemplate(AdTemplate.DISPLAY_TYPE_HTML5),
								script: new ScriptAdTemplate(AdTemplate.DISPLAY_TYPE_HTML5),
								iframe: new IFrameAdTemplate(AdTemplate.DISPLAY_TYPE_HTML5),
								vpaid: null	// not supported in html5 mode					
							}
						}						
					)
			};	
		}
		
		public function clearVPAIDForciblyStoppedFlag():void {
			_vpaidForciblyStopped = false;
		}
		
		public function flagVPAIDForciblyStopped():void {
			_vpaidForciblyStopped = true;
		}
		
		public function wasVPAIDForciblyClosed():Boolean {
			return _vpaidForciblyStopped;
		}
		
		public function loadingOnFailover():Boolean {
			return _loadingOnFailover;
		}
		
		public function shouldFailoverOnVPAIDError(errorMessage:String):Boolean {
			if(loadOnDemand && _adServerConfig != null) {
				if(_adServerConfig.failoverConditions != null) {
					if(_adServerConfig.failoverConditions.hasFailoverConditionOnVPAIDError()) {
						return _adServerConfig.failoverConditions.onVPAIDError.shouldFailover(errorMessage);
					}
				}
			}
			return false;
		}	

		public function shouldFailoverOnStreamError(errorMessage:String):Boolean {
			if(loadOnDemand && _adServerConfig != null) {
				if(_adServerConfig.failoverConditions != null) {
					if(_adServerConfig.failoverConditions.hasFailoverConditionOnStreamError()) {
						return _adServerConfig.failoverConditions.onStreamError.shouldFailover(errorMessage);
					}
				}
			}
			return false;
		}	
			
		protected function formRegionsConfig(displayMode:String, customConfig:Array, defaultConfig:Object):Array {
			if(customConfig == null) {
				return [
				 	new AdSlotRegionConfig(displayMode, defaultConfig)
				];
			}
			else if(customConfig.length == 0) {
				return [
				 	new AdSlotRegionConfig(displayMode, defaultConfig)
				];
			}
			else {
				var result:Array = new Array();
				for(var i:int=0; i < customConfig.length; i++) {
					result.push(new AdSlotRegionConfig(displayMode, defaultConfig, customConfig[i]));
				}
				return result;
			}
		}
		
		public function hasRegions(displayMode:String):Boolean {
			if(_regions != null) {
				if(_regions.hasOwnProperty(displayMode)) {
					return (_regions[displayMode].length > 0);
				}
			}
			return false;
		}
		
		public function get regions():Object {
			return _regions;
		}
	
		public function get preferredDisplayMode():String {
			if(_regions != null) {
				if(_regions.hasOwnProperty("preferred")) {
					if(StringUtils.matchesIgnoreCase(_regions.preferred, "HTML5")) {
						return "html5";
					}
				}
			}	
			return "flash";
		}
		
		public override function get streamID():String {
			return _id;
		}
		
		public function get adSlotID():String {
			return id + "-" + associatedStreamIndex;
		}
		
		public function load(listener:AdSlotOnDemandLoadListener):Boolean {
			_loadingOnFailover = false;
			if(loadOnDemand == true) {
				_needsRefresh = false;
				_onDemandLoadListener = listener;
				loading = true;
				var slots:Array = new Array();
				slots.push(this);
				_activeAdServerRequestProcessor = new AdServerRequestProcessor(this, slots, true, true);
				_activeAdServerRequestProcessor.start();				
				return true;				
			}
			else {
				_onDemandLoadListener = null;
				_activeAdServerRequestProcessor = null;
			}
			return false;
		}
		
		public function loadByFailover(listener:AdSlotOnDemandLoadListener):Boolean {
			// _activeAdServerRequestProcessor.lastAdServerRequest.failoverRequestCount	holds the index of the last 
			// processed ad tag so if we need to fail over, we need to start at the next ad tag in the list
			
			if(loadOnDemand == true && _activeAdServerRequestProcessor != null) {
				_loadingOnFailover = true;
				_needsRefresh = false;
				loading = true;
				return _activeAdServerRequestProcessor.restartOnFailover();				
			}
			else {
				_onDemandLoadListener = null;
				_activeAdServerRequestProcessor = null;
			}
			return false;
		}
		
		public function set adServerRequest(adServerRequest:AdServerRequest):void {
			_adServerRequest = adServerRequest;
		}

		public function get adServerRequest():AdServerRequest {
			return _adServerRequest;
		}
		
		public function getLastProcessedPreloadedAdTagIndex():int {
			if(_adServerRequest != null) {
				return _adServerRequest.failoverRequestCount;
			}
			return 0;
		}
		
		public function getLastProcessedOnDemandAdTagIndex():int {
			if(_activeAdServerRequestProcessor != null) {
				return _activeAdServerRequestProcessor.getLastProcessedAdTagIndex();		
			}
			return 0;
		}
		
		public function fireErrorUrls(errorCode:String=null):void {
			if(hasVideoAd()) {
				_videoAd.fireErrorUrls(errorCode);
			}		
		}
		
		public override function resetAllTrackingPoints():void {
			super.resetAllTrackingPoints();
			if(hasVideoAd()) _videoAd.resetImpressions();
		}
		
		public function set loadOnDemand(loadOnDemand:Boolean):void {
			_loadOnDemand = loadOnDemand;
		}
		
		public function get loadOnDemand():Boolean {
			return _loadOnDemand;
		}
		
		public function hasLimitedDisplayCount():Boolean {
			return (_maxDisplayCount > -1)
		}
		
		public function set maxDisplayCount(maxDisplayCount:int):void {
			_maxDisplayCount = maxDisplayCount;
		}
		
		public function get maxDisplayCount():int {
			return _maxDisplayCount;
		}
		
		public function loadPreviouslyAttempted():Boolean {
			return false;
		}

		public function set refreshOnReplay(refreshOnReplay:Boolean):void {
			_refreshOnReplay = refreshOnReplay;
		}
		
		public function get refreshOnReplay():Boolean {
			return _refreshOnReplay;
		}

		public function hasPositionDefined():Boolean {
			return _position != null;
		}
		
		public function requiresFixedPosition():Boolean {
			return false;
		}
		
		public function requiresAutoPosition():Boolean {
			if(hasPositionDefined()) {
				return (_position.toUpperCase().indexOf("AUTO") > -1);	
			}
			return false;
		}
		
		public function getAutoPositionAlignment():String {
			if(hasPositionDefined()) {
				if(_position.toUpperCase().indexOf("AUTO:") > -1 && _position.length > 5) {
					var alignment:String = _position.substr(_position.toUpperCase().indexOf("AUTO:") + 5);
					if(alignment != null) {
						alignment = StringUtils.trim(alignment).toUpperCase();
						if("BOTTOM CENTER TOP LEFT RIGHT".indexOf(alignment) > -1 ) {
							return alignment;
						}						
					}
				}
			}
			return "BOTTOM";
		}
		
		public override function get title():String {
			if(hasVideoAd()) {
				return _videoAd.adTitle;	
			}
			return _title;
		}		
		
		public function get adServerType():String {
			if(this.adServerConfig != null) {
				return this.adServerConfig.type;
			}	
			return "undefined";
		}
		
		public function get adServerTag():String {
			if(this.adServerConfig != null) {
				if(adServerConfig.tag == null) {
					return adServerConfig.apiAddress;
				}
				else return adServerConfig.tag;
			}
			return "undefined";
		}

		public function occursBetweenTimes(rangeStartTime:Number, rangeEndTime:Number):Boolean {
			var startTimeInSeconds:int = getStartTimeAsSeconds();
			if(startTimeInSeconds > 0) {
				return (rangeStartTime <= startTimeInSeconds && startTimeInSeconds <= rangeEndTime);
			}
			return false;
		}
		
		protected override function clearTrackingTable(clearOnlyStreamEvents:Boolean=false):void {
			CONFIG::debugging { doLog("Clearing the tracking table attached to " + _position + " AdSlot '" + _key + "'", Debuggable.DEBUG_CONFIG); }
			_trackingTable = new TrackingTable(id, key, originatingStreamIndex); 		
		}

        public override function isLoaded():Boolean {
        	return true;
        }
		
		public override function getStreamToPlay():NetworkResource {
			if(hasLinearAd() && hasVideoAd()) {
				return _videoAd.getStreamToPlay(); 
			}
			return null;
		}

		protected override function cleanseStreamName(rawName:String):String {
			return super.cleanseStreamName(rawName);
		}

        public override function get baseURL():String {
			var streamURL:AdNetworkResource = getStreamToPlay() as AdNetworkResource;
			if(streamURL != null) {
				if(streamURL.isRTMP() && (streamURL.hasFileMarker() == false)) {
					if(_vastController != null) {
						if(_vastController.config.adsConfig.hasStreamers()) {
							streamURL.streamers = _vastController.config.adsConfig.streamers;		
						}
					}
				}
				return streamURL.netConnectionAddress;
			}        	
        	return super.baseURL;
        }
		
		public override function get streamName():String {
			if(isInteractive()) {
				return null;
			}
			else {
				var streamURL:AdNetworkResource = getStreamToPlay() as AdNetworkResource;
				if(streamURL != null) {
					if(streamURL.isRTMP() && (streamURL.hasFileMarker() == false)) {
						if(_vastController != null) {
							if(_vastController.config.adsConfig.hasStreamers()) {
								streamURL.streamers = _vastController.config.adsConfig.streamers;		
							}
						}
						return streamURL.getDecoratedRTMPFilename();
					}
					return cleanseStreamName(streamURL.getFilename(streamType + ":"));				
				}
				return null;				
			}
		}

		public function canReplay():Boolean {
			return _vastController.config.adsConfig.replayOverlays;
		}
		
		public override function shouldMaintainAspectRatio():Boolean {
			if(hasVideoAd()) {
				return _videoAd.shouldMaintainAspectRatio(); 				
			}	
			return false;			
		}

		public function markForRefresh():void {
			_needsRefresh = true;
		}

		public function requiresLoading():Boolean {
			if(_loadOnDemand) {
				if(_videoAd != null) {
					if(_refreshOnReplay) {
						return _needsRefresh;
					}
					return _videoAd.isEmpty();
				}
				return true;					
			}
			return false;
		}
		
		public function set loading(loading:Boolean):void {
			_loading = loading;
		}
		
		public function get loading():Boolean {
			return _loading;
		}
		
		public override function isInteractive():Boolean {
			if(hasVideoAd()) {
				return _videoAd.isInteractive(); 				
			}	
			return false;			
		}
		
		public function set zone(zone:String):void {
			_zone = zone;
		}
		
		public function get zone():String {
			return _zone;
		}
		
		public function set adServerConfig(adServerConfig:AdServerConfig):void {
			_adServerConfig = adServerConfig;
		}
		
		public function get adServerConfig():AdServerConfig {
			return _adServerConfig;
		}
		
		public function hasAdServerConfigured():Boolean {
			if(_adServerConfig != null) {
				return (_adServerConfig.serverType != null);	
			}
			return false;
		}

		public function set position(position:String):void {
			_position = position;
		}
		
		public function get position():String {
			return _position;
		}

		public override function isSlicedStream():Boolean {
			return false; 
		}
		
		public override function set duration(durationAsSeconds:*):void {
			if(_videoAd != null) _videoAd.setLinearAdDurationFromSeconds(int(durationAsSeconds));
			super.duration = durationAsSeconds;
		}

		public override function get duration():String {
			if(_videoAd != null) {
				if(_duration == null) {
					return new String(_videoAd.duration);
				}
				else if(_duration.toUpperCase().indexOf("RECOMMENDED:") > -1 && _duration.length > 12) {
					// format is "recommended:XX" where XX is the time to use if recommended is not available
					return new String(_videoAd.getDurationGivenRecommendation(
					               parseInt(_duration.substr(_duration.toUpperCase().indexOf("RECOMMENDED:")+12))));
				}
			}
			return super.duration;
		}

		public function set originatingAssociatedStreamIndex(originatingAssociatedStreamIndex:int):void {
			_originatingAssociatedStreamIndex = originatingAssociatedStreamIndex;
		}
		
		public function get originatingAssociatedStreamIndex():int {
			return _originatingAssociatedStreamIndex;
		}
		
		public function set applyToParts(applyToParts:Object):void {
			_applyToParts = applyToParts;
		}
		
		public function get applyToParts():Object {
			return _applyToParts;
		}

		public function set associatedStreamStartTime(associatedStreamStartTime:int):void {
			_associatedStreamStartTime = associatedStreamStartTime;
		}
		
		public function get associatedStreamStartTime():int {
			return _associatedStreamStartTime;
		}
		
		public function get slotType():String {
			if(isPreRoll() || isMidRoll() || isPostRoll()) {
				return AD_TYPE_LINEAR;
			}
			else if(isCompanion()) {
				return AD_TYPE_COMPANION;
			}
			return AD_TYPE_NON_LINEAR;
		}
		
		public function isPreRoll():Boolean {
			if(_position == null) return false;
			return (_position.toLowerCase() == SLOT_POSITION_PRE_ROLL);
		}
		
		public function isMidRoll():Boolean {
			if(_position == null) return false;
			return (_position.toLowerCase() == SLOT_POSITION_MID_ROLL);
		}
		
		public function isPostRoll():Boolean {
			if(_position == null) return false;
			return (_position.toLowerCase() == SLOT_POSITION_POST_ROLL);
		}
		
		public function isCompanion():Boolean {
			if(_position == null) return false;
			return (_position.toLowerCase() == SLOT_POSITION_COMPANION);			
		}
		
		public function isActive():Boolean {
			if(_loadOnDemand) return true;
			if(_videoAd != null) {
				return (_videoAd.hasEmptyLinearAd() == false || _videoAd.hasEmptyNonLinearAds() == false);
			}
			return false;
		}
		
		public function get played():Boolean {
			return _played;
		}

		public function set played(played:Boolean):void {
			_played = played;
		}
		
		public function markAsPlaying():void {
			_isPlaying = true;
			_played = true;
		}

		public function isPlaying():Boolean {
			return _isPlaying;
		}
		
		public function canPlay():Boolean {
			return isInteractive();
		}
		
		public function markAsPlayed():void {
			_played = true;
			_isPlaying = false;
		}
		
		public function shouldBePlaying(milliseconds:Number):Boolean {
			return (_trackingTable.timeBetweenTwoPoints(milliseconds, "NS", "NE") && (played == false || canReplay()));
		}
		
		public function toRunIndefinitely():Boolean {
			return (!hasDuration() || getDurationAsInt() == -1 || hasZeroDuration());
		}
		
		public function companionsShowing():Boolean {
			return _companionsShowing;
		}
		
		public function set overlayVideoPlaying(overlayVideoPlaying:Boolean):void {
			_overlayVideoPlaying = overlayVideoPlaying;
		}
		
		public function isOverlayVideoPlaying():Boolean {
			return _overlayVideoPlaying;
		}
		
		public function isEmpty():Boolean {
			return !hasNonLinearAds() && !hasLinearAd();	
		}
		
		public function getFlashMediaToPlay(preferredWidth:Number, preferredHeight:Number, interactiveOnly:Boolean=false):FlashMedia {
			if(_videoAd != null){
				return _videoAd.getFlashMediaToPlay(preferredWidth, preferredHeight, interactiveOnly);
			}
			return null;
		}
		
		public function hasNonLinearAds():Boolean {
			if(_videoAd != null) {
				return _videoAd.hasNonLinearAds();
			}
			else return false;			
		}
		
		public function hasLinearAd():Boolean {
			if(_videoAd != null) {
				return _videoAd.hasLinearAd();	
			}
			return false;
		}
		
		public function hasLinearClickThroughs():Boolean {
			if(hasLinearAd()) {
				return getLinearVideoAd().hasClickThroughURL();
			}
			return false;
		}
		
		public function getLinearVideoAd():LinearVideoAd {
			if(_videoAd != null) {
				return _videoAd.linearVideoAd;
			}
			return null;
		}
		
		public function getNonLinearVideoAd():NonLinearVideoAd {
			if(_videoAd != null) {
				if(_videoAd.nonLinearVideoAds != null) {
					return _videoAd.nonLinearVideoAds[0];				
				}
			}
			return null;
		}
		
		public function getAttachedLinearAdDurationAsInt():int {
			if(_videoAd != null) {
				return _videoAd.duration;			
			}
			return 0;
		}
		
		public function hasCompanionAds():Boolean {
			if(_videoAd != null) {
				return _videoAd.hasCompanionAds();
			}
			else return false;
		}
		
		public function set videoAd(videoAd:VideoAd):void {
			if(videoAd != null) {
				videoAd.setPreferredSelectionCriteria(
					{
						deliveryType: _deliveryType,
						mimeType: _mimeType,
						bitrate: _bitrate,
						width: _width,
						height: _height
					}
				);
			}
			_videoAd = videoAd;
		}
		
		public function get videoAd():VideoAd {
			return _videoAd;
		}
		
		public function hasVideoAd():Boolean {
			return (_videoAd != null);
		}
		
		public function isEmptyLinear():Boolean {
			if(isPreRoll() || isPostRoll() || isMidRoll()) {
				if(_videoAd != null) {
					return _videoAd.isEmpty();
				}
			}
			return false;
		}
		
		public override function isLinear():Boolean {
			if(_videoAd != null) {
				return (isPreRoll() || isPostRoll() || isMidRoll()) && _videoAd.isLinear();
			}
			else if(_loadOnDemand) {
				return (isPreRoll() || isPostRoll() || isMidRoll());
			}
			return false;
		}
		
		public function isNonLinear():Boolean {
			if(_videoAd != null) {
				return (!isPreRoll() && !isPostRoll() && !isMidRoll()) && _videoAd != null && _videoAd.hasNonLinearAds();
			}
			else if(_loadOnDemand) {
				return (!isPreRoll() && !isPostRoll() && !isMidRoll());
			}
			return false;
		}
		
		public function getSlotType():String {
			if(isLinear()) {
				if(isInteractive()) {
					return "Linear interactive";
				}
				return "Linear";
			}
			else if(isNonLinear()) {
				if(isInteractive()) {
					return "Non-linear Interactive";
				}
				return "Non-linear";
			}
			else if(isCompanion()) {
				return "Companion";
			}
			return "Unknown";
		}
		
		public function set disableControl(disableControls:Boolean):void {
			_disableControls = disableControls;
		}
		
		public function get disableControls():Boolean {
			return _disableControls;
		}

		public override function declareTrackingPoints(currentTimeInSeconds:int=0, clearOnlyStreamEvents:Boolean=false):void {
			if(_trackingPointsSet == false) {
				if(getDurationAsInt() > 0) {
					clearTrackingTable();
					if(isLinear() && (isInteractive() == false)) {
						var timeFactor:int = 1000;
						var streamDuration:int = getDurationAsInt();
						if(config.adsConfig.shortenLinearAdDurationPercentage > 0) {
							// If we have a value specified to shorten the duration of the stream by a percentage rate, do that
							streamDuration = streamDuration - ((config.adsConfig.shortenLinearAdDurationPercentage / 100) * streamDuration);
							CONFIG::debugging { doLog("Duration of the linear ad stream has been reduced by " + config.adsConfig.shortenLinearAdDurationPercentage + "% from " + getDurationAsInt() + " to " + streamDuration, Debuggable.DEBUG_CUEPOINT_FORMATION); }
						}
						var startTime:int = currentTimeInSeconds + streamStartTime;
						var midpointMilliseconds:int = Math.round(((startTime * timeFactor) + ((streamDuration * timeFactor) / 2)) / 100) * 100;
						var endFirstQuartileMilliseconds:int = Math.round(((startTime * timeFactor) + ((streamDuration * timeFactor) / 4)) / 100) * 100; 
						var endThirdQuartileMilliseconds:int = Math.round(((startTime * timeFactor) + (((streamDuration * timeFactor) / 4) * 3)) / 100) * 100;
						
						// Setup the Begin Ad event
						
						setTrackingPoint(new TrackingPoint((startTime * timeFactor) + _vastController.startStreamSafetyMargin, "BA"));
						
						// Setup the Quartile Tracking Events - include Progress tracking points if this is a V3 ad

						setTrackingPoint(new TrackingPoint(endFirstQuartileMilliseconds, "1Q"));
						setTrackingPoint(new TrackingPoint(midpointMilliseconds, "HW"));
						setTrackingPoint(new TrackingPoint(endThirdQuartileMilliseconds, "3Q"));
						addProgressTrackingPoints(streamDuration, timeFactor);
						
						// Setup the Start Ad Notice event
						
						setTrackingPoint(new TrackingPoint((startTime * timeFactor) + _vastController.startStreamSafetyMargin, "SN"));

						// Setup the Skip Button events
												
						if(_vastController.config.adsConfig.isSkipAdButtonEnabled()) {
							var delayedStartTime:int = 0;
							if(_vastController.config.adsConfig.skipAdConfig.isTimeDelayed()) {
								delayedStartTime = _vastController.config.adsConfig.skipAdConfig.showAfterSeconds;
								setTrackingPoint(new TrackingPoint((startTime * timeFactor) + (delayedStartTime * timeFactor), "DS"));
							}
							if(_vastController.config.adsConfig.skipAdConfig.isTimeRestricted()) {
								setTrackingPoint(new TrackingPoint((startTime * timeFactor) + ((delayedStartTime + _vastController.config.adsConfig.skipAdConfig.showForSeconds) * timeFactor), "HS"));
							}
						}
						
						// Setup the Hide Ad Notice and End Ad events
						
						setTrackingPoint(new TrackingPoint((((startTime + streamDuration) * timeFactor) - _vastController.endStreamSafetyMargin), "HN"));
						setTrackingPoint(new TrackingPoint((((startTime + streamDuration) * timeFactor) - _vastController.endStreamSafetyMargin), "EA"));
	
						if(hasTimedNotice()) {
							declareNoticeTimerTrackingPoints(streamDuration, false);
						}						
					}
					if(hasNonLinearAds()) { 
						addNonLinearAdTrackingPoints(key, true, false); 
					}
					if(hasCompanionAds()) { 
						addCompanionAdTrackingPoints(key, currentTimeInSeconds, getDurationAsInt());
					}			
					markTrackingPointsAsSet();					
				}
				else {
					CONFIG::debugging { doLog("Not setting Ad tracking points on AdSlot[" + key + "] - it has a 0 duration specified", Debuggable.DEBUG_CUEPOINT_FORMATION); }
				}
			}
			else {	
				CONFIG::debugging { doLog("Not setting Ad tracking points on AdSlot[" + key + "] - already set once", Debuggable.DEBUG_CUEPOINT_FORMATION); }
			}
		}

		protected function addProgressTrackingPoints(duration:int, timeFactor:int):void {
			if(videoAd is VideoAdV3) {
				if(videoAd.hasProgressTrackingEvents()) {
					var events:Array = videoAd.getProgressTrackingEvents();
					if(events != null) {
						for(var i:int = 0; i < events.length; i++) {
							setTrackingPoint(new TrackingPoint(events[i].calculateStartTime(duration, timeFactor), "PE"));
						}
					}
				}
			}
		}
		
		protected function addCompanionAdTrackingPoints(adSlotIndex:int, startPoint:int, duration:int, overrideSetFlag:Boolean=false, fireTrackingEvent:Boolean=true, isChildLinear:Boolean=false):void {
			setTrackingPoint(new TrackingPoint((startPoint * 1000) + _vastController.startStreamSafetyMargin, "CS", new String(adSlotIndex)), overrideSetFlag, fireTrackingEvent, isChildLinear); 

			if(duration > 0) {
				setTrackingPoint(new TrackingPoint((((startPoint + duration) * 1000) - _vastController.endStreamSafetyMargin), "CE", new String(adSlotIndex)), overrideSetFlag, fireTrackingEvent, isChildLinear);
				CONFIG::debugging { doLog("Tracking point set on AdSlot[" + key + "] at " + startPoint + " seconds and run for " + duration + " seconds for companion ad with Ad id " + id, Debuggable.DEBUG_CUEPOINT_FORMATION);	}		
			}
			else {
				// if no duration is set, set the companion ad duration to 4 hours
				setTrackingPoint(new TrackingPoint(((startPoint + (60 * 60 * 4)) * 1000), "CE", new String(adSlotIndex)), overrideSetFlag, fireTrackingEvent, isChildLinear);
				CONFIG::debugging { doLog("Tracking point set on AdSlot[" + key + "] at " + startPoint + " seconds running indefinitely - Companion Ad id " + id, Debuggable.DEBUG_CUEPOINT_FORMATION);	}
			}
		}
		
		public function addNonLinearAdTrackingPoints(adSlotIndex:int, resetStartTimeToZeroEachStream:Boolean=false, checkCompanionAds:Boolean=false, overrideSetFlag:Boolean=false):void {
			var startPoint:int = ((resetStartTimeToZeroEachStream) ? 0 : associatedStreamStartTime) + getStartTimeAsSeconds();
			var duration:int = getDurationAsInt();
			setTrackingPoint(new TrackingPoint(startPoint * 1000, "NS", new String(adSlotIndex)), overrideSetFlag);

			if(duration > 0) {
				setTrackingPoint(new TrackingPoint(((startPoint + duration) * 1000) - _vastController.endStreamSafetyMargin, "NE", new String(adSlotIndex)), overrideSetFlag);
				CONFIG::debugging { doLog("Tracking point set on AdSlot[" + key + "] at " + startPoint + " seconds and run for " + duration + " seconds for non-linear ad with Ad id " + id, Debuggable.DEBUG_CUEPOINT_FORMATION);	}			
			}
			else {
				// if no duration is set, set the non-linear ad duration to 4 hours
				setTrackingPoint(new TrackingPoint(((startPoint + (60 * 60 * 4)) * 1000), "NE", new String(adSlotIndex)), overrideSetFlag);
				CONFIG::debugging { doLog("Tracking point set on AdSlot[" + key + "] at " + startPoint + " seconds running indefinitely - non-linear Ad id " + id, Debuggable.DEBUG_CUEPOINT_FORMATION); }
			}

			if(checkCompanionAds && hasCompanionAds()) {
				addCompanionAdTrackingPoints(adSlotIndex, startPoint, duration); 
			}
			
			if(hasLinearAd()) {
				// setup the tracking points for the attached linear ad, but don't fire off tracking events just yet
				var timeFactor:int = 1000;
				var streamDuration:int = getAttachedLinearAdDurationAsInt();
				var startTime:int = 0;
				var midpointMilliseconds:int = Math.round(((startTime * timeFactor) + ((streamDuration * timeFactor) / 2)) / 100) * 100;
				var endFirstQuartileMilliseconds:int = Math.round(((startTime * timeFactor) + ((streamDuration * timeFactor) / 4)) / 100) * 100; 
				var endThirdQuartileMilliseconds:int = Math.round(((startTime * timeFactor) + (((streamDuration * timeFactor) / 4) * 3)) / 100) * 100;

				setTrackingPoint(new TrackingPoint((startTime * timeFactor) + _vastController.startStreamSafetyMargin, "BA"), false, false, true);
				setTrackingPoint(new TrackingPoint(endFirstQuartileMilliseconds, "1Q"), false, false, true);
				setTrackingPoint(new TrackingPoint(midpointMilliseconds, "HW"), false, false, true);
				setTrackingPoint(new TrackingPoint(endThirdQuartileMilliseconds, "3Q"), false, false, true);
				setTrackingPoint(new TrackingPoint((startTime * timeFactor) + _vastController.startStreamSafetyMargin, "SN"), false, false, true);
				setTrackingPoint(new TrackingPoint((((startTime + streamDuration) * timeFactor) - _vastController.endStreamSafetyMargin), "HN"), false, false, true);
		 		setTrackingPoint(new TrackingPoint((((startTime + streamDuration) * timeFactor) - _vastController.endStreamSafetyMargin), "EA"), false, false, true);
				addProgressTrackingPoints(streamDuration, timeFactor);
					
				if(hasTimedNotice()) {
					declareNoticeTimerTrackingPoints(streamDuration, true);
				}					
				if(hasCompanionAds()) { 
					addCompanionAdTrackingPoints(key, 0, streamDuration, false, false, true);
				}							
			}
		}

		public function triggerTrackingEvent(eventType:String):void {
			if(_videoAd != null) {
				_videoAd.triggerTrackingEvent(eventType);
			}	
		}
		
		protected function declareNoticeTimerTrackingPoints(duration:int, isChildLinear:Boolean=false):void {
			CONFIG::debugging { doLog("Declaring ad notice tracking points...", Debuggable.DEBUG_CUEPOINT_FORMATION); }
			var timeFactor:int = 1000;
			for(var i:int=1; i < duration; i++) {
				setTrackingPoint(new TrackingPoint((i * timeFactor), "TN"), false, false, isChildLinear);
			}
		}

		public function shouldForceFireImpressions():Boolean {
			if(_adServerConfig != null) {
				return _adServerConfig.forceImpressionServing;
			}
			return false;
		}
				
        public function processForcedImpression(overrideIfAlreadyFired:Boolean=false):void {
			if(_videoAd != null) {
				if(shouldForceFireImpressions()) {
					_videoAd.triggerForcedImpressionConfirmations(overrideIfAlreadyFired);				
				}
				else {
					CONFIG::debugging { doLog("Impressions not to be forcibly fired for ad slot " + key, Debuggable.DEBUG_TRACKING_EVENTS); }
				}
			}
        }
        
		public override function processStartStream(contentPlayhead:String=null):void {
			markAsPlaying();
			markForRefresh();
			if(_videoAd != null) {
				_videoAd.processStartAdEvent(contentPlayhead);
				_vastController.fireAdPlaybackAnalytics(AnalyticsProcessor.START, this, _videoAd.linearVideoAd);
			}
			else {
				CONFIG::debugging { doLog("tracking event at start of AdSlot[" + key + "] ignored - no ad to display", Debuggable.DEBUG_CUEPOINT_EVENTS); }
			}
		}

		public override function processStreamComplete(contentPlayhead:String=null):void {
			markAsPlayed();
			if(_videoAd != null) {
				_videoAd.processAdCompleteEvent(contentPlayhead);
				_vastController.fireAdPlaybackAnalytics(AnalyticsProcessor.COMPLETE, this, _videoAd.linearVideoAd);
			}
			else {
				CONFIG::debugging { doLog("tracking event at end of AdSlot[" + key + "] ignored - no ad to display", Debuggable.DEBUG_CUEPOINT_EVENTS); }
			}
		}
		
	 	public override function processStopStream(contentPlayhead:String=null):void {
			if(_videoAd != null) {
				_videoAd.processStopAdEvent(contentPlayhead);
				_vastController.fireAdPlaybackAnalytics(AnalyticsProcessor.STOP, this, _videoAd.linearVideoAd);
			}
			else {
				CONFIG::debugging { doLog("tracking event for stop AdSlot[" + key + "] ignored - no ad to display", Debuggable.DEBUG_CUEPOINT_EVENTS); }
			}
	 	}
	 	
	 	public override function processPauseStream(contentPlayhead:String=null):void {
			if(_videoAd != null) {
				_videoAd.processPauseAdEvent(contentPlayhead);				
				_vastController.fireAdPlaybackAnalytics(AnalyticsProcessor.PAUSE, this, _videoAd.linearVideoAd);
			}
			else {
				CONFIG::debugging { doLog("tracking event for pause AdSlot[" + key + "] ignored - no ad to display", Debuggable.DEBUG_CUEPOINT_EVENTS); }
			}
	 	}
	 	
	 	public override function processResumeStream(contentPlayhead:String=null):void {
			if(_videoAd != null) {
				_videoAd.processResumeAdEvent(contentPlayhead);
				_vastController.fireAdPlaybackAnalytics(AnalyticsProcessor.RESUME, this, _videoAd.linearVideoAd);
			}
			else {
				CONFIG::debugging { doLog("tracking event for resume AdSlot[" + key + "] ignored - no ad to display", Debuggable.DEBUG_CUEPOINT_EVENTS); }
			}
	 	}
	 	
	 	protected function processAdMidpointComplete(contentPlayhead:String=null):void {
			if(_videoAd != null) {
				_videoAd.processHitMidpointAdEvent(contentPlayhead);
				_vastController.fireAdPlaybackAnalytics(AnalyticsProcessor.MIDPOINT, this, _videoAd.linearVideoAd);
			}
			else {
				CONFIG::debugging { doLog("tracking event for midpoint AdSlot[" + key + "] ignored - no ad to display", Debuggable.DEBUG_CUEPOINT_EVENTS); }
			}
	 	}
	 	
	 	protected function processAdFirstQuartileComplete(contentPlayhead:String=null):void {
			if(_videoAd != null) {
				_videoAd.processFirstQuartileCompleteAdEvent(contentPlayhead);
				_vastController.fireAdPlaybackAnalytics(AnalyticsProcessor.FIRST_QUARTILE, this, _videoAd.linearVideoAd);
			}
			else {
				CONFIG::debugging { doLog("tracking event for first quartile AdSlot[" + key + "] ignored - no ad to display", Debuggable.DEBUG_CUEPOINT_EVENTS); }
			}
	 	}
	 	
	 	protected function processAdThirdQuartileComplete(contentPlayhead:String=null):void {
			if(_videoAd != null) {
				_videoAd.processThirdQuartileCompleteAdEvent(contentPlayhead);
				_vastController.fireAdPlaybackAnalytics(AnalyticsProcessor.THIRD_QUARTILE, this, _videoAd.linearVideoAd);
			}
			else {
				CONFIG::debugging { doLog("tracking event for third quartile AdSlot[" + key + "] ignored - no ad to display", Debuggable.DEBUG_CUEPOINT_EVENTS); }
			}
	 	}

        override public function processFullScreenEvent(contentPlayhead:String=null):void {	
			CONFIG::debugging { doLog("AdSlot " + id + " full screen event", Debuggable.DEBUG_TRACKING_EVENTS); }       
		 	if(_videoAd != null) {
		 		_videoAd.processFullScreenAdEvent(contentPlayhead);
				_vastController.fireAdPlaybackAnalytics(AnalyticsProcessor.FULLSCREEN, this, _videoAd.linearVideoAd);
		 	}
			else {
				CONFIG::debugging { doLog("tracking event for fullscreen on AdSlot[" + key + "] ignored - no ad to display", Debuggable.DEBUG_CUEPOINT_EVENTS); }
			}
        }

        override public function processFullScreenExitEvent(contentPlayhead:String=null):void {	
			CONFIG::debugging { doLog("AdSlot " + id + " full screen exit event", Debuggable.DEBUG_TRACKING_EVENTS); }       
		 	if(_videoAd != null) {
		 		_videoAd.processFullScreenExitAdEvent(contentPlayhead);
		 	}
			else {
				CONFIG::debugging { doLog("tracking event for fullscreen exit on AdSlot[" + key + "] ignored - no ad to display", Debuggable.DEBUG_CUEPOINT_EVENTS); }
			}
        }

        override public function processMuteEvent(contentPlayhead:String=null):void {	
			CONFIG::debugging { doLog("AdSlot " + id + " mute event", Debuggable.DEBUG_TRACKING_EVENTS); }       
		 	if(_videoAd != null) {
		 		_videoAd.processMuteAdEvent(contentPlayhead);
				_vastController.fireAdPlaybackAnalytics(AnalyticsProcessor.MUTE, this, _videoAd.linearVideoAd);
		 	}
			else {
				CONFIG::debugging { doLog("tracking event for mute on AdSlot[" + key + "] ignored - no ad to display", Debuggable.DEBUG_CUEPOINT_EVENTS); }
			}
        }

        override public function processUnmuteEvent(contentPlayhead:String=null):void {	
			CONFIG::debugging { doLog("AdSlot " + id + " unmute event", Debuggable.DEBUG_TRACKING_EVENTS); }       
		 	if(_videoAd != null) {
		 		_videoAd.processUnmuteAdEvent(contentPlayhead);
				_vastController.fireAdPlaybackAnalytics(AnalyticsProcessor.UNMUTE, this, _videoAd.linearVideoAd);
		 	}
			else {
				CONFIG::debugging { doLog("tracking event for unmute on AdSlot[" + key + "] ignored - no ad to display", Debuggable.DEBUG_CUEPOINT_EVENTS); }
			}	
        }

		protected function createNonLinearDisplayEvent():VideoAdDisplayEvent { 
		 	var displayEvent:VideoAdDisplayEvent = new VideoAdDisplayEvent(_vastController);
            displayEvent.customData.adSlot = this;
			return displayEvent;
		}
			 	
	 	protected function actionNonLinearAdStart(contentPlayhead:String=null):void { 
	 	    markAsPlaying();
	 		if(this.isLinear()) {
	 			CONFIG::debugging { doLog("tracking event for non-linear overlay start ignored on Linear Ad - not implemented", Debuggable.DEBUG_CUEPOINT_EVENTS); }
	 		}
	 		else {
		 		if(_videoAd != null) {
		 			if(requiresLoading()) {
	 					CONFIG::debugging { doLog("Re-loading Overlay 'on-demand'", Debuggable.DEBUG_CUEPOINT_EVENTS); }	 				
	 					load(_vastController); 
		 			}
		 			else {
			 			CONFIG::debugging { doLog("tracking event for non-linear overlay start being processed - this is for a stand alone ad slot", Debuggable.DEBUG_CUEPOINT_EVENTS); }
			 			_videoAd.processStartNonLinearAdEvent(createNonLinearDisplayEvent(), contentPlayhead);  				
						markForRefresh();
		 			}
	 			}
	 			else {
	 				if(loadOnDemand) {
	 					CONFIG::debugging { doLog("loading Overlay 'on-demand'", Debuggable.DEBUG_CUEPOINT_EVENTS); }
	 					load(_vastController); 
	 				}
	 				else {
	 					CONFIG::debugging { doLog("tracking event for non-linear overlay start ignored - no ad to display", Debuggable.DEBUG_CUEPOINT_EVENTS); }
	 				}
	 			}
	 		}
	 	}

	 	protected function actionNonLinearAdEnd(resetTrackingOnReplay:Boolean=false, contentPlayhead:String=null):void { 
	 	    markAsPlayed();
	 		if(this.isLinear()) {
	 			CONFIG::debugging { doLog("tracking event for non-linear overlay stop on Linear Ad ignored - not implemented", Debuggable.DEBUG_CUEPOINT_EVENTS); }
	 		}
	 		else {
		 		if(_videoAd != null) {
		 			CONFIG::debugging { doLog("tracking event for non-linear overlay stop being processed - this is for a stand alone ad slot", Debuggable.DEBUG_CUEPOINT_EVENTS); }
			 		_videoAd.processStopNonLinearAdEvent(createNonLinearDisplayEvent(), contentPlayhead); 
			 		if(resetTrackingOnReplay) {
			 			resetAllTrackingPoints();
			 		}
			 		else {
			 		 	resetRepeatableTrackingPoints();
			 		}
	 			}
	 			else {
	 				CONFIG::debugging { doLog("tracking event for non-linear overlay end ignored - no ad to display", Debuggable.DEBUG_CUEPOINT_EVENTS); }
	 			}
	 		}
	 	}
	 	
 	 	public function actionCompanionAdStart(contentPlayhead:String=null):void { 
			_companionsShowing = true;
	 		if(_videoAd != null) {
		 		var displayEvent:VideoAdDisplayEvent = new VideoAdDisplayEvent(_vastController, _width, _height);
	 			_videoAd.processStartCompanionAdEvent(displayEvent, contentPlayhead);
	 		}
	 		else {
	 			CONFIG::debugging { doLog("tracking event for companion ad end ignored - no ad to display", Debuggable.DEBUG_CUEPOINT_EVENTS); }
	 		}
	 	}

	 	public function actionCompanionAdEnd(contentPlayhead:String=null):void { 
			_companionsShowing = false;
	 		if(_videoAd != null) {
		 		var displayEvent:VideoAdDisplayEvent = new VideoAdDisplayEvent(_vastController, _width, _height);
	 			_videoAd.processStopCompanionAdEvent(displayEvent, contentPlayhead);
	 		}
	 		else {
	 			CONFIG::debugging { doLog("tracking event for companion ad end ignored - no ad to display", Debuggable.DEBUG_CUEPOINT_EVENTS); }
	 		}
	 	}
	 	
	 	protected function actionAdNoticeCountdownTick(millisecondsPlayed:int):void { 
	 		if(_notice != null) {
	 			if(_notice.region != undefined) {
	 				if(_notice.region != null && _videoAd != null) {
						var remainingDurationInSeconds:int = Math.round(_videoAd.duration - (millisecondsPlayed / 1000));			
	 					_vastController.onTickAdNotice(new AdNoticeDisplayEvent(AdNoticeDisplayEvent.TICK, _notice, remainingDurationInSeconds));
	 				}
	 			}
	 		}
	 	}
	 	
	 	protected function actionSurveyStart():void {
	 		if(_videoAd != null) {
	 			if(_videoAd.hasSurvey()) {
	 				_vastController.onSurveyDisplay(_videoAd.survey);
	 			}
	 		}
	 	}
	 	
	 	protected function actionSurveyEnd():void {
	 		if(_videoAd != null) {
	 			if(_videoAd.hasSurvey()) {
	 				_vastController.onSurveyHide();
	 			}
	 		}
	 	}
	 	
	 	public function hasNotice():Boolean {
	 		return noticeToBeShown();	
	 	}
	 	
	 	public function hasTimedNotice():Boolean {
			if(_notice != null) {
				if(_notice.message != undefined) {
					return (_notice.message.indexOf("_countdown_") > -1)				
				}
			}	 
			return false;		
	 	}
	 	
		protected function noticeToBeShown():Boolean {
			if(_notice != null) {
				if(_notice.show) {
					return _notice.show;
				}
			}
			return false;
		}
		
		protected function canSkipWithoutDelayOnLinearAd():Boolean {
			if(canSkipOnLinearAd()) {
				return !_vastController.config.adsConfig.skipAdConfig.isTimeDelayed();
			}
			return false;
		}
		
		protected function canSkipOnLinearAd():Boolean {
			if(_vastController.config.adsConfig.skipAdConfig.hasMinimumAdDuration()) {
				if(_vastController.canSkipOnLinearAd()) {
					return (this.getDurationAsInt() >= _vastController.config.adsConfig.skipAdConfig.minimumAdDuration);
				}
				return false;
			}
			return _vastController.canSkipOnLinearAd();	
		}
		
	 	protected function showAdNotice():void {
			if(disableControls) {
				turnOffSeekerBar();
			}
			if(_vastController != null) {
				if(_clickSignEnabled) {
					_vastController.enableVisualLinearAdClickThroughCue(this);			
				}
		 		if(noticeToBeShown()) {
		 			if(_notice.region != undefined && _notice.region != null) {
		 				if(_notice.message != undefined && _notice.region != null) {
							_vastController.onShowAdNotice(new AdNoticeDisplayEvent(AdNoticeDisplayEvent.DISPLAY, _notice, ((_videoAd) ? _videoAd.duration : 0)));
		 				}
		 			}
		 		}
		 		if(canSkipWithoutDelayOnLinearAd()) {
		 			var adSlot:AdSlot = this;
					_vastController.activateLinearAdSkipButton(
						function():void {
							hideAdNotice();
							_vastController.onLinearAdSkip(adSlot);
						}
					);
		 		}
	 		}
	 	}
	 	
	 	protected function hideAdNotice():void {
			if(disableControls) {
				turnOnSeekerBar();
			}
			if(_vastController != null) {
				if(_clickSignEnabled) {
					_vastController.disableVisualLinearAdClickThroughCue(this);				
				}			
		 		if(noticeToBeShown()) {
		 			if(_notice.region != undefined && _notice.region != null) {
		 		    	_vastController.onHideAdNotice(new AdNoticeDisplayEvent(AdNoticeDisplayEvent.HIDE, _notice));
		 			}
		 		}
		 		if(canSkipOnLinearAd()) {
					_vastController.deactivateLinearAdSkipButton();		 			
		 		}
			}
	 	}
	 	
        public override function processTimeEvent(timeEvent:TimeEvent, includeChildLinear:Boolean=true, resetTrackingOnReplay:Boolean=false):void {
        	if((isNonLinear() && !toRunIndefinitely()) && 
        	   isPlaying() && 
        	   !isOverlayVideoPlaying() && // excludes the playback of on-click linear videos
        	   (isNonLinear() && (timeEvent.isLinearAdEvent() == false)) && // excludes the firing up of on-click linear videos
        	   (!_trackingTable.isTimeInBaseRange(timeEvent.milliseconds) || timeEvent.label == "NE")) {
     			    CONFIG::debugging { doLog("AdSlot: " + id + " forcibly closing down the active non-linear - current time is out of range", Debuggable.DEBUG_CUEPOINT_EVENTS); }
				    actionNonLinearAdEnd(resetTrackingOnReplay); 
				    actionCompanionAdEnd(); 
				    _vastController.onProcessTrackingPoint(_trackingTable.getTrackingPointOfType("NE", false, true));	
				    _vastController.onProcessTrackingPoint(_trackingTable.getTrackingPointOfType("CE", false, true));
        	}
        	else {
	        	var trackingPoints:Array = _trackingTable.activeTrackingPoints(timeEvent, includeChildLinear);
	        	for(var i:int=0; i < trackingPoints.length; i++) {
	        		var trackingPoint:TrackingPoint = trackingPoints[i];			
		        	if(trackingPoint != null) {
			 			CONFIG::debugging { doLog("AdSlot: " + id + " matched request to process tracking event of type '" + trackingPoint.label + "' @ milliseconds:'" + timeEvent.milliseconds + "', include children:" + includeChildLinear + ", resetTrackingOnReplay: " + resetTrackingOnReplay, Debuggable.DEBUG_CUEPOINT_EVENTS); }
						var description:String;
													
		        		switch(trackingPoint.label) {
				 			case "BA": // start of the Ad stream
				 				description = "Begin linear video advertisement event";
				 				processStartStream(timeEvent.getTimestamp());
				 				actionSurveyStart();
						 		_vastController.onProcessTrackingPoint(trackingPoint);
						 		_vastController.onLinearAdStart(this);	
				 				break;
				 			case "EA": // end of the Ad stream
				 				description = "End linear video advertisement event";
				 				processStreamComplete(timeEvent.getTimestamp());
						 		actionSurveyEnd();
						 		_vastController.onProcessTrackingPoint(trackingPoint);	
						 		_vastController.onLinearAdComplete(this);					 				
				 				break;
				 			case "SS": // stop stream
				 				description = "Stop stream event";
				 				processStopStream(timeEvent.getTimestamp());
						 		_vastController.onProcessTrackingPoint(trackingPoint);	
				 				break;
				 			case "PS": // pause stream
				 				description = "Pause stream event";
				 				processPauseStream(timeEvent.getTimestamp());
						 		_vastController.onProcessTrackingPoint(trackingPoint);	
				 				break;
				 			case "RS": // resume stream
				 				description = "Resume stream event";
				 				processResumeStream(timeEvent.getTimestamp());
						 		_vastController.onProcessTrackingPoint(trackingPoint);	
				 				break;
				 			case "HW": // halfway midpoint
				 				description = "Halfway point tracking event";
				 				processAdMidpointComplete(timeEvent.getTimestamp());
						 		_vastController.onProcessTrackingPoint(trackingPoint);	
				 				break;
				 			case "1Q": // end of first quartile
				 				description = "1st quartile tracking event";
				 				processAdFirstQuartileComplete(timeEvent.getTimestamp());
						 		_vastController.onProcessTrackingPoint(trackingPoint);	
				 				break;
				 			case "3Q": // end of third quartile
				 				description = "3rd quartile tracking event";
				 				processAdThirdQuartileComplete(timeEvent.getTimestamp());
						 		_vastController.onProcessTrackingPoint(trackingPoint);	
				 				break;
				 			case "DS": // delayed start time skip ad notice
				 				if(this.canSkipOnLinearAd()) {
						 			var adSlot:AdSlot = this;
									_vastController.activateLinearAdSkipButton(
										function():void {
											hideAdNotice();
											_vastController.onLinearAdSkip(adSlot);
										}
									);
				 				}
								break;		
				 			case "HS": // hide timed skip ad notice (only used if the skip ad notice shows for a nominated duration)
				 				if(this.canSkipOnLinearAd()) {
									_vastController.deactivateLinearAdSkipButton();
				 				}
								break;
				 			case "SN": // show ad notice
				 				description = "Show ad notice event";
				 			    showAdNotice();
						 		_vastController.onProcessTrackingPoint(trackingPoint);	
						 		break;			 			    
				 			case "HN": // hide the ad notice
				 				description = "Hide ad notice event";
				 				hideAdNotice();
						 		_vastController.onProcessTrackingPoint(trackingPoint);	
				 				break;
				 			case "NS": // a trigger to start a non-linear overlay
				 				if(_vastController.config.adsConfig.replayOverlays || (_vastController.config.adsConfig.replayOverlays == false && played == false)) {
					 				if(!isPlaying()) {
						 				description = "Start non-linear ad event";
						 				actionNonLinearAdStart(timeEvent.getTimestamp()); 
						 				actionSurveyStart();
								 		_vastController.onProcessTrackingPoint(trackingPoint);	
								 	}
								 	else {
								 		CONFIG::debugging { doLog("Ignoring request to start non-linear ad - already playing", Debuggable.DEBUG_CUEPOINT_EVENTS); }
								 	}
				 				}
							 	else {
							 		CONFIG::debugging { doLog("Ignoring request to start non-linear ad - already played and replay='false'", Debuggable.DEBUG_CUEPOINT_EVENTS); }
							 	}
				 				break;
				 			case "NE": // a trigger to stop a non-linear overlay
				 				description = "End non-linear ad event";
				 				actionNonLinearAdEnd(resetTrackingOnReplay, timeEvent.getTimestamp()); 
						 		actionSurveyEnd();
						 		_vastController.onProcessTrackingPoint(trackingPoint);	
				 				break;
				 			case "CS": // start a companion ad or a survey
				 				if(!companionsShowing()) {
					 				description = "Companion start event";
		 		 					actionCompanionAdStart(timeEvent.getTimestamp()); 
							 		_vastController.onProcessTrackingPoint(trackingPoint);	
							 	}
							 	else {
							 		CONFIG::debugging { doLog("Ignoring request to show companion ad(s) - already showing", Debuggable.DEBUG_CUEPOINT_EVENTS); }
							 	} 
				 				break;
				 			case "CE": // stop a companion ad
				 				description = "Companion end event";
				 				actionCompanionAdEnd(timeEvent.getTimestamp()); 
						 		_vastController.onProcessTrackingPoint(trackingPoint);	
				 				break;
				 			case "TN": // timed ad notice - countdown value
				 			    description = "Timed ad notice";
				 			    actionAdNoticeCountdownTick(trackingPoint.milliseconds); 
				 			    _vastController.onProcessTrackingPoint(trackingPoint);
				 		}	        		
		        	}        			        		
	        	}
        	}
	 	}
	 	
	 	public function closeActiveOverlaysAndCompanions(resetTrackingOnReplay:Boolean=false):void {
	 		actionNonLinearAdEnd(resetTrackingOnReplay); 
	 		actionCompanionAdEnd();
	 		actionSurveyEnd();
	 	}
	 	
	 	// On demand template load API
	
		public function onTemplateLoaded(template:AdServerTemplate):void {
			loading = false;
			_template = template;
			_videoAd = null; // resets the ad when failover happens
			if(template != null) {
				if(template.hasAds(shouldForceFireImpressions())) {
					CONFIG::debugging { doLog("On demand ad request complete - a template with " + template.ads.length + " ads returned for ad slot " + this.id + " at index " + this.index, Debuggable.DEBUG_VAST_TEMPLATE); }
					_videoAd = template.getNextNonEmptyVideoAdStartingAtIndex(0);
					if(_videoAd != null) {
						if(_videoAd.isNonLinear()) {
							if(_videoAd.hasEmptyNonLinearAds() == false) {
								if(isNonLinear()) {
									CONFIG::debugging { doLog("On demand ad is non-linear - displaying overlay (and associated companions) immediately", Debuggable.DEBUG_VAST_TEMPLATE); }
				 					actionNonLinearAdStart(); 
				 					actionCompanionAdStart(); 
									_vastController.onProcessTrackingPoint(_trackingTable.getTrackingPointOfType("NS", false, true));	
							 		_vastController.onProcessTrackingPoint(_trackingTable.getTrackingPointOfType("CS", false, true));	
							 	}
							 	else {
									CONFIG::debugging { doLog("On demand ad is non-linear - not starting it though as this ad slot is linear and does not match the non-linear ad tag", Debuggable.DEBUG_VAST_TEMPLATE); }
							 	}
							}
						}
						else {
							if(_videoAd.hasEmptyLinearAd() == false) {
								CONFIG::debugging { doLog("On demand ad is linear - declaring tracking points and marking as not set", Debuggable.DEBUG_VAST_TEMPLATE); }
								markTrackingPointsAsNotSet();
								declareTrackingPoints();
							}
						}
					}
				}
				else {
					CONFIG::debugging { doLog("On demand ad request complete - an empty template has been returned for ad slot " + this.id + " at index " + this.index, Debuggable.DEBUG_VAST_TEMPLATE); }
//					fireErrorUrls("303");
				}
			}
			else {
				CONFIG::debugging { doLog("On demand ad request complete - a NULL template has been returned for ad slot " + this.id + " at index " + this.index, Debuggable.DEBUG_VAST_TEMPLATE); }
			}
			if(_onDemandLoadListener != null) {
				_onDemandLoadListener.onAdSlotLoaded(new AdSlotLoadEvent(AdSlotLoadEvent.LOADED, this));
			}
		}
		
		public function onTemplateLoadError(event:Event):void {
			CONFIG::debugging { doLog("On demand ad request failed on ad slot " + this.id + " at index " + this.index + " - " + event.toString(), Debuggable.DEBUG_VAST_TEMPLATE); }
			loading = false;
			if(_onDemandLoadListener != null) {
				_onDemandLoadListener.onAdSlotLoadError(new AdSlotLoadEvent(AdSlotLoadEvent.LOAD_ERROR, this, event));
			}
		}

		public function onTemplateLoadTimeout(event:Event):void {
			CONFIG::debugging { doLog("On demand ad request timed out on ad slot " + this.id + " at index " + this.index, Debuggable.DEBUG_VAST_TEMPLATE); }
			loading = false;
			if(_onDemandLoadListener != null) {
				_onDemandLoadListener.onAdSlotLoadError(new AdSlotLoadEvent(AdSlotLoadEvent.LOAD_TIMEOUT, this, event));
			}
		}

		public function onTemplateLoadDeferred(event:Event):void {
			CONFIG::debugging { doLog("On demand ad request deferred on ad slot " + this.id + " at index " + this.index, Debuggable.DEBUG_VAST_TEMPLATE); }
			loading = false;
			if(_onDemandLoadListener != null) _onDemandLoadListener.onAdSlotLoadDeferred(new AdSlotLoadEvent(AdSlotLoadEvent.LOAD_DEFERRED, this, event));
		}
		
		public function onAdCallStarted(request:AdServerRequest):void {
			if(_onDemandLoadListener != null) {
				_onDemandLoadListener.onAdCallStarted(request);
			}
		}

		public function onAdCallFailover(masterRequest:AdServerRequest, failoverRequest:AdServerRequest):void { 
			if(_onDemandLoadListener != null) {
				_onDemandLoadListener.onAdCallFailover(masterRequest, failoverRequest);
			}
		}
		
		public function onAdCallComplete(request:AdServerRequest, hasAds:Boolean):void {
			if(_onDemandLoadListener != null) {
				_onDemandLoadListener.onAdCallComplete(request, hasAds);
			}
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

		// Copying methods
		
        public function get clonedAdServerConfig():AdServerConfig {
        	if(_adServerConfig != null) {
	        	return _adServerConfig;   		
        	}
        	return null;
        }
        
		public function markAsCopy(originalAdSlot:AdSlot):void {
			_originalAdSlot = originalAdSlot;
		}
	
		public function isCopy():Boolean {
			return (_originalAdSlot != null);
		}
	
		public function clone(instanceNumber:int=0):AdSlot {
			var clonedAdSlot:AdSlot = new AdSlot(
			                                _parent,
			                                _owner,
		                         			_vastController, 
		                         			_key, 
		                         			_associatedStreamIndex, 
		                         			_id + '-c', 
		                         			_zone, 
		                         			_position, 
		                         			_applyToParts, 
		                         			_duration, 
		                         			_originalDuration,
		                         			_startTime, 
		                         			_notice, 
		                         			_disableControls, 
		                         			null, 
		                         			_companionDivIDs, 
		                         			_streamType,
		                         			_deliveryType,
		                         			_bitrate,
		                         			_playOnce,
		                         			_metaData,
		                         			_autoPlay,
		                         			_regions,
		                         			_playerConfig,
		                         			_clickSignEnabled,
		                         			clonedAdServerConfig,
		                         			_previewImage,
		                         			_loadOnDemand,
		                         			_refreshOnReplay
		                      		  );
		    clonedAdSlot.originatingAssociatedStreamIndex = _originatingAssociatedStreamIndex;
		    clonedAdSlot.played = _played;
		    clonedAdSlot.markAsCopy(this);
		    return clonedAdSlot;
		}

		public override function toJSObject():Object {
			var o:Object = new Object();
			o = {
				id: _id,
				uid: _uid,
				type: getSlotType(),
				position: _position,
				loadOnDemand: _loadOnDemand,
				refreshOnReplay: _refreshOnReplay,
				associatedStreamIndex: _associatedStreamIndex,
				showNotice: noticeToBeShown(),
				regions: _regions
			};
			return o;
		}

        public override function toShortString():String {
        	return "position: " + _position +
        	       ((_loadOnDemand) ? " (ON DEMAND)" : "") +
        	       ", " + 
        	       super.toShortString();
        }

		public override function toString():String {
			return super.toString() +
			   ", adSlotId: " + adSlotID +
			   ", position: " + _position + 
			   ", loadOnDemand: " + _loadOnDemand +
			   ", originatingAssociatedStreamIndex: " + _originatingAssociatedStreamIndex +
			   ", associatedStreamIndex: " + _associatedStreamIndex +
			   ", associatedStreamStartTime: " + _associatedStreamStartTime +
			   ", showNotice: " + noticeToBeShown() +
			   ", metaData: " + _metaData;
		}
	}	
}
