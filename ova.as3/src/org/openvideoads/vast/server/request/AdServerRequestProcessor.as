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
 */    
package org.openvideoads.vast.server.request {
	import flash.events.Event;
	import flash.utils.Dictionary;
	
	import org.openvideoads.base.Debuggable;
	import org.openvideoads.vast.analytics.AnalyticsProcessor;
	import org.openvideoads.vast.model.VideoAdServingTemplate;
	import org.openvideoads.vast.schedule.ads.AdSlot;
	import org.openvideoads.vast.server.config.AdServerConfig;
	import org.openvideoads.vast.server.events.TemplateEvent;
	import org.openvideoads.vast.server.response.AdServerTemplate;
	import org.openvideoads.vast.server.response.TemplateLoadListener;
	
	/**
	 * @author Paul Schulz
	 */
	public class AdServerRequestProcessor extends Debuggable implements TemplateLoadListener {
		protected var _templateLoadListener:TemplateLoadListener = null;
		protected var _groups:Dictionary = new Dictionary();
		protected var _groupKeys:Array = new Array();
		protected var _vastResponses:Array = null;
		protected var _activeAdServerRequests:Array = null;
		protected var _activeAdServerRequestGroupsIndex:int = 0;
		protected var _activeAdServerRequestIndex:int = 0;
		protected var _lastAdServerRequest:AdServerRequest = null;
		protected var _templates:Array = new Array();
		protected var _activeTemplate:AdServerTemplate = null;
		protected var _finalTemplate:AdServerTemplate = new VideoAdServingTemplate();
		protected var _loadSuccessRecorded:Boolean = false;
		protected var _loadErrorRecorded:Boolean = false;
		protected var _loadTimeoutRecorded:Boolean = false
		protected var _lastTimeoutEvent:Event = null;
		protected var _lastErrorEvent:Event = null;
		protected var _callingOnDemand:Boolean = false;
		
		public function AdServerRequestProcessor(templateLoadListener:TemplateLoadListener, adSlots:Array, alwaysLoad:Boolean=false, callingOnDemand:Boolean=false) {
			super();
			_templateLoadListener = templateLoadListener;
			_callingOnDemand = callingOnDemand;
			CONFIG::debugging { doLog("Creating ad server request groups across " + adSlots.length + " ad slots", Debuggable.DEBUG_CONFIG); }
			for(var i:int = 0; i < adSlots.length; i++) {
				if(alwaysLoad == false && AdSlot(adSlots[i]).loadOnDemand) {
					CONFIG::debugging { doLog("Ignoring ad request in ad slot " + i + " - slot to be loaded on demand", Debuggable.DEBUG_CONFIG); }
				}
				else {
					if(adSlots[i].hasAdServerConfigured()) {
						var adServerTypeKey:String = AdServerConfig(adSlots[i].adServerConfig).typeKey(); 
						if(_groups[adServerTypeKey] == null) {
							_groups[adServerTypeKey] = new AdServerRequestGroup(adSlots[i].adServerConfig.serverType, adSlots[i].adServerConfig.oneAdPerRequest);
							_groupKeys.push(adServerTypeKey);
						}
						CONFIG::debugging { doLog("AdSlot[" + i + "] has been added to '" + adServerTypeKey + "' group", Debuggable.DEBUG_CONFIG); }
						_groups[adServerTypeKey].addAdSlot(adSlots[i]);					
					}
					else {
						CONFIG::debugging { doLog("Not configuring ad request for slot " + i + " - no ad server configuration provided", Debuggable.DEBUG_CONFIG); }
					}
				}
			}
			CONFIG::debugging { doLog("Have configured " + _groupKeys.length + " ad server request groups", Debuggable.DEBUG_CONFIG); }
		}

		public function unload():void {
        	for(var i:int=0; i < _templates.length; i++) {
        		_templates[i].unload();
        	}			
        	if(_finalTemplate != null) {
        		_finalTemplate.unload();
        	}
		}

		CONFIG::callbacks
		public function canFireAPICalls():Boolean {
			if(_templateLoadListener != null) {
				return _templateLoadListener.canFireAPICalls();				
			}
			return false;
		}

		CONFIG::callbacks
		public function canFireEventAPICalls():Boolean {
			if(_templateLoadListener != null) {
				return _templateLoadListener.canFireEventAPICalls();				
			}
			return false;
		}

		CONFIG::callbacks
		public function get useV2APICalls():Boolean {
			if(_templateLoadListener != null) {
				return _templateLoadListener.useV2APICalls;				
			}
			return false;
		}

		CONFIG::callbacks
		public function get jsCallbackScopingPrefix():String {
			if(_templateLoadListener != null) {
				return _templateLoadListener.jsCallbackScopingPrefix;				
			}
			return "";
		}

		public function get analyticsProcessor():AnalyticsProcessor {
			if(_templateLoadListener != null) {
				return _templateLoadListener.analyticsProcessor;				
			}
			return null;
		}

		protected function resetLoadStatusValues():void {
			_loadSuccessRecorded = false;
			_loadErrorRecorded = false;
			_loadTimeoutRecorded = false
			_lastTimeoutEvent = null;
			_lastErrorEvent = null;
		}
		
        public function start():void {
        	resetLoadStatusValues();
        	_templates = new Array();
 			if(_groupKeys.length > 0) {
				startProcessingAdServerRequestGroup(0);
			}
			else {
				CONFIG::debugging { doLog("No ad requests to process - 0 ad server groupings found", Debuggable.DEBUG_VAST_TEMPLATE); }
				postProcessRequestsAndNotifyListener();
			}       	
        }
        
        public function restartOnFailover():Boolean {
        	if(_activeTemplate != null) {
        		if(_activeTemplate.hasFailoverCallsAvailable()) {
        			unload();
        			_activeTemplate.clearAds();
	        		_activeTemplate.attempFailoverAdServerCall();
	        		_finalTemplate = new VideoAdServingTemplate();
	        		_templates = new Array();
	        		return true;
        		}
        		else {
					CONFIG::debugging { doLog("Not failing over - we've run out of ad requests", Debuggable.DEBUG_VAST_TEMPLATE); }
        		}
        	}
        	return false;
        }
        
        public function get lastAdServerRequest():AdServerRequest {
        	return _lastAdServerRequest;
        }

		public function getLastProcessedAdTagIndex():int {
			if(lastAdServerRequest != null) {
				return lastAdServerRequest.failoverRequestCount;
			}
			return 0;
		}
        
        protected function setActiveTemplate(adServerRequest:AdServerRequest):void {
        	adServerRequest.callOnDemand = _callingOnDemand;
			_activeTemplate = adServerRequest.createMasterAdServerTemplate(this);         	
        	_lastAdServerRequest = adServerRequest;
        }
        
        protected function startProcessingAdServerRequestGroup(groupIndex:int=0):void {
        	CONFIG::debugging { doLog("Triggering ad server requests for group '" + _groupKeys[groupIndex] + "' (" + groupIndex + ")", Debuggable.DEBUG_VAST_TEMPLATE); }
			_activeAdServerRequestGroupsIndex = groupIndex;
			if(_groups[_groupKeys[groupIndex]].oneAdPerRequest) {
				CONFIG::debugging { doLog("One ad per request required by ad server in group '" + _groupKeys[groupIndex] + "' (" + groupIndex + ")", Debuggable.DEBUG_VAST_TEMPLATE); }
				_activeAdServerRequests = _groups[_groupKeys[groupIndex]].getAdServerRequests();
				_activeAdServerRequestIndex = 0;
				setActiveTemplate(_activeAdServerRequests[_activeAdServerRequestIndex]); 
			}
			else {
				CONFIG::debugging { doLog("Multiple ads per request permitted by ad server in group '" + _groupKeys[groupIndex] + "' (" + groupIndex + ")", Debuggable.DEBUG_VAST_TEMPLATE); }
				_activeAdServerRequests = null;
				if(_groups[_groupKeys[groupIndex]].getSingleAdServerRequest() != null) {
					setActiveTemplate(_groups[_groupKeys[groupIndex]].getSingleAdServerRequest()); 
				}
				else moveOntoNextAdServerRequestGroup();
			}        	
        }
        
        protected function moveOntoNextAdServerRequestGroup():void {
			// we were processing that group as a single request which is now done, so move onto the next group
			if(_activeAdServerRequestGroupsIndex+1 < _groupKeys.length) {
	       		CONFIG::debugging { doLog("Moving onto the next ad server request group at index " + _activeAdServerRequestGroupsIndex+1, Debuggable.DEBUG_VAST_TEMPLATE); }
				startProcessingAdServerRequestGroup(_activeAdServerRequestGroupsIndex+1);
			}
			else {
	       		CONFIG::debugging { doLog("All ad server request groups have been processed - kicking off the post-request process", Debuggable.DEBUG_VAST_TEMPLATE); }
				postProcessRequestsAndNotifyListener();
			}        	
        }
        
        protected function processNextAdServerRequestInActiveAdServerRequestGroup():void {
        	if(_activeAdServerRequestIndex+1 < _activeAdServerRequests.length) {
        		_activeAdServerRequestIndex++;
				CONFIG::debugging { doLog("Triggering next ad server request (" + (_activeAdServerRequestIndex+1) + " of " + _activeAdServerRequests.length + ")", Debuggable.DEBUG_VAST_TEMPLATE); }
        		var adServerRequest:AdServerRequest = _activeAdServerRequests[_activeAdServerRequestIndex];
				_activeTemplate = adServerRequest.createMasterAdServerTemplate(this); 
        	}
        	else {
        		moveOntoNextAdServerRequestGroup();
        	}
        }
        
        protected function postProcessRequestsAndNotifyListener():void {
        	// merge any retrieved templates together before notifying the listener with the result
        	CONFIG::debugging { doLog("Merging " + _templates.length + " VAST responses back into 1 master VAST template:" + _finalTemplate.uid, Debuggable.DEBUG_VAST_TEMPLATE); }
        	for(var i:int=0; i < _templates.length; i++) {
        		_finalTemplate.merge(_templates[i]);
        		_finalTemplate.addEmptyErrorAds(_templates[i].getEmptyVideoAdsWithErrorUrls());
        	}
        	CONFIG::debugging { doLog("Merge complete - " + _finalTemplate.ads.length + " ads, " + _finalTemplate.getEmptyVideoAdsWithErrorUrls().length + " empty error ads recorded in the master VAST template:" + _finalTemplate.uid, Debuggable.DEBUG_VAST_TEMPLATE); }
        	_finalTemplate.dataLoaded = true;
        
        	if(_templateLoadListener != null) {
        		if(_loadErrorRecorded && !_loadSuccessRecorded) {
	        		_templateLoadListener.onTemplateLoadError(new TemplateEvent(TemplateEvent.LOAD_FAILED, (_lastErrorEvent != null) ? _lastErrorEvent.toString() : null));
        		}
	        	else if(_loadTimeoutRecorded && !_loadSuccessRecorded) {
	        		_templateLoadListener.onTemplateLoadTimeout(new TemplateEvent(TemplateEvent.LOAD_TIMEOUT, (_lastTimeoutEvent != null) ? _lastTimeoutEvent.toString() : null));	        		
	        	}
	        	else _templateLoadListener.onTemplateLoaded(_finalTemplate);
        	}      	
        }
       
        protected function takeNextStep():void {
			if(_activeAdServerRequests != null) {
				// we are processing this ad server request group one ad request at a time
				processNextAdServerRequestInActiveAdServerRequestGroup();
			}
			else moveOntoNextAdServerRequestGroup();
        }
        
		public function onTemplateLoaded(template:AdServerTemplate):void {
			_loadSuccessRecorded = true;
			_templates.push(template);
			takeNextStep();
		}
		
		public function onTemplateLoadError(event:Event):void {
			_loadErrorRecorded = true;
			_lastErrorEvent = event;
			takeNextStep();
		}

		public function onTemplateLoadTimeout(event:Event):void {
			_loadTimeoutRecorded = true;
			_lastTimeoutEvent = event;
			takeNextStep();
		}

		public function onTemplateLoadDeferred(event:Event):void {
			takeNextStep();
		}

		public function onAdCallStarted(request:AdServerRequest):void { 
			if(_templateLoadListener != null) _templateLoadListener.onAdCallStarted(request); 
		}

		public function onAdCallFailover(masterRequest:AdServerRequest, failoverRequest:AdServerRequest):void { 
			if(_templateLoadListener != null) _templateLoadListener.onAdCallFailover(masterRequest, failoverRequest); 
		}
		
		public function onAdCallComplete(request:AdServerRequest, hasAds:Boolean):void { 
			if(_templateLoadListener != null) _templateLoadListener.onAdCallComplete(request, hasAds); 
		}		
	}
}
			

