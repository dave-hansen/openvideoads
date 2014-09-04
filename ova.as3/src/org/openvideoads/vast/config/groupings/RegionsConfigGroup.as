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
//	import flash.external.ExternalInterface;
	
	import org.openvideoads.regions.config.RegionsConfig;
	import org.openvideoads.vast.config.ConfigLoadListener;
	
	/**
	 * @author Paul Schulz
	 */
	public class RegionsConfigGroup extends RegionsConfig implements ConfigLoadListener {
		protected var _onLoadedListener:ConfigLoadListener = null;
		protected var _loading:Boolean = true;
		protected var _initialising:Boolean = false;
		
		public function RegionsConfigGroup(config:Object=null, onLoadedListener:ConfigLoadListener=null) {
			super(config);
		}
		
        public function initialise(config:Object=null, onLoadedListener:ConfigLoadListener=null):void {
        	markAsLoading();
        	setLoadedListener(onLoadedListener);
        	setup(config);
			markAsLoaded();
        }		

		public function setLoadedListener(onLoadListener:ConfigLoadListener):void {
			_onLoadedListener = onLoadListener;
		}

		public function hasLoadedListener():Boolean {
			return (_onLoadedListener != null);
		}
        
        public function initialising():Boolean {
        	return _initialising;
        }

        public function markAsLoading():void {
        	_initialising = true;
        	_loading = true;
        }
        
        public function markAsLoaded():void {
        	_loading = false;
        	_initialising = false;
			onOVAConfigLoaded();
        }
        
        public function isOVAConfigLoading():Boolean {
			return _loading;
		}
		
		public function onOVAConfigLoaded():void {
			_loading = false;
			if(isOVAConfigLoading() == false) {
				if(hasLoadedListener()) {
					_onLoadedListener.onOVAConfigLoaded();
				}
			}
		}
	}
}