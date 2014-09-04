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
package org.openvideoads.vast.config.groupings.analytics.google {
	import flash.display.DisplayObject;
	
	import org.openvideoads.util.StringUtils;
	import org.openvideoads.vast.config.ConfigLoadListener;
	import org.openvideoads.vast.config.groupings.ConfigLoader;

	public class GoogleAnalyticsConfigGroup extends ConfigLoader {
		protected var _enabled:Boolean = true;
		protected var _ova:GoogleAnalyticsTrackingGroup = new GoogleAnalyticsTrackingGroup("OVA", { enable: true, impressions: { enable: true } });
		protected var _custom:GoogleAnalyticsTrackingGroup = null;
		protected var _displayObject:DisplayObject = null;

		public static const OVA:String = "OVA"; 
		public static const CUSTOM:String = "CUSTOM"; 
				
		public function GoogleAnalyticsConfigGroup(config:Object=null, onLoadedListener:ConfigLoadListener=null) {
			super(config, onLoadedListener);
		}
		
		protected function syncDisplayObject():void {
			if(_displayObject != null) {
				ova.displayObject = _displayObject;
				if(_custom != null) _custom.displayObject = _displayObject;					
			}
		}
		
		public override function initialise(config:Object=null, onLoadedListener:ConfigLoadListener=null, forceEnable:Boolean=false):void {
			markAsLoading();
			super.initialise(config, onLoadedListener);			
			if(config != null) {
				if(config.enable != undefined) {
					if(config.enable is String) {
						_enabled = (config.enable.toUpperCase() == "TRUE");
					}
					else _enabled = config.enable;								
				}
				if(config.ova != undefined) {
					this.ova = new GoogleAnalyticsTrackingGroup("OVA", config.ova, forceEnable);
					if(config.ova.displayObject != null) _displayObject = config.ova.displayObject;
				}
				if(config.custom != undefined) {
					if(config.custom.displayObject != null) _displayObject = config.custom.displayObject;
					this.custom = new GoogleAnalyticsTrackingGroup("CUSTOM");
					this.custom.initialise(config.custom, forceEnable);
				}
				syncDisplayObject();				
			}		
			markAsLoaded();
		}

		public function update(values:Object):void {
			if(StringUtils.matchesIgnoreCase(values.element, OVA)) {
				ova.update(values);
			}
			if(StringUtils.matchesIgnoreCase(values.element, CUSTOM)) {
				custom.update(values);						
			}
			// Make sure the display object reference stays in sync
			if(values.displayObject != null) {
				_displayObject = values.displayObject;
			}
			syncDisplayObject();
		}

		public function get enabled():Boolean {
			if(_enabled == false) return false;
			return (ova.trackingEnabled || custom.trackingEnabled);	
		}
		
		public function set ova(ova:GoogleAnalyticsTrackingGroup):void {
			_ova = ova;
		}
		
		public function get ova():GoogleAnalyticsTrackingGroup {
			if(_ova == null) _ova = new GoogleAnalyticsTrackingGroup(OVA);
			return _ova;
		}
		
		public function set custom(custom:GoogleAnalyticsTrackingGroup):void {
			_custom = custom;
		}
		
		public function get custom():GoogleAnalyticsTrackingGroup {
			if(_custom == null) _custom = new GoogleAnalyticsTrackingGroup(CUSTOM, { enable: false });
			return _custom;
		}	
	}
}