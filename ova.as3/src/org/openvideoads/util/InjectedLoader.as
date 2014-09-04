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
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.net.URLRequest;
	import flash.utils.ByteArray;
	import flash.utils.Timer;
	
	/**
	 * @author Paul Schulz
	 */
	public class InjectedLoader extends TransformingLoader {
		protected var _delayTimer:Timer = null;

		public function InjectedLoader() {
		}
		
		public override function load(request:URLRequest):void {
		}
		
		public function process(data:String):void {
			this.data = data;
			_delayTimer = new Timer(300, 1);
		    _delayTimer.addEventListener(TimerEvent.TIMER, onDelayTimeEvent);
		    _delayTimer.start();	
		}

		private function onDelayTimeEvent(e:TimerEvent):void {
			this.dispatchEvent(new Event(Event.COMPLETE));
		}
				
		public function getBytesLoaded():uint {
			if(this.data != null) {
				var b:ByteArray = new ByteArray();
   				b.writeUTFBytes(this.data);
   				return b.length;
			}
			return 0;
		}
	}
}