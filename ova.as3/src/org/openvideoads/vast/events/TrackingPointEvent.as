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
	import org.openvideoads.vast.tracking.TrackingPoint;
	
	import flash.events.Event;
	
	/**
	 * @author Paul Schulz
	 */
	public class TrackingPointEvent extends Event {
		public static const SET:String = "tp-set";
		public static const FIRED:String = "tp-fired";
		
		public static const LINEAR_AD_STARTED:String = "BA";
		public static const LINEAR_AD_COMPLETE:String = "EA";
		public static const LINEAR_AD_Q1:String = "Q1";
		public static const LINEAR_AD_HW:String = "HW";
		public static const LINEAR_AD_Q3:String = "Q3";
		
		public static const SHOW_STARTED:String = "BS";
		public static const SHOW_COMPLETE:String = "ES";
		
		protected var _data:Object = null;
		
		public function TrackingPointEvent(type:String, data:Object = null, bubbles:Boolean = false, cancelable:Boolean = false) {
			super(type, bubbles, cancelable);
			if(data != null) _data = data;
		}

        public function get eventType():String {
        	if(hasTrackingPoint()) {
        		return trackingPoint.type;
        	}
        	return null;
        }
        
        public function isAdStartEvent():Boolean {
        	return (eventType == LINEAR_AD_STARTED);	
        }

        public function isAdCompleteEvent():Boolean {	
        	return (eventType == LINEAR_AD_COMPLETE);	
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
		
		public function hasTrackingPoint():Boolean {
			return (_data != null && (data is TrackingPoint));
		}
		
		public function get trackingPoint():TrackingPoint {
			return _data as TrackingPoint;
		}
		
		public override function clone():Event {
			return new TrackingPointEvent(type, _data, bubbles, cancelable);
		}
		
		public override function toString():String {
			return _data.toString();
		}
	}
}