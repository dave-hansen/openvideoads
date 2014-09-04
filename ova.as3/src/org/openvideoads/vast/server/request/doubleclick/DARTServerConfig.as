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
	import org.openvideoads.vast.server.config.AdServerConfig;
	import org.openvideoads.vast.server.config.CustomProperties;

	/**
	 * @author Paul Schulz
	 */
	public class DARTServerConfig extends AdServerConfig {
		public function DARTServerConfig(config:Object=null) {
			this.oneAdPerRequest = true;
			super("DART", config);
		}

		/* 
		 * An example DART request:
		 *      http://ad.doubleclick.net/pfadx/AngelaSite;kw=angelaredirect;sz=468x60;ord=3402677;dcmt=text/html
		 */
	
		protected override function get defaultTemplate():String {
			return "__api-address__/pfadx/__site__;kw=__redirect__;sz=__size__;ord=__zone__;dcmt=__dcmt__";
		}
	
		protected override function get defaultCustomProperties():CustomProperties {
			return new CustomProperties(
				{
					"size": "460x360",
					"dcmt": "text/html"
				}
			);
		}
	}
}