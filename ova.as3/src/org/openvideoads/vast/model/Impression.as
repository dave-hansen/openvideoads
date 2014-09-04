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
package org.openvideoads.vast.model {
	import org.openvideoads.util.NetworkResource;
	
	/**
	 * @author Paul Schulz
	 */
	public class Impression extends NetworkResource {
		public function Impression(id:String, url:String) {
			super(id, url);
		}
		
		public function unload():void {
			super.close();
		}
		
		public override function toJSObject():Object {
			var o:Object = super.toJSObject();
			o.eventType = "impression";
			return o;
		}
	}
}