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
package org.openvideoads.regions.config {
	import org.openvideoads.base.Debuggable;
	import org.openvideoads.util.StringUtils;
	
	/**
	 * @author Paul Schulz
	 */
	public class RegionsConfig extends BaseRegionConfig {
		protected var _makeRegionsVisible:Boolean = false;
		protected var _regions:Array = new Array();
		protected var _skin:String = null;
		
		public function RegionsConfig(config:Object=null) {
			super(config);
		}

		public override function setup(config:Object):void {
			super.setup(config);
			id = "master";
			if(config != null) {
				// This is the new "regions.declarations" config - replaced old "overlays.regions" approach
				if(config.hasOwnProperty("declarations")) {
					regions = config.declarations;
				}
				if(config.closeButton != undefined) {
					closeButton = new CloseButtonConfig(config.closeButton);
				}
			}
		}

		public function hasRegionDefinitions():Boolean {
			return _regions.length > 0;
		}

		public function set makeRegionsVisible(visible:Boolean):void {
			_makeRegionsVisible = visible;
		}
		
		public function get makeRegionsVisible():Boolean {
			return _makeRegionsVisible;
		}
		
		public function set regions(newRegions:Array):void {
			_regions = new Array();
			if(newRegions != null) {
				CONFIG::debugging { doLog("Recording " + newRegions.length + " custom region declarations...", Debuggable.DEBUG_REGION_FORMATION); }
				for(var i:int=0; i < newRegions.length; i++) {
					var regionViewConfig:RegionViewConfig = new RegionViewConfig(properties);
					regionViewConfig.setup(newRegions[i]);
					_regions.push(regionViewConfig);
				}				
			}
		}
	
		public function get regions():Array {
			return _regions;
		}		
	}
}