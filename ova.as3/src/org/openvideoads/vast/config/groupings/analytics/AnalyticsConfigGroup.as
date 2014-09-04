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
package org.openvideoads.vast.config.groupings.analytics {
	import org.openvideoads.base.Debuggable;
	import org.openvideoads.util.StringUtils;
	import org.openvideoads.vast.config.ConfigLoadListener;
	import org.openvideoads.vast.config.groupings.ConfigLoader;
	import org.openvideoads.vast.config.groupings.analytics.google.GoogleAnalyticsConfigGroup;
	
	public class AnalyticsConfigGroup extends ConfigLoader {
		protected var _google:GoogleAnalyticsConfigGroup; 

		public static const GOOGLE_ANALYTICS:String = "GA";
		
		public function AnalyticsConfigGroup(config:Object=null, onLoadedListener:ConfigLoadListener=null) {
			super(config, onLoadedListener);
		}
		
		public override function initialise(config:Object=null, onLoadedListener:ConfigLoadListener=null, forceEnable:Boolean=false):void {
			markAsLoading();
			super.initialise(config, onLoadedListener);			
			if(config != null) {
				if(config.google != undefined) {
					google.initialise(config.google, null, forceEnable);
				}
			}		
			markAsLoaded();
		}

		public override function isOVAConfigLoading():Boolean {
			if(_google != null) {
				return (loading() && _google.loading());				
			}
			return loading();
		}

		public function update(values:Array):void {
			if(values != null) {
				for(var i:int=0; i < values.length; i++) {
					if(StringUtils.matchesIgnoreCase(values[i].type, GOOGLE_ANALYTICS)) {
						google.update(values[i]);
					}
				}
			}
		}
		
		public function googleEnabled():Boolean {
			return google.enabled;
		}
		
		public function set google(config:*):void {
			if(config is GoogleAnalyticsConfigGroup) {
				_google = config;			
			}
			else _google = new GoogleAnalyticsConfigGroup(config);
		}
		
		public function get google():GoogleAnalyticsConfigGroup {
			if(_google == null) _google = new GoogleAnalyticsConfigGroup();
			return _google;
		}
	}
}