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
package org.openvideoads.vast.server.response {
	import flash.events.Event;
	
	import org.openvideoads.vast.analytics.AnalyticsProcessor;
	import org.openvideoads.vast.server.request.AdServerRequest;
	
	/**
	 * @author Paul Schulz
	 */
	public interface TemplateLoadListener {
		function onAdCallStarted(request:AdServerRequest):void;
		function onAdCallFailover(masterRequest:AdServerRequest, failoverRequest:AdServerRequest):void;
		function onAdCallComplete(request:AdServerRequest, hasAds:Boolean):void;
		function onTemplateLoaded(template:AdServerTemplate):void;
		function onTemplateLoadError(event:Event):void;
		function onTemplateLoadTimeout(event:Event):void;
		function onTemplateLoadDeferred(event:Event):void;
		CONFIG::callbacks {
			function canFireAPICalls():Boolean;
			function canFireEventAPICalls():Boolean;
			function get useV2APICalls():Boolean;
			function get jsCallbackScopingPrefix():String;
		}
		function get analyticsProcessor():AnalyticsProcessor;
		function get uid():String;
	}
}