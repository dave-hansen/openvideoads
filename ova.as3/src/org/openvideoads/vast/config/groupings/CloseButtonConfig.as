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
	import org.openvideoads.util.StringUtils;
	
	/**
	 * @author Paul Schulz
	 */
	
	public class CloseButtonConfig extends Debuggable {
		protected var _enable:Boolean = true;
		protected var _region:String = "overlay-close-button";
		protected var _program:Boolean = true;
		
		public function CloseButtonConfig(config:*=null) {
			super();
			initialise(config);
		}
		
		public function initialise(config:*):void {
			if(config != null) {
				if(config is String) {
					_enable = StringUtils.validateAsBoolean(config);
				}
				else if(config is Boolean) {
					_enable = config;
				}
				else {
					if(config.hasOwnProperty("enable")) {
						_enable = StringUtils.validateAsBoolean(config.enable);					
					}
					if(config.hasOwnProperty("region")) {
						_region = config.region;
					}
					if(config.hasOwnProperty("program")) {
						_program = StringUtils.validateAsBoolean(config.program);
					}
				}
			}
		}
		
		public function get enabled():Boolean {
			return _enable;
		}
		
		public function get region():String {
			return _region;
		}
		
		public function get program():Boolean {
			return _program;
		}
	}
}