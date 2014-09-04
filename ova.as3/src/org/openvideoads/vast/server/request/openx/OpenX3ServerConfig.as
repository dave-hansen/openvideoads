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
	public class OpenX3ServerConfig extends AdServerConfig {
		public function OpenX3ServerConfig(config:Object=null) {
			super("OpenX3", config);
		}

        /*
         * Example URLs are:
         *      http://openxenterprise.com/v/1.0/av?auid=1&test=true           - HTML companion only
         *      http://openxenterprise.com/v/1.0/av?auid=9&test=true           - Linear ad
         *      http://openxenterprise.com/v/1.0/av?auid=11&test=true          - Non-linear ad
         *      http://openxenterprise.com/v/1.0/av?pgid=105&test=true         - Non-linear and companion
         *      http://openxenterprise.com/v/1.0/av?auid=9&pgid=105&test=true  - Linear and Non-Linear with Companion
         *      http://openxenterprise.com/v/1.0/av?pgid=105&test=true&c.gender=male
         */
		protected override function get defaultTemplate():String {
			return "__api-address__?__zones__&test=true";
		}
		
		protected override function get defaultCustomProperties():CustomProperties {
			return new CustomProperties();
/*
			return "__api-address__?__zones__&test=__test__&VMaxd=__VMaxd__&VPI=__VPI__&VHt=__VHt__&VWd=__VWd__&VBw=__VBw__&Vstrm=__Vstrm__&o=__o__&cs=__cs__&cb=__cb__&ch=__ch__&plg=__plg__&r=__r__&ref=__ref__&res=__res__&tg=__tg__&tid=__tid__&tz=__tz__&url=__url__&__customVariables__";
				{
					"test": "",
					"VMaxd": "",
					"VPI": "",
					"VHt": "",
					"VWd": "",
					"VBw": "",
					"Vstrm": "",
					"o": "",
					"cs": "",
					"cb": "",
					"ch": "",
					"plg": "",
					"r": "",
					"ref": "",
					"res": "",
					"tg": "",
					"tid": "",
					"tz": "",
					"url": "",
					"customVariables": ""
				}
			);
*/
		}
	}	
}