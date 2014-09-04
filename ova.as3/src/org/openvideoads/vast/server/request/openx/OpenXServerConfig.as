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
	import org.openvideoads.vast.server.config.AdServerConfig;
	import org.openvideoads.vast.server.config.CustomProperties;
	
	/**
	 * @author Paul Schulz
	 */
	public class OpenXServerConfig extends AdServerConfig {
		public function OpenXServerConfig(config:Object=null) {
			super("OpenX", config);
		}

        /* 
         * An example URL IS:
         *    http://openx.openvideoads.org/openx/www/delivery/fc.php?
         *        script=bannerTypeHtml:vastInlineBannerTypeHtml:vastInlineHtml
         *        &zones=pre-roll0-0%3D15%7Cpre-roll0-1%3D15
         *        &nz=1
         *        &source=
         *        &r=3455833.2338929176
         *        &block=1&format=vast
         *        &charset=UTF_8
         */
		protected override function get defaultTemplate():String {
			return "__api-address__?script=__script__&zones=__zones__&nz=__nz__&source=__source__&r=__r__&block=__block__&format=__format__&charset=__charset__&__target__";
		}
		
		protected override function get defaultCustomProperties():CustomProperties {
			return new CustomProperties(
				{
					"script": "bannerTypeHtml:vastInlineBannerTypeHtml:vastInlineHtml",
					"nz": "1",
					"source": "",
					"r": "__random-number__",
					"block": "__allow-duplicates-as-binary__",
					"format": "vast",
					"charset": "UTF-8"
				}
			);
		}
	}
}