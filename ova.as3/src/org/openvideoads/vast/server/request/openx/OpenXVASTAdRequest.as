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
	public class OpenXVASTAdRequest extends AdServerRequest {
		public function OpenXVASTAdRequest(config:OpenXServerConfig=null) {
			super((config != null) ? config : new OpenXServerConfig());
		}
		
		public override function get replaceIds():Boolean {
			return false;
		}
		
		protected override function replaceDuplicatesAsBinary(template:String):String {
			var thePattern:RegExp = new RegExp("__allow-duplicates-as-binary__", "g");
			template = template.replace(thePattern, (_config.allowAdRepetition) ? "0" : "1");
			return template;
		}
		
		protected override function replaceZones(template:String):String {
			var zoneIDs:String = "";
			if(_zones != null) {
				for(var i:int = 0; i < _zones.length; i++) {
					if(zoneIDs.length > 0) {
						zoneIDs += "%7C";
					}
					zoneIDs += _zones[i].id + "%3D" + _zones[i].zone;		
				}
			}
			var thePattern:RegExp = new RegExp("__zones__", "g");
			template = template.replace(thePattern, zoneIDs);
			return template;	
		}
		
	 	public override function formRequest(zones:Array=null):String {
	 		var template:String = super.formRequest(zones);
	 		// check to see if the __target__ has been replaced - if not, clean up the URL
			var thePattern:RegExp = new RegExp("&__target__", "g");
	 		template = template.replace(thePattern, "");
	 		_formedRequest = template;
	 		return _formedRequest;
	 	}
	}
}