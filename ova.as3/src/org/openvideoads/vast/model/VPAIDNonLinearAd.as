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
	import org.openvideoads.base.Debuggable;
	import org.openvideoads.util.BrowserUtils;
	import org.openvideoads.util.PopupWindow;
	import org.openvideoads.util.StringUtils;
	import org.openvideoads.vast.events.OverlayAdDisplayEvent;
	import org.openvideoads.vast.events.VideoAdDisplayEvent;
	import org.openvideoads.vast.overlay.OverlayView;
	import org.openvideoads.vast.overlay.VPAIDWrapper;
	import org.openvideoads.vpaid.IVPAID;
	import org.openvideoads.vpaid.VPAIDEvent;

	/**
	 * @author Paul Schulz
	 */
	public class VPAIDNonLinearAd extends NonLinearFlashAd implements VPAIDPlayback {
		protected var _vpaidWrapper:VPAIDWrapper = null;
		protected var _adIsInLinearMode:Boolean = false;
		
		// VPAID 1.x event handlers
		
		protected var _onAdCompleteHandler:Function;
		protected var _onAdErrorHandler:Function;
		protected var _onAdLogHandler:Function;
		protected var _onAdStartHandler:Function;
		protected var _onAdLinearChangeHandler:Function;
		protected var _onAdExpandedChangeHandler:Function;
		protected var _onAdVolumeChangeHandler:Function;
		protected var _onLoadedHandler:Function;
		protected var _onImpressionHandler:Function;
		protected var _onClickThruHandler:Function;
		protected var _onUserAcceptInvitationHandler:Function;
		protected var _onMinimizeHandler:Function;
		protected var _onCloseHandler:Function;
		protected var _onVideoStartHandler:Function;
		protected var _onVideoFirstQuartileHandler:Function;
		protected var _onVideoMidpointHandler:Function;
		protected var _onVideoThirdQuartileHandler:Function;
		protected var _onVideoCompleteHandler:Function;
		protected var _onPausedHandler:Function;
		protected var _onPlayingHandler:Function;
		protected var _onRemainingTimeChangeHandler:Function;

		// Additional VPAID 2.x event handlers
		
		protected var _onAdSkippedHandler:Function;
		protected var _onAdSizeChangeHandler:Function;
		protected var _onAdSkippableStateChangeHandler:Function;
		protected var _onAdDurationChangeHandler:Function;
		protected var _onAdInteractionHandler:Function;

		protected var _externalAPICallHandler:Function = null;
		protected var _maxDurationTimeoutInSeconds:int = 65;
		protected var _maxDurationTimeoutEnabled:Boolean = false;
		protected var _activeOverlay:OverlayView = null;
		protected var _running:Boolean = false;
		protected var _stopped:Boolean = false;
		protected var _adTerminated:Boolean = false;

		public function VPAIDNonLinearAd() {
			super();
		}

		public override function signalLoadError(errorMessage:String):void {
			callbackOnError(errorMessage)
		}

		public function setOverlay(overlay:OverlayView):void {
			_activeOverlay = overlay;
		}
		
		public function getOverlay():OverlayView {
			return _activeOverlay;	
		}
		
		public function hasActiveOverlay():Boolean {
			return (_activeOverlay != null);
		}
		
		public function closeActiveOverlay():void {
			if(hasActiveOverlay()) {
				_activeOverlay.hide();
				_activeOverlay = null;
			}
		}

		public override function unload():void {
			if(haveLoadedVPAIDResource()) {
				if(isStopped() == false) {
					CONFIG::debugging { doLog("Unloading the Non-Linear VPAID resource - stopping the ad first...", Debuggable.DEBUG_VPAID); }
 					_adTerminated = true;
					_vpaidWrapper.stopAd();
				}
				else {
					CONFIG::debugging { doLog("Unloading the Non-Linear VPAID resource - ad already stopped", Debuggable.DEBUG_VPAID); }
				}
				removeListeners();
				if(hasActiveOverlay()) {
					_activeOverlay.clearDisplayContent();
					closeActiveOverlay();			
				}
				_vpaidWrapper = null;
				super.unload();
			}
		}
		
		public function getVPAID():IVPAID {
			if(_vpaidWrapper != null) {
				return _vpaidWrapper;
			}
			return null;
		}
		
		public function isRunning():Boolean {
			return (haveLoadedVPAIDResource() && _running);
		}
		
		public function isStopped():Boolean {
			return _stopped;
		}
		
		public function haveLoadedVPAIDResource():Boolean {
			return (_vpaidWrapper != null);
		}

		public function registerStartHandler(onStartHandler:Function):void {	
			_onAdStartHandler = onStartHandler;
		}

		public function registerErrorHandler(onErrorHandler:Function):void {	
			_onAdErrorHandler = onErrorHandler;
		}

		public function registerLogHandler(onLogHandler:Function):void {	
			_onAdLogHandler = onLogHandler;
		}
		
		public function registerCompleteHandler(onCompleteHandler:Function):void {
			_onAdCompleteHandler = onCompleteHandler;
		}

		public function registerExpandedChangeHandler(onExpandedChangeHandler:Function):void {
			_onAdExpandedChangeHandler = onExpandedChangeHandler;
		}

		public function registerLinearChangeHandler(onLinearChangeHandler:Function):void {
			_onAdLinearChangeHandler = onLinearChangeHandler;
		}

		public function registerRemainingTimeChangeHandler(onRemainingTimeChangeHandler:Function):void {
			_onRemainingTimeChangeHandler = onRemainingTimeChangeHandler;
		}

		public function registerVolumeChangeHandler(onAdVolumeChangeHandler:Function):void {
			_onAdVolumeChangeHandler = onAdVolumeChangeHandler;
		}

		public function registerLoadedHandler(onLoadedHandler:Function):void {
			_onLoadedHandler = onLoadedHandler
		}

		public function registerImpressionHandler(onImpressionHandler:Function):void {
			_onImpressionHandler = onImpressionHandler;
		}

		public function registerClickThruHandler(onClickThruHandler:Function):void {
			_onClickThruHandler = onClickThruHandler;	
		}

		public function registerUserAcceptInvitationHandler(onUserAcceptInvitationHandler:Function):void {
			_onUserAcceptInvitationHandler = onUserAcceptInvitationHandler;
		}

		public function registerMinimizeHandler(onMinimizeHandler:Function):void {
			_onMinimizeHandler = onMinimizeHandler;
		}

		public function registerCloseHandler(onCloseHandler:Function):void {
			_onCloseHandler = onCloseHandler;
		}

		public function registerVideoStartHandler(onVideoStartHandler:Function):void {
			_onVideoStartHandler = onVideoStartHandler;
		}

		public function registerVideoFirstQuartileHandler(onVideoFirstQuartileHandler:Function):void {
			_onVideoFirstQuartileHandler = onVideoFirstQuartileHandler;
		}

		public function registerVideoMidpointHandler(onVideoMidpointHandler:Function):void {
			_onVideoMidpointHandler = onVideoMidpointHandler;
		}

		public function registerVideoThirdQuartileHandler(onVideoThirdQuartileHandler:Function):void {
			_onVideoThirdQuartileHandler = onVideoThirdQuartileHandler;
		}

		public function registerVideoCompleteHandler(onVideoCompleteHandler:Function):void {
			_onVideoCompleteHandler = onVideoCompleteHandler;
		}

		public function registerOnPausedHandler(onPausedHandler:Function):void {
			_onPausedHandler = onPausedHandler;
		}
		
		public function registerOnPlayingHandler(onPlayingHandler:Function):void {
			_onPlayingHandler = onPlayingHandler;
		}

		public function registerAdSkippedHandler(onAdSkippedHandler:Function):void {
			_onAdSkippedHandler = onAdSkippedHandler;
		}
		
		public function registerAdSizeChangeHandler(onAdSizeChangeHandler:Function):void {
			_onAdSizeChangeHandler = onAdSizeChangeHandler;
		}
		
		public function registerAdSkippableStateChangeHandler(onAdSkippableStateChangeHandler:Function):void {
			_onAdSkippableStateChangeHandler = onAdSkippableStateChangeHandler;
		}
		
		public function registerAdDurationChangeHandler(onAdDurationChangeHandler:Function):void {
			_onAdDurationChangeHandler = onAdDurationChangeHandler;
		}
		
		public function registerAdInteractionHandler(onAdInteractionHandler:Function):void {
			_onAdInteractionHandler = onAdInteractionHandler;
		}

		public function registerExternalAPICallHandler(externalAPICallHandler:Function):void {
			_externalAPICallHandler = externalAPICallHandler;
		}

		protected function fireExternalAPICall(eventType:String, data:Object=null):void {
			if(_externalAPICallHandler != null) {
				_externalAPICallHandler(new VPAIDEvent(eventType, data));
			}	
		}

		public function setMaxDurationTimeout(maxDurationTimeout:int):void {
			_maxDurationTimeoutInSeconds = maxDurationTimeout;
		}

		public function enableMaxDurationTimeout():void {
			_maxDurationTimeoutEnabled = true;
		}

		public function disableMaxDurationTimeout():void {
			_maxDurationTimeoutEnabled = false;
		}
		
		protected function callbackOnStart():void {
			_running = true;
			if(_onAdStartHandler != null) {
				_onAdStartHandler(new VPAIDEvent(VPAIDEvent.AdStarted));
			}
		}

		protected function callbackOnError(message:String):void {
			unload();
			_running = false;
			if(_onAdErrorHandler != null) {
				_onAdErrorHandler(new VPAIDEvent(VPAIDEvent.AdError, message));	
			}			
		}
		
		protected function callbackOnLogged(data:*=null):void {
			if(_onAdLogHandler != null) {
				_onAdLogHandler(new VPAIDEvent(VPAIDEvent.AdLog, data));	
			}			
		}
		
		protected function callbackOnComplete(eventType:String):void {
			unload();
			_running = false;
			if(_onAdCompleteHandler != null) {
				_onAdCompleteHandler(new VPAIDEvent(eventType, { terminated: _adTerminated }));
			}
		}

		protected function callbackOnLoaded():void {
			if(_onLoadedHandler != null) {
				_onLoadedHandler(new VPAIDEvent(VPAIDEvent.AdLoaded));
			}
		}
			
		protected function callbackOnImpression():void {
			if(_onImpressionHandler != null) {
				_onImpressionHandler(new VPAIDEvent(VPAIDEvent.AdImpression));
			}
		}
		
		protected function callbackOnClickThru():void {
			if(_onClickThruHandler != null) {
				_onClickThruHandler(new VPAIDEvent(VPAIDEvent.AdClickThru));
			}			
		}
		
		protected function callbackOnUserAcceptInvitation():void {
			if(_onUserAcceptInvitationHandler != null) {
				_onUserAcceptInvitationHandler(new VPAIDEvent(VPAIDEvent.AdUserAcceptInvitation));
			}			
		}

		protected function callbackOnVolumeChange():void {
			if(_onAdVolumeChangeHandler != null) {
				_onAdVolumeChangeHandler(new VPAIDEvent(VPAIDEvent.AdVolumeChange, (_vpaidWrapper != null) ? _vpaidWrapper.adVolume : null));
			}			
		}
		
		protected function callbackOnMinimize():void {
			if(_onMinimizeHandler != null) {
				_onMinimizeHandler(new VPAIDEvent(VPAIDEvent.AdUserMinimize));
			}			
		}
		
		protected function callbackOnClose():void {
			if(_onCloseHandler != null) {
				_onCloseHandler(new VPAIDEvent(VPAIDEvent.AdUserClose));
			}			
		}
		
		protected function callbackOnVideoStart():void {
			if(_onVideoStartHandler != null) {
				_onVideoStartHandler(new VPAIDEvent(VPAIDEvent.AdVideoStart));
			}			
		}
		
		protected function callbackOnVideoFirstQuartile():void {
			if(_onVideoFirstQuartileHandler != null) {
				_onVideoFirstQuartileHandler(new VPAIDEvent(VPAIDEvent.AdVideoFirstQuartile));
			}			
		}
		
		protected function callbackOnVideoMidpoint():void {
			if(_onVideoMidpointHandler != null) {
				_onVideoMidpointHandler(new VPAIDEvent(VPAIDEvent.AdVideoMidpoint));
			}
		}
		
		protected function callbackOnVideoThirdQuartile():void {
			if(_onVideoThirdQuartileHandler != null) {
				_onVideoThirdQuartileHandler(new VPAIDEvent(VPAIDEvent.AdVideoThirdQuartile));
			}			
		}
		
		protected function callbackOnVideoComplete():void {
			if(_onVideoCompleteHandler != null) {
				_onVideoCompleteHandler(new VPAIDEvent(VPAIDEvent.AdVideoComplete));
			}			
		}

		protected function callbackOnPaused():void {
			if(_onPausedHandler != null) {
				_onPausedHandler(new VPAIDEvent(VPAIDEvent.AdPaused));
			}			
		}
		
		protected function callbackOnPlaying():void {
			if(_onPlayingHandler != null) {
				_onPlayingHandler(new VPAIDEvent(VPAIDEvent.AdPlaying));
			}			
		}

		protected function callbackOnAdSkipped():void {
			if(_onAdSkippedHandler != null) {
				_onAdSkippedHandler(new VPAIDEvent(VPAIDEvent.AdSkipped));
			}
		}
		
		protected function callbackOnAdSizeChange():void {
			if(_onAdSizeChangeHandler != null) {
				_onAdSizeChangeHandler(new VPAIDEvent(VPAIDEvent.AdSizeChange));
			}
		}
		
		protected function callbackOnAdSkippableStateChange():void {
			if(_onAdSkippableStateChangeHandler != null) {
				_onAdSkippableStateChangeHandler(new VPAIDEvent(VPAIDEvent.AdSkippableStateChange));
			}
		}
		
		protected function callbackOnAdDurationChange():void {
			if(_onAdDurationChangeHandler != null) {
				_onAdDurationChangeHandler(new VPAIDEvent(VPAIDEvent.AdDurationChange));
			}
		}
		
		protected function callbackOnAdInteraction():void {
			if(_onAdInteractionHandler != null) {
				_onAdInteractionHandler(new VPAIDEvent(VPAIDEvent.AdInteraction));
			}
		}

		public override function isInteractive():Boolean {
			return true;
		}

		public override function triggerTrackingEvent(eventType:String, contentPlayhead:String=null):void {
			if(_parentAdContainer != null) {
				super.triggerTrackingEvent(eventType, contentPlayhead);
				if(_parentAdContainer.hasWrapper()) {
					_parentAdContainer.wrapper.triggerTrackingEvent(eventType, contentPlayhead);
				}
				else _parentAdContainer.triggerTrackingEvent(eventType, contentPlayhead);				
			}
		}
		
		protected function triggerImpressionConfirmations():void {
			if(_parentAdContainer != null) {
				if(_parentAdContainer.hasWrapper()) {
					_parentAdContainer.wrapper.triggerImpressionConfirmations();
				}
				_parentAdContainer.triggerImpressionConfirmations();				
			}
		}
		
		protected function triggerClickTracking():void {
			CONFIG::debugging { doLog("VPAIDNonLinearAd::triggerClickTracking() - firing click tracking urls", Debuggable.DEBUG_VPAID); }
			this.fireClickTracking();
		}	

		public override function start(displayEvent:VideoAdDisplayEvent, region:*=null):void {
			if(displayEvent.controller != null) {
				activeDisplayRegion = region;
				displayEvent.controller.onDisplayNonLinearAd(
				           new OverlayAdDisplayEvent(
				                     OverlayAdDisplayEvent.DISPLAY, 
				                     this,
				                     displayEvent.customData.adSlot,
				                     region
				           ));				
			}
		}

		protected function removeListeners():void {
			if(_vpaidWrapper != null) {
				// VPAID 1.x
				_vpaidWrapper.removeEventListener(VPAIDEvent.AdLoaded, onVPAIDAdLoaded);
				_vpaidWrapper.removeEventListener(VPAIDEvent.AdStarted, onVPAIDAdStarted);
				_vpaidWrapper.removeEventListener(VPAIDEvent.AdStopped, onVPAIDAdStopped);
				_vpaidWrapper.removeEventListener(VPAIDEvent.AdLinearChange, onVPAIDAdLinearChange);
				_vpaidWrapper.removeEventListener(VPAIDEvent.AdExpandedChange, onVPAIDAdExpandedChange);
				_vpaidWrapper.removeEventListener(VPAIDEvent.AdRemainingTimeChange, onVPAIDAdRemainingTimeChange);
				_vpaidWrapper.removeEventListener(VPAIDEvent.AdVolumeChange, onVPAIDAdVolumeChange);
				_vpaidWrapper.removeEventListener(VPAIDEvent.AdImpression, onVPAIDAdImpression);
				_vpaidWrapper.removeEventListener(VPAIDEvent.AdVideoStart, onVPAIDAdVideoStart);
				_vpaidWrapper.removeEventListener(VPAIDEvent.AdVideoFirstQuartile, onVPAIDAdVideoFirstQuartile);
				_vpaidWrapper.removeEventListener(VPAIDEvent.AdVideoMidpoint, onVPAIDAdVideoMidpoint);
				_vpaidWrapper.removeEventListener(VPAIDEvent.AdVideoThirdQuartile, onVPAIDAdVideoThirdQuartile);
				_vpaidWrapper.removeEventListener(VPAIDEvent.AdVideoComplete, onVPAIDAdVideoComplete);
				_vpaidWrapper.removeEventListener(VPAIDEvent.AdClickThru, onVPAIDAdClickThru);
				_vpaidWrapper.removeEventListener(VPAIDEvent.AdUserAcceptInvitation, onVPAIDAdUserAcceptInvitation);
				_vpaidWrapper.removeEventListener(VPAIDEvent.AdUserClose, onVPAIDAdUserClose);
				_vpaidWrapper.removeEventListener(VPAIDEvent.AdPaused, onVPAIDAdPaused);
				_vpaidWrapper.removeEventListener(VPAIDEvent.AdPlaying, onVPAIDAdPlaying);
				_vpaidWrapper.removeEventListener(VPAIDEvent.AdLog, onVPAIDAdLog);
				_vpaidWrapper.removeEventListener(VPAIDEvent.AdError, onVPAIDAdError);
				// VPAID 2.x
				_vpaidWrapper.removeEventListener(VPAIDEvent.AdSkipped, onVPAIDAdSkipped);
				_vpaidWrapper.removeEventListener(VPAIDEvent.AdSkippableStateChange, onVPAIDAdSkippableStateChange);
				_vpaidWrapper.removeEventListener(VPAIDEvent.AdSizeChange, onVPAIDAdSizeChange);
				_vpaidWrapper.removeEventListener(VPAIDEvent.AdDurationChange, onVPAIDAdDurationChange);
				_vpaidWrapper.removeEventListener(VPAIDEvent.AdInteraction, onVPAIDAdInteraction);
			}
		}
		
		public function registerAsVPAID(vpaidWrapper:VPAIDWrapper):Boolean {	
			if(vpaidWrapper != null) {
				_vpaidWrapper = vpaidWrapper;
				
				// Handshake on the API version

				var vpaidVersionSupportedByAd:String = null;		
						
				if(_vpaidWrapper.isV100()) {
					CONFIG::debugging { doLog("VPAID 1.0.0 Ad loaded - interface not supported", Debuggable.DEBUG_VPAID); }
					vpaidVersionSupportedByAd = _vpaidWrapper.initVPAIDVersion("1.0.0");
				}
				else if(_vpaidWrapper.isV110()) {
					vpaidVersionSupportedByAd = _vpaidWrapper.handshakeVersion("2.0");
					CONFIG::debugging { doLog("VPAID Ad loaded - VPAID version handshake reports VPAID Ad version as " + vpaidVersionSupportedByAd, Debuggable.DEBUG_VPAID);	}				
					
					// register all the event handlers
					
					_vpaidWrapper.addEventListener(VPAIDEvent.AdLoaded, onVPAIDAdLoaded);
					_vpaidWrapper.addEventListener(VPAIDEvent.AdStarted, onVPAIDAdStarted);
					_vpaidWrapper.addEventListener(VPAIDEvent.AdStopped, onVPAIDAdStopped);
					_vpaidWrapper.addEventListener(VPAIDEvent.AdLinearChange, onVPAIDAdLinearChange);
					_vpaidWrapper.addEventListener(VPAIDEvent.AdExpandedChange, onVPAIDAdExpandedChange);
					_vpaidWrapper.addEventListener(VPAIDEvent.AdRemainingTimeChange, onVPAIDAdRemainingTimeChange);
					_vpaidWrapper.addEventListener(VPAIDEvent.AdVolumeChange, onVPAIDAdVolumeChange);
					_vpaidWrapper.addEventListener(VPAIDEvent.AdImpression, onVPAIDAdImpression);
					_vpaidWrapper.addEventListener(VPAIDEvent.AdVideoStart, onVPAIDAdVideoStart);
					_vpaidWrapper.addEventListener(VPAIDEvent.AdVideoFirstQuartile, onVPAIDAdVideoFirstQuartile);
					_vpaidWrapper.addEventListener(VPAIDEvent.AdVideoMidpoint, onVPAIDAdVideoMidpoint);
					_vpaidWrapper.addEventListener(VPAIDEvent.AdVideoThirdQuartile, onVPAIDAdVideoThirdQuartile);
					_vpaidWrapper.addEventListener(VPAIDEvent.AdVideoComplete, onVPAIDAdVideoComplete);
					_vpaidWrapper.addEventListener(VPAIDEvent.AdClickThru, onVPAIDAdClickThru);
					_vpaidWrapper.addEventListener(VPAIDEvent.AdUserAcceptInvitation, onVPAIDAdUserAcceptInvitation);
					_vpaidWrapper.addEventListener(VPAIDEvent.AdUserClose, onVPAIDAdUserClose);
					_vpaidWrapper.addEventListener(VPAIDEvent.AdPaused, onVPAIDAdPaused);
					_vpaidWrapper.addEventListener(VPAIDEvent.AdPlaying, onVPAIDAdPlaying);
					_vpaidWrapper.addEventListener(VPAIDEvent.AdLog, onVPAIDAdLog);
					_vpaidWrapper.addEventListener(VPAIDEvent.AdError, onVPAIDAdError);				

					if(vpaidVersionSupportedByAd == "2.0" || vpaidVersionSupportedByAd == "2.0.0") {
						_vpaidWrapper.addEventListener(VPAIDEvent.AdSkipped, onVPAIDAdSkipped);
						_vpaidWrapper.addEventListener(VPAIDEvent.AdSkippableStateChange, onVPAIDAdSkippableStateChange);
						_vpaidWrapper.addEventListener(VPAIDEvent.AdSizeChange, onVPAIDAdSizeChange);
						_vpaidWrapper.addEventListener(VPAIDEvent.AdDurationChange, onVPAIDAdDurationChange);
						_vpaidWrapper.addEventListener(VPAIDEvent.AdInteraction, onVPAIDAdInteraction);						
					}
					
					return true;
				}
				else {
					CONFIG::debugging { doLog("VPAID Ad Loaded but it does not have a valid VPAID API version - ignoring completely", Debuggable.DEBUG_VPAID); }
				}
			}	
			_stopped = true;	
			return false;
		}
		
		public function startVPAID(width:Number=-1, height:Number=-1, mode:String="normal", passReferrer:Boolean=false, referrer:String=null):void {
			if(_vpaidWrapper != null) {
				_adTerminated = false;
				var environmentVars:String = "";
				if(passReferrer) {
					if(referrer != null) {
						environmentVars = "referrer=" + referrer;
						CONFIG::debugging { doLog("Passing in the referrer manually as '" + referrer + "' to the VPAID ad via the environmentVars", Debuggable.DEBUG_VPAID); }
					}
					else {
						try {
							var referrer:String = BrowserUtils.getReferrer(true);
							environmentVars = "referrer=" + referrer;
							CONFIG::debugging { doLog("Passing in the referrer automatically '" + referrer + "' to the VPAID ad via the environmentVars", Debuggable.DEBUG_VPAID); }
						}
						catch(e:Error) { };							
					}
				}
				_vpaidWrapper.initAd(
						Math.floor(width), 
						Math.floor(height), 
						mode, 
						400, 
						(adParameters == null) ? "" : adParameters, 
						(environmentVars == null) ? "" : environmentVars
				);
			}
		}		

		public function resize(width:Number, height:Number, viewMode:String):void {				
			if(_vpaidWrapper != null) {
				_vpaidWrapper.resizeAd(width, height, viewMode);
			}	
		}
		
		public function pause():void {
			if(_vpaidWrapper != null) {
				_vpaidWrapper.pauseAd();
			}				
		}		

		public function resume():void {
			if(_vpaidWrapper != null) {
				_vpaidWrapper.resumeAd();
			}				
		}		

        // VPAID Event Handlers
        
		protected function onVPAIDAdLoaded(event:*):void {
			CONFIG::debugging { doLog("VPAIDMediaFile::VPAID.AdLoaded event received - starting Ad", Debuggable.DEBUG_VPAID); }
			try {
				fireExternalAPICall(VPAIDEvent.AdLoaded);
				_vpaidWrapper.startAd();					
			}
			catch(e:Error) {
				callbackOnError("Exception generated in VPAID.startAd() - aborting - " + e.message);
			}
		}		

		protected function onVPAIDAdStarted(event:*):void {
			CONFIG::debugging { doLog("VPAIDMediaFile::VPAID.AdStarted event received", Debuggable.DEBUG_VPAID); }
			_stopped = false;
			callbackOnStart();
			triggerTrackingEvent(TrackingEvent.EVENT_START);
			fireExternalAPICall(VPAIDEvent.AdStarted);
		}		

		protected function onVPAIDAdStopped(event:*):void {
			CONFIG::debugging { doLog("VPAIDMediaFile::VPAID.AdStopped event received", Debuggable.DEBUG_VPAID); }
			_stopped = true;
			triggerTrackingEvent(TrackingEvent.EVENT_STOP);
			callbackOnComplete(VPAIDEvent.AdStopped);
		}		

		protected function onVPAIDAdLinearChange(event:*):void {	
			CONFIG::debugging { doLog("VPAIDMediaFile::VPAID.AdLinearChange event received (adLinear == " + _vpaidWrapper.adLinear + ")", Debuggable.DEBUG_VPAID); }
			if(_onAdLinearChangeHandler != null) {
				_onAdLinearChangeHandler(new VPAIDEvent(VPAIDEvent.AdLinearChange, _vpaidWrapper.adLinear));
			}
		}
		
		protected function onVPAIDAdExpandedChange(event:*):void {
			CONFIG::debugging { doLog("VPAIDMediaFile::VPAID.AdExpandedChange event received (adExpanded == " + _vpaidWrapper.adExpanded + ")", Debuggable.DEBUG_VPAID); }
			if(_vpaidWrapper.adExpanded) {
				triggerTrackingEvent(TrackingEvent.EVENT_EXPAND);
			}
			else {
				triggerTrackingEvent(TrackingEvent.EVENT_COLLAPSE);				
			}
			if(_onAdExpandedChangeHandler != null) {
				_onAdExpandedChangeHandler(new VPAIDEvent(VPAIDEvent.AdExpandedChange, { expanded: _vpaidWrapper.adExpanded, linearPlayback: _vpaidWrapper.adLinear }));
			}
		}

		protected function onVPAIDAdRemainingTimeChange(event:*):void {
			var remainingTime:Number = _vpaidWrapper.adRemainingTime;
			CONFIG::debugging { doLog("VPAIDMediaFile::VPAID.AdRemainingTimeChange event received (adRemainingTime == " + remainingTime + ")", Debuggable.DEBUG_VPAID); }
			if(_onRemainingTimeChangeHandler != null) {
				_onRemainingTimeChangeHandler(new VPAIDEvent(VPAIDEvent.AdRemainingTimeChange, remainingTime));
			}
		}		
		
		protected function onVPAIDAdVolumeChange(event:*):void {
			CONFIG::debugging { doLog("VPAIDMediaFile::VPAID.AdVolumeChange event received", Debuggable.DEBUG_VPAID); }
			callbackOnVolumeChange();
		}		
		
		protected function onVPAIDAdImpression(event:*):void {
			CONFIG::debugging { doLog("VPAIDMediaFile::VPAID.AdImpression event received", Debuggable.DEBUG_VPAID); }
			triggerImpressionConfirmations();
			triggerTrackingEvent(TrackingEvent.EVENT_CREATIVE_VIEW);
			fireExternalAPICall(VPAIDEvent.AdImpression);
			callbackOnImpression();
		}		
		
		protected function onVPAIDAdVideoStart(event:*):void {
			CONFIG::debugging { doLog("VPAIDMediaFile::VPAID.AdVideoStart event received", Debuggable.DEBUG_VPAID); }
			fireExternalAPICall(VPAIDEvent.AdVideoStart);
			callbackOnVideoStart();
		}		
		
		protected function onVPAIDAdVideoFirstQuartile(event:*):void {
			CONFIG::debugging { doLog("VPAIDMediaFile::VPAID.AdVideoFirstQuartile event received", Debuggable.DEBUG_VPAID); }
			triggerTrackingEvent(TrackingEvent.EVENT_1STQUARTILE);
			fireExternalAPICall(VPAIDEvent.AdVideoFirstQuartile);
			callbackOnVideoFirstQuartile();
		}		
		
		protected function onVPAIDAdVideoMidpoint(event:*):void {
			CONFIG::debugging { doLog("VPAIDMediaFile::VPAID.AdVideoMidpoint event received", Debuggable.DEBUG_VPAID); }
			triggerTrackingEvent(TrackingEvent.EVENT_MIDPOINT);
			fireExternalAPICall(VPAIDEvent.AdVideoMidpoint);
			callbackOnVideoMidpoint();
		}		
		
		protected function onVPAIDAdVideoThirdQuartile(event:*):void {
			CONFIG::debugging { doLog("VPAIDMediaFile::VPAID.AdVideoThirdQuartile event received", Debuggable.DEBUG_VPAID); }
			triggerTrackingEvent(TrackingEvent.EVENT_3RDQUARTILE);
			fireExternalAPICall(VPAIDEvent.AdVideoThirdQuartile);
			callbackOnVideoThirdQuartile();
		}		
		
		protected function onVPAIDAdVideoComplete(event:*):void {
			CONFIG::debugging { doLog("VPAIDMediaFile::VPAID.AdVideoComplete event received", Debuggable.DEBUG_VPAID); }
			triggerTrackingEvent(TrackingEvent.EVENT_COMPLETE);
			fireExternalAPICall(VPAIDEvent.AdVideoComplete);
			callbackOnVideoComplete();
		}
		
		protected function onVPAIDAdClickThru(event:*):void {
			try {
				// The event can tell the player to handle the processing of the click through URL
				// Event data for handling the click event comes in the form
				// var data:Object = { "playerHandles": true, "url": "http://destination_page" };
				if(event.data != undefined && event.data != null) {
					if(event.data.playerHandles && !StringUtils.isEmpty(event.data.url)) {
						CONFIG::debugging { doLog("VPAIDMediaFile::VPAID.AdClickThru event received - VPAID ad has requested browser to open click through URL " + event.data.url, Debuggable.DEBUG_VPAID);	}		
						PopupWindow.openWindow(event.data.url, "_blank");
					}
				}
				else {
					CONFIG::debugging { doLog("VPAIDMediaFile::VPAID.AdClickThru event received - VPAID ad internally opening click through URL", Debuggable.DEBUG_VPAID); }
				}
			}
			catch(e:Error) {
			}
			triggerClickTracking();
			fireExternalAPICall(VPAIDEvent.AdClickThru);
			callbackOnClickThru();
		}		
		
		protected function onVPAIDAdUserAcceptInvitation(event:*):void {
			CONFIG::debugging { doLog("VPAIDMediaFile::VPAID.AdUserAcceptInvitation event received", Debuggable.DEBUG_VPAID); }
			triggerTrackingEvent(TrackingEvent.EVENT_ACCEPT);
			fireExternalAPICall(VPAIDEvent.AdUserAcceptInvitation);
			callbackOnUserAcceptInvitation();
		}		
		
		protected function onVPAIDAdUserMinimize(event:*):void {
			CONFIG::debugging { doLog("VPAIDMediaFile::VPAID.AdUserMinimize event received", Debuggable.DEBUG_VPAID); }
			triggerTrackingEvent(TrackingEvent.EVENT_COLLAPSE);
			fireExternalAPICall(VPAIDEvent.AdUserMinimize);
			callbackOnMinimize();
		}		
		
		protected function onVPAIDAdUserClose(event:*):void {
			CONFIG::debugging { doLog("VPAIDMediaFile::VPAID.AdUserClose event received", Debuggable.DEBUG_VPAID); }
			triggerTrackingEvent(TrackingEvent.EVENT_CLOSE);
			fireExternalAPICall(VPAIDEvent.AdUserClose);
			callbackOnClose();
		}		
		
		protected function onVPAIDAdPaused(event:*):void {
			CONFIG::debugging { doLog("VPAIDMediaFile::VPAID.AdPaused event received", Debuggable.DEBUG_VPAID); }
			triggerTrackingEvent(TrackingEvent.EVENT_PAUSE);
			fireExternalAPICall(VPAIDEvent.AdPaused);
			callbackOnPaused();
		}		
		
		protected function onVPAIDAdPlaying(event:*):void {
			CONFIG::debugging { doLog("VPAIDMediaFile::VPAID.AdPlaying event received", Debuggable.DEBUG_VPAID); }
			fireExternalAPICall(VPAIDEvent.AdPlaying);
			callbackOnPlaying();
		}		
		
		protected function onVPAIDAdLog(event:*):void {
			if(event != null) {
                if(event.data != null) {
                	if(event.data is String) {
						CONFIG::debugging { doLog("VPAIDMediaFile::VPAID.AdLog - " + event.data, Debuggable.DEBUG_VPAID); }           		                		
						callbackOnLogged(event.data);
						return;
                	}
                	else if(event.data is Object) {
						CONFIG::debugging { doLog("VPAIDMediaFile::VPAID.AdLog - " + event.data.message, Debuggable.DEBUG_VPAID); }           		
						callbackOnLogged(event.data.message);
						return;
                	}
					else {
						CONFIG::debugging { doLog("VPAIDMediaFile::VPAID.AdLog - can't work out how to print out the VPAID log message", Debuggable.DEBUG_VPAID); }
					}            		
                }
				else {
					CONFIG::debugging { doLog("VPAIDMediaFile::VPAID.AdLog - no data supplied in log event", Debuggable.DEBUG_VPAID); }
				}
			}
			else {
				CONFIG::debugging { doLog("VPAIDMediaFile::VPAID.AdLog - no event supplied to logging call", Debuggable.DEBUG_VPAID); }
				callbackOnLogged();
			}
		}		

		protected function onVPAIDAdError(event:*):void {
			var message:String = ((event.data != null) ? ((event.data.message != undefined) ? event.data.message : event.data) : "no error message provided");
			CONFIG::debugging { doLog("VPAIDMediaFile::VPAID.AdError event received - " + message, Debuggable.DEBUG_VPAID); }
			callbackOnError(message);
		}

		protected function onVPAIDAdSkipped(event:*):void {
			// TO IMPLEMENT
			fireExternalAPICall(VPAIDEvent.AdSkipped, event.data);
		}
		
		protected function onVPAIDAdSkippableStateChange(event:*):void {
			// TO IMPLEMENT
			fireExternalAPICall(VPAIDEvent.AdSkippableStateChange, event.data);
		}

		protected function onVPAIDAdSizeChange(event:*):void {
			// TO IMPLEMENT
			fireExternalAPICall(VPAIDEvent.AdSizeChange, event.data);
		}

		protected function onVPAIDAdDurationChange(event:*):void {
			// TO IMPLEMENT
			fireExternalAPICall(VPAIDEvent.AdDurationChange, event.data);
		}

		protected function onVPAIDAdInteraction(event:*):void {
			// TO IMPLEMENT
			fireExternalAPICall(VPAIDEvent.AdInteraction, event.data);
		}

		public function toRuntimeStateJSObject():Object {
			if(_vpaidWrapper != null) {
				return _vpaidWrapper.toRuntimeStateJSObject();			
			}
			else return new Object();
		}
	}
}