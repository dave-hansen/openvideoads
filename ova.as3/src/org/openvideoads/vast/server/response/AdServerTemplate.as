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
package org.openvideoads.vast.server.response {
	import flash.events.*;
	import flash.net.URLRequest;
	
	import org.openvideoads.base.Debuggable;
	import org.openvideoads.events.TimedLoaderEvent;
	import org.openvideoads.util.StringUtils;
	import org.openvideoads.util.TimedURLLoader;
	import org.openvideoads.util.TransformingLoader;
	import org.openvideoads.vast.analytics.AnalyticsProcessor;
	import org.openvideoads.vast.model.VideoAd;
	import org.openvideoads.vast.server.config.AdServerConfig;
	import org.openvideoads.vast.server.request.AdServerRequest;
	
	/**
	 * @author Paul Schulz
	 */
	public class AdServerTemplate extends Debuggable {
		protected var _replaceAdIds:Boolean = false;
		protected var _replacementAdIds:Array = null;
		protected var _listener:TemplateLoadListener = null;
		protected var _templateData:String = "";
		protected var _ads:Array = new Array();
		protected var _emptyErrorAds:Array = new Array();
		protected var _dataLoaded:Boolean = false;
		protected var _xmlLoader:TransformingLoader = null;
		protected var _registeredLoaders:Array = new Array();
		protected var _masterAdRequest:AdServerRequest = null;
		protected var _isMaster:Boolean = false;
		protected var _activeRequest:AdServerRequest = null;
		protected var _forceImpressionServing:Boolean = false;
		protected var _lastParseErrorCode:String = null;

		public function AdServerTemplate(listener:TemplateLoadListener=null, request:AdServerRequest=null, replaceAdIds:Boolean=false, adIds:Array=null) {
			super();
			_replaceAdIds = replaceAdIds; 
			_replacementAdIds = adIds;
			CONFIG::debugging { doLog("Template instantiated (" + ((request == null) ? "no ad tag" : request.formRequest()) + ") UID = " + _uid + ", replaceAdIds is " + _replaceAdIds + ", listeners is " + ((listener != null) ? listener.uid : "NO UID"), Debuggable.DEBUG_VAST_TEMPLATE); }
			if(listener != null) _listener = listener;
			if(request != null) load(request);
		}

		public function load(request:AdServerRequest, retry:Boolean=false):void {
		}
		
		public function unload():void {
			CONFIG::debugging { doLog("Request received to unload template " + _uid, Debuggable.DEBUG_VAST_TEMPLATE); }
			if(_xmlLoader != null) {
				CONFIG::debugging { doLog("Closing the active VAST URLLoader in template " + _uid, Debuggable.DEBUG_VAST_TEMPLATE); }
				_xmlLoader.close();
			}
		}

		public function clearAds():void {
			CONFIG::debugging { doLog("Clearing out the ads that are held in the template " + _uid, Debuggable.DEBUG_VAST_TEMPLATE); }
			_ads = new Array();
		}
		
		public function set isMaster(isMaster:Boolean):void {
			_isMaster = isMaster;
		}
		
		public function get isMaster():Boolean {
			return _isMaster;
		}
		
		public function set masterAdRequest(adRequest:AdServerRequest):void {
			_masterAdRequest = adRequest;
			if(_masterAdRequest != null) {
				_forceImpressionServing = _masterAdRequest.forceImpressionServing();
			}
		}
		
		public function get masterAdRequest():AdServerRequest {
			return _masterAdRequest;
		}

		protected function getAdServerConfig():AdServerConfig {
			if(_masterAdRequest != null) {
				return _masterAdRequest.config;
			}
			return null;
		}

		protected function isAcceptableLinearAdMediaFileMimeType(mimeType:String):Boolean {
			if(_masterAdRequest != null) {
				if(_masterAdRequest.config != null) {
					return _masterAdRequest.config.isAcceptedLinearAdMimeType(mimeType);				
				}
			}
			return true;			
		}
		
		protected function getLinearAcceptableAdMimeTypes():Array {
			if(_masterAdRequest != null) {
				if(_masterAdRequest.config != null) {
					return _masterAdRequest.config.acceptedLinearAdMimeTypes;	
				}
			}
			return null;
		}
		
		public function get forceImpressionServing():Boolean {
			return _forceImpressionServing;
		}

		protected function mustEnsureSingleAdUnitRecordedPerInlineAd():Boolean {
			if(_masterAdRequest != null) {
				return _masterAdRequest.mustEnsureSingleAdUnitRecordedPerInlineAd();
			}	
			return true;
		}

		public function hasParseError():Boolean {
			return (_lastParseErrorCode != null); 
		}
		
		public function getParseError():String {
			return _lastParseErrorCode;
		}
		
		public function setParseError(errorCode:String):void {
			_lastParseErrorCode = errorCode;
		}
		
		protected function replacingAdIds():Boolean {
			return _replaceAdIds;
		}

		protected function getReplacementAdId(requiredType:String):String {
			return null;
		}

		protected function replaceAdIds(ads:Array):Array {
			if(ads != null) {
				for(var i:int = 0; i < ads.length; i++) {
					var newId:String = getReplacementAdId(ads[i].adType);
					if(newId != null) {
						CONFIG::debugging { doLog("Replacing VideoAd.id '" + ads[i].id + "' with '" + newId + "' in Template:" + _uid, Debuggable.DEBUG_VAST_TEMPLATE); }
						ads[i].id = newId;
					}					
				}
			}
			return ads;
		}

		protected function resetReplacementIds_V2():void {
			if(_replacementAdIds != null) {
				for each(var adId:Object in _replacementAdIds) {
					adId.assigned = false;
				}
			}
		}
		
		public function getMasterAdServerConfig():AdServerConfig {
			if(_masterAdRequest != null) {
				return _masterAdRequest.config;
			}
			return null;
		}
		
		public function registerLoader(loaderUID:String):void {
			_registeredLoaders.push(loaderUID);
		}

		public function deregisterLoader(loaderUID:String):void {
			var locationIndex:int = _registeredLoaders.indexOf(loaderUID);
			if(locationIndex > -1 && locationIndex < _registeredLoaders.length) {
				_registeredLoaders[locationIndex] = null;
			}
		}
		
		protected function registeredLoadersIsEmpty():Boolean {
			if(_registeredLoaders.length > 0) {
				for(var i:int=0; i < _registeredLoaders.length; i++) {
					if(_registeredLoaders[i] != null) {
						return false;
					}
				}
			}
			return true;
		}
		
		protected function loadTemplateData(request:AdServerRequest):void {
			if(request != null) {
				_activeRequest = request;
				_activeRequest.template = this;
				var requestString:String = _activeRequest.formRequest();
				if(StringUtils.isEmpty(requestString) == false) {
					// Check if there are any [CACHEBUSTING] macros that need to be replaced
					
					if(requestString.indexOf("[CACHEBUSTING]") > -1) {
						// Always replace that macro with an eight digit random number
						var thePattern:RegExp = new RegExp("\\[CACHEBUSTING\\]", "g");
						requestString = requestString.replace(thePattern, Math.random());				
					}

					CONFIG::debugging { doLog("Loading VAST data from " + request.serverType() + " - formed request is " + requestString, Debuggable.DEBUG_VAST_TEMPLATE); }
										
					if(_listener != null) {
						_listener.onAdCallStarted(request);
					}
					_xmlLoader = new TimedURLLoader(request.timeoutInSeconds * 1000);
					if(request.requiresTransformation()) {
						_xmlLoader.transformers = request.config.transformers;
					}
		   		    _xmlLoader.addEventListener(Event.COMPLETE, templateLoaded);
					_xmlLoader.addEventListener(ErrorEvent.ERROR, errorHandler);
					_xmlLoader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, errorHandler);
					_xmlLoader.addEventListener(IOErrorEvent.IO_ERROR, errorHandler);
					_xmlLoader.addEventListener(TimedLoaderEvent.TIMED_OUT, timeoutHandler);
					_xmlLoader.load(new URLRequest(requestString));	
					if(_listener != null) {
						 if(_listener.analyticsProcessor != null) {
						 	_listener.analyticsProcessor.fireAdCallTracking(AnalyticsProcessor.FIRED, _activeRequest, _activeRequest.isWrapped());
						 }
					}
				}
				else errorHandler(new Event("Empty ad tag - ignored"));
			}
			else {
				CONFIG::debugging { doLog("Not loading the request - it is null - ignoring", Debuggable.DEBUG_VAST_TEMPLATE); }
			}
		}

		protected function fireTemplateLoadedTracking():void {
			if(_listener != null) {
				 if(_listener.analyticsProcessor != null && _activeRequest != null) {
				 	_listener.analyticsProcessor.fireAdCallTracking(AnalyticsProcessor.COMPLETE, _activeRequest, _activeRequest.isWrapped());
				 }
			}
		}

		protected function templateLoaded(e:Event):void {
			fireTemplateLoadedTracking();
			signalTemplateLoaded(_uid);
		}

		protected function errorHandler(e:Event):void {
			signalTemplateLoadError(_uid, e);
		}
		
		protected function timeoutHandler(e:Event):void {
			signalTemplateLoadTimeout(_uid, e);
		}
		
		public function hasFailoverCallsAvailable():Boolean {
			if(_masterAdRequest != null) {
				return _masterAdRequest.hasFailoverRequestsAvailable();
			}
			return false;
		}
		
		protected function needsToFailover():Boolean {
			return isMaster && (hasAds() == false) && hasFailoverCallsAvailable();
		}

		public function closeXMLLoader():void {
			if(_xmlLoader != null) {
				try {
					_xmlLoader.close();
					_xmlLoader = null;
				}
				catch(e:Error) {
				}
			}
		}	
			
		public function signalTemplateLoaded(uid:String):void {
			if(_listener != null) {
				 _listener.onAdCallComplete(_activeRequest, hasAds());
			}
			closeXMLLoader();
			deregisterLoader(uid);
			if(registeredLoadersIsEmpty()) {
				if(needsToFailover()) {
					attempFailoverAdServerCall();				
				}
				else {
					if(_listener != null) {
						_listener.onTemplateLoaded(this);
					}
				}			
			}				
		}

		public function signalTemplateLoadError(uid:String, e:Event):void {
			if(_listener != null) {
				 _listener.onAdCallComplete(_activeRequest, false);
				 if(_listener.analyticsProcessor != null && _activeRequest != null) {
				 	_listener.analyticsProcessor.fireAdCallTracking(AnalyticsProcessor.ERROR, _activeRequest, _activeRequest.isWrapped(), e.toString());
				 }
			}
			closeXMLLoader();
			deregisterLoader(uid);
			if(registeredLoadersIsEmpty()) {
				if(needsToFailover()) {
					attempFailoverAdServerCall();									
				}
				else {
					if(_listener != null) {
						_listener.onTemplateLoadError(e);
					}
				}
			}
		}

		public function signalTemplateLoadTimeout(uid:String, e:Event):void {
			if(_listener != null) {
				 _listener.onAdCallComplete(_activeRequest, false);
				 if(_listener.analyticsProcessor != null && _activeRequest != null) {
				 	_listener.analyticsProcessor.fireAdCallTracking(AnalyticsProcessor.TIMED_OUT, _activeRequest, _activeRequest.isWrapped());
				 }
			}
			closeXMLLoader();
			deregisterLoader(uid);
			if(registeredLoadersIsEmpty()) {
				if(needsToFailover()) {
					attempFailoverAdServerCall();					
				}
				else {
					if(_listener != null) {
						_listener.onTemplateLoadTimeout(e);
					}
				}
			}
		}

		public function signalTemplateLoadDeferred(uid:String, e:Event):void {
			if(_listener != null) {
				 if(_listener.analyticsProcessor != null && _activeRequest != null) {
				 	_listener.analyticsProcessor.fireAdCallTracking(AnalyticsProcessor.DEFERRED, _activeRequest, _activeRequest.isWrapped());
				 }
			}
			closeXMLLoader();
			deregisterLoader(uid);
			if(registeredLoadersIsEmpty()) {
				if(needsToFailover()) {
					attempFailoverAdServerCall();					
				}
				else {
					if(_listener != null) {
						_listener.onTemplateLoadDeferred(e);
					}					
				}
			}
		}
		
		public function attempFailoverAdServerCall():void {
			var failoverRequest:AdServerRequest = _masterAdRequest.nextFailoverAdServerRequest();
			if(failoverRequest != null) {
				CONFIG::debugging { doLog("Failing over - attempting to retrieve ads from fail-over ad server - clearing out any ads from this template", Debuggable.DEBUG_VAST_TEMPLATE); }
				_ads = new Array();	// this ensures that any blank ads from the previous ad call are removed
				if(_listener != null) {
					 _listener.onAdCallFailover(_masterAdRequest, failoverRequest);
					 if(_listener.analyticsProcessor != null && _activeRequest != null) {
					 	_listener.analyticsProcessor.fireAdCallTracking(AnalyticsProcessor.FAILED_OVER, failoverRequest, failoverRequest.isWrapped());
					 }
				}
				_replaceAdIds = failoverRequest.replaceIds;
				resetReplacementIds_V2();
				load(failoverRequest, true);			
			}
			else {
				signalTemplateLoadError(_uid, new Event("Unexpeced error - No ad server request to failover to - signaling error"));
				CONFIG::debugging { doLog("Can't failover - No ad server request to failover to - signaling error", Debuggable.DEBUG_VAST_TEMPLATE); }		
			}
		}
		
		/**
		 * Identifies whether or not the data has been successfully loaded into the template. Remains false
		 * until the data has been retrieved from the OpenX Ad Server. Can be forceably set if there
		 * aren't any ads to get data for - hence why there is this public interface
		 * 
		 * @param loadedStatus a boolean value that identifies whether or not the data has been loaded 
		 */
		public function set dataLoaded(loadedStatus:Boolean):void {
			_dataLoaded = loadedStatus;
		}
				
		/**
		 * Identifies whether or not the data has been successfully loaded into the template. Remains false
		 * until the data has been retrieved from the OpenX Ad Server.
		 * 
		 * @return <code>true</code> if the data has been successfully retrieved 
		 */
		public function get dataLoaded():Boolean {
			return _dataLoaded;
		}
	
		/**
		 * Allows the list of "ads" to be manually set.
		 * 
		 * @param ads an array of VideoAd(s)
		 */
		public function set ads(ads:Array):void {
			_ads = ads;
		}
		
		/**
		 * Returns the number of ads recorded in this template.
		 */
		public function getAdCount():int {
			if(_ads != null) {
				return _ads.length;
			}
			return 0;
		}

		/**
		 * Returns the list of video ads that are currently held by the template. If there are no
		 * ads currently being held, a zero length array is returned.
		 * 
		 * @return array an array of VideoAd(s)
		 */
		public function get ads():Array {
			return _ads;
		}		

		public function hasAds(includeEmptyAdsInCount:Boolean=false):Boolean {
			if(_ads == null) {
				return false;
			}
			for each(var ad:VideoAd in _ads) {
				if(ad.hasAds(includeEmptyAdsInCount)) {
					return true;
				}
			}
			return false;
		}
		
		public function getEmptyVideoAdsWithErrorUrls():Array {
			return _emptyErrorAds;
		}
		
		public function addEmptyErrorAds(emptyErrorAds:Array):void {
			_emptyErrorAds.concat(emptyErrorAds);
		}

		/**
		 * Returns the raw template data that was returned by the Open X VAST server
		 * 
		 * return string the raw data
		 */
		public function getRawTemplateData():String {
			return _templateData;
		}
		
		/**
		 * Returns a version of the raw template data without newlines etc. that break a html textarea
		 * 
		 * return string the raw data minus newlines
		 */
		public function getHtmlFriendlyTemplateData():String {
		    var xmlData:XML = new XML(getRawTemplateData());
			var thePattern:RegExp = /\n/g;
			var encodedString:String = xmlData.toXMLString().replace(thePattern, "\\n");			
			return encodedString;
		}
		
		public function getMergedAds():Array {
			return _ads;
		}

		protected function cleanAdList(list:Array):Array {
			if(_forceImpressionServing == false) {
				if(list != null) {
					var result:Array = new Array();
					var removeCount:int = 0;
					for(var i:int=0; i < list.length; i++) {
						if(VideoAd(list[i]).isEmpty() == false) {
							result.push(list[i]);
						}
						else {
							++removeCount;
						}
					}
					CONFIG::debugging { doLog("Removed " + removeCount + " empty ads from the response", Debuggable.DEBUG_VAST_TEMPLATE); }				
					return result;
				}
			}	
			return list;
		}
		
		public function merge(template:AdServerTemplate, replaceIds:Boolean=false, isV2Wrapper:Boolean=false):void {
			CONFIG::debugging { doLog("Merging ads from Template " + template.uid + " into Template " + this.uid, Debuggable.DEBUG_VAST_TEMPLATE); }				
			
			if(template.forceImpressionServing) {
				CONFIG::debugging { doLog("Will merge empty video ads to support 'forcedImpressionServing'", Debuggable.DEBUG_VAST_TEMPLATE); }
				_forceImpressionServing = true;
			}
			else {
				CONFIG::debugging { doLog("Empty ads will be removed when merging templates", Debuggable.DEBUG_VAST_TEMPLATE); }				
				_forceImpressionServing = false;
			}
			
			// Record the empty ads with error urls separately so that the error URLs can be fired later if required

			_emptyErrorAds = _emptyErrorAds.concat(template.getEmptyVideoAdsWithErrorUrls());

			var _adsList:Array = (isV2Wrapper) ? template.getMergedAds() : template.ads;
			var _fullList:Array = new Array();
			_fullList = _fullList.concat(_adsList);
			_fullList = _fullList.concat(_ads);

			for each(var ad:VideoAd in _fullList) {
				if(ad.isEmpty() && !ad.isCompanionOnlyAd() && ad.hasErrorTracking()) {
					_emptyErrorAds.push(ad);					
				}
			}
			CONFIG::debugging { doLog(_emptyErrorAds.length + " empty error ads recorded in Template:" + _uid, Debuggable.DEBUG_VAST_TEMPLATE); }
			
			if(template.hasAds(_forceImpressionServing)) { // Modified to ensure that 'true' means that empty ads are merged to support forced impression firing
				if(replaceIds) {
					CONFIG::debugging { doLog("Merging (and replacing IDs) " + template.ads.length + " ads from Template:" + template.uid + " into this " + ((isV2Wrapper) ? "V2 Wrapper" : "V1") + " Template:" + _uid, Debuggable.DEBUG_VAST_TEMPLATE); }
					_ads = _ads.concat(replaceAdIds(cleanAdList(_adsList)));
				}
				else {
					CONFIG::debugging { doLog("Merging (leaving IDs untouched) " + template.ads.length + " ads from Template:" + template.uid + " into this " + ((isV2Wrapper) ? "V2 Wrapper" : "V1") + " Template:" + _uid, Debuggable.DEBUG_VAST_TEMPLATE); }
					_ads = _ads.concat(cleanAdList(_adsList));
				}
			}
			else {
				CONFIG::debugging { doLog("No ads in Template '" + template.uid + "' to merge with Template " + _uid + " - returning", Debuggable.DEBUG_VAST_TEMPLATE); }
			} 
			_templateData += template.getRawTemplateData();
		}

		public function filterLinearAdMediaFileByMimeType(mimeTypes:Array):void {
			// not implemented in the default template
		}

		public function getVideoAdWithID(id:String):VideoAd {
			CONFIG::debugging { doLog("Looking for a Video Ad " + id + " in Template:" + _uid, Debuggable.DEBUG_VAST_TEMPLATE); }
			if(_ads != null) {
				for(var i:int = 0; i < _ads.length; i++) {
					if(_ads[i].id == id) {
						CONFIG::debugging { doLog("- Assessing '" + _ads[i].id + "' in Template:" + _uid + " - match found - returning it", Debuggable.DEBUG_VAST_TEMPLATE); }
						return _ads[i];
					}
					else {
						CONFIG::debugging { doLog("- Assessing '" + _ads[i].id + "' in Template:" + _uid + " - no match", Debuggable.DEBUG_VAST_TEMPLATE); }
					}
				}	
				CONFIG::debugging { doLog("Could not find Video Ad " + id + " in the VAST template", Debuggable.DEBUG_VAST_TEMPLATE); }
			}
			else {
				CONFIG::debugging { doLog("No ads in the list!", Debuggable.DEBUG_VAST_TEMPLATE); }
			}
			return null;
		}				

		public function getNextNonEmptyVideoAdStartingAtIndex(index:int):VideoAd {
			if(_ads != null) {
				if(_ads.length > 0) {
					for(var i:int = index; i < _ads.length; i++) {
						if(VideoAd(_ads[i]).isEmpty() == false && VideoAd(_ads[i]).isCompanionOnlyAd() == false) {
							return _ads[i];
						}
					}
				}
			}
			return null;
		}
		
		/**
		 * Add a VideoAd to the end of the current list of video ads recorded for this template
		 * 
		 * @param ad a VideoAd
		 */
		public function addVideoAd(ad:VideoAd):void {
			_ads.push(ad);
		}		
	}
}