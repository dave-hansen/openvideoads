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

	public class VideoAdV3 extends VideoAdV2 {
		
		public function VideoAdV3() {
			super();
		}
		
		public override function hasProgressTrackingEvents():Boolean {
			return hasTrackingEventType(TrackingEvent.EVENT_PROGRESS);
		}
		
		public override function getProgressTrackingEvents():Array {
			return getTrackingEventsOfType(TrackingEvent.EVENT_PROGRESS);
		}
	}
}