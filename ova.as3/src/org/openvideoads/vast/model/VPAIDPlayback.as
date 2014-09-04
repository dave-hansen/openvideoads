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
package org.openvideoads.vast.model {
	import org.openvideoads.vast.overlay.OverlayView;
	import org.openvideoads.vast.overlay.VPAIDWrapper;
	import org.openvideoads.vpaid.IVPAID;
	
	/**
	 * @author Paul Schulz
	 */
	public interface VPAIDPlayback {
		function registerStartHandler(onCompleteHandler:Function):void;
		function registerErrorHandler(onErrorHandler:Function):void;
		function registerLogHandler(onLogHandler:Function):void;
		function registerCompleteHandler(onCompleteHandler:Function):void;
		function registerExpandedChangeHandler(onExpandedChangeHandler:Function):void;
		function registerLinearChangeHandler(onLinearChangeHandler:Function):void;
		function registerRemainingTimeChangeHandler(onTimeChangeHandler:Function):void;

		function registerLoadedHandler(onLoadedHandler:Function):void;
		function registerImpressionHandler(onImpressionHandler:Function):void;
		function registerClickThruHandler(onClickThruHandler:Function):void;
		function registerUserAcceptInvitationHandler(onUserAcceptInvitationHandler:Function):void;
		function registerMinimizeHandler(onMinimizeHandler:Function):void;
		function registerCloseHandler(onCloseHandler:Function):void;
		function registerVolumeChangeHandler(onAdVolumeChangeHandler:Function):void;
		function registerVideoStartHandler(onVideoStartHandler:Function):void;
		function registerVideoFirstQuartileHandler(onVideoFirstQuartileHandler:Function):void;
		function registerVideoMidpointHandler(onVideoMidpointHandler:Function):void;
		function registerVideoThirdQuartileHandler(onVideoThirdQuartileHandler:Function):void;
		function registerVideoCompleteHandler(onVideoCompleteHandler:Function):void;
		function registerAdSkippedHandler(onAdSkippedHandler:Function):void;
		function registerAdSizeChangeHandler(onAdSizeChangeHandler:Function):void;
		function registerAdSkippableStateChangeHandler(onAdSkippableStateChangeHandler:Function):void;
		function registerAdDurationChangeHandler(onAdDurationChangeHandler:Function):void;
		function registerAdInteractionHandler(onAdInteractionHandler:Function):void;

		function registerExternalAPICallHandler(externalAPICallHandler:Function):void;
		
		function registerAsVPAID(vpaidWrapper:VPAIDWrapper):Boolean;
		function startVPAID(width:Number=-1, height:Number=-1, mode:String="normal", passReferrer:Boolean=false, referrer:String=null):void;
		function getVPAID():IVPAID;
		function toRuntimeStateJSObject():Object;
		function isRunning():Boolean;
		function setMaxDurationTimeout(maxDurationTimeout:int):void;
		function enableMaxDurationTimeout():void;
		function disableMaxDurationTimeout():void;
		function resize(width:Number, height:Number, viewMode:String):void;
		function setOverlay(overlay:OverlayView):void;
		function getOverlay():OverlayView;
		function hasActiveOverlay():Boolean;
		function closeActiveOverlay():void;
		function unload():void;
		function pause():void;
		function resume():void;
	}
}