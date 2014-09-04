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
package org.openvideoads.vast.server.request.adify {
	import org.openvideoads.vast.server.config.AdServerConfig;
	import org.openvideoads.vast.server.config.CustomProperties;
	
	/**
	 * @author Paul Schulz
	 */
	public class AdifyServerConfig extends AdServerConfig {
		public function AdifyServerConfig(config:Object=null) {
			this.oneAdPerRequest = true;
			super("Adify", config);
		}

        /* 
         * An example URL IS:
         *     http://ad.afy11.net/ad?enc=4&asId=1000002629107&sf=0&ct=256
         */
		protected override function get defaultTemplate():String {
			return "__api-address__/ad?enc=__enc__&asId=__zone__&sf=__sf__&ct=__ct__";
		}
		
		protected override function get defaultCustomProperties():CustomProperties {
			return new CustomProperties(
				{
					"enc": "4",
					"sf": "0",
					"ct": "256"
				}
			);
		}
	}
}