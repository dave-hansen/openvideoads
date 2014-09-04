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
package org.openvideoads.regions.events {
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import org.openvideoads.regions.view.RegionView;

	/**
	 * @author Paul Schulz
	 */
	public class RegionMouseEvent extends Event {
		public static const REGION_CLICKED:String = "region-clicked";

		protected var _regionView:RegionView;
		protected var _originalMouseEvent:MouseEvent = null;
		
		public function RegionMouseEvent(type:String, regionView:RegionView, originalMouseEvent:MouseEvent, bubbles:Boolean = false, cancelable:Boolean = false) {
			super(type, bubbles, cancelable);
			_regionView = regionView;
			_originalMouseEvent = originalMouseEvent;
		}
		
		public function get regionView():RegionView {
			return _regionView;
		}
		
		public function get regionID():String {
			return _regionView.id;
		}
		
		public function set originalMouseEvent(mouseEvent:MouseEvent):void {
			_originalMouseEvent = mouseEvent;
		}
		
		public function get originalMouseEvent():MouseEvent {
			return _originalMouseEvent;
		}
		
		public override function clone():Event {
			return new RegionMouseEvent(type, regionView, originalMouseEvent, bubbles, cancelable);
		}
	}
}