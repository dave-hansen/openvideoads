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
package org.openvideoads.vast.analytics {
	import org.openvideoads.vast.server.request.AdServerRequest;
	import org.openvideoads.vast.schedule.ads.AdSlot;
	
	public interface AnalyticsInterface {

        // Ad call tracking		

		function fireAdCallTracking(type:String, adRequest:AdServerRequest, wrapped:Boolean=false, additionalParams:*=null):void;
		
        // Template load tracking

        function fireTemplateLoadTracking(type:String, additionalParams:*=null):void;

        // Pre-loaded ad scheduling tracking		

        function fireAdSchedulingTracking(type:String, adSlot:AdSlot, additionalParams:*=null):void;
        
        // On-demand ad slot load tracking		

        function fireAdSlotTracking(type:String, adSlot:AdSlot, additionalParams:*=null):void;

		// Impression tracking

		function fireImpressionTracking(type:String, adSlot:AdSlot, ad:*, additionalParams:*=null):void;

        // Standard linear ad playback tracking

        function fireAdPlaybackTracking(type:String, adSlot:AdSlot, ad:*, additionalParams:*=null):void;

        // Standard VPAID playback tracking

        function fireVPAIDPlaybackTracking(type:String, adSlot:AdSlot, ad:*, additionalParams:*=null):void;

        // Standard linear and non-linear ad click-through tracking

        function fireAdClickTracking(type:String, adSlot:AdSlot, ad:*, additionalParams:*=null):void;
	}
}
