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
package org.openvideoads.vast.model {
	import flash.events.Event;
	
	import org.openvideoads.base.Debuggable;
	import org.openvideoads.regions.view.FlashMedia;
	import org.openvideoads.util.NetworkResource;
	import org.openvideoads.util.StringUtils;
	import org.openvideoads.vast.analytics.AnalyticsProcessor;
	import org.openvideoads.vast.events.VideoAdDisplayEvent;
	import org.openvideoads.vast.server.config.AdServerConfig;
	import org.openvideoads.vast.server.request.AdServerRequest;
	import org.openvideoads.vast.server.request.wrapped.WrappedAdServerRequest;
	import org.openvideoads.vast.server.response.AdServerTemplate;
	import org.openvideoads.vast.server.response.TemplateLoadListener;
	
	/**
	 * @author Paul Schulz
	 */
	public class WrappedVideoAdV1 extends VideoAd implements TemplateLoadListener {
		protected var _vastAdTag:String = null;
		protected var _template:VideoAdServingTemplate = null;
		protected var _originalAdId:Object = null
		protected var _vastContainer:VideoAdServingTemplate = null;
		protected var _wrappedVideoAd:VideoAd = null;
		protected var _wrapperClickTracking:Array = new Array();
		protected var _wrapperCustomClicks:Array = new Array();
		protected var _masterAdServerConfig:AdServerConfig = null;
		
		public function WrappedVideoAdV1(originalAdId:Object, wrapperXML:XML=null, vastContainer:VideoAdServingTemplate=null, masterAdServerConfig:AdServerConfig=null) {
			super();
			_originalAdId = originalAdId;
			_vastContainer = vastContainer;
			_masterAdServerConfig = masterAdServerConfig;
			CONFIG::debugging { doLog("Created new WrappedVideoAd: " + _uid + ", parent Template: " + ((vastContainer != null) ? vastContainer.uid : "no UID"), Debuggable.DEBUG_VAST_TEMPLATE); }
			if(wrapperXML != null) initialise(wrapperXML);
		}
		
		protected function initialise(wrapperXML:XML):void {
			CONFIG::debugging { 
				doLog("XML response has " + wrapperXML.children().length() + " attributes defined - see trace", Debuggable.DEBUG_VAST_TEMPLATE); 
				doTrace(wrapperXML, Debuggable.DEBUG_VAST_TEMPLATE);
			}
			id = wrapperXML.adId;
			adSystem = wrapperXML.AdSystem;
			if(wrapperXML.VASTAdTagURL.URL != undefined) {
				vastAdTag = wrapperXML.VASTAdTagURL.URL.text();
			}
			if(wrapperXML.Error != null) {
				if(wrapperXML.Error.URL != undefined) {
					addErrorUrl(wrapperXML.Error.URL);
				}
				else {
					addErrorUrl(wrapperXML.Error);
				}
			}
			parseImpressions(wrapperXML);
			parseTrackingEvents(wrapperXML);
			parseVideoClicks(wrapperXML);
			if(hasVASTAdTag()) {
				loadVASTFromWrappedAdServer();
			}
			else {
				CONFIG::debugging { doLog("Not loading the wrapped VAST ad tag as the URL is blank '" + vastAdTag + "'", Debuggable.DEBUG_VAST_TEMPLATE); }
			}
		}

		public override function setPreferredSelectionCriteria(criteria:Object):void {
			_preferredSelectionCriteria = criteria;
			if(_wrappedVideoAd != null) _wrappedVideoAd.setPreferredSelectionCriteria(criteria);
		}

		public function parseVideoClicks(wrapperXML:XML):void {
			if(wrapperXML.VideoClicks != undefined) {
				if(wrapperXML.VideoClicks.ClickTracking != undefined) {
					var clickList:XMLList;
					var clickURL:XML;
					var i:int=0;
					if(wrapperXML.VideoClicks.ClickTracking.children().length() > 0) {
						CONFIG::debugging { doLog("Parsing V1 Wrapper VideoClicks ClickTracking tags...", Debuggable.DEBUG_VAST_TEMPLATE); }
						clickList = wrapperXML.VideoClicks.ClickTracking.children();
						for(i = 0; i < clickList.length(); i++) {
							clickURL = clickList[i];
							if(!StringUtils.isEmpty(clickURL.text())) {
								addClickTrack(new NetworkResource(clickURL.@id, clickURL.text()));
							}
						}
					}					
				}
				if(wrapperXML.VideoClicks.CustomClick != undefined) {
					if(wrapperXML.VideoClicks.CustomClick.children().length() > 0) {
						CONFIG::debugging { doLog("Parsing V1 Wrapper VideoClicks CustomClick tags...", Debuggable.DEBUG_VAST_TEMPLATE); }
						clickList = wrapperXML.CustomClick.ClickTracking.children();
						for(i = 0; i < clickList.length(); i++) {
							clickURL = clickList[i];
							if(!StringUtils.isEmpty(clickURL.text())) {
								addCustomClick(new NetworkResource(clickURL.@id, clickURL.text()));
							}
						}
					}					
				}
			}			
		}

		public function addClickTrack(clickURL:NetworkResource):void {
			_wrapperClickTracking.push(clickURL);
		}

        public override function addClickTrackingItems(clickList:Array):void {
			if(hasReplacementVideoAd()) {
				return _wrappedVideoAd.addClickTrackingItems(clickList);
			}			
        }

		public function addCustomClick(customClick:NetworkResource):void {
			_wrapperCustomClicks.push(customClick);
		}

        public override function addCustomClickTrackingItems(clickList:Array):void {
			if(hasReplacementVideoAd()) {
				return _wrappedVideoAd.addCustomClickTrackingItems(clickList);
			}			
        }

		public override function getImpressionList():Array {
			if(hasReplacementVideoAd()) {
				return _wrappedVideoAd.getImpressionList();
			}
			return new Array();
		}

		CONFIG::callbacks
		public override function canFireAPICalls():Boolean {
			if(_vastContainer != null) {
				return _vastContainer.canFireAPICalls();				
			}
			return false;
		}

		CONFIG::callbacks
		public override function canFireEventAPICalls():Boolean {
			if(_vastContainer != null) {
				return _vastContainer.canFireEventAPICalls();				
			}
			return false;
		}
		
		CONFIG::callbacks
		public override function get useV2APICalls():Boolean {
			if(_vastContainer != null) {
				return _vastContainer.useV2APICalls;				
			}
			return false;
		}

		CONFIG::callbacks
		public override function get jsCallbackScopingPrefix():String {
			if(_vastContainer != null) {
				return _vastContainer.jsCallbackScopingPrefix;				
			}
			return "";
		}

		public function get analyticsProcessor():AnalyticsProcessor {
			if(_vastContainer != null) {
				return _vastContainer.analyticsProcessor;				
			}
			return null;
		}

		public override function set id(id:String):void {
			if(hasReplacementVideoAd()) {
				_wrappedVideoAd.id = id;
			}			
			_id = id;			
		}

		public override function get id():String {
			if(hasReplacementVideoAd()) {
				return _wrappedVideoAd.id;
			}
			if(_originalAdId != null) {
				if(_originalAdId.hasOwnProperty("id")) {
					// deals with the case where an empty ad exists for forced impression firing
					return _originalAdId.id;
				}
			}			
			return _id;
		}
		
		public function set vastAdTag(vastAdTag:String):void {
			_vastAdTag = vastAdTag;
		}
		
		public function get vastAdTag():String {
			return _vastAdTag;
		}
		
		public function hasVASTAdTag():Boolean {
			return (_vastAdTag != null && (StringUtils.isEmpty(_vastAdTag) == false))
		}

		public function loadVASTFromWrappedAdServer():void {
			if(_vastAdTag != null) {
				if(_vastContainer != null) {
					_vastContainer.registerLoader(_uid);
				}
				var adServerRequest:WrappedAdServerRequest = new WrappedAdServerRequest(_vastAdTag, _masterAdServerConfig);
				var adIds:Array = new Array;
				adIds.push(_originalAdId);
				_template = new VideoAdServingTemplate(this, adServerRequest, true, adIds);					
			}
			else {
				CONFIG::debugging { doLog("Request to load ad from wrapped ad server has been ignored - no vastAdTag provided in wrapper XML", Debuggable.DEBUG_VAST_TEMPLATE); }
			}
		}
		
		public function onTemplateLoaded(template:AdServerTemplate):void {
			CONFIG::debugging { doLog(_uid + " has been notified that a template (" + template.uid + ") has loaded. Wrapped Ad is set to the first ad in the returned template", Debuggable.DEBUG_VAST_TEMPLATE); }
			_wrappedVideoAd = _template.getFirstAd();
			if(_wrappedVideoAd != null) {
				_wrappedVideoAd.addClickTrackingItems(_wrapperClickTracking);
				_wrappedVideoAd.addCustomClickTrackingItems(_wrapperCustomClicks);
				CONFIG::callbacks {				
					_wrappedVideoAd.setCanFireEventAPICalls((_vastContainer != null) ? _vastContainer.canFireEventAPICalls() : this.canFireEventAPICalls());
				}
				_wrappedVideoAd.wrapper = this;		
			}
			else {
				CONFIG::debugging { doLog("Cannot record parent clicks - template has not returned an ad", Debuggable.DEBUG_VAST_TEMPLATE); }
			}
			_vastContainer.signalTemplateLoaded(_uid);
		}
		
		public function onTemplateLoadError(event:Event):void {
			CONFIG::debugging { doLog("ERROR obtaining VAST data for original ad " + _originalAdId.id), Debuggable.DEBUG_VAST_TEMPLATE; }
			fireErrorUrls();
			_vastContainer.signalTemplateLoadError(_uid, event);
		}	

		public function onTemplateLoadTimeout(event:Event):void {	
			CONFIG::debugging { doLog("TIMEOUT obtaining VAST data for original ad " + _originalAdId.id), Debuggable.DEBUG_VAST_TEMPLATE; }
			fireErrorUrls();
			_vastContainer.signalTemplateLoadTimeout(uid, event);
		}

		public function onTemplateLoadDeferred(event:Event):void {	
			CONFIG::debugging { doLog("DEFERRED obtaining VAST data for original ad " + _originalAdId.id), Debuggable.DEBUG_VAST_TEMPLATE; }
			_vastContainer.signalTemplateLoadDeferred(uid, event);
		}

		public function onAdCallStarted(request:AdServerRequest):void {
			_vastContainer.onAdCallStarted(request);
		}

		public function onAdCallFailover(masterRequest:AdServerRequest, failoverRequest:AdServerRequest):void {
			_vastContainer.onAdCallFailover(masterRequest, failoverRequest);
		}
		
		public function onAdCallComplete(request:AdServerRequest, hasAds:Boolean):void {
			_vastContainer.onAdCallComplete(request, hasAds);
		}

		public function hasReplacementVideoAd():Boolean {
			return (_wrappedVideoAd != null);
		}		

		public override function setLinearAdDurationFromSeconds(durationAsSeconds:int):void {
			if(hasReplacementVideoAd()) {
				return _wrappedVideoAd.setLinearAdDurationFromSeconds(durationAsSeconds);
			}
			else return super.setLinearAdDurationFromSeconds(durationAsSeconds);			
		}
		
		public override function get duration():int {
			if(hasReplacementVideoAd()) {
				return _wrappedVideoAd.duration;
			}
			else return super.duration;
		}
				
		/*
		public override function get error():String {
			if(hasReplacementVideoAd()) {
				return _wrappedVideoAd.error;
			}
			return super.error;
		}
		*/

		public override function get errorUrls():Array {
			if(hasReplacementVideoAd()) {
				if(hasErrorTracking()) {
					return _errorUrls.concat(_wrappedVideoAd.errorUrls);	
				}
				return _wrappedVideoAd.errorUrls;
			}
			return super.errorUrls;
		}

		public override function get linearVideoAd():LinearVideoAd {
			if(hasReplacementVideoAd()) {
				return _wrappedVideoAd.linearVideoAd;
			}
			else {
				return super.linearVideoAd;
			}
		}

		public override function get nonLinearVideoAds():Array {
			if(hasReplacementVideoAd()) {
				return _wrappedVideoAd.nonLinearVideoAds;
			}
			return super.nonLinearVideoAds;
		}
		
		public override function get firstNonLinearVideoAd():NonLinearVideoAd {
			if(hasReplacementVideoAd()) {
				if(hasNonLinearAds()) {
					return _wrappedVideoAd.firstNonLinearVideoAd;
				}
				return null;
			}
			else return super.firstNonLinearVideoAd;
		}
		
		public override function hasNonLinearAds():Boolean {
			if(hasReplacementVideoAd()) {
				return _wrappedVideoAd.hasNonLinearAds();				
			}
			return super.hasNonLinearAds();
		}
		
		public override function hasLinearAd():Boolean {
			if(hasReplacementVideoAd()) {
				return _wrappedVideoAd.hasLinearAd();			
			}
			return super.hasLinearAd();
		}

		public override function isInteractive():Boolean { 
			if(hasReplacementVideoAd()) {
				return _wrappedVideoAd.isInteractive(); 											
			}
			return super.isInteractive(); 
		}

		public override function canScale():Boolean { 
			if(hasReplacementVideoAd()) {
				return _wrappedVideoAd.canScale(); 				
			}
			return super.canScale(); 	
		}
		
		public override function shouldMaintainAspectRatio():Boolean { 
			if(hasReplacementVideoAd()) {
				return _wrappedVideoAd.shouldMaintainAspectRatio(); 				
			}
			return super.shouldMaintainAspectRatio(); 	
		}
		
		public override function get companionAds():Array {
			if(hasReplacementVideoAd()) {					
				return _wrappedVideoAd.companionAds;
			}
			return super.companionAds;
		}

		public override function hasCompanionAds():Boolean {
			if(hasReplacementVideoAd()) {
				return _wrappedVideoAd.hasCompanionAds();				
			}
			return super.hasCompanionAds();
		}

		public override function isLinear():Boolean {
			if(hasReplacementVideoAd()) {
				return _wrappedVideoAd.isLinear();					
			}
			return super.isLinear();	
		}
		
		public override function isNonLinear():Boolean {
			if(hasReplacementVideoAd()) {
				return _wrappedVideoAd.isNonLinear();				
			}
			return super.isNonLinear();	
		}
		
		public override function getStreamToPlay():AdNetworkResource { 
			if(hasReplacementVideoAd()) {
				return _wrappedVideoAd.getStreamToPlay(); 
			}
			else return super.getStreamToPlay(); 
		}

		public override function getFlashMediaToPlay(preferredWidth:Number, preferredHeight:Number, interactiveOnly:Boolean=false):FlashMedia {
			if(hasReplacementVideoAd()) {
				return _wrappedVideoAd.getFlashMediaToPlay(preferredWidth, preferredHeight, interactiveOnly);
			}
			else return super.getFlashMediaToPlay(preferredWidth, preferredHeight, interactiveOnly);			
		}

		public override function triggerTrackingEvent(eventType:String, id:String=null, contentPlayhead:String=null):void {
			if(hasReplacementVideoAd()) {
				_wrappedVideoAd.triggerTrackingEvent(eventType, contentPlayhead);
			}
			super.triggerTrackingEvent(eventType, id, contentPlayhead);
		}

		public override function triggerForcedImpressionConfirmations(overrideIfAlreadyFired:Boolean=false):void {
			if(hasReplacementVideoAd()) {
				_wrappedVideoAd.triggerForcedImpressionConfirmations(overrideIfAlreadyFired);
			}
			super.triggerForcedImpressionConfirmations();
		}

		public override function processStartAdEvent(contentPlayhead:String=null):void {
			if(hasReplacementVideoAd()) {
				_wrappedVideoAd.processStartAdEvent(contentPlayhead);
			}
			super.processStartAdEvent(contentPlayhead);
		}

		public override function processStopAdEvent(contentPlayhead:String=null):void {
			if(hasReplacementVideoAd()) {
				_wrappedVideoAd.processStopAdEvent(contentPlayhead);
			}
			super.processStopAdEvent(contentPlayhead);
		}
		
		public override function processPauseAdEvent(contentPlayhead:String=null):void {
			if(hasReplacementVideoAd()) {
				_wrappedVideoAd.processPauseAdEvent(contentPlayhead);
			}
			super.processPauseAdEvent(contentPlayhead);
		}

		public override function processResumeAdEvent(contentPlayhead:String=null):void {
			if(hasReplacementVideoAd()) {
				_wrappedVideoAd.processResumeAdEvent(contentPlayhead);
			}
			super.processResumeAdEvent(contentPlayhead);
		}

		public override function processFullScreenAdEvent(contentPlayhead:String=null):void {
			if(hasReplacementVideoAd()) {
				_wrappedVideoAd.processFullScreenAdEvent(contentPlayhead);
			}
			super.processFullScreenAdEvent(contentPlayhead);
		}

		public override function processMuteAdEvent(contentPlayhead:String=null):void {
			if(hasReplacementVideoAd()) {
				_wrappedVideoAd.processMuteAdEvent(contentPlayhead);
			}
			super.processMuteAdEvent(contentPlayhead);
		}

		public override function processUnmuteAdEvent(contentPlayhead:String=null):void {
			if(hasReplacementVideoAd()) {
				_wrappedVideoAd.processUnmuteAdEvent(contentPlayhead);
			}
			super.processUnmuteAdEvent(contentPlayhead);
		}

		public override function processReplayAdEvent(contentPlayhead:String=null):void {
			if(hasReplacementVideoAd()) {
				_wrappedVideoAd.processReplayAdEvent(contentPlayhead);
			}
			super.processReplayAdEvent(contentPlayhead);
		}

		public override function processHitMidpointAdEvent(contentPlayhead:String=null):void {
			if(hasReplacementVideoAd()) {
				_wrappedVideoAd.processHitMidpointAdEvent(contentPlayhead);
			}
			super.processHitMidpointAdEvent(contentPlayhead);
		}

		public override function processFirstQuartileCompleteAdEvent(contentPlayhead:String=null):void {
			if(hasReplacementVideoAd()) {
				_wrappedVideoAd.processFirstQuartileCompleteAdEvent(contentPlayhead);
			}
			super.processFirstQuartileCompleteAdEvent(contentPlayhead);
		}

		public override function processThirdQuartileCompleteAdEvent(contentPlayhead:String=null):void {
			if(hasReplacementVideoAd()) {
				_wrappedVideoAd.processThirdQuartileCompleteAdEvent(contentPlayhead);
			}
			super.processThirdQuartileCompleteAdEvent(contentPlayhead);
		}

		public override function processAdCompleteEvent(contentPlayhead:String=null):void {
			if(hasReplacementVideoAd()) {
				_wrappedVideoAd.processAdCompleteEvent(contentPlayhead);
			}
			super.processAdCompleteEvent(contentPlayhead);
		}
		
		public override function processStartNonLinearAdEvent(event:VideoAdDisplayEvent, contentPlayhead:String=null):void {
			if(hasReplacementVideoAd()) {
				_wrappedVideoAd.processStartNonLinearAdEvent(event, contentPlayhead);
			}
			super.triggerImpressionConfirmations();
		}
		
		public override function processStopNonLinearAdEvent(event:VideoAdDisplayEvent, contentPlayhead:String=null):void { 
			if(hasReplacementVideoAd()) {
				_wrappedVideoAd.processStopNonLinearAdEvent(event, contentPlayhead);
			}
			super.processStopNonLinearAdEvent(event, contentPlayhead);
		}
		
		public override function processStartCompanionAdEvent(displayEvent:VideoAdDisplayEvent, contentPlayhead:String=null):void {
			if(hasReplacementVideoAd()) {
				_wrappedVideoAd.processStartCompanionAdEvent(displayEvent, contentPlayhead);
			}
			super.processStartCompanionAdEvent(displayEvent, contentPlayhead);
		}
		
		public override function processStopCompanionAdEvent(displayEvent:VideoAdDisplayEvent, contentPlayhead:String=null):void {
			if(hasReplacementVideoAd()) {
				_wrappedVideoAd.processStopCompanionAdEvent(displayEvent, contentPlayhead);
			}
			super.processStopCompanionAdEvent(displayEvent, contentPlayhead);
		}	

		public override function toJSObject():Object {
			if(hasReplacementVideoAd()) {
				return _wrappedVideoAd.toJSObject();
			}
			return super.toJSObject();
		}			
	}
}