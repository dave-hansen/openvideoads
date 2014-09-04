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
package org.openvideoads.util {
    import flash.events.*;
    import flash.net.*;
    import flash.utils.Timer;
    
    import org.openvideoads.base.Debuggable;
		
	/**
	 * @author Paul Schulz
	 */
	public class NetworkResource extends Debuggable {
		protected var _id:String = null;
		protected var _url:String = null;
		protected var _mimeType:String = null;
		protected var _loader:URLLoader = new URLLoader();
		protected var _timeoutTimer:Timer = null;
		protected var _fired:Boolean = false;
		
		public function NetworkResource(id:String = null, url:String = null, mimeType:String = null) {
			super();
			_id = id;
			this.url = url;
			_mimeType = mimeType;
		}
		
		public function close():void {
			if(_loader != null) {
				try {
					_loader.close();
					_loader = null;
				}
				catch(e:Error) {
				}
			}
		}
		
		public function set id(id:String):void {
			_id = id;
		}
		
		public function get id():String {
			return _id;
		}
		
		public function markAsFired():void {
			_fired = true;
		}
		
		public function reset():void {
			_fired = false;
		}
		
		public function set url(url:String):void {
			_url = StringUtils.removeControlChars(StringUtils.trim(url));
		}
		
		public function get url():String {
			return _url;
		}
		
		public function hasUrl():Boolean {
			if(_url != null) {
				return (StringUtils.trim(_url).length > 0);	
			}
			return false;			
		}
		
		public function hasMimeType():Boolean {
			return (_mimeType != null);
		}
		
		public function set mimeType(mimeType:String):void {
			_mimeType = mimeType;
		}
		
		public function get mimeType():String {
			return _mimeType;
		}
		
		public function isMimeType(mimeType:String):Boolean {
			if(_mimeType != null) {
				return StringUtils.matchesIgnoreCase(mimeType, _mimeType);
			}	
			return false;
		}
		
		public function hasFileExtension(extension:String):Boolean {
			if(_url != null) {
				var lastDotIndex:int = _url.lastIndexOf(".");
				return StringUtils.matchesIgnoreCase(_url.substr(lastDotIndex), extension);
			}
			return false;
		}
		
		public function get qualifiedHTTPUrl():String {
			if(!isQualified()) {
				return "http://" + StringUtils.trim(_url);
			}
			else {
				return _url;
			}
		}

		public function get qualifiedUrl():String {
			return qualifiedHTTPUrl;
		}

		public function hasMP4FileMarker():Boolean {
			if(_url != null) {
				return (_url.indexOf("mp4:") > -1);
			}
			return false;
		}

		public function hasFLVFileMarker():Boolean {
			if(_url != null) {
				return (_url.indexOf("flv:") > -1);
			}
			return false;
		}
		
		public function hasFileMarker():Boolean {
			if(_url != null) {
				return hasMP4FileMarker() || hasFLVFileMarker();
			}
			return false;
		}
				
		public function get data():String {
			return _loader.data;
		}
		
		public function isQualified():Boolean {
			if(_url != null) {
				return (_url.indexOf("http://") > -1 || _url.indexOf("https://") > -1 || _url.indexOf("rtmp://") > -1);
			}
			return false;
		}
		
		public function getQualifiedStreamAddress(defaultNetConnectionURL:String = null):String {
			if(isQualified()) {
				return _url;
			}
			else {
				if(defaultNetConnectionURL != null) {
					return defaultNetConnectionURL	+ _url;
				}
				else return _url;
			}
		}
		
		public function getFilename(fileMarker:String=null):String {
			if(_url != null) {
				if(fileMarker != null) {
					var firstMarkerIndex:int = _url.indexOf(fileMarker);
					if(firstMarkerIndex == -1) {
						return _url;
					}
					else return _url.substr(firstMarkerIndex);
				}
				else {
					var lastSlashIndex:int = _url.lastIndexOf("/");
					if(lastSlashIndex == -1) {
						return _url;
					}
					else { // strip out the URI
						return _url.substr(lastSlashIndex+1);
					}
				}
			}
			else return null;
		}
		
		public function get netConnectionAddress():String {
			if(_url != null) {
				if(_url.indexOf("mp4:") > 0) {
					return _url.substr(0, _url.indexOf("mp4:"));
				}			
				else if(_url.indexOf("flv:") > 0) {					
					return _url.substr(0, _url.indexOf("flv:"));
				}
			}
			return null;
		}
		
		public function isRTMP():Boolean {
			if(_url != null) {
				return (_url.indexOf("rtmp") > -1);			
			}
			else return false;
		}
		
		public function getURI():String {
			if(_url != null) {
				var lastSlashIndex:int = _url.lastIndexOf("/");
				if(lastSlashIndex == -1) {
					return null;
				}
				else { // strip out the filename
					return _url.substr(0, lastSlashIndex+1);
				}			
			}
			else return null;
		}
		
		public function isStream():Boolean {
			var filename:String = getFilename();
       		var pattern:RegExp = new RegExp('(?i).*\\.(mp4|flv|wmv|mp3|3g2|3gp|aac|f4b|f4p|f4v|m4a|m4v|mov|sdp)');			
    		return (filename.match(pattern) != null);			
		}
		
		public function isLiveURL():Boolean {
			var filename:String = getFilename();
			if(filename != null) {
				return (filename.indexOf("(live)") > -1);
			}
			return false;
		}
		
		public static function getDomain(url:String):String {
			if(url != null) {
				if(StringUtils.beginsWith(url, "http://localhost")) {
					return "localhost";
				}
				var parts:Array = url.split("/"); 
				if(StringUtils.beginsWith(url, "http")) {
					// It's http(s)://my-domain/my-page so take everything between the 2 and 3 slashes
					if(parts.length >= 3) {
						return parts[2];
					}
				}
				else {
					// it could be something like openx.openvideoads.org/my-page so take everything up to the first slash
					return parts[0];
				}
			}
			return null;
		}
		
		public function getLiveStreamName():String {
			if(isLiveURL()) {
				var filename:String = getFilename();
				return filename.substr(filename.lastIndexOf("(live)") + 6);
			}
			else return null;					
		}
		
		public static function addBaseURL(baseURL:String, fileName:String):String {
			if (fileName == null) return null;
			
			if (isCompleteURLWithProtocol(fileName)) return fileName;
			if (fileName.indexOf("/") == 0) return fileName;
			
			if (baseURL == '' || baseURL == null || baseURL == 'null') {
				return fileName;
			}
			if (baseURL != null) {
				if (baseURL.lastIndexOf("/") == baseURL.length - 1)
					return baseURL + fileName;
				return baseURL + "/" + fileName;
			}
			return fileName;
		}

        public static function appendToPath(base:String, postFix:String):String {
            if (StringUtils.endsWith(base, "/")) return base + postFix;
            return base + "/" + postFix;
        }

		public static function isCompleteURLWithProtocol(fileName:String):Boolean {
			if (! fileName) return false;
			return fileName.indexOf("://") > 0;
		}		
		
		public function callAfterReplacing(variable:String, value:String, maxWaitSeconds:int=-1):void {			
			if(_url != null) {
				call(maxWaitSeconds, _url.replace(variable, value));			
			}
		}
		
		public function call(maxWaitSeconds:int=-1, providedUrl:String=null):void {
			if(_fired) {
				// We've already marked this resource as fired so don't do it again
				return;
			}
			
			var finalUrl:String = null;
			
			if(providedUrl != null) {
				finalUrl = providedUrl;
			}
			else finalUrl = _url;
			
			if(finalUrl.indexOf("[CACHEBUSTING]") > -1) {
				// Always replace that macro with an eight digit random number
				var thePattern:RegExp = new RegExp("\\[CACHEBUSTING\\]", "g");
				finalUrl = finalUrl.replace(thePattern, Math.random());				
			}
			
			if(finalUrl != null) {
				if(StringUtils.trim(finalUrl).length > 0) {
					CONFIG::debugging { doLog("Making HTTP call to " + finalUrl, Debuggable.DEBUG_HTTP_CALLS); }
					_loader = new URLLoader();
					_loader.addEventListener(Event.COMPLETE, callComplete);
					_loader.addEventListener(ErrorEvent.ERROR, errorHandler)
					_loader.addEventListener(AsyncErrorEvent.ASYNC_ERROR, errorHandler);
					_loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, errorHandler);
					_loader.addEventListener(IOErrorEvent.IO_ERROR, errorHandler);
					if(maxWaitSeconds > 0) {
						startTimeoutTimer(maxWaitSeconds * 1000);
					}
					_loader.load(new URLRequest(finalUrl));
				}
				else {
					CONFIG::debugging { doLog("HTTP call not made - the URL is empty", Debuggable.DEBUG_HTTP_CALLS); }
				}	
			}
			else {
				CONFIG::debugging { doLog("HTTP call cannot be made - no URL set", Debuggable.DEBUG_HTTP_CALLS); }
			}
		}
		
		public function doReplacementsAndCall(replacements:Array):void {
			if(replacements.length > 0) {
				for(var i:int = 0; i < replacements.length; i++) {
					var thePattern:RegExp = new RegExp(replacements[i].id, "g");
					_url = _url.replace(thePattern, replacements[i].value);
				}
			}
			call();
		}

		protected function startTimeoutTimer(interval:int):void {
			if(_timeoutTimer != null) stopTimeoutTimer();
			if(interval > 0) {
				CONFIG::debugging { doLog("HTTP call timer started - max call duration is set at " + interval + " milliseconds", Debuggable.DEBUG_HTTP_CALLS); }
				_timeoutTimer = new Timer(interval, 1);
				_timeoutTimer.addEventListener(TimerEvent.TIMER, timeoutCall);
				_timeoutTimer.start();			
			}
		}
		
		protected function stopTimeoutTimer():void {
			if(_timeoutTimer != null) {
				_timeoutTimer.stop();
				_timeoutTimer = null;
			}
		}
		
		protected function timeoutCall(event:TimerEvent):void {
			stopTimeoutTimer();
			CONFIG::debugging { doLog("HTTP ERROR: Call has been forcibly timed out", Debuggable.DEBUG_HTTP_CALLS); }
			close();
		}
		
		protected function callComplete(e:Event):void {
			if(_loader != null) {
				CONFIG::debugging { doLog("HTTP call complete (to " + id + ") - " + _loader.bytesLoaded + " bytes loaded", Debuggable.DEBUG_HTTP_CALLS); }
				loadComplete(_loader.data);
			}
			else {
				CONFIG::debugging { doLog("HTTP call complete (to " + id + ") - loader is null so no load data available", Debuggable.DEBUG_HTTP_CALLS); }
			}
		}
		
		protected function errorHandler(e:Event):void {
			CONFIG::debugging { doLog("HTTP ERROR: " + e.toString(), Debuggable.DEBUG_HTTP_CALLS); }
			close();
		}		
		
		protected function loadComplete(data:String):void {
			close();
		}
		
		public static function addParameterToURLString(url:String, parameter:String):String {
			if(url.indexOf("?") > 0) {
				return url + "&" + parameter;
			}
			else return url + "?" + parameter;
		}
		
		public function clone():NetworkResource {
			return new NetworkResource(_id, _url);
		}

		public override function toJSObject():Object {
			var o:Object = new Object();
			o = {
				id: _id,
				uid: _uid,
				url: _url,
				mimeType: _mimeType
			}
			return o;
		}
	}
}