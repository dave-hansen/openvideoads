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
package org.openvideoads.vast.server.config {
	import org.openvideoads.base.Debuggable;
	import org.openvideoads.vast.server.request.adform.AdformServerConfig;
	import org.openvideoads.vast.server.request.adify.AdifyServerConfig;
	import org.openvideoads.vast.server.request.adtech.AdTechServerConfig;
	import org.openvideoads.vast.server.request.direct.DirectServerConfig;
	import org.openvideoads.vast.server.request.doubleclick.DARTServerConfig;
	import org.openvideoads.vast.server.request.injected.InjectedServerConfig;
	import org.openvideoads.vast.server.request.lightningcast.LightningcastServerConfig;
	import org.openvideoads.vast.server.request.liverail.LiverailServerConfig;
	import org.openvideoads.vast.server.request.oas.OasServerConfig;
	import org.openvideoads.vast.server.request.oasis.OasisServerConfig;
	import org.openvideoads.vast.server.request.openx.OpenX3ServerConfig;
	import org.openvideoads.vast.server.request.openx.OpenXServerConfig;
	
	/**
	 * @author Paul Schulz
	 */
	public class AdServerConfigFactory {
		public static const AD_SERVER_ADFORM:String = "ADFORM";
		public static const AD_SERVER_ADIFY:String = "ADIFY";
		public static const AD_SERVER_ADTECH:String = "ADTECH";
		public static const AD_SERVER_DART:String = "DART";
		public static const AD_SERVER_DIRECT:String = "DIRECT";
		public static const AD_SERVER_INJECT:String = "INJECT";
		public static const AD_SERVER_LIGHTNINGCAST:String = "LIGHTNINGCAST";
		public static const AD_SERVER_LIVERAIL:String = "LIVERAIL";
		public static const AD_SERVER_OAS:String = "OAS"; //247 Real Media
		public static const AD_SERVER_OASIS:String = "OASIS";
		public static const AD_SERVER_OPENX_V2:String = "OPENX";
		public static const AD_SERVER_OPENX_V3:String = "OPENX3";
		
		public static function getAdServerConfig(type:String):AdServerConfig {
			switch(type.toUpperCase()) {
				case AD_SERVER_ADIFY:
					return new AdifyServerConfig();

				case AD_SERVER_ADFORM:
					return new AdformServerConfig();

				case AD_SERVER_ADTECH:
					return new AdTechServerConfig();
					
				case AD_SERVER_DART:
					return new DARTServerConfig();

				case AD_SERVER_DIRECT:
					return new DirectServerConfig();

				case AD_SERVER_INJECT:
					return new InjectedServerConfig();

				case AD_SERVER_LIGHTNINGCAST:
					return new LightningcastServerConfig();

				case AD_SERVER_LIVERAIL:
					return new LiverailServerConfig();

				case AD_SERVER_OAS:
					return new OasServerConfig();

				case AD_SERVER_OASIS:
					return new OasisServerConfig();

				case AD_SERVER_OPENX_V2:
					return new OpenXServerConfig();

				case AD_SERVER_OPENX_V3:
					return new OpenX3ServerConfig();

				default:
					CONFIG::debugging { Debuggable.getInstance().doLog("Cannot create AdServerConfig object for type " + type + " - creating Direct type as default", Debuggable.DEBUG_CONFIG); }
					return new DirectServerConfig();
			}
			return null;
		}
	}
}