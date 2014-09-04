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
package org.openvideoads.vast.server.request {
	import org.openvideoads.vast.server.request.direct.DirectVASTAdRequest;
	import org.openvideoads.vast.server.request.openx.OpenXVASTAdRequest;
	import org.openvideoads.vast.server.request.openx.OpenX3VASTAdRequest;
	import org.openvideoads.vast.server.request.adtech.AdTechVASTAdRequest;
	import org.openvideoads.vast.server.request.adocean.AdOceanVASTAdRequest;
	import org.openvideoads.vast.server.request.oas.OasVASTAdRequest;
	import org.openvideoads.vast.server.request.doubleclick.DARTVASTAdRequest;
	import org.openvideoads.vast.server.request.oasis.OasisVASTAdRequest;
	import org.openvideoads.vast.server.request.adify.AdifyVASTAdRequest;
	import org.openvideoads.vast.server.request.lightningcast.LightningcastVASTAdRequest;
	import org.openvideoads.vast.server.request.liverail.LiverailVASTAdRequest;
	import org.openvideoads.vast.server.request.adform.AdformVASTAdRequest;
	import org.openvideoads.vast.server.request.injected.InjectedVASTAdRequest;
	import org.openvideoads.util.StringUtils;
	
	/**
	 * @author Paul Schulz
	 */
	public class AdServerRequestFactory {
		public static const AD_SERVER_DIRECT:String = "DIRECT";
		public static const AD_SERVER_INJECT:String = "INJECT";

		CONFIG::connectors {
			public static const AD_SERVER_ADFORM:String = "ADFORM";
			public static const AD_SERVER_ADIFY:String = "ADIFY";
			public static const AD_SERVER_ADOCEAN:String = "ADOCEAN";
			public static const AD_SERVER_ADTECH:String = "ADTECH";
			public static const AD_SERVER_DART:String = "DART";
			public static const AD_SERVER_LIGHTNINGCAST:String = "LIGHTNINGCAST";
			public static const AD_SERVER_LIVERAIL:String = "LIVERAIL";
			public static const AD_SERVER_OAS:String = "OAS"; //247 Real Media
			public static const AD_SERVER_OASIS:String = "OASIS";
			public static const AD_SERVER_OPENX_V2:String = "OPENX";
			public static const AD_SERVER_OPENX_V3:String = "OPENX3";
		}
		
		public static function create(type:String):AdServerRequest {
			if(StringUtils.matchesIgnoreCase(type, AD_SERVER_INJECT)) {
				return new InjectedVASTAdRequest();
			}
			CONFIG::connectors {
				switch(type.toUpperCase()) {
					case AD_SERVER_ADIFY:
						return new AdifyVASTAdRequest();
	
					case AD_SERVER_ADFORM:
						return new AdformVASTAdRequest();

					case AD_SERVER_ADOCEAN:
						return new AdOceanVASTAdRequest();
	
					case AD_SERVER_ADTECH:
						return new AdTechVASTAdRequest();
	
					case AD_SERVER_DART:
						return new DARTVASTAdRequest();
	
					case AD_SERVER_LIGHTNINGCAST:
						return new LightningcastVASTAdRequest();
	
					case AD_SERVER_LIVERAIL:
						return new LiverailVASTAdRequest();
	
					case AD_SERVER_OAS:
						return new OasVASTAdRequest();
	
					case AD_SERVER_OASIS:
						return new OasisVASTAdRequest();
	
					case AD_SERVER_OPENX_V2:
						return new OpenXVASTAdRequest();
	
					case AD_SERVER_OPENX_V3:
						return new OpenX3VASTAdRequest();
				}
			}
			
			return new DirectVASTAdRequest();
		}
	}
}