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
	import org.openvideoads.util.NetworkResource;
	import org.openvideoads.vast.config.ConfigLoadListener;
	
	public class RemoteConfigGroup extends NetworkResource implements ConfigLoadListener {
		protected var _trackerURL:String = "http://tracker.openvideoads.org/log-event.php";
		protected var _debugURL:String = "http://debug.openvideoads.org/log-debug.php";
		
		public function RemoteConfigGroup() {
			loadRemoteConfig();
		}

        public function initialise(config:Object=null):void {
			onOVAConfigLoaded();
        }
		
		public function isOVAConfigLoading():Boolean {
			return false;
		}

		public function initialising():Boolean {
			return false;
		}
				
		public function onOVAConfigLoaded():void {
		}
		
		public function markAsLoaded():void {
		}
		
		private function loadRemoteConfig():void {	
			// Not doing this for now
		}
		
		public function get trackerURL():String {
			return _trackerURL;
		}
	}
}