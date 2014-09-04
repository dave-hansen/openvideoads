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
package org.openvideoads.vast.server.events {
	import flash.events.Event;
	
	import org.openvideoads.vast.server.response.AdServerTemplate;
	
	/**
	 * @author Paul Schulz
	 */
	public class TemplateEvent extends Event {
		public static const LOADED:String = "loaded";
		public static const LOAD_FAILED:String = "load-failed";
		public static const LOAD_TIMEOUT:String = "load-timeout";
		public static const LOAD_DEFERRED:String = "load-deferred";
		
		protected var _data:Object = null;
		
		public function TemplateEvent(type:String, data:Object = null, bubbles:Boolean = false, cancelable:Boolean = false) {
			super(type, bubbles, cancelable);
			if(data != null) _data = data;
		}

 		public function hasData():Boolean {
 			return (_data != null);
 		}		
 		
		public function set data(data:Object):void {
			_data = data;
		}
		
		public function get data():Object {
			return _data;
		}
		
		public function hasTemplate():Boolean {
			return (_data != null && (data is AdServerTemplate));
		}
		
		public function get template():AdServerTemplate {
			return _data as AdServerTemplate;
		}
		
		public override function clone():Event {
			return new TemplateEvent(type, _data, bubbles, cancelable);
		}
		
		public override function toString():String {
			if(_data != null) {
				if(_data.hasOwnProperty("message")) {
					return _data.message;
				}
				return _data.toString();			
			}
			return "No error message provided";
		}
	}
}