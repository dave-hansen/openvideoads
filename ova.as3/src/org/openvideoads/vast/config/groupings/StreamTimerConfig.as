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
package org.openvideoads.vast.config.groupings {
	import org.openvideoads.base.Debuggable;

	/**
	 * @author Paul Schulz
	 */
	public class StreamTimerConfig extends Debuggable {
		protected var _enabled:Boolean = false;
		protected var _tickRate:Number = 100;
		protected var _cycles:Number = 100000;
		
		public function StreamTimerConfig(config:Object=null) {
			super();
			if(config != null) initialise(config);
		}
		
		public function initialise(config:Object):void {
			if(config != null) {
				if(config.enabled != undefined) {
					if(config.enabled is String) {
						_enabled = (config.enabled.toUpperCase() == "TRUE");
					}
					else _enabled = config.enabled;					
				}
				if(config.tickRate != undefined) {
					_tickRate = config.tickRate;
				}
				if(config.cycles != undefined) {
					_cycles = config.cycles;
				}
			}
		}
		
		public function set enabled(enabled:Boolean):void {
			_enabled = enabled;
		}
		
		public function get enabled():Boolean {
			return _enabled;
		}
		
		public function set tickRate(tickRate:Number):void {
			_tickRate = tickRate;
		}
		
		public function get tickRate():Number {
			return _tickRate;
		}
		
		public function set cycles(cycles:Number):void {
			_cycles = cycles;
		}
		
		public function get cycles():Number {
			return _cycles;
		}
	}
}