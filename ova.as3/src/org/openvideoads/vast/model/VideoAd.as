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
package org.openvideoads.vast.model {
	import flash.external.ExternalInterface;
	
	import org.openvideoads.base.Debuggable;
	import org.openvideoads.regions.view.FlashMedia;
	import org.openvideoads.util.ArrayUtils;
	import org.openvideoads.util.NetworkResource;
	import org.openvideoads.util.StringUtils;
	import org.openvideoads.util.Timestamp;
	import org.openvideoads.vast.events.VideoAdDisplayEvent;
	import org.openvideoads.vast.schedule.ads.AdSlot;
	import org.openvideoads.vast.server.config.AdServerConfig;
	
	/**
	 * @author Paul Schulz
	 */
	public class VideoAd extends Debuggable {
		protected var _id:String;
		protected var _inlineAdId:String = null;
		protected var _adId:String = null;
		protected var _sequenceId:String;
		protected var _creativeId:String;
		protected var _adSystem:String;
		protected var _adTitle:String;
		protected var _description:String;
		protected var _survey:String;
		protected var _errorUrls:Array = new Array();
		protected var _impressions:Array = new Array();			
		protected var _trackingEvents:Array = new Array();		
		protected var _linearVideoAd:LinearVideoAd = null;
		protected var _nonLinearVideoAds:Array  = new Array();
		protected var _companionAds:Array  = new Array();
		protected var _impressionsFired:Boolean = false;
		protected var _indexCounters:Array = new Array();
		CONFIG::callbacks {
			protected var _canFireAPICalls:Boolean = true;
			protected var _canFireEventAPICalls:Boolean = false;
			protected var _useV2APICalls:Boolean = false;
			protected var _jsCallbackScopingPrefix:String = "";
		}
		protected var _extensions:Array = new Array();
		protected var _wrapper:WrappedVideoAdV1 = null;		
		protected var _preferredSelectionCriteria:Object = null;

		public static const AD_TYPE_LINEAR:String = "linear";
		public static const AD_TYPE_NON_LINEAR:String = "non-linear";
		public static const AD_TYPE_COMPANION:String = "companion";
		public static const AD_TYPE_UNKNOWN:String = "unknown";
		public static const AD_TYPE_VPAID_LINEAR:String = "linear-vpaid";
		public static const AD_TYPE_VPAID_NON_LINEAR:String = "non-linear-vpaid";		

		public function VideoAd() {
			super();
		}

		public function unload():void {
			if(hasAds()) {
				if(hasLinearAd()) {
					_linearVideoAd.unload();
				}
				if(hasNonLinearAds()) {
					for(var n:int=0; n < _nonLinearVideoAds.length; n++) {
						_nonLinearVideoAds[n].unload();
					}
				}
			}
			if(hasImpressions()) {
				for(var i:int=0; i < _impressions.length; i++) {
					_impressions[i].unload();
				}												
			}
			if(hasTrackingEvents()) {
				for(var t:int=0; t < _trackingEvents.length; t++) {
					_trackingEvents[t].unload();
				}								
			}
			if(hasCompanionAds()) {
				for(var c:int=0; c < _companionAds.length; c++) {
					_companionAds[c].unload();
				}				
			}
		}

		public function set id(id:String):void {
			_id = id;
		}
		
		public function get id():String {
			return _id;
		}

		public function setPreferredSelectionCriteria(criteria:Object):void {
			_preferredSelectionCriteria = criteria;
		}
		
		public function hasPreferredSelectionCriteria():Boolean {
			return (_preferredSelectionCriteria != null);
		}
		
		public function getPreferredBitrate():* {			
			if(_preferredSelectionCriteria != null) {
				if(_preferredSelectionCriteria.hasOwnProperty("bitrate")) return _preferredSelectionCriteria.bitrate;
			}
			return -1;
		}

		public function getPreferredMimeType():* {
			if(_preferredSelectionCriteria != null) {
				if(_preferredSelectionCriteria.hasOwnProperty("mimeType")) return _preferredSelectionCriteria.mimeType;
			}
			return "any";
		}
		
		public function getPreferredDeliveryType():String {
			if(_preferredSelectionCriteria != null) {
				if(_preferredSelectionCriteria.hasOwnProperty("deliveryType")) return _preferredSelectionCriteria.deliveryType;
			}
			return "any";
		}

		public function getPreferredWidth():* {
			if(_preferredSelectionCriteria != null) {
				if(_preferredSelectionCriteria.hasOwnProperty("width")) return _preferredSelectionCriteria.width;
			}
			return -1;
		}

		public function getPreferredHeight():* {
			if(_preferredSelectionCriteria != null) {
				if(_preferredSelectionCriteria.hasOwnProperty("height")) return _preferredSelectionCriteria.height;
			}
			return -1;
		}
		
		public function hasAds(includeEmptyAdsInCount:Boolean=false):Boolean {
			if(includeEmptyAdsInCount) {
				return (hasLinearAd() || hasNonLinearAds() || hasImpressions());
			}
			else {
				return (hasEmptyLinearAd() == false) || (hasNonLinearAds() && (hasEmptyNonLinearAds() == false));
			}
		}
				
		public function hasMultipleAdUnits():Boolean {
			return (hasLinearAd() && hasNonLinearAds());
		}
		
		public function isFromAdSystem(system:String):Boolean {
			return StringUtils.matchesIgnoreCase(_adSystem, "OPENX");
		}

		public function filterLinearAdMediaFileByMimeType(mimeTypes:Array):void {
			if(_linearVideoAd != null) {
				_linearVideoAd.filterLinearAdMediaFileByMimeType(mimeTypes);
			}
		}

		protected function isAcceptableLinearAdMediaFileMimeType(mimeType:String, adServerConfig:AdServerConfig):Boolean {
			if(adServerConfig != null) {
				return adServerConfig.isAcceptedLinearAdMimeType(mimeType);
			}
			return true;			
		}
		
		public function hasWrapper():Boolean {
			return (_wrapper != null);
		}
		
		public function set wrapper(wrapper:WrappedVideoAdV1):void {
			_wrapper = wrapper;
		}
		
		public function get wrapper():WrappedVideoAdV1 {
			return _wrapper;
		}
		
		CONFIG::callbacks
		public function setCanFireAPICalls(canFireAPICalls:Boolean):void {
			_canFireAPICalls = canFireAPICalls;
		}
		
		CONFIG::callbacks
		public function canFireAPICalls():Boolean {
			return _canFireAPICalls;
		}

		CONFIG::callbacks
		public function setCanFireEventAPICalls(canFireEventAPICalls:Boolean):void {
			_canFireEventAPICalls = canFireEventAPICalls;
		}
		
		CONFIG::callbacks
		public function canFireEventAPICalls():Boolean {
			return _canFireEventAPICalls;
		}

		CONFIG::callbacks
		public function set useV2APICalls(useV2APICalls:Boolean):void {
			_useV2APICalls = useV2APICalls;
		}

		CONFIG::callbacks
		public function get useV2APICalls():Boolean {
			return _useV2APICalls;
		}
		
		CONFIG::callbacks
		public function set jsCallbackScopingPrefix(jsCallbackScopingPrefix:String):void {
			_jsCallbackScopingPrefix = jsCallbackScopingPrefix;
		}
		
		CONFIG::callbacks
		public function get jsCallbackScopingPrefix():String {
			return _jsCallbackScopingPrefix;
		}
		
		protected function clearIndexCounters():void {
			_indexCounters = new Array();
		}

		protected function createIndex(width:int, height:int):int {
			for(var i:int = 0; i < _indexCounters.length; i++) {
				if(_indexCounters[i].width == width && _indexCounters[i].height == height) {
					_indexCounters[i].index = _indexCounters[i].index + 1;
					return _indexCounters[i].index;
				}
			}
			_indexCounters.push({ width: width, height: height, index: 0});
			return 0;
		}
		
		public function injectAllTrackingData(videoAd:VideoAd):VideoAd {
			return videoAd;
		}

        /* V1.0 PARSING METHODS ******************************************************************************/
		
        public function parseImpressions(ad:XML):void {
			CONFIG::debugging { doLog("Parsing V1.X impression tags...", Debuggable.DEBUG_VAST_TEMPLATE); }
			if(ad.Impression != null && ad.Impression.children() != null) {
				var impressions:XMLList = ad.Impression.children();
				for(var i:int = 0; i < impressions.length(); i++) {
					this.addImpression(new Impression(impressions[i].@id, impressions[i]));
				}
			}
			CONFIG::debugging { doLog(_impressions.length + " impressions recorded", Debuggable.DEBUG_VAST_TEMPLATE); }      	
        }        
        	
		public function hasTrackingEventType(type:String):Boolean {
			if(_trackingEvents != null) {
				for(var i:int = 0; i < _trackingEvents.length; i++) {
					if(_trackingEvents[i].isType(type)) {
						return true;
					}
				}
			}
			return false;
		}
		
		public function getTrackingEventsOfType(type:String):Array {
			var results:Array = new Array();
			if(_trackingEvents != null) {
				for(var i:int = 0; i < _trackingEvents.length; i++) {
					if(_trackingEvents[i].isType(type)) {
						results.add(_trackingEvents[i]);
					}
				}
			}
			return results;
		}

		public function hasProgressTrackingEvents():Boolean {
			return false;
		}
		
		public function getProgressTrackingEvents():Array {
			return new Array();
		}
        	
        protected function createTrackingEvent(trackingEventXML:XML):TrackingEvent {
			return new TrackingEvent(trackingEventXML.@event);
        }
        
        protected function parseTrackingEventTags(ad:XML):void {
			if(ad.TrackingEvents != null && ad.TrackingEvents.children() != null) {
				var trackingEvents:XMLList = ad.TrackingEvents.children();
				CONFIG::debugging { doLog(trackingEvents.length() + " tracking events specified", Debuggable.DEBUG_VAST_TEMPLATE); }
				for(var i:int = 0; i < trackingEvents.length(); i++) {
					var trackingEventXML:XML = trackingEvents[i];
					var trackingEvent:TrackingEvent = createTrackingEvent(trackingEventXML);
					var trackingEventURLs:XMLList = trackingEventXML.children();
					for(var j:int = 0; j < trackingEventURLs.length(); j++) {
						var trackingEventURL:XML = trackingEventURLs[j];
						trackingEvent.addURL(new NetworkResource(trackingEventURL.@id, trackingEventURL.text()));
					}
					this.addTrackingEvent(trackingEvent);				
				}
			} 
        }
        	
        public function parseTrackingEvents(ad:XML):void {
			CONFIG::debugging { doLog("Parsing V1.X TrackingEvent tags...", Debuggable.DEBUG_VAST_TEMPLATE); }
			parseTrackingEventTags(ad);
        }
        	
        public function parseLinears(ad:XML, index:int=-1, adServerConfig:AdServerConfig=null):void {
			CONFIG::debugging { doLog("Parsing V1.X Linear Ad tags...", Debuggable.DEBUG_VAST_TEMPLATE); }
			var newLinearVideoAd:LinearVideoAd = new LinearVideoAd();
			var apiFramework:String = "";
			var adParameters:String = "";
			newLinearVideoAd.adID = ad.Video.AdID;
			newLinearVideoAd.index = index;
			CONFIG::callbacks {
				newLinearVideoAd.canFireAPICalls = _canFireAPICalls;
				newLinearVideoAd.canFireEventAPICalls = _canFireEventAPICalls;
				newLinearVideoAd.useV2APICalls = _useV2APICalls;
				newLinearVideoAd.jsCallbackScopingPrefix = _jsCallbackScopingPrefix;
			}
			var duration:String = null; 
			if(ad.Video.VideoLength != undefined) {
				duration = ad.Video.VideoLength;
			}
			else if(ad.Video.Duration != undefined) {
				duration = ad.Video.Duration;
			}
			if(duration != null) {
				if(Timestamp.validate(duration)) {
					newLinearVideoAd.duration = duration; 
				}
				else {
					newLinearVideoAd.duration = Timestamp.secondsStringToTimestamp(duration);
					CONFIG::debugging { doLog("Duration has been specified in non-compliant manner (hh:mm:ss) - assuming seconds - converted to: " + newLinearVideoAd.duration, Debuggable.DEBUG_VAST_TEMPLATE); }
				}
			}
			if(ad.Video.AdParameters != undefined) {
				if(!StringUtils.isEmpty(ad.Video.AdParameters.@apiFramework)) {
					apiFramework = ad.Video.AdParameters.@apiFramework;
					adParameters = ad.Video.AdParameters.text();
					CONFIG::debugging { doLog("Have recorded an apiFramework ('" + apiFramework + "') and ad parameters for this video ad", Debuggable.DEBUG_VAST_TEMPLATE); }
				}
				else {
					CONFIG::debugging { doLog("Cannot record ad parameters for this video ad - apiFramework not specified", Debuggable.DEBUG_VAST_TEMPLATE); }
				}
			}
			if(ad.Video.VideoClicks != undefined) {
				var clickList:XMLList;
				var clickURL:XML;
				var i:int=0;
				if(ad.Video.VideoClicks.ClickThrough.children().length() > 0) {
					CONFIG::debugging { doLog("Parsing V1.X VideoClicks ClickThrough tags...", Debuggable.DEBUG_VAST_TEMPLATE); }
					clickList = ad.Video.VideoClicks.ClickThrough.children();
					for(i = 0; i < clickList.length(); i++) {
						clickURL = clickList[i];
						if(!StringUtils.isEmpty(clickURL.text())) {
							newLinearVideoAd.addClickThrough(new NetworkResource(clickURL.@id, clickURL.text()));
						}
					}
				}
				if(ad.Video.VideoClicks.ClickTracking.children().length() > 0) {
					CONFIG::debugging { doLog("Parsing V1.X VideoClicks ClickTracking tags...", Debuggable.DEBUG_VAST_TEMPLATE); }
					clickList = ad.Video.VideoClicks.ClickTracking.children();
					for(i = 0; i < clickList.length(); i++) {
						clickURL = clickList[i];
						if(!StringUtils.isEmpty(clickURL.text())) {
							newLinearVideoAd.addClickTrack(new NetworkResource(clickURL.@id, clickURL.text()));
						}
					}
				}
				if(ad.Video.VideoClicks.CustomClick.children().length() > 0) {
					CONFIG::debugging { doLog("Parsing V1.X VideoClicks CustomClick tags...", Debuggable.DEBUG_VAST_TEMPLATE); }
					clickList = ad.Video.CustomClick.ClickTracking.children();
					for(i = 0; i < clickList.length(); i++) {
						clickURL = clickList[i];
						if(!StringUtils.isEmpty(clickURL.text())) {
							newLinearVideoAd.addCustomClick(new NetworkResource(clickURL.@id, clickURL.text()));
						}
					}
				}
			}
			if(ad.Video.MediaFiles != undefined) {
				var mediaFiles:XMLList = ad.Video.MediaFiles.children();
				for(i = 0; i < mediaFiles.length(); i++) {
					var mediaFileXML:XML = mediaFiles[i];
					if(mediaFileXML.children().length() > 0) {
						if(isAcceptableLinearAdMediaFileMimeType(mediaFileXML.@type, adServerConfig)) {
							var mediaFile:MediaFile = (StringUtils.matchesIgnoreCase(apiFramework, "VPAID") ? new VPAIDMediaFile() : new MediaFile());
							mediaFile.id = mediaFileXML.@id; 
							mediaFile.bandwidth = mediaFileXML.@bandwidth; 
							mediaFile.delivery = mediaFileXML.@delivery; 
							mediaFile.mimeType = mediaFileXML.@type; 
							mediaFile.bitRate = int(mediaFileXML.@bitrate); 
							mediaFile.width = mediaFileXML.@width; 
							mediaFile.height = mediaFileXML.@height; 
							mediaFile.scale = mediaFileXML.@scalable; 
							mediaFile.maintainAspectRatio = mediaFileXML.@maintainAspectRatio; 
							mediaFile.apiFramework = apiFramework; 
							mediaFile.adParameters = adParameters; 
							mediaFile.parentAd = newLinearVideoAd;
							var mediaFileURLXML:XML = mediaFileXML.children()[0];
							mediaFile.url = new AdNetworkResource(mediaFileURLXML.@id, mediaFileURLXML.text(), mediaFileXML.@type);
							newLinearVideoAd.addMediaFile(mediaFile);
						}
						else {
							CONFIG::debugging { doLog("Excluding '" + mediaFileXML.text() + "' as mime type '" +  mediaFileXML.@type + "' is to be filtered out", Debuggable.DEBUG_VAST_TEMPLATE); }
						}
					}
					else {
						CONFIG::debugging { doLog("Excluding MediaFile '" + mediaFileXML.text() + "' because it is an empty declaration", Debuggable.DEBUG_VAST_TEMPLATE); }
					}
				}					
				CONFIG::debugging { doLog(newLinearVideoAd.mediaFileCount() + " V1.X MediaFiles added to the linear video ad", Debuggable.DEBUG_VAST_TEMPLATE); }
			}
			this.linearVideoAd = newLinearVideoAd;
        }	
        
        public function parseNonLinears(ad:XML, index:int=-1):void {
			CONFIG::debugging { doLog("Parsing V1.X NonLinearAd tags...", Debuggable.DEBUG_VAST_TEMPLATE); }
			var nonLinearAds:XMLList = ad.NonLinearAds.children();
			var i:int=0;
			CONFIG::debugging { doLog(nonLinearAds.length() + " non-linear ads specified", Debuggable.DEBUG_VAST_TEMPLATE); }
			for(i = 0; i < nonLinearAds.length(); i++) {
				var nonLinearAdXML:XML = nonLinearAds[i];
				var nonLinearAd:NonLinearVideoAd = null;
				switch(nonLinearAdXML.@resourceType.toUpperCase()) {
					case "HTML":
						CONFIG::debugging { doLog("Creating NonLinearHtmlAd()", Debuggable.DEBUG_VAST_TEMPLATE); }
						nonLinearAd = new NonLinearHtmlAd();
						break;
					case "TEXT":
						CONFIG::debugging { doLog("Creating NonLinearTextAd()", Debuggable.DEBUG_VAST_TEMPLATE); }
						nonLinearAd = new NonLinearTextAd();
						break;
					case "SCRIPT":
						CONFIG::debugging { doLog("Creating NonLinearScriptAd()", Debuggable.DEBUG_VAST_TEMPLATE); }
						nonLinearAd = new NonLinearScriptAd();
						break;
					case "IFRAME":
						CONFIG::debugging { doLog("Creating NonLinearIFrameAd()", Debuggable.DEBUG_VAST_TEMPLATE); }
						nonLinearAd = new NonLinearIFrameAd();
					    break;
					case "STATIC":
						if(nonLinearAdXML.@creativeType != undefined && nonLinearAdXML.@creativeType != null) {
							switch(nonLinearAdXML.@creativeType.toUpperCase()) {
								case "IMAGE/JPEG":
								case "JPEG":
								case "IMAGE/GIF":
								case "GIF":
								case "IMAGE/PNG":
								case "PNG":
								    CONFIG::debugging { doLog("Creating NonLinearImageAd()", Debuggable.DEBUG_VAST_TEMPLATE); }
									nonLinearAd = new NonLinearImageAd();
									break;
								case "APPLICATION/X-SHOCKWAVE-FLASH":
								case "SWF":
									if(StringUtils.matchesIgnoreCase(nonLinearAdXML.@apiFramework, "VPAID")) {
									    CONFIG::debugging { doLog("Creating VPAIDNonLinearAd()", Debuggable.DEBUG_VAST_TEMPLATE); }
										nonLinearAd = new VPAIDNonLinearAd();																		
									}
									else {
									    CONFIG::debugging { doLog("Creating NonLinearFlashAd()", Debuggable.DEBUG_VAST_TEMPLATE); }
										nonLinearAd = new NonLinearFlashAd();								
									}
									break;
								case "SCRIPT":
								case "JAVASCRIPT":
								case "TEXT/JAVASCRIPT":
								case "TEXT/SCRIPT":
								    nonLinearAd = new NonLinearScriptAd();
								    break;
								default:
								    CONFIG::debugging { doLog("Creating NonLinearVideoAd()", Debuggable.DEBUG_VAST_TEMPLATE); }
									nonLinearAd = new NonLinearVideoAd();
							}									
						}
						else nonLinearAd = new NonLinearVideoAd();
						break;
					default:
						nonLinearAd = new NonLinearVideoAd();
				}
				CONFIG::callbacks {
					nonLinearAd.canFireAPICalls = _canFireAPICalls;
					nonLinearAd.canFireEventAPICalls = _canFireEventAPICalls;
					nonLinearAd.useV2APICalls = _useV2APICalls;
					nonLinearAd.jsCallbackScopingPrefix = _jsCallbackScopingPrefix;
				}
				nonLinearAd.index = index;
				nonLinearAd.id = nonLinearAdXML.@id;
				nonLinearAd.width = nonLinearAdXML.@width;
				nonLinearAd.height = nonLinearAdXML.@height; 
				if(nonLinearAdXML.@expandedWidth != undefined) nonLinearAd.expandedWidth = nonLinearAdXML.@expandedWidth; 
				if(nonLinearAdXML.@expandedHeight != undefined) nonLinearAd.expandedHeight = nonLinearAdXML.@expandedHeight; 
				nonLinearAd.resourceType = nonLinearAdXML.@resourceType; 
				nonLinearAd.creativeType = nonLinearAdXML.@creativeType; 
				nonLinearAd.apiFramework = nonLinearAdXML.@apiFramework; 
				nonLinearAd.maintainAspectRatio = nonLinearAdXML.@maintainAspectRatio;
				nonLinearAd.scale = nonLinearAdXML.@scalable;
				if(nonLinearAdXML.URL != undefined) nonLinearAd.url = new NetworkResource(null, nonLinearAdXML.URL.text());
				if(nonLinearAdXML.Code != undefined) {
					nonLinearAd.codeBlock = nonLinearAdXML.Code.text();
				}
				if(nonLinearAdXML.NonLinearClickThrough != undefined) {
					var nlClickList:XMLList = nonLinearAdXML.NonLinearClickThrough.children();
					var nlClickURL:XML;
					for(var j:int = 0; j < nlClickList.length(); j++) {
						nlClickURL = nlClickList[j];
						nonLinearAd.addClickThrough(new NetworkResource(nlClickURL.@id, nlClickURL.text()));
					}							
				}
				this.addNonLinearVideoAd(nonLinearAd);
			}
        }
        
        public function parseCompanions(ad:XML):void {
			CONFIG::debugging { doLog("Parsing V1.X CompanionAd tags...", Debuggable.DEBUG_VAST_TEMPLATE); }
			var companionAds:XMLList = ad.CompanionAds.children();
			var i:int=0;
			CONFIG::debugging { doLog(companionAds.length() + " companions specified", Debuggable.DEBUG_VAST_TEMPLATE); }
			clearIndexCounters();
			for(i = 0; i < companionAds.length(); i++) {
				var companionAdXML:XML = companionAds[i];
				var companionAd:CompanionAd = new CompanionAd(this);
				companionAd.id = companionAdXML.@id;
				companionAd.width = companionAdXML.@width;
				companionAd.height = companionAdXML.@height; 
				companionAd.index = createIndex(companionAd.width, companionAd.height);
				if(companionAdXML.@resourceType != undefined) {
					companionAd.resourceType = companionAdXML.@resourceType; 
				}
				else companionAd.resourceType = "static";
				if(companionAdXML.@creativeType != undefined) companionAd.creativeType = companionAdXML.@creativeType;
				if(companionAdXML.URL != undefined) companionAd.url = new NetworkResource(null, companionAdXML.URL.text());
				if(companionAdXML.Code != undefined) {
					companionAd.codeBlock = companionAdXML.Code.text();							
				}
				if(companionAdXML.AltText != undefined) companionAd.altText = companionAdXML.AltText.text();
				if(companionAdXML.AdParameters != undefined) {
					companionAd.adParameters = companionAdXML.AdParameters.text();
					CONFIG::debugging { doLog("Companion Ad has adParameters set", Debuggable.DEBUG_VAST_TEMPLATE); }
				}	
				if(companionAdXML.CompanionClickThrough != undefined) {
					CONFIG::debugging { doLog("Parsing V1.X Companion ClickThrough tags...", Debuggable.DEBUG_VAST_TEMPLATE); }
					var caClickList:XMLList = companionAdXML.CompanionClickThrough; 
					CONFIG::debugging { doLog(caClickList.length() + " Companion ClickThroughs detected", Debuggable.DEBUG_VAST_TEMPLATE); }
					var caClickURL:XML;
					for(var j:int = 0; j < caClickList.length(); j++) {
						caClickURL = caClickList[j];
						if(caClickURL.URL != undefined) {
							companionAd.addClickThrough(new NetworkResource(caClickURL.@id, caClickURL.URL.text()));						
						}
					}							
				}
				this.addCompanionAd(companionAd);						 						
			}					
        }

		//<Extension type="NonLinearClickTracking"> supported for Christophe			
        public function parseExtensions(ad:XML):void {
			var extensions:XMLList = ad.Extensions.children();
			CONFIG::debugging { doLog("Parsing V1.0 extension tags (" + extensions.length() + ") - The only tags supported at this time are: type='NonLinearClickTracking'", Debuggable.DEBUG_VAST_TEMPLATE); }
			for(var i:int=0; i < extensions.length(); i++) {
				var extensionXML:XML = extensions[i];
				if(extensionXML.@type == "NonLinearClickTracking") {
					if(extensionXML.ClickTracking != undefined) {
						CONFIG::debugging { doLog("Have " + extensionXML.ClickTracking.children().length() + " non-linear click tracking extensions specified", Debuggable.DEBUG_VAST_TEMPLATE); }
						var clickList:XMLList = extensionXML.ClickTracking.children();
						var extendedClickTrackingItems:Array = new Array();
						for(var j:int=0; j < clickList.length(); j++) {
							if(!StringUtils.isEmpty(clickList[j].text())) {
								extendedClickTrackingItems.push(new NetworkResource(clickList[j].@id, clickList[j].text()));							
							}
						}
						// add this click tracking onto every non-linear video ads
						for(var x:int=0; x < _nonLinearVideoAds.length; x++) {
							NonLinearVideoAd(_nonLinearVideoAds[x]).addNonLinearClickTrackingExtensionItems(extendedClickTrackingItems);
						}
						CONFIG::debugging { doLog("Added " + extendedClickTrackingItems.length + " click tracking extensions to " + _nonLinearVideoAds.length + " non-linear ads", Debuggable.DEBUG_VAST_TEMPLATE); }
					}
				}
			}
        }
        
        public function addClickTrackingItems(clickList:Array):void {
        	if(_linearVideoAd != null) {
        		_linearVideoAd.addClickTrackingItems(clickList);	
        	}
        }

        public function addCustomClickTrackingItems(clickList:Array):void {
        	if(_linearVideoAd != null) {
				_linearVideoAd.addCustomClickTrackingItems(clickList);
        	}        	
        }

        /* HELPER METHODS ***********************************************************************************/
        
		public function set adId(adId:String):void {
			_adId = adId;
		}
		
		public function get adId():String {
			return _adId;
		}

		public function set inlineAdId(inlineAdId:String):void {
			_inlineAdId = inlineAdId;
		}
		
		public function get inlineAdId():String {
			return _inlineAdId;
		}
		
		public function belongsToInlineAd(idToMatch:String):Boolean {
			return (_inlineAdId == idToMatch);
		}

		public function set creativeId(creativeId:String):void {
			_creativeId = creativeId;
		}
		
		public function get creativeId():String {
			return _creativeId;
		}

		public function set sequenceId(sequenceId:String):void {
			_sequenceId = sequenceId;
		}
		
		public function get sequenceId():String {
			return _sequenceId;
		}
		
		public function set adSystem(adSystem:String):void {
			_adSystem = adSystem;
		}
		
		public function get adSystem():String {
			return _adSystem;
		}
		
		public function get duration():int {
			if(_linearVideoAd != null) {
				return Timestamp.timestampToSeconds(_linearVideoAd.duration);
			}
			else if(hasNonLinearAds()) {
				if(_nonLinearVideoAds[0].hasRecommendedMinDuration()) {
					return _nonLinearVideoAds[0].recommendedMinDuration;
				}
			}
			return 0;
		}
		
		public function getDurationGivenRecommendation(recommendedDuration:int):int {
			var recordedDuration:int = duration;
			if(recordedDuration == 0 && recommendedDuration > 0) {
				return recommendedDuration;
			}
			return recordedDuration;
		}
		
		public function set adTitle(adTitle:String):void {
			_adTitle = adTitle;
		}
		
		public function get adTitle():String {
			return _adTitle;
		}
		
		public function set description(description:String):void {
			_description = description;
		}
		
		public function get description():String {
			return _description;
		}
		
		public function hasSurvey():Boolean {
			return (_survey != null);
		}
		
		public function set survey(survey:String):void {
			_survey = survey;
		}
		
		public function get survey():String {
			return _survey;
		}
		
		public function hasErrorTracking():Boolean {
			return (_errorUrls.length > 0);
		}
		
		public function addErrorUrl(errorUrl:String):void {
			_errorUrls.push(new NetworkResource("error", errorUrl));
		}

		public function addErrorUrls(errorUrls:Array):void {
			if(errorUrls != null) {
				_errorUrls = _errorUrls.concat(errorUrls);
			}
		}

		public function set errorUrls(errorUrls:Array):void {
			_errorUrls = errorUrls;
		}
		
		public function get errorUrls():Array {
			return _errorUrls;
		}
		
		public function fireErrorUrls(errorCode:String="900"):void {
			if(hasErrorTracking()) {
				for each(var errorUrl:NetworkResource in errorUrls) {
					errorUrl.callAfterReplacing("[ERRORCODE]", errorCode);
					errorUrl.markAsFired();
				}
			}
		}
		
		public function set impressions(impressions:Array):void {
			_impressions = impressions;
		}
		
		public function get impressions():Array {
			return _impressions;
		}

		public function get baseImpressions():Array {
			return _impressions;
		}		
		
		public function addImpression(impression:NetworkResource):void {
			_impressions.push(impression);
		}
		
		public function addImpressions(impressions:Array):void {
			_impressions = _impressions.concat(impressions);
		}
		
		public function hasImpressions():Boolean {
			return (_impressions.length > 0);
		}
		
		public function getImpressionList():Array {
			var result:Array = new Array();
			if(hasImpressions()) {
				for(var i:int=0; i < _impressions.length; i++) {
					result.push(NetworkResource(_impressions[i]).url);
				}
			}	
			return result;
		}
		
		public function hasExtensions():Boolean {
			return (_extensions.length > 0);
		}
		
		public function set extensions(extensions:Array):void {
			if(extensions != null) {
				_extensions = extensions;
			}
			else _extensions = new Array();
		}
		
		public function get extensions():Array {
			return _extensions;
		}

		public function setLinearAdDurationFromSeconds(durationAsSeconds:int):void {
			if(_linearVideoAd != null) {
				_linearVideoAd.setDurationFromSeconds(durationAsSeconds);
			}
			else {
				CONFIG::debugging { doLog("ERROR: Cannot change the duration for this linear ad - it does not have a linear ad attached", Debuggable.DEBUG_CONFIG); }
			}
		}		
		
		public function set trackingEvents(trackingEvents:Array):void {
			_trackingEvents = trackingEvents;
		}
		
		public function get trackingEvents():Array {
			return _trackingEvents;
		}

		public function addTrackingEvent(trackEvent:TrackingEvent):void {
			_trackingEvents.push(trackEvent);
		}
		
		public function addTrackingEventItems(trackingEvents:Array):void {
			_trackingEvents = _trackingEvents.concat(trackingEvents);
		}

		public function hasTrackingEvents():Boolean {
			return (_trackingEvents.length > 0);
		}

		public function hasClickTracking():Boolean {
			if(hasLinearAd()) {
				return _linearVideoAd.hasClickTracking();
			}
			return false;
		}
				
		public function set linearVideoAd(linearVideoAd:LinearVideoAd):void {
			linearVideoAd.parentAdContainer = this;
			_linearVideoAd = linearVideoAd;
		}
		
		public function get linearVideoAd():LinearVideoAd {
			return _linearVideoAd;
		}
		
		public function set nonLinearVideoAds(nonLinearVideoAds:Array):void {
			if(nonLinearVideoAds != null) {
				for each(var nonLinearVideoAd:NonLinearVideoAd in nonLinearVideoAds) {
					addNonLinearVideoAd(nonLinearVideoAd);
				}				
			}
			_nonLinearVideoAds = nonLinearVideoAds;
		}
		
		public function get nonLinearVideoAds():Array {
			return _nonLinearVideoAds;
		}
		
		public function get firstNonLinearVideoAd():NonLinearVideoAd {
			if(hasNonLinearAds()) {
				return _nonLinearVideoAds[0];
			}
			else return null;
		}
		
		public function addNonLinearVideoAd(nonLinearVideoAd:NonLinearVideoAd):void {
			nonLinearVideoAd.parentAdContainer = this;
			_nonLinearVideoAds.push(nonLinearVideoAd);
		}
		
		public function hasNonLinearAds():Boolean {
			return _nonLinearVideoAds.length > 0;
		}

		public function hasLinearAd():Boolean {
			if(_linearVideoAd != null) {
				return (_linearVideoAd.isEmpty() == false);
			}
			return false;
		}

		public function hasEmptyLinearAd():Boolean {
			if(_linearVideoAd != null) {
				return _linearVideoAd.isEmpty();
			}	
			return true;		
		}

		public function hasEmptyNonLinearAds():Boolean {
			if(hasNonLinearAds()) {
				var result:Boolean = true;
				for(var i:int=0; i < _nonLinearVideoAds.length; i++) {
					if(_nonLinearVideoAds[i].isEmpty() == false) {
						result = false;
					}
				}
				return result;
			}
			return false;
		}
		
		public function set companionAds(companionAds:Array):void {
			_companionAds = companionAds;
		}
		
		public function get companionAds():Array {
			return _companionAds;
		}
		
		public function addCompanionAd(companionAd:CompanionAd):void {
			_companionAds.push(companionAd);
		}
		
		public function addCompanionAds(companionAds:Array):void {
			_companionAds = _companionAds.concat(companionAds);
		}
		
		public function hasCompanionAds():Boolean {
			return (_companionAds.length > 0);
		}
		
		public function companionCount():int {
			if(_companionAds != null) {
				return _companionAds.length;
			}
			return 0;
		}
		
		public function isCompanionOnlyAd():Boolean {
			if(hasCompanionAds()) {
				return (hasLinearAd() == false && hasNonLinearAds() == false);
			}
			return false;
		}
		
		public function isEmpty():Boolean {
			if(isLinear()) {
				return hasEmptyLinearAd();
			}
			else if(isNonLinear()) {
				return hasEmptyNonLinearAds();
			}
			else if(isCompanionOnlyAd()) {
			}
			return true;
		}

		public function isUnknownType():Boolean {
			return (!isLinear() && !isNonLinear() && !isCompanion());
		}
		
		public function isLinear():Boolean {
			return (_linearVideoAd != null && !isNonLinear());	
		}
		
		public function isNonLinear():Boolean {
			return hasNonLinearAds();
		}
		
		public function isCompanion():Boolean {
			return (!isLinear() && !isNonLinear() && hasCompanionAds());
		}
		
		public function isWrapperTemplateAd():Boolean {
			return isEmpty();
		}		
		
		public function get adType():String {
			if(isLinear()) {
				if(isInteractive()) {
					return AD_TYPE_VPAID_LINEAR;
				}
				return AD_TYPE_LINEAR;
			}
			else if(isNonLinear()) {
				if(isInteractive()) {
					return AD_TYPE_VPAID_NON_LINEAR;
				}
				return AD_TYPE_NON_LINEAR;
			}
			else if(isCompanion()) {
				return AD_TYPE_COMPANION;
			}
			return AD_TYPE_LINEAR; //AD_TYPE_UNKNOWN;			
		}
		
		public function getFlashMediaToPlay(preferredWidth:Number, preferredHeight:Number, interactiveOnly:Boolean=false):FlashMedia {
			var result:FlashMedia = null;
			if(isLinear()) {
				result = _linearVideoAd.getMediaFileToPlay(null, [ "APPLICATION/X-SHOCKWAVE-FLASH", "SWF" ], -1, preferredWidth, preferredHeight, interactiveOnly) as FlashMedia;
			}
			else {
				if(hasNonLinearAds()) {
					if(_nonLinearVideoAds.length == 1) {
						if(_nonLinearVideoAds[0] is NonLinearFlashAd) return _nonLinearVideoAds[0];
					}
					else {
						var iToReturn:int = -1;
						var bestDifference:int = -1;
						var thisDifference:int = -1;
						for(var i:int=0; i < _nonLinearVideoAds.length; i++) {
							if(_nonLinearVideoAds[i] is NonLinearFlashAd) {
								if(_nonLinearVideoAds[i].width == preferredWidth && _nonLinearVideoAds[i].height == preferredHeight) {
									return _nonLinearVideoAds[i];
								}
								else {
									thisDifference = Math.abs(_nonLinearVideoAds[i].width - preferredWidth) + Math.abs(_nonLinearVideoAds[i].height - preferredHeight);
									if(bestDifference == -1 || (thisDifference < bestDifference)) {
										iToReturn = i;										
										bestDifference = thisDifference;
									}
								}
							}
						}						
						if(iToReturn > -1) {
							return _nonLinearVideoAds[iToReturn];
						} 
					}
				}
			}
			
			if(result == null) {
				fireErrorUrls("403"); // VAST 3 code for "cannot find a media file for this player"
			}
			
			return result;
		}
		
		public function getStreamToPlay():AdNetworkResource { 
			var result:AdNetworkResource = null;

			if(isLinear() || (isNonLinear() && _linearVideoAd != null)) {
				result = _linearVideoAd.getStreamToPlay(
					getPreferredDeliveryType(), 
					getPreferredMimeType(), 
					getPreferredBitrate(), 
					getPreferredWidth(), 
					getPreferredHeight(), 
					hasPreferredSelectionCriteria()
				);
			}
			
			if(result == null) {
				fireErrorUrls("403"); // VAST 3 code for "cannot find a media file for this player"
			}
			
			return result;
		}
		
		public function canScale():Boolean { 
			if(_linearVideoAd != null) {
				return _linearVideoAd.canScale(getPreferredDeliveryType(), getPreferredMimeType(), getPreferredBitrate(), getPreferredWidth(), getPreferredHeight(), hasPreferredSelectionCriteria());				
			}	
			return false;
		}
		
		public function shouldMaintainAspectRatio():Boolean { 
			if(_linearVideoAd != null) {
				return _linearVideoAd.shouldMaintainAspectRatio(getPreferredDeliveryType(), getPreferredMimeType(), getPreferredBitrate(), getPreferredWidth(), getPreferredHeight(), hasPreferredSelectionCriteria());				
			}	
			return false;			
		}
		
		public function isInteractive():Boolean { 
			if(isLinear()) { 
				return _linearVideoAd.isInteractive(getPreferredDeliveryType(), getPreferredMimeType(), getPreferredBitrate(), getPreferredWidth(), getPreferredHeight(), hasPreferredSelectionCriteria());								
			}
			if(hasNonLinearAds()) {
				return NonLinearVideoAd(_nonLinearVideoAds[0]).isInteractive();
			}
			return false;
		}
		
		public function getMatchingCompanions(divs:Array):Array {
			if(divs != null && hasCompanionAds()) {
				var result:Array = new Array();
				var selectedCompanions:Array = new Array();
				for(var i:int=0; i < divs.length; i++) {
					for(var j:int=0; j < _companionAds.length; j++) {
						if(selectedCompanions.indexOf(_companionAds[j]) == -1) {
							if(_companionAds[j].suitableForDisplayInDIV(divs[i])) {
								selectedCompanions.push({ div: divs[i], companion: _companionAds[j] });
							}
						}
					}
				}
				return selectedCompanions;
			}
			return new Array();
		}
				
		protected function _triggerTrackingEvent(eventType:String, id:String=null, contentPlayhead:String=null):void {
			for(var i:int = 0; i < _trackingEvents.length; i++) {
				var trackingEvent:TrackingEvent = _trackingEvents[i];
				if(trackingEvent.eventType == eventType) {
					trackingEvent.execute(null, contentPlayhead);
					CONFIG::callbacks {
						fireEventAPICall("onTrackingEvent", trackingEvent.toJSObject());
					}
				}				
			}
		}

		public function triggerTrackingEvent(eventType:String, id:String=null, contentPlayhead:String=null):void {
			_triggerTrackingEvent(eventType, id, contentPlayhead);
		}
		
		public function triggerCreativeViewEvents(contentPlayhead:String=null):void {
			_triggerTrackingEvent(TrackingEvent.EVENT_CREATIVE_VIEW, null, contentPlayhead);	
		}
		
		public function resetImpressions():void {
			_impressionsFired = false;
		}
		
		public function triggerImpressionConfirmations(overrideIfAlreadyFired:Boolean=false):void {
			if(overrideIfAlreadyFired || !_impressionsFired) {
				CONFIG::debugging { doLog("Triggering " + _impressions.length + " impression events...", Debuggable.DEBUG_TRACKING_EVENTS); }
				for(var i:int = 0; i < _impressions.length; i++) {
					var impression:NetworkResource = _impressions[i];
					impression.call();
					CONFIG::callbacks {
						fireEventAPICall("onImpressionEvent", impression.toJSObject(), false);
					}
				}				
			}
			_impressionsFired = true;
		}

		public function triggerForcedImpressionConfirmations(overrideIfAlreadyFired:Boolean=false):void {
			if(overrideIfAlreadyFired || !_impressionsFired) {
				CONFIG::debugging { doLog("Firing " + _impressions.length + " impressions forcibly for video ad '" + this.id + "' - " + this.uid, Debuggable.DEBUG_TRACKING_EVENTS); }
				for(var i:int = 0; i < _impressions.length; i++) {
					var impression:NetworkResource = _impressions[i];
					impression.call();
					CONFIG::callbacks {
						fireEventAPICall("onImpressionEvent", impression.toJSObject(), true);
					}
				}	
				_impressionsFired = true;
			}
			else {
				CONFIG::debugging { doLog("Not forcing impressions to fire - already fired once!", Debuggable.DEBUG_TRACKING_EVENTS); }
			}
		}
		
		CONFIG::callbacks
		protected function fireEventAPICall(... args):* {
			if(ExternalInterface.available && canFireEventAPICalls()) {
				try {					
					if(_useV2APICalls) {
						// These are the new V2 API callbacks
						CONFIG::debugging { doLog("Firing V2 API call " + args[0] + "()", Debuggable.DEBUG_JAVASCRIPT); }
						ExternalInterface.call(_jsCallbackScopingPrefix + "onOVAEventCallback", args);
					}
					else {
						// These are the old V1 API callbacks
						CONFIG::debugging { doLog("Firing V1 Event API call " + args[0] + "()", Debuggable.DEBUG_API); }
						switch(args.length) {
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
					CONFIG::debugging { doLog("Exception making external call (" + args[0] + ") - " + e); }				
				}
			}
		}

		CONFIG::callbacks
		protected function fireAPICall(... args):* {
			if(ExternalInterface.available && canFireAPICalls()) {
				try {
					if(_useV2APICalls) {
						// These are the new V2 API callbacks
						CONFIG::debugging { doLog("Firing V2 API call " + args[0] + "()", Debuggable.DEBUG_JAVASCRIPT); }
						ExternalInterface.call(_jsCallbackScopingPrefix + "onOVAEventCallback", args);
					}
					else {
						// These are the old V1 API callbacks
						CONFIG::debugging { doLog("Firing V1 API call " + args[0] + "()", Debuggable.DEBUG_API); }
						switch(args.length) {
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
					CONFIG::debugging { doLog("Exception making external call (" + args[0] + ") - " + e, Debuggable.DEBUG_API); }
				}				
			}
		}		

		public function processStartAdEvent(contentPlayhead:String=null):void {
			// call the impression tracking urls
			if(hasNonLinearAds() == false) { // this is here to stop impressions firing for overlays that have video ads attached
				triggerImpressionConfirmations();
			}
			
			// call the creativeView tracking urls
			triggerCreativeViewEvents(contentPlayhead);
			
			// now call the start click tracking urls
			_triggerTrackingEvent(TrackingEvent.EVENT_START, null, contentPlayhead);
			CONFIG::callbacks {
				fireAPICall("onLinearAdStart", toJSObject());
			}
		}

		public function processStopAdEvent(contentPlayhead:String=null):void {
			_triggerTrackingEvent(TrackingEvent.EVENT_STOP, null, contentPlayhead);
			CONFIG::callbacks {
				fireAPICall("onLinearAdStop", toJSObject());
			}
		}
		
		public function processPauseAdEvent(contentPlayhead:String=null):void {
			_triggerTrackingEvent(TrackingEvent.EVENT_PAUSE, null, contentPlayhead);
			CONFIG::callbacks {
				fireAPICall("onLinearAdPause", toJSObject());
			}
		}

		public function processResumeAdEvent(contentPlayhead:String=null):void {
			_triggerTrackingEvent(TrackingEvent.EVENT_RESUME, null, contentPlayhead);
			CONFIG::callbacks {
				fireAPICall("onLinearAdResume", toJSObject());
			}
		}

		public function processFullScreenAdEvent(contentPlayhead:String=null):void {
			_triggerTrackingEvent(TrackingEvent.EVENT_FULLSCREEN, null, contentPlayhead);
			CONFIG::callbacks {
				fireAPICall("onLinearAdFullscreen", toJSObject());
			}
		}

		public function processFullScreenExitAdEvent(contentPlayhead:String=null):void {
			_triggerTrackingEvent(TrackingEvent.EVENT_FULLSCREEN_EXIT, null, contentPlayhead);
			CONFIG::callbacks {
				fireAPICall("onLinearAdFullscreenExit", toJSObject());
			}
		}

		public function processMuteAdEvent(contentPlayhead:String=null):void {
			_triggerTrackingEvent(TrackingEvent.EVENT_MUTE, null, contentPlayhead);
			CONFIG::callbacks {
				fireAPICall("onLinearAdMute", toJSObject());
			}
		}

		public function processUnmuteAdEvent(contentPlayhead:String=null):void {
			_triggerTrackingEvent(TrackingEvent.EVENT_UNMUTE, null, contentPlayhead);
			CONFIG::callbacks {
				fireAPICall("onLinearAdUnmute", toJSObject());
			}
		}

		public function processReplayAdEvent(contentPlayhead:String=null):void {
			_triggerTrackingEvent(TrackingEvent.EVENT_REPLAY, null, contentPlayhead);
			CONFIG::callbacks {
				fireAPICall("onLinearAdReplay", toJSObject());
			}
		}

		public function processHitMidpointAdEvent(contentPlayhead:String=null):void {
			_triggerTrackingEvent(TrackingEvent.EVENT_MIDPOINT, null, contentPlayhead);
			CONFIG::callbacks {
				fireAPICall("onLinearAdMidPointComplete", toJSObject());
			}
		}

		public function processFirstQuartileCompleteAdEvent(contentPlayhead:String=null):void {
			_triggerTrackingEvent(TrackingEvent.EVENT_1STQUARTILE, null, contentPlayhead);
			CONFIG::callbacks {
				fireAPICall("onLinearAdFirstQuartileComplete", toJSObject());
			}
		}

		public function processThirdQuartileCompleteAdEvent(contentPlayhead:String=null):void {
			_triggerTrackingEvent(TrackingEvent.EVENT_3RDQUARTILE, null, contentPlayhead);
			CONFIG::callbacks {
				fireAPICall("onLinearAdThirdQuartileComplete", toJSObject());
			}
		}

		public function processAdCompleteEvent(contentPlayhead:String=null):void {
			_triggerTrackingEvent(TrackingEvent.EVENT_COMPLETE, null, contentPlayhead);
			CONFIG::callbacks {
				fireAPICall("onLinearAdFinish", toJSObject());
			}
		}

		protected function clearActiveDisplayRegions():void {
			for(var i:int = 0; i < _nonLinearVideoAds.length; i++) {
				_nonLinearVideoAds[i].clearActiveDisplayRegion();
			}			
		}	
		
		protected function hasNonLinearAdsAvailableForDisplay(acceptedAdTypes:Array):int {
			for(var i:int = 0; i < _nonLinearVideoAds.length; i++) {
				if(_nonLinearVideoAds[i].hasActiveDisplayRegion() == false && _nonLinearVideoAds[i].matchesAcceptedAdTypes(acceptedAdTypes)) {
					return i;
				}
			}
			return -1;
		}
		
		public function processStartNonLinearAdEvent(event:VideoAdDisplayEvent, contentPlayhead:String=null):void {
			if(event.customData != null) {
				if(event.customData.adSlot != null) {
					clearActiveDisplayRegions();
					var displayMode:String = event.customData.adSlot.preferredDisplayMode; 
					var matchCount:int = 0;
					for(var x:int=0; x < 2; x++) {
						if(event.customData.adSlot.hasRegions(displayMode)) {
							for(var fi:int=0; (fi < event.customData.adSlot.regions[displayMode].length) && (AdSlot(event.customData.adSlot).hasLimitedDisplayCount() == false || (AdSlot(event.customData.adSlot).hasLimitedDisplayCount() && (matchCount < AdSlot(event.customData.adSlot).maxDisplayCount))); fi++) {
								// loop through the declared regions and for those that are enabled, process them
								if(event.customData.adSlot.regions[displayMode][fi].enable) {
									var matched:Boolean = false;
									var i:int = 0;
									if(event.customData.adSlot.regions[displayMode][fi].hasSize()) {
										CONFIG::debugging { doLog("Searching for a non-linear ad that matches " + displayMode.toUpperCase() + " region at index " + fi + " - size is " + event.customData.adSlot.regions[displayMode][fi].width + "x" + event.customData.adSlot.regions[displayMode][fi].height, Debuggable.DEBUG_DISPLAY_EVENTS); }
										for(i = 0; i < _nonLinearVideoAds.length && !matched; i++) {
											if(_nonLinearVideoAds[i].hasActiveDisplayRegion() == false) {
												if(_nonLinearVideoAds[i].matchesSizeAndAcceptedAdTypes(event.customData.adSlot.regions[displayMode][fi].width, event.customData.adSlot.regions[displayMode][fi].height, event.customData.adSlot.regions[displayMode][fi].acceptedAdTypes)) {
													matched = true;
													matchCount++;
													CONFIG::debugging { doLog("Non-linear ad at index " + i + " of type " + _nonLinearVideoAds[i].contentType() + " matches based on size - triggering display", Debuggable.DEBUG_DISPLAY_EVENTS); }
													_nonLinearVideoAds[i].start(event, event.customData.adSlot.regions[displayMode][fi]);
											        triggerImpressionConfirmations();
												}
											}
										}
										if(!matched) {
											var freeNonLinearAdIndex:int = hasNonLinearAdsAvailableForDisplay(event.customData.adSlot.regions[displayMode][fi].acceptedAdTypes);
											if(freeNonLinearAdIndex > -1 && event.customData.adSlot.regions[displayMode][fi].alwaysMatch) {
												// although we don't have a match, ensure we always do - so take the first ad in the list
												CONFIG::debugging { doLog("Although we couldn't get a direct match, forcing match to index 0 because 'alwaysMatch' is true - type is " + _nonLinearVideoAds[freeNonLinearAdIndex].contentType() + ", size is " + _nonLinearVideoAds[lowestScoredIndex].width + "x" + _nonLinearVideoAds[lowestScoredIndex].height, Debuggable.DEBUG_DISPLAY_EVENTS); }
												matchCount++;
												_nonLinearVideoAds[freeNonLinearAdIndex].start(event, event.customData.adSlot.regions[displayMode][fi]);
										        triggerImpressionConfirmations();
											}
											else {
												CONFIG::debugging { doLog("Cannot find a non-linear ad that matches the " + displayMode + " region sized " + event.customData.adSlot.regions[displayMode][fi].width + "x" + event.customData.adSlot.regions[displayMode][fi].height, Debuggable.DEBUG_DISPLAY_EVENTS); }
											}
										}
									}
									else {
										CONFIG::debugging { doLog("Searching for a non-linear ad that matches " + displayMode.toUpperCase() + " region at index " + fi + " - no size declared - OVA estimating best size", Debuggable.DEBUG_DISPLAY_EVENTS); }
										var score:int = 0;
										var lowestScore:int = -1;
										var lowestScoredIndex:int = -1;
										for(i = 0; i < _nonLinearVideoAds.length; i++) {
											if(_nonLinearVideoAds[i].hasActiveDisplayRegion() == false) {
												score = _nonLinearVideoAds[i].deriveScoreBasedOnEstimatedSizeAndAcceptedAdTypes(event.controller.playerWidth, event.controller.playerHeight, event.customData.adSlot.regions[displayMode][fi].acceptedAdTypes);
												if(score < 0) {
													// Outside of the player dimensions and not scalable, so ignore
												}
												else if(score == 0) {
													// exact match based on size or it is scalable
													CONFIG::debugging { doLog("Non-linear ad at index " + i + " of type " + _nonLinearVideoAds[i].contentType() + " matches based on estimated size - exact width match", Debuggable.DEBUG_DISPLAY_EVENTS);	}											
													lowestScoredIndex = i;
													break;
												}
												else {
													// different size than player, so rank based on size difference
													if((lowestScoredIndex == -1) || (score < lowestScore)) {
														lowestScore = score;
														lowestScoredIndex = i;
													}
												}
											}
										}
										if(_nonLinearVideoAds.length > 0 && lowestScoredIndex == -1 && event.customData.adSlot.regions[displayMode][fi].alwaysMatch) {
											// although we don't have a match, ensure we always do - so take the first available ad in the list
											lowestScoredIndex = hasNonLinearAdsAvailableForDisplay(event.customData.adSlot.regions[displayMode][fi].acceptedAdTypes);
											CONFIG::debugging { doLog("Although we couldn't get a direct match, trying to force match because 'alwaysMatch' is true", Debuggable.DEBUG_DISPLAY_EVENTS); }
										}
										if(lowestScoredIndex > -1) {
											CONFIG::debugging { doLog("Best estimated match is non-linear at index " + lowestScoredIndex + " - size is " + _nonLinearVideoAds[lowestScoredIndex].width + "x" + _nonLinearVideoAds[lowestScoredIndex].height, Debuggable.DEBUG_DISPLAY_EVENTS); }
											matchCount++;
											_nonLinearVideoAds[lowestScoredIndex].start(event, event.customData.adSlot.regions[displayMode][fi]);
									        triggerImpressionConfirmations();
										}
										else {
											CONFIG::debugging { doLog("OVA unable to find a matching non-linear ad using estimation rules", Debuggable.DEBUG_DISPLAY_EVENTS); }
										}
									}
								}
							}
						}
						displayMode = (displayMode == "flash") ? "html5" : "flash";
					}
				}
				return ;
			}
		}
		
		public function processStopNonLinearAdEvent(event:VideoAdDisplayEvent, contentPlayhead:String=null):void { 
			for(var i:int = 0; i < _nonLinearVideoAds.length; i++) {
				if(_nonLinearVideoAds[i].hasActiveDisplayRegion()) {
					_nonLinearVideoAds[i].stop(event);
				}
			}
		}
		
		public function processStartCompanionAdEvent(displayEvent:VideoAdDisplayEvent, contentPlayhead:String=null):void {
			if(displayEvent.controller.displayingCompanions()) {
				for(var i:int = 0; i < _companionAds.length; i++) {
					_companionAds[i].start(displayEvent); 
				}
			}
			else {
				CONFIG::debugging { doLog("Ignoring request to start a companion - no companions are configured on this page", Debuggable.DEBUG_CUEPOINT_EVENTS); }
			}
		}
		
		public function processStopCompanionAdEvent(displayEvent:VideoAdDisplayEvent, contentPlayhead:String=null):void {
			if(displayEvent.controller.displayingCompanions()) {
				for(var i:int = 0; i < _companionAds.length; i++) {
					_companionAds[i].stop(displayEvent);
				}
			}
			else {
				CONFIG::debugging { doLog("Ignoring request to stop a companion - no companions are configured on this page", Debuggable.DEBUG_CUEPOINT_EVENTS); }
			}
		}
		
		public function split():Array {
			var result:Array = new Array();
			if(hasLinearAd() && hasNonLinearAds()) {
				// copy across the non-linear video ads to a separate ad
				var nlVideoAds:VideoAd = new VideoAd();
				nlVideoAds.inlineAdId = _inlineAdId;
				nlVideoAds.adId = _adId;
				nlVideoAds.sequenceId = _sequenceId;
				nlVideoAds.creativeId = _creativeId;
				nlVideoAds.adSystem = _adSystem;
				nlVideoAds.adTitle = _adTitle;
				nlVideoAds.description = _description;
				nlVideoAds.survey = _survey;
				nlVideoAds.errorUrls = _errorUrls;
				nlVideoAds.impressions = _impressions;
				nlVideoAds.trackingEvents = _trackingEvents;
				nlVideoAds.companionAds = _companionAds;
				nlVideoAds.extensions = _extensions;
				CONFIG::callbacks {
					nlVideoAds.setCanFireAPICalls(_canFireAPICalls);
					nlVideoAds.setCanFireEventAPICalls(_canFireEventAPICalls);
				}
				nlVideoAds.nonLinearVideoAds = _nonLinearVideoAds;
				
				// now clear out the non-linears from this ad
				this.nonLinearVideoAds = new Array();
				
				// finally, put the two separate ads into the result array
				result.push(this);
				result.push(nlVideoAds);
			}	
			else result.push(this);
			return result;
		}

		public function linearAdToJSObject():Object {
			if(hasLinearAd()) {
				return _linearVideoAd.toJSObject();
			}
			return "";
		}
		
		public function nonLinearAdsToJSObjects():Array {
			var result:Array = new Array();
			if(hasNonLinearAds()) {
				for(var i:int=0; i < _nonLinearVideoAds.length; i++) {
					result.push(_nonLinearVideoAds[i].toJSObject());
				}
			}
			return result;
		}

		public function companionAdsToJSObjects():Array {
			var result:Array = new Array();
			if(hasCompanionAds()) {
				for(var i:int=0; i < _companionAds.length; i++) {
					result.push(_companionAds[i].toJSObject());
				}
			}
			return result;
		}
		
		public override function toJSObject():Object {
			var o:Object = new Object();
			o = {
				id: _id,
				uid: _uid,
				adId: _adId,
				inlineAdId: _inlineAdId,
				type: this.adType,
				adSystem: _adSystem,
				adTitle: _adTitle,
				description: _description,
				survey: _survey,
				impressions: ArrayUtils.convertToJSObjectArray(_impressions),
				trackingEvents: ArrayUtils.convertToJSObjectArray(_trackingEvents),
				linearAd: linearAdToJSObject(),
				nonLinearAds: nonLinearAdsToJSObjects(),
				companionAds: companionAdsToJSObjects(),
				sequenceId: _sequenceId,
				creativeId: _creativeId,
				extensions: _extensions 
			};
			return o;
		}
	}
}