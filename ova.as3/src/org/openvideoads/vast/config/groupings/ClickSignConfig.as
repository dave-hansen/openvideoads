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
	import org.openvideoads.regions.config.CloseButtonConfig;
	import org.openvideoads.regions.config.RegionViewConfig;
	
	/**
	 * @author Paul Schulz
	 */
	public class ClickSignConfig extends RegionViewConfig {
		protected var _enabled:Boolean = true;
		protected var _target:String = "_blank";
		
		public function ClickSignConfig(config:Object=null) {
			super(null);
			_id = "reserved-click-me-prompt";
	    	_verticalAlignPosition = "CENTER";
			_horizontalAlign = "CENTER"; 
			_width = 250;
			_height = 32;
			_opacity = 0.5;
			_borderRadius = 20;
			_backgroundColor = "#000000";
            _style = ".smalltext { font-size:12; }";
            _html = "<p class=\"smalltext\" align=\"center\">CLICK FOR MORE INFORMATION</p>";
            _scaleRate = 0.75;
            _closeButton = new org.openvideoads.regions.config.CloseButtonConfig({ enabled: false });
			setup(config);
			if(config != null) {
				if(config.closeButton != undefined) {
					if(config.closeButton is org.openvideoads.regions.config.CloseButtonConfig) {
						_closeButton = config.closeButton;					
					}
					else _closeButton = new org.openvideoads.regions.config.CloseButtonConfig(config.closeButton);
				}
				if(config.enabled != undefined) {
					if(config.enabled is String) {
						this.enabled = ((config.enabled.toUpperCase() == "TRUE") ? true : false);											
					}
					else this.enabled = config.enabled;									
				}	
				if(config.target != undefined) {
					_target = config.target; 
				}			
			}
		}
		
		public function set enabled(enabled:Boolean):void {
			_enabled = enabled;
		}
		
		public function get enabled():Boolean {
			return _enabled;
		}

		public function set target(target:String):void {
			_target = target;
		}
		
		public function get target():String {
			return _target;
		}
	}
}