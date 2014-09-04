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
	public class SeekerBarEvent extends Event {
		public static const TOGGLE:String = "toggle";
		
		protected var _turnOn:Boolean = false;
		
		public function SeekerBarEvent(type:String, turnOn:Boolean, bubbles:Boolean = false, cancelable:Boolean = false) {
			super(type, bubbles, cancelable);
			_turnOn = turnOn;
		}

        public function turnOn():Boolean {
        	return _turnOn;
        }
        
        public function turnOff():Boolean {
        	return !turnOn();
        }
        
		public override function clone():Event {
			return new SeekerBarEvent(type, _turnOn, bubbles, cancelable);
		}
	}
}