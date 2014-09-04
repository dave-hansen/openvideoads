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
package org.openvideoads.vast.server.request.lightningcast {
	import org.openvideoads.vast.server.config.AdServerConfig;
	import org.openvideoads.vast.server.config.CustomProperties;
	
	/**
	 * @author Paul Schulz
	 */
	public class LightningcastServerConfig extends AdServerConfig {
		public function LightningcastServerConfig(config:Object=null) {
			this.oneAdPerRequest = true;
			super("Lightningcast", config);
		}

        /* 
         * An example URL IS:
         *     http://web.lightningcast.net/servlets/getPlaylist?ver=2.0&nwid=106414&content=http%3A//streaming.openvideoads.org/shows/the-black-hole.mp4&level=Test_Implent%3ATest_400_300&format=Video-Flash-400-400x300&uid=ABC&regions=Standardbanner&crlen=t&resp=VAST
         */
		protected override function get defaultTemplate():String {
			return "__api-address__?ver=__ver__&nwid=__nwid__&content=__content__&level=__level__&format=__format__&uid=__uid__&regions=__regions__&crlen=__crlen__&resp=__resp__";
		}
		
		protected override function get defaultCustomProperties():CustomProperties {
			return new CustomProperties(
				{
					"api-address": "http://web.lightningcast.net/servlets/getPlaylist",
					"version": "2.0",
					"nwid": "",
					"level": "",
					"format": "",
					"uid": "",
					"regions": "",
					"crlen": "t",
					"resp": "VAST"
				}
			);
		}
	}
}
