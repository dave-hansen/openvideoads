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
	import org.openvideoads.vast.schedule.Stream;
	import org.openvideoads.vast.schedule.ads.AdSlot;
	
	import flash.events.Event;
	
	/**
	 * @author Paul Schulz
	 */
	public class NonLinearSchedulingEvent extends Event {
		public static const SCHEDULE:String = "schedule-non-linear";

		protected var _adSlot:AdSlot = null;
		
		public function NonLinearSchedulingEvent(type:String, adSlot:AdSlot, bubbles:Boolean = false, cancelable:Boolean = false) {
			super(type, bubbles, cancelable);
			_adSlot = adSlot;
		}
		
		public function set adSlot(adSlot:AdSlot):void {
			_adSlot = adSlot;
		}
		
		public function get adSlot():AdSlot {
			return _adSlot;
		}		
	}
}