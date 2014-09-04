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
package org.openvideoads.util {
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.events.TimerEvent;
	import flash.net.URLRequest;
	import flash.utils.Timer;
	
	import org.openvideoads.base.Debuggable;
	import org.openvideoads.events.TimedLoaderEvent;

	/**
	 * @author Paul Schulz
	 */
	
	public class TimedURLLoader extends TransformingLoader {
		protected var _maxWaitTimeInMilliseconds:int = -1;
		protected var _timeoutTimer:Timer = null;
		
		public function TimedURLLoader(maxWaitTimeInMilliseconds:Number=-1) {
			super();
			_maxWaitTimeInMilliseconds = maxWaitTimeInMilliseconds;
			addEventListener(Event.COMPLETE, stopTimerHandler);
			addEventListener(ErrorEvent.ERROR, stopTimerHandler);
			addEventListener(SecurityErrorEvent.SECURITY_ERROR, stopTimerHandler);
			addEventListener(IOErrorEvent.IO_ERROR, stopTimerHandler);
		}
		
		public override function load(request:URLRequest):void {
			if(_maxWaitTimeInMilliseconds > 0) {
				startTimeoutTimer();
			}
			super.load(request);
		}

		protected function stopTimerHandler(e:Event):void {
			if(_timeoutTimer != null) stopTimeoutTimer();
		}
		
		protected function startTimeoutTimer():void {
			if(_timeoutTimer != null) stopTimeoutTimer();
			if(_maxWaitTimeInMilliseconds > 0) {
				CONFIG::debugging {doLog("HTTP timed load started - max wait time is " + _maxWaitTimeInMilliseconds + " milliseconds", Debuggable.DEBUG_HTTP_CALLS); }
				_timeoutTimer = new Timer(_maxWaitTimeInMilliseconds, 1);
				_timeoutTimer.addEventListener(TimerEvent.TIMER, timeoutCall);
				_timeoutTimer.start();			
			}
		}
		
		protected function stopTimeoutTimer():void {
			if(_timeoutTimer != null) {
				_timeoutTimer.stop();
				_timeoutTimer = null;
				CONFIG::debugging {doLog("HTTP timer has been stopped", Debuggable.DEBUG_HTTP_CALLS); }
			}
		}
		
		protected function timeoutCall(event:TimerEvent):void {
			this.close();
			stopTimeoutTimer();
			CONFIG::debugging {doLog("HTTP timed load has forcibly timed out", Debuggable.DEBUG_HTTP_CALLS); }	
			dispatchEvent(new TimedLoaderEvent(TimedLoaderEvent.TIMED_OUT));		
		}	
		
		// DEBUG METHODS
		
		CONFIG::debugging
		protected function doLog(data:String, level:int=1):void {
			Debuggable.getInstance().doLog(data, level);
		}
		
		CONFIG::debugging
		protected function doTrace(o:Object, level:int=1):void {
			Debuggable.getInstance().doTrace(o, level);
		}
	}
}