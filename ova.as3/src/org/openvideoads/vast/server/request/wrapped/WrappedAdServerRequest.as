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
package org.openvideoads.vast.server.request.wrapped {
	import org.openvideoads.base.Debuggable;
	import org.openvideoads.util.NetworkResource;
	import org.openvideoads.vast.server.config.AdServerConfig;
	import org.openvideoads.vast.server.request.AdServerRequest;

	public class WrappedAdServerRequest extends AdServerRequest {
		protected var _url:String = null;
		
		public function WrappedAdServerRequest(url:String, masterAdServerConfig:AdServerConfig) {
			super(new WrappedAdServerConfig(masterAdServerConfig));
			if(parseWrappedAdTags()){
				_url = processTemplate(url);			
			}
			else _url = url;
		}

		public override function isWrapped():Boolean {
			return true;
		}
		
	 	public override function formRequest(zones:Array=null):String {
	 		if(hasCacheBusterRequirement()) {
		 		// add in a cache-busting parameter as per VAST2 spec
		 		_formedRequest = NetworkResource.addParameterToURLString(_url, "cache-buster=" + Math.random());		
	 		}
	 		else _formedRequest = _url;
	 		return _formedRequest;
	 	}	
	}
}