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
package org.openvideoads.base {
	import org.openvideoads.base.Debuggable;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	
	/**
	 * @author Paul Schulz
	 */
	public class EventController extends Debuggable {
		protected var _eventDispatcher:EventDispatcher = new EventDispatcher();

		public function EventController() {
			super();
		}

        public function dispatchEvent(event:Event):void {
        	_eventDispatcher.dispatchEvent(event);
        }
        
        public function addEventListener(type:String, listener:Function, useCapture:Boolean = false, priority:int = 0, useWeakReference:Boolean = false):void {
        	_eventDispatcher.addEventListener(type, listener, useCapture, priority, useWeakReference);
        }
        
        public function removeEventListener(type:String, listener:Function, useCapture:Boolean = false):void {
        	_eventDispatcher.removeEventListener(type, listener, useCapture);
        }
	}
}