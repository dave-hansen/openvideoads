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
	import org.openvideoads.base.Debuggable;
	import org.openvideoads.util.ArrayUtils;
	import org.openvideoads.util.NetworkResource;
	
	/**
	 * @author Paul Schulz
	 */
	public class TrackingEvent extends Debuggable {
		private var _urls:Array = new Array();
		private var _eventType:String;
		private var _lastFired:Number = -1;
		private var _alwaysFire:Boolean = false;

		// VAST V1 events		
		
		public static const EVENT_START:String = "start";
		public static const EVENT_STOP:String = "stop";
		public static const EVENT_RESUME:String = "resume";
		public static const EVENT_MIDPOINT:String = "midpoint";
		public static const EVENT_1STQUARTILE:String = "firstQuartile";
		public static const EVENT_3RDQUARTILE:String = "thirdQuartile";
		public static const EVENT_COMPLETE:String = "complete";
		public static const EVENT_MUTE:String = "mute";
		public static const EVENT_UNMUTE:String = "unmute";
		public static const EVENT_PAUSE:String = "pause";
		public static const EVENT_REPLAY:String = "replay";
		public static const EVENT_FULLSCREEN:String = "fullscreen";
		
		// VAST V2 events
		
		public static const EVENT_REWIND:String = "rewind";
		public static const EVENT_EXPAND:String = "expand";
		public static const EVENT_COLLAPSE:String = "collapse";
		public static const EVENT_CLOSE:String = "close";
		public static const EVENT_ACCEPT:String = "acceptInvitation";
		public static const EVENT_CREATIVE_VIEW:String = "creativeView";
		
		// VAST V3 events
		
		public static const EVENT_FULLSCREEN_EXIT:String = "exitFullscreen";
		public static const EVENT_SKIP:String = "skip"; // TO DO
		public static const EVENT_ACCEPT_INVITATION_LINEAR:String = "acceptInvitationLinear"; // TO DO
		public static const EVENT_CLOSE_LINEAR:String = "closeLinear"; // TO DO
		public static const EVENT_PROGRESS:String = "progress"; 
		
		public static const TRIGGER_FIRE_DELAY_MILLISECONDS:Number = 5000; // 5 second delay between refiring of events
 
		public function TrackingEvent(eventType:String = null, url:NetworkResource = null, alwaysFire:Boolean=false) {
			super();
			_eventType = eventType;
			_alwaysFire = alwaysFire;
			if(url != null) addURL(url);
		}
		
		public function unload():void {
			if(_urls != null) {
				for(var i:int = 0; i < _urls.length; i++) {
					urls[i].close();
				}								
			}
		}
		
		public function set urls(urls:Array):void {
			_urls = urls;
		}
		
		public function get urls():Array {
			return _urls;
		}
		
		public function getURLList():Array {
			var result:Array = new Array();
			if(_urls != null) {
				for(var i:int=0; i < _urls.length; i++) {
					result.push(NetworkResource(_urls[i]).url);
				}
			}
			return result;
		}
		
		public function addURL(url:NetworkResource):void {
			_urls.push(url);
		}
		
		public function set eventType(eventType:String):void {
			_eventType = eventType;
		}
		
		public function get eventType():String {
			return _eventType;
		}
		
		public function isType(type:String):Boolean {
			if(_eventType != null && type != null) {
				return _eventType.toUpperCase() == type.toUpperCase();
			}
			return false;
		}

		public function execute(assetURI:String=null, contentPlayhead:String=null):void {
			var replacements:Array = new Array();
			
			if(assetURI != null) {
				replacements.push({ id: "\\[ASSETURI\\]", value: assetURI });
			}

			if(contentPlayhead != null) {
				replacements.push({ id: "\\[CONTENTPLAYHEAD\\]", value: contentPlayhead });
			}
			
			CONFIG::debugging { doLog("Firing tracking event - " + eventType, Debuggable.DEBUG_TRACKING_EVENTS); }
			for(var i:int = 0; i < _urls.length; i++) {
				urls[i].doReplacementsAndCall(replacements);
			}	
		}	
			
		public function clone():TrackingEvent {
			var newTE:TrackingEvent = new TrackingEvent(_eventType, null, _alwaysFire);
			newTE.urls = _urls;
			return newTE;
		}

		public override function toJSObject():Object {
			var o:Object = new Object();
			o = {
				uid: _uid,
				eventType: _eventType,
				urls: ArrayUtils.convertToJSObjectArray(_urls),
				alwaysFire: _alwaysFire
			}
			return o;
		}
	}
}