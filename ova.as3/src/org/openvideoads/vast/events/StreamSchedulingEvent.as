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
	
	import flash.events.Event;
	
	/**
	 * @author Paul Schulz
	 */
	public class StreamSchedulingEvent extends Event {
		public static const SCHEDULE:String = "schedule-stream";
		public static const REMOVE:String = "remove-stream";

		protected var _stream:Stream = null;
		protected var _scheduleIndex:int = -1;
		
		public function StreamSchedulingEvent(type:String, scheduleIndex:int, stream:Stream, bubbles:Boolean = false, cancelable:Boolean = false) {
			super(type, bubbles, cancelable);
			_scheduleIndex = scheduleIndex;
			_stream = stream;
		}
		
		public function set scheduleIndex(scheduleIndex:int):void {
			_scheduleIndex = scheduleIndex;
		}
		
		public function get scheduleIndex():int {
			return _scheduleIndex;
		}
		
		public function set stream(stream:Stream):void {
			_stream = stream;
		}
		
		public function get stream():Stream {
			return _stream;
		}		
	}
}