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
package org.openvideoads.vast.events {
	import flash.events.Event;
	
	import org.openvideoads.vast.server.request.AdServerRequest;
	
	/**
	 * @author Paul Schulz
	 */
	public class AdTagEvent extends Event {
	
		public static const CALL_STARTED:String = "adcall-started";
		public static const CALL_FAILOVER:String = "adcall-failover";
		public static const CALL_COMPLETE:String = "adcall-complete";
	
		protected var _requestInfo:*;
		
		public function AdTagEvent(type:String, requestInfo:*, bubbles:Boolean = false, cancelable:Boolean = false) {
			super(type, bubbles, cancelable);
			_requestInfo = requestInfo;
		}
		
		public function calledOnDemand():Boolean {
			if(_requestInfo != null) {
				if(_requestInfo.masterTag != null) {
					return _requestInfo.masterTag.callOnDemand;
				}
			}	
			return false;
		}
		
		public function includesLinearAds():Boolean {
			if(_requestInfo != null) {
				if(_requestInfo.masterTag != null) {
					return _requestInfo.masterTag.includesLinearAds();	
				}
			}
			return false;
		}
		
		public function get requestInfo():* {
			return _requestInfo;
		}
	}
}