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
package org.openvideoads.vast.server.request.oas {
	import org.openvideoads.vast.server.config.AdServerConfig;
	import org.openvideoads.vast.server.config.CustomProperties;

	/**
	 * @author Pedro Faustino, 24/7 Real Media
	 */
	public class OasServerConfig extends AdServerConfig {
		public function OasServerConfig(config:Object=null) {
			this.oneAdPerRequest = true;
			super("OAS", config);
		}

		/* 
		 * An example OAS request:
	 	 *     http://oas.server.com/RealMedia/ads/adstream_sx.ads/
		 *          site.com/sports/actual/
		 *          [RANDOM_NUMBER]@
		 *          x01?
		 *          keyword1=keyvalue1
		 */
	
		protected override function get defaultTemplate():String {
			return "__api-address__/__sitepage__/__random-number__@__listpos__?__target__";
		}
	
		protected override function get defaultCustomProperties():CustomProperties {
			return new CustomProperties(
				{
					"target": ""
				}
			);
		}
	}
}