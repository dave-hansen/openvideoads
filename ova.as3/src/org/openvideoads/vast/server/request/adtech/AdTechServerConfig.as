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
 package org.openvideoads.vast.server.request.adtech {
	import org.openvideoads.vast.server.config.AdServerConfig;
	import org.openvideoads.vast.server.config.CustomProperties;
	
	/**
	 * @author Paul Schulz
	 */
	public class AdTechServerConfig extends AdServerConfig {

		public function AdTechServerConfig(config:Object=null) {
			this.oneAdPerRequest = true;
			this.forceImpressionServing = true;
			super("AdTech", config);
		}
		
		/* 
		 * An example AdTech request:
		 *     http://de.at.atwola.com/
		 *          ?adrawdata/3.0/515.1/
		 *          2189418/0/1725/
		 *          noperf=1;
		 *          cc=2;
		 *          header=yes;
		 *          alias=myalias;
		 *          cookie=yes;
		 *          adct=204;
		 *          key=key1+key2;
		 *          grp=[group];
		 *          misc=[TIMESTAMP]
		 */
		protected override function get defaultTemplate():String {
			return "__api-address__/__zone__/__nondynamic__;alias=__alias____aliaspostfix__;key=__key__;__key-value__;__cookie-name__=__cookie-value__;grp=__group__;misc=__random-number__";
		}
		
		protected override function get defaultCustomProperties():CustomProperties {
			return new CustomProperties(
				{
					"nondynamic": "noperf=1;cc=2;header=yes;cookie=yes;adct=204",
					"alias": "", 
					"aliaspostfix": "", 
					"key": "key1+key2", 
					"key-value": "", 
					"cookie-name": "",
					"cookie-value": "",
					"group": "[group]" 
				}
			);
		}
	}
}