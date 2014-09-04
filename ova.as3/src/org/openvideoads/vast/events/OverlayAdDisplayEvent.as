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
	import flash.events.MouseEvent;
	
	import org.openvideoads.vast.config.groupings.AdSlotRegionConfig;
	import org.openvideoads.vast.model.NonLinearVideoAd;
	import org.openvideoads.vast.schedule.ads.AdSlot;
	
	/**
	 * @author Paul Schulz
	 */
	public class OverlayAdDisplayEvent extends NonLinearAdDisplayEvent {
		public static const DISPLAY:String = "display-overlay";
		public static const HIDE:String = "hide-overlay";
		public static const DISPLAY_NON_OVERLAY:String = "display-non-overlay";
		public static const HIDE_NON_OVERLAY:String = "hide-non-overlay";
		public static const CLICKED:String = "overlay-clicked";
		public static const CLOSE_CLICKED:String = "overlay-close-clicked";
		public static const DISPLAY_MODE_FLASH:String = "flash";
		public static const DISPLAY_MODE_HTML5:String = "html5";
		
		protected var _adSlot:AdSlot = null;
		protected var _region:AdSlotRegionConfig = null;
		protected var _originalMouseEvent:MouseEvent = null;

		public function OverlayAdDisplayEvent(type:String, nonLinearVideoAd:NonLinearVideoAd, adSlot:AdSlot, region:AdSlotRegionConfig=null, originalMouseEvent:MouseEvent=null, bubbles:Boolean = false, cancelable:Boolean = false) {
			super(type, nonLinearVideoAd, bubbles, cancelable);
            _adSlot = adSlot;
			_region = region;
			_originalMouseEvent = originalMouseEvent;
		}

		public function get adSlot():AdSlot {
			return _adSlot;
		}
		
		public function get region():AdSlotRegionConfig {
			return _region;
		}

		public function set originalMouseEvent(mouseEvent:MouseEvent):void {
			_originalMouseEvent = mouseEvent;
		}
		
		public function get originalMouseEvent():MouseEvent {
			return _originalMouseEvent;
		}
		
		public function get displayMode():String {
			if(_region != null) {
				return _region.displayMode;
			}
			return OverlayAdDisplayEvent.DISPLAY_MODE_FLASH;	
		}
		
		public override function clone():Event {
			return new OverlayAdDisplayEvent(type, nonLinearVideoAd, _adSlot, _region, _originalMouseEvent, bubbles, cancelable);
		}
		
		public override function toString():String {
			if(nonLinearVideoAd != null) {
				return "resourceType: " + nonLinearVideoAd.resourceType + ", " +
				   	   "creativeType: " + nonLinearVideoAd.creativeType + ", " +
				   	   "displayMode; " + displayMode + ", " + 
				       "width: " + nonLinearVideoAd.width + ", " +
				       "height: " + nonLinearVideoAd.height;
			}
			else return "no ad";
		}
	}
}