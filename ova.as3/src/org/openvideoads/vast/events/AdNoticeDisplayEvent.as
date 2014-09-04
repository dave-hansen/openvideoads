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
	
	/**
	 * @author Paul Schulz
	 */
	public class AdNoticeDisplayEvent extends Event {
		public static const DISPLAY:String = "display-notice";
		public static const HIDE:String = "hide-notice";
		public static const TICK:String = "tick-notice";
		
		protected var _notice:Object = null;
		protected var _duration:int = 0;
		
		public function AdNoticeDisplayEvent(type:String, notice:Object = null, duration:int=0, bubbles:Boolean = false, cancelable:Boolean = false) {
			super(type, bubbles, cancelable);
			if(notice != null) _notice = notice;
			_duration = duration;
		}

 		public function hasNotice():Boolean {
 			return (_notice != null);
 		}		
 		
		public function set notice(notice:Object):void {
			_notice = notice;
		}
		
		public function get notice():Object {
			return _notice;
		}
		
		public function set duration(duration:int):void {
			_duration = duration;
		}
		
		public function get duration():int {
			return _duration;
		}
		
		public override function clone():Event {
			return new AdNoticeDisplayEvent(type, _notice, _duration, bubbles, cancelable);
		}
	}
}