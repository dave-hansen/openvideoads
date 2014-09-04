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
package org.openvideoads.vast.server.request {	
	import flash.utils.Dictionary;
	
	import org.openvideoads.base.Debuggable;
	import org.openvideoads.vast.schedule.ads.AdSlot;
	
	/**
	 * @author Paul Schulz
	 */
	public class AdServerRequestGroup extends Debuggable {
		protected var _serverType:String = null;
		protected var _oneAdPerRequest:Boolean = false;
		protected var _adSlots:Array = new Array();
		
		public function AdServerRequestGroup(serverType:String, oneAdPerRequest:Boolean=false) {
			_serverType = serverType;
			_oneAdPerRequest = oneAdPerRequest;
		}

		public function get oneAdPerRequest():Boolean {
			return _oneAdPerRequest;				
		}
		
		public function addAdSlot(adSlot:AdSlot):void {
			_adSlots.push(adSlot);
		}
		
		public function get serverType():String {
			return _serverType;
		}
		
		public function set serverType(serverType:String):void {
			_serverType = serverType;
		}
		
		public function getAdServerRequests():Array {
			var requests:Array = new Array();
			if(_adSlots.length > 0) {
				var adServerRequest:AdServerRequest;
				for(var i:int=0; i < _adSlots.length; i++) {
					adServerRequest = AdServerRequestFactory.create(_adSlots[i].adServerConfig.serverType);
					adServerRequest.config = _adSlots[i].adServerConfig;
					adServerRequest.addZone(_adSlots[i].adSlotID, _adSlots[i].zone, _adSlots[i].slotType);
					requests.push(adServerRequest);
					_adSlots[i].adServerRequest = adServerRequest;
				}				
			}
			return requests;
		}
		
		public function getSingleAdServerRequest():AdServerRequest {
			if(_adSlots.length > 0) {
				if(_adSlots[0].adServerConfig.serverType != null) {
					var adServerRequest:AdServerRequest = AdServerRequestFactory.create(_adSlots[0].adServerConfig.serverType);
					adServerRequest.config = _adSlots[0].adServerConfig;
					if(adServerRequest != null) {
						for(var i:int=0; i < _adSlots.length; i++) {
							adServerRequest.addZone(_adSlots[i].adSlotID, _adSlots[i].zone, _adSlots[i].slotType);
							_adSlots[i].adServerRequest = adServerRequest;
						}
						return adServerRequest;
					}					
				}
			}
			return null;			
		}		
	}
}