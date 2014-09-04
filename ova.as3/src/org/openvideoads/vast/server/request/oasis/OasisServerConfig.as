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
package org.openvideoads.vast.server.request.oasis {
	import org.openvideoads.vast.server.config.AdServerConfig;
	import org.openvideoads.vast.server.config.CustomProperties;

	/**
	 * @author Paul Schulz
	 */
	public class OasisServerConfig extends AdServerConfig {
		public function OasisServerConfig(config:Object=null) {
			this.oneAdPerRequest = true;
			super("OASIS", config);
		}

		/* 
		 * An example OASIS request:
		 *      http://ahs2.adhostingsolutions.com/oasisi-i.php?s=1566&w=1&h=1&k=some_keyword_value&t=_blank
		 */
	
		protected override function get defaultTemplate():String {
			return "__api-address__?s=__zone__&w=__w__&h=__h__&k=__k__&t=__t__&cb=__random-number__";
		}
	
		protected override function get defaultCustomProperties():CustomProperties {
			return new CustomProperties(
				{
					"w": "1",
					"h": "1",
					"k": "",
					"t": "_blank"
				}
			);
		}
	}
}