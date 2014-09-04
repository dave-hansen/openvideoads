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
	import org.openvideoads.util.NetworkResource;
	import org.openvideoads.util.Timestamp;

	public class ProgressTrackingEvent extends TrackingEvent {
		
		protected var _offset:String = null;
		
		public function ProgressTrackingEvent(offset:String = null, url:NetworkResource = null, alwaysFire:Boolean=false) {
			super(TrackingEvent.EVENT_PROGRESS, url, alwaysFire);
			_offset = offset;
			CONFIG::debugging { doLog("Created progress tracking event - offset is " + offset, Debuggable.DEBUG_TRACKING_EVENTS); }
		}
		
		public function set offset(offset:String):void {
			_offset = offset;
		}
		
		public function get offset():String {
			return _offset;
		}
		
		// Duration is in seconds, millsecondFactor is 1000 to convert the timing to milliseconds
		
		public function calculateStartTime(duration:int, millsecondFactor:int):Number {
			if(_offset != null) {
				if(_offset.indexOf(":") > -1) {
					return Timestamp.timestampToMilliseconds(_offset);
				}
				else if(_offset.indexOf("%") > 0) {
					// it's a percentage offset format - e.g. 30%
					var percentageRate:Number = new Number(_offset.substr(0, _offset.indexOf("%")));
					if(percentageRate > 0 && percentageRate <= 100 && duration > 0) {
						return Math.round((duration * millsecondFactor) / (100 / percentageRate));
					}
					return 0;
				}
				else {
					// assume it's a millisecond number
					return new Number(_offset);
				}
			}
			return 0;
		}
	}
}