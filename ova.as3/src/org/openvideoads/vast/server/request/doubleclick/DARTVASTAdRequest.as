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
package org.openvideoads.vast.server.request.doubleclick {
	import org.openvideoads.vast.server.request.AdServerRequest;

	/**
	 * @author Paul Schulz
	 */
	public class DARTVASTAdRequest extends AdServerRequest {
		public function DARTVASTAdRequest(config:DARTServerConfig=null) {
			super((config != null) ? config : new DARTServerConfig());
		}

		protected override function replaceRandomNumber(template:String):String {
			var thePattern:RegExp = new RegExp("__random-number__", "g");
			template = template.replace(thePattern, "1" + Math.floor(Math.random()*100000000));
			return template;	
		}

		protected override function replaceZone(template:String):String {
			if(_zones != null) {
				if(_zones.length > 0) {
					if(_zones[0].zone != null) {
						var results:Array = _zones[0].zone.split("@");
						if(results.length == 2) {
							var sitepage:String = results[0];
							var listpos:String = results[1];
							var sitepagePattern:RegExp = new RegExp("__sitepage__", "g");
							var listposPattern:RegExp = new RegExp("__listpos__", "g");
							template = template.replace(sitepagePattern, sitepage);
							template = template.replace(listposPattern, listpos);
						}						
					}
				}
			}

			return template;	
		}
		
		public override function verifyRequestURL(url:String, properties:Object):String {
			// check that the request has ord=[unique-string] replaced where appropriate
			
			// check that the URL has ';dcmt=text/html' appended to it so we get back the VAST response
			// in the appropriate format

			return url;
		}
	}	
}