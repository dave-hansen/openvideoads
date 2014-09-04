package org.openvideoads.vpaid {
	import flash.display.MovieClip;
	import flash.external.ExternalInterface;
	import flash.system.Security;

	public class VPAIDBase extends MovieClip implements IVPAID {
		protected var _remainingTime:Number = 0;
		protected var _adDuration:Number = 0;
		protected var _adWidth:Number = 0;
		protected var _adHeight:Number = 0;
		protected var _adVolume:Number = 0;
		protected var _adExpanded:Boolean = false;
		protected var _adSkippableState:Boolean = false;
		protected var _adCompanions:String = null;
		protected var _adIcons:Boolean = false;

		protected static var SUPPORTED_VPAID_VERSION:String = "2.0";

		public function VPAIDBase() {
			mouseEnabled = false;
            Security.allowDomain("*");			
		}

		public function get adWidth():Number {
			return _adWidth;
		}
		
		public function set adWidth(adWidth:Number):void {
			_adWidth = adWidth;
		}
		
		public function get adHeight():Number {
			return _adHeight;
		}
		
		public function set adHeight(adHeight:Number):void {
			_adHeight = adHeight;
		}
		
        public function get adLinear():Boolean {	
        	return false;
        }
        
        public function get adExpanded():Boolean {
        	return _adExpanded;
        }
        
		public function get adSkippableState():Boolean { 
			return _adSkippableState;
		}        
		
        public function get adCompanions():String {
        	return _adCompanions;
        }
        
        public function get adIcons():Boolean {
        	return _adIcons;
        }

        public function get adDuration():Number {
        	return _adDuration;
        }
        
        public function get adRemainingTime():Number {
        	return _remainingTime;
        }

        public function get adVolume():Number {
        	return 0;
        }
        
        public function set adVolume(value:Number):void {
        	_adVolume = value;
        }
        
        public function handshakeVersion(playerVPAIDVersion:String):String {
        	return SUPPORTED_VPAID_VERSION;
        }
        
        public function initAd(width:Number, height:Number, viewMode:String, desiredBitrate:Number, creativeData:String, environmentVars:String):void {
            logAd("VPAID.initAd(" + width + "," + height + ",'" + viewMode + "'," + desiredBitrate + ",'" + creativeData + "','" + environmentVars + "') triggered");
        	adWidth = width;
        	adHeight = height;
            dispatchEvent(new VPAIDEvent(VPAIDEvent.AdLoaded));
        }

        public function resizeAd(width:Number, height:Number, viewMode:String):void {
        }
        
        public function startAd():void {
        	renderAd();
            dispatchEvent(new VPAIDEvent(VPAIDEvent.AdImpression));
            dispatchEvent(new VPAIDEvent(VPAIDEvent.AdStarted));
        }
        
        public function stopAd():void {
            dispatchEvent(new VPAIDEvent(VPAIDEvent.AdStopped));
        }
        
        public function pauseAd():void {       	
            dispatchEvent(new VPAIDEvent(VPAIDEvent.AdPaused));
        }
        
        public function resumeAd():void {       	
            dispatchEvent(new VPAIDEvent(VPAIDEvent.AdPlaying));
        }
        
        public function expandAd():void {   
        	_adExpanded = true;    	
            dispatchEvent(new VPAIDEvent(VPAIDEvent.AdExpandedChange));
        }
        
        public function collapseAd():void {
        	_adExpanded = false;    	
            dispatchEvent(new VPAIDEvent(VPAIDEvent.AdExpandedChange));
        }

        public function skipAd():void {
            dispatchEvent(new VPAIDEvent(VPAIDEvent.AdSkipped));
        }

		public function logAd(data:String):void {
			dispatchEvent(new VPAIDEvent(VPAIDEvent.AdLog, data));
		}
		
        // AD IMPLEMENTATION
        
        protected function renderAd():void {
        }
        
        // INTERNAL DEBUGGING
        
        CONFIG::debugging
		public function doLog(data:String):void {
			try {						
				ExternalInterface.call("console.log", (new Date()).toTimeString() + ": " + data);					
			}
			catch(e:Error) {}
		}
	}
}