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
	import flash.external.ExternalInterface;
	
	import org.openvideoads.base.Debuggable;
	import org.openvideoads.util.ArrayUtils;
	import org.openvideoads.util.NetworkResource;
	import org.openvideoads.util.StringUtils;
	import org.openvideoads.util.Timestamp;

	/**
	 * @author Paul Schulz
	 */
	public class TrackedVideoAd extends Debuggable {
		protected var _id:String;
		protected var _adID:String;
		protected var _trackingEvents:Array = new Array();				
		protected var _clickThroughs:Array = new Array();
		protected var _clickTracking:Array = new Array();
		protected var _extendedClickTracking:Array = new Array();
		protected var _customClicks:Array = new Array();
		protected var _parentAdContainer:VideoAd = null;
		protected var _scale:Boolean = false;
		protected var _maintainAspectRatio:Boolean = false;
		protected var _recommendedMinDuration:int = -1;
		protected var _index:int = -1;
		protected var _isVAST2:Boolean = false;
		CONFIG::callbacks {
			protected var _canFireAPICalls:Boolean = true;
			protected var _canFireEventAPICalls:Boolean = false;
			protected var _useV2APICalls:Boolean = false;
			protected var _jsCallbackScopingPrefix:String = "";
		}
		
		public function TrackedVideoAd() {
			super();
			CONFIG::debugging { doLog("Instantiated: UID is " + _uid, Debuggable.DEBUG_VAST_TEMPLATE); }
		}

		public function unload():void {
			if(hasClickTracking()) {
				for(var i:int=0; i < _clickTracking.length; i++) {
					NetworkResource(_clickTracking[i]).close();
				}
			}
			if(hasCustomClickTracking()) {
				for(var j:int=0; j < _customClicks.length; j++) {
					NetworkResource(_customClicks[j]).close();
				}
			}
			if(hasExtendedClickTracking()) {
				for(var h:int=0; h < _extendedClickTracking.length; h++) {
					NetworkResource(_extendedClickTracking[h]).close();
				}				
			}
		}
		
		public function set id(id:String):void {
			_id = id;
		}
		
		public function get id():String {
			return _id;
		}

		public function set uid(guid:String):void {
			_uid = uid;
		}
		
		public function set adID(adID:String):void {
			_adID = adID;
		}
		
		public function get adID():String {
			return _adID;
		}
		
		public function get index():int {
			return _index;
		}
		
		public function set index(index:int):void {
			_index = index;
		}

		public function set isVAST2(isVAST2:Boolean):void {
			_isVAST2 = isVAST2;
		}
		
		public function get isVAST2():Boolean {
			return _isVAST2;
		}		

		CONFIG::callbacks
		public function set canFireAPICalls(canFireAPICalls:Boolean):void {
			_canFireAPICalls = canFireAPICalls;
		}

		CONFIG::callbacks
		public function get canFireAPICalls():Boolean {
			return _canFireAPICalls;
		}
		
		CONFIG::callbacks
		public function set canFireEventAPICalls(canFireEventAPICalls:Boolean):void {
			_canFireEventAPICalls = canFireEventAPICalls;
		}

		CONFIG::callbacks
		public function get canFireEventAPICalls():Boolean {
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


		public function set scale(scale:*):void {
			_scale = StringUtils.validateAsBoolean(scale);
		}
		
		public function get scale():Boolean {
			return _scale;
		}
		
		public function set maintainAspectRatio(maintainAspectRatio:*):void {
			_maintainAspectRatio = StringUtils.validateAsBoolean(maintainAspectRatio);
		}
		
		public function get maintainAspectRatio():Boolean {
			return _maintainAspectRatio;
		}

		public function get duration():String {
			// the duration must be returned as a HH:MM:SS string
			return Timestamp.secondsToTimestamp(_recommendedMinDuration);
		}

		public function getDurationAsInt():int {
			return Timestamp.timestampToSeconds(duration);
		}
		
		public function get recommendedMinDuration():int {
			return _recommendedMinDuration;
		}
		
		public function set recommendedMinDuration(recommendedMinDuration:*):void {
			if(typeof recommendedMinDuration == 'string') {
				_recommendedMinDuration = parseInt(recommendedMinDuration);
			}
			else _recommendedMinDuration = recommendedMinDuration;
		}

		public function hasRecommendedMinDuration():Boolean {
			return _recommendedMinDuration > -1;
		}

		public function set parentAdContainer(parentAdContainer:VideoAd):void {
			_parentAdContainer = parentAdContainer;
		}
		
		public function get parentAdContainer():VideoAd {
			return _parentAdContainer;
		}

		public function set trackingEvents(trackingEvents:Array):void {
			_trackingEvents = trackingEvents;
		}
		
		public function get trackingEvents():Array {
			return _trackingEvents;
		}
		
		public function hasTrackingEvents():Boolean {
			return (_trackingEvents.length > 0);
		}
		
		public function addTrackingEvent(trackEvent:TrackingEvent):void {
			_trackingEvents.push(trackEvent);
		}

		public function addTrackingEventItems(newTrackingEvents:Array):void {
			_trackingEvents = _trackingEvents.concat(newTrackingEvents);
		}

		protected function getAssetURI():String {
			return null;
		}
		
		public function triggerTrackingEvent(eventType:String, contentPlayhead:String=null):void {
			if(_trackingEvents != null && eventType != null) {
				for(var i:int = 0; i < _trackingEvents.length; i++) {
					var trackingEvent:TrackingEvent = _trackingEvents[i];
					if(trackingEvent.eventType != null) {
						if(trackingEvent.eventType.toUpperCase() == eventType.toUpperCase()) {
							trackingEvent.execute(getAssetURI(), contentPlayhead);
							CONFIG::callbacks {
								fireEventAPICall("onTrackingEvent", trackingEvent.toJSObject());
							}
						}									
					}
				}				
			}
		}
		
		public function getTrackingEventList():Array {
			var result:Array = new Array();
			if(hasTrackingEvents()) {
				for(var i:int=0; i < _trackingEvents.length; i++) {
					result.push(
						{ 
							type: _trackingEvents[i].eventType,
							urls: _trackingEvents[i].getURLList()
						}
					);
				}
			}
			return result;
		}
			
		public function addClickThroughs(clickThroughs:Array):void {
			if(_clickThroughs != null) {
				_clickThroughs.concat(clickThroughs);
			}	
			else _clickThroughs = clickThroughs;
		}
		
		public function set clickThroughs(clickThroughs:Array):void {
			_clickThroughs = clickThroughs;
		}
		
		public function get clickThroughs():Array {
			return _clickThroughs;
		}
		
		public function clickThroughCount():int {
			return _clickThroughs.length;
		}
		
		public function getClickThroughURLString():String {
			if(hasClickThroughs()) {
				return _clickThroughs[0].qualifiedUrl;
			}	
			return null;
		}
		
		public function getClickThroughURLArray():Array {
			var result:Array = new Array();
			if(hasClickThroughs()) {
				for(var i:int=0; i < _clickThroughs.length; i++) {
					result.push(_clickThroughs[i].qualifiedHTTPUrl);
				}
			}
			return result;
		}
		
		public function addClickThrough(clickThrough:NetworkResource):void {
			_clickThroughs.push(clickThrough);
		}
		
		public function hasClickThroughs():Boolean {
			return (_clickThroughs.length > 0);
		}
		
		public function firstClickThrough():String {
			if(hasClickThroughs()) {
				return _clickThroughs[0].qualifiedHTTPUrl;
			}	
			else return null;
		}

		public function hasClickTracking():Boolean {
			return (_clickTracking.length > 0);	
		}
		
		public function set clickTracking(clickTracking:Array):void {
			_clickTracking = clickTracking;
		}
		
		public function get clickTracking():Array {
			return _clickTracking;
		}

		public function clickTrackingCount():int {
			return _clickTracking.length;
		}
		
		public function addClickTrack(clickURL:NetworkResource):void {
			_clickTracking.push(clickURL);
		}

		public function fireClickTracking():void {
			if(hasClickTracking()) {	
				for(var i:int = 0; i < _clickTracking.length; i++) {
					_clickTracking[i].call();
					CONFIG::callbacks {
						fireEventAPICall("onClickTrackingEvent", _clickTracking[i].toJSObject());
					}
				}
			}
		}
		
        public function addClickTrackingItems(clickList:Array):void {
        	if(clickList != null) {
	        	_clickTracking = _clickTracking.concat(clickList);  
        	}
        }

		public function set customClicks(customClicks:Array):void {
			_customClicks = customClicks;
		}
		
		public function get customClicks():Array {
			return _customClicks;
		}
		
		public function customClickCount():int {
			return _customClicks.length;
		}		
		
		public function addCustomClick(customClick:NetworkResource):void {
			_customClicks.push(customClick);
		}

        public function addCustomClickTrackingItems(clickList:Array):void {
        	if(clickList != null) {
	        	_customClicks = _customClicks.concat(clickList);        		
        	}
        }

		public function hasCustomClickTracking():Boolean {
			return (_customClicks.length > 0);	
		}

		public function fireCustomClickTracking():void {
			if(hasCustomClickTracking()) {	
				for(var i:int = 0; i < _customClicks.length; i++) {
					_customClicks[i].call();
					CONFIG::callbacks {
						fireEventAPICall("onCustomClickTrackingEvent", _customClicks[i].toJSObject());
					}
				}
			}
		}
				
		public function hasClickThroughURL():Boolean {
			return (_clickThroughs.length > 0);
		}

		public function hasExtendedClickTracking():Boolean {
			if(_extendedClickTracking != null) {
				return (_extendedClickTracking.length > 0);				
			}
			return false;
		}

		CONFIG::callbacks
		protected function fireEventAPICall(... args):* {
			if (ExternalInterface.available && canFireEventAPICalls) {
				try {
					if(_useV2APICalls) {
						// These are the new V2 API callbacks
						CONFIG::debugging { doLog("Firing V2 API call " + args[0] + "()", Debuggable.DEBUG_JAVASCRIPT); }
						ExternalInterface.call(_jsCallbackScopingPrefix + "onOVAEventCallback", args);
					}
					else {
						// These are the old V1 API callbacks
						CONFIG::debugging { doLog("Firing API call " + args[0] + "()", Debuggable.DEBUG_JAVASCRIPT); }
						try {					
							return ExternalInterface.call(args[0],args[1]);
						}
						catch(e:Error) {
							CONFIG::debugging { doLog("Exception making external call (" + args[0] + ") - " + e); }				
						}
					}
				}
				catch(e:Error) {
					CONFIG::debugging { doLog("Exception making external call (" + args[0] + ") - " + e); }
				}				
			}
		}
				
		public function clone(subClone:*=null):* {
			var clone:TrackedVideoAd;
			if(subClone == null) {
				clone = new TrackedVideoAd();
			}
			else clone = subClone;
			clone.id = _id;
			clone.uid = _uid;
			clone.adID = _adID;
			clone.parentAdContainer = _parentAdContainer;
			clone.scale = _scale;
			clone.maintainAspectRatio = _maintainAspectRatio;
			clone.recommendedMinDuration = _recommendedMinDuration;
			clone.index = _index;
			clone.isVAST2 = _isVAST2;
			for each(var trackingEvent:TrackingEvent in _trackingEvents) {
				clone.addTrackingEvent(trackingEvent.clone());
			}
			for each(var clickThrough:NetworkResource in _clickThroughs) {
				clone.addClickThrough(clickThrough.clone());
			}
			for each(var clickTracking:NetworkResource in _clickTracking) {
				clone.addClickTrack(clickTracking.clone());
			}
			for each(var customClick:NetworkResource in _customClicks) {
				clone.addCustomClick(customClick.clone());
			}
			return clone;
		}

		public override function toJSObject():Object {
			var o:Object = new Object();
			o = {
				adId: _adID,
				id: _id,
				uid: _uid,
				trackingEvents: ArrayUtils.convertToJSObjectArray(_trackingEvents),
				clickThroughs: ArrayUtils.convertToJSObjectArray(_clickThroughs),
				clickTracking: ArrayUtils.convertToJSObjectArray(_clickTracking),
				customClicks: ArrayUtils.convertToJSObjectArray(_customClicks),
				scale: _scale,
				maintainAspectRatio: _maintainAspectRatio,
				recommendedMinDuration: _recommendedMinDuration,
				index: _index,
				isVAST2: _isVAST2
			};
			return o;
		}	
	}
}