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
	import org.openvideoads.util.StringUtils;
	import org.openvideoads.vast.config.ConfigLoadListener;
	
	/**
	 * @author Paul Schulz
	 */
	public class DebugConfigGroup extends ConfigLoader {
		private var _debugger:String = "firebug";
		private var _levels:String = "fatal, config";

		public function DebugConfigGroup(config:Object=null, onLoadedListener:ConfigLoadListener=null) {
			super(config, onLoadedListener);
		}

        public override function initialise(config:Object=null, onLoadedListener:ConfigLoadListener=null, forceEnable:Boolean=false):void {
        	markAsLoading();
        	super.initialise(config, onLoadedListener);
			if(config != null) {
				if(config.levels != undefined) this.levels = config.levels;
				if(config.debugger != undefined) this.debugger = config.debugger;
			}        	
			markAsLoaded();
        }

		public function debuggersSpecified():Boolean {
			return (_debugger != null);
		}
		
		public function set debugger(debugger:String):void {
			_debugger = debugger;
		}
		
		public function get debugger():String {
			return _debugger;
		}
		
		public function set levels(levels:String):void {
			if(levels != null) {
				if(!StringUtils.isEmpty(levels)) {
					_levels = levels;			
				}
			}
		}
		
		public function get levels():String {
			return _levels;
		}
		
		public function debugLevelSpecified():Boolean {
			return (_levels != null);
		}
		
		public function outputingDebug():Boolean {
			return StringUtils.trim(_levels).toUpperCase() != "NONE";
		}
	}
}