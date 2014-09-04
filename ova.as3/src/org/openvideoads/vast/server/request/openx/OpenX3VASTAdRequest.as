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
package org.openvideoads.vast.server.request.openx {
	import org.openvideoads.vast.server.request.AdServerRequest;

	/**
	 * @author Paul Schulz
	 */
	public class OpenX3VASTAdRequest extends AdServerRequest {
		public function OpenX3VASTAdRequest(config:OpenX3ServerConfig=null) {
			super((config != null) ? config : new OpenX3ServerConfig());
		}
		
		public override function get replaceIds():Boolean {
			return false;
		}

		protected override function replaceZones(template:String):String {
			var zoneIDs:String = "";
			if(_zones != null) {
				for(var i:int = 0; i < _zones.length; i++) {
					if(zoneIDs.length > 0) {
						zoneIDs += "&";
					}
					zoneIDs += _zones[i].zone;		
				}
			}
			var thePattern:RegExp = new RegExp("__zones__", "g");
			template = template.replace(thePattern, zoneIDs);
	 		_formedRequest = template;
	 		return _formedRequest;
	 	}
	}
}