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
	import org.openvideoads.vast.schedule.ads.AdSlot;
	import org.openvideoads.vast.model.LinearVideoAd;
	
	import flash.events.Event;
	
	/**
	 * @author Paul Schulz
	 */
	public class LinearAdDisplayEvent extends Event {
		public static const STARTED:String = "linear-ad-started";
		public static const COMPLETE:String = "linear-ad-complete";
		public static const SKIPPED:String = "linear-ad-skipped";
		public static const CLICK_THROUGH:String = "linear-ad-click-through";

		protected var _adSlot:AdSlot = null;
		
		public function LinearAdDisplayEvent(type:String, adSlot:AdSlot, bubbles:Boolean = false, cancelable:Boolean = false) {
			super(type, bubbles, cancelable);
			_adSlot = adSlot;
		}
		
		public function set adSlot(adSlot:AdSlot):void {
			_adSlot = adSlot;	
		}
		
		public function get ad():LinearVideoAd {
			return this.linearVideoAd;
		}
		
		public function get linearVideoAd():LinearVideoAd {
			if(_adSlot != null) {
				return _adSlot.videoAd.linearVideoAd;
			}
			return null;
		}
	}
}