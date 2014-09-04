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
package org.openvideoads.vast.schedule.ads {
	import org.openvideoads.vast.events.AdSlotLoadEvent;
	import org.openvideoads.vast.server.request.AdServerRequest;
	
	/**
	 * @author Paul Schulz
	 */
	public interface AdSlotOnDemandLoadListener {
		function onAdSlotLoaded(event:AdSlotLoadEvent):void;
		function onAdSlotLoadError(event:AdSlotLoadEvent):void;
		function onAdSlotLoadTimeout(event:AdSlotLoadEvent):void;
		function onAdSlotLoadDeferred(event:AdSlotLoadEvent):void;
		function onAdCallStarted(request:AdServerRequest):void;
		function onAdCallFailover(masterRequest:AdServerRequest, failoverRequest:AdServerRequest):void;
		function onAdCallComplete(request:AdServerRequest, hasAds:Boolean):void;
	}
}