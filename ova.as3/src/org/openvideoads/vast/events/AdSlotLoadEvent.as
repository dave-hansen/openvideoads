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
package org.openvideoads.vast.events {
	import flash.events.Event;
	
	import org.openvideoads.vast.schedule.ads.AdSlot;
	
	/**
	 * @author Paul Schulz
	 */
	public class AdSlotLoadEvent extends Event {
		public static const LOADED:String = "adslot-load-success";
		public static const LOAD_ERROR:String = "adslot-load-error";
		public static const LOAD_TIMEOUT:String = "adslot-load-timeout";
		public static const LOAD_DEFERRED:String = "adslot-load-deferred";
		
		protected var _adSlot:AdSlot = null;
		protected var _nestedEvent:Event = null;

		public function AdSlotLoadEvent(type:String, adSlot:AdSlot, nestedEvent:Event=null, bubbles:Boolean = false, cancelable:Boolean = false) {
			super(type, bubbles, cancelable);
			_nestedEvent = nestedEvent;
			_adSlot = adSlot;
		}
		
		public function hasAdSlot():Boolean {
			return (_adSlot != null);
		}
		
		public function get adSlot():AdSlot {
			return _adSlot;
		}
		
		public function hasNestedEvent():Boolean {
			return (_nestedEvent != null);
		}
		
		public function get nestedEvent():Event {
			return _nestedEvent;
		}
		
		public function adSlotHasLinearAds():Boolean {
			if(_adSlot != null) {
				return _adSlot.hasLinearAd();
			}	
			return false;
		}
		
		public override function toString():String {
			if(_nestedEvent != null) {
				return _nestedEvent.toString();
			}
			else if(_adSlot != null) {
				return _adSlot.toString();
			}
			return "no data";
		}
	}
}