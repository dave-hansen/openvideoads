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
	import org.openvideoads.vast.schedule.ads.templates.*;

	/**
	 * @author Paul Schulz
	 */
	public class OverlaysConfig extends Debuggable {
		protected var _replay:Boolean = true;
		
		public function OverlaysConfig(config:Object=null) {
			initialise(config);
		}
		
		public function initialise(config:Object):void {
			if(config != null) {
				if(config.hasOwnProperty("replay")) {
					this.replay = config.replay;
				}
			}
		}
				
		public function set replay(value:*):void {
			if(value is String) {
				_replay = (String(value).toUpperCase() == "TRUE") ? true : false;											
			}
			else _replay = value;
		}
		
		public function get replay():Boolean {
			return _replay;
		}
	}
}