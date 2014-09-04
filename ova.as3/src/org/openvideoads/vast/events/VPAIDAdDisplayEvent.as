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
	public class VPAIDAdDisplayEvent extends Event {
		public static const LINEAR_LOADING:String = "ova-vpaid-linear-loading";
		public static const NON_LINEAR_LOADING:String = "nl-loading";
		public static const LINEAR_LOADED:String = "ova-vpaid-linear-loaded";
		public static const NON_LINEAR_LOADED:String = "ova-vpaid-nl-loaded";
		public static const LINEAR_IMPRESSION:String = "ova-vpaid-linear-impression";
		public static const NON_LINEAR_IMPRESSION:String = "ova-vpaid-nl-impression";
		public static const LINEAR_START:String = "ova-vpaid-linear-start";
		public static const LINEAR_COMPLETE:String = "ova-vpaid-linear-complete";
		public static const LINEAR_ERROR:String = "ova-vpaid-linear-error";
		public static const LINEAR_LINEAR_CHANGE:String = "ova-vpaid-linear-linear-change";
		public static const LINEAR_EXPANDED_CHANGE:String = "ova-vpaid-linear-expanded-change";
		public static const LINEAR_TIME_CHANGE:String = "ova-vpaid-linear-time-change";
		public static const NON_LINEAR_START:String = "ova-vpaid-nl-start";
		public static const NON_LINEAR_COMPLETE:String = "ova-vpaid-nl-complete";
		public static const NON_LINEAR_ERROR:String = "ova-vpaid-nl-error";
		public static const NON_LINEAR_LINEAR_CHANGE:String = "ova-vpaid-nl-linear-change";
		public static const NON_LINEAR_EXPANDED_CHANGE:String = "ova-vpaid-nl-expanded-change";
		public static const NON_LINEAR_TIME_CHANGE:String = "ova-vpaid-nl-time-change";
		public static const VIDEO_AD_START:String = "ova-video-ad-start";
		public static const VIDEO_AD_FIRST_QUARTILE:String = "ova-video-ad-first-quartile";
		public static const VIDEO_AD_MIDPOINT:String = "ova-video-ad-midpoint";
		public static const VIDEO_AD_THIRD_QUARTILE:String = "ova-video-ad-third-quartile";
		public static const VIDEO_AD_COMPLETE:String = "ova-video-ad-complete";
		public static const LINEAR_CLICK_THRU:String = "ova-linear-click-thru";
		public static const NON_LINEAR_CLICK_THRU:String = "ova-vpaid-nl-click-thru";
		public static const LINEAR_USER_ACCEPT_INVITATION:String = "ova-vpaid-linear-user-accept-invitation";
		public static const LINEAR_USER_MINIMIZE:String = "ova-vpaid-linear-user-minimize";
		public static const LINEAR_USER_CLOSE:String = "ova-vpaid-linear-user-close";
		public static const NON_LINEAR_USER_ACCEPT_INVITATION:String = "ova-vpaid-nl-user-accept-invitation";
		public static const NON_LINEAR_USER_MINIMIZE:String = "ova-vpaid-nl-user-minimize";
		public static const NON_LINEAR_USER_CLOSE:String = "ova-vpaid-nl-user-close";
		public static const LINEAR_VOLUME_CHANGE:String = "ova-vpaid-linear-volume-change";
		public static const NON_LINEAR_VOLUME_CHANGE:String = "ova-vpaid-nl-volume-change";
		public static const SKIPPED:String = "ova-vpaid-skipped";
		public static const SKIPPABLE_STATE_CHANGE:String = "ova-vpaid-skippable-state-change";
		public static const SIZE_CHANGE:String = "ova-vpaid-size-change";
		public static const DURATION_CHANGE:String = "ova-vpaid-duration-change";
		public static const AD_INTERACTION:String = "ova-vpaid-ad-interaction";
		public static const AD_LOG:String = "ova-vpaid-ad-log";
		
		protected var _data:* = null;
		protected var _adSlot:AdSlot = null;
		
		public function VPAIDAdDisplayEvent(type:String, adSlot:AdSlot, data:* = null, bubbles:Boolean = false, cancelable:Boolean = false) {
			super(type, bubbles, cancelable);
			_adSlot = adSlot;
			_data = data;
		}

		public function get adSlot():AdSlot {
			return _adSlot;
		}
		
		public function hasData():Boolean {
			return _data != null;
		}
		
		public function get data():* {
			return _data;
		}
		
		public override function clone():Event {
			return new VPAIDAdDisplayEvent(type, adSlot, data, bubbles, cancelable);
		}
	}
}