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
package org.openvideoads.vast.overlay.button.skip {
	import flash.events.Event;
	
	/**
	 * @author Paul Schulz
	 */
	public class SkipAdButtonDisplayEvent extends Event {
		public static const DISPLAY:String = "display-skip-button";
		public static const HIDE:String = "hide-skip-button";

		protected var _region:String = null;
		protected var _resource:String = null;
		protected var _callbackMethod:Function = null; 
		
		public function SkipAdButtonDisplayEvent(type:String, region:String, resource:String=null, callbackMethod:Function=null, bubbles:Boolean = false, cancelable:Boolean = false) {
			super(type, bubbles, cancelable);
			_region = region;
			_resource = resource;
			_callbackMethod = callbackMethod;
		}

		public function get region():String {
			return _region;
		}
		
		public function get resource():String {
			return _resource;
		}
		
		public function get callbackMethod():Function {
			return _callbackMethod;
		}
		
		public function isImageButton():Boolean {
			return true;
		}
		
		public function isFlashButton():Boolean {
			return false;
		}
		
		public override function clone():Event {
			return new SkipAdButtonDisplayEvent(type, _region, _resource, _callbackMethod, bubbles, cancelable);
		}
	}
}