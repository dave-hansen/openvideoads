/*
 * VPAID events that a VPAID SWF can dispatch.  This class does not need to be used for any VPAID SWFs, 
 * but it can help make coding easier.  This source can be found in the VPAID specification: 
 * http://www.iab.net/media/file/VPAIDFINAL51109.pdf
 */
package org.openvideoads.vast.overlay {
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.utils.*;
	
	import org.openvideoads.base.Debuggable;
	import org.openvideoads.vpaid.IVPAID;
	
	public class VPAIDWrapper extends EventDispatcher implements IVPAID {
		protected var _ad:*;
		protected var _currentWidth:int = -1;
		protected var _currentHeight:int = -1;
		protected var _muteOnStartup:Boolean = false;
		protected var _playerVolumeOnStartup:Number = -1;
		
		protected static const VPAID_PROVIDER_WRAPPED_WITH_GET_VPAID:String = "WRAPPED_WITH_GET_VPAID";
		protected static const VPAID_PROVIDER_STANDARD:String = "STANDARD";
		
		public function VPAIDWrapper(ad:*, muteOnStartup:Boolean=false, playerVolumeOnStartup:Number=-1) {
			_muteOnStartup = muteOnStartup;
			_playerVolumeOnStartup = playerVolumeOnStartup;
			switch(determineAdProvider(ad)) {
				case VPAID_PROVIDER_WRAPPED_WITH_GET_VPAID:
					_ad = ad.getVPAID();
					CONFIG::debugging { doLog("VPAIDWrapper::constructor() - the VPAID ad provider uses a wrapper - accessing the ad SWF via _ad.getVPAID()", Debuggable.DEBUG_VPAID); }
					break;
								
				default:
					_ad = ad;
			}
		}
	
		protected function determineAdProvider(ad:*):String {
			var classInfo:XML = describeType(ad);
			if(vpaidAdIsWrapped(ad, "getVPAID", classInfo)) { // used by the EyeWonder, Adotube wrapper
				return VPAID_PROVIDER_WRAPPED_WITH_GET_VPAID;
			}
			return VPAID_PROVIDER_STANDARD;			
		}	
			
		// Properties
		
		public function get adLinear():Boolean {
			if(_ad != null) {
				return _ad.adLinear;
			}
			return false;
		}

		public function get adExpanded():Boolean {
			if(_ad != null) {
				return _ad.adExpanded; 
			}
			return false;
		}
		
		public function get adHeight():Number {
			if(_ad != null) {
				return _ad.height;
			}
			return 0;			
		}

		public function get adWidth():Number {
			if(_ad != null) {
				return _ad.width;
			}
			return 0;			
		}
		
        public function get adDuration():Number {
			if(_ad != null) {
				return _ad.adDuration;
			}
			return 0;			
        }
		
		public function get adSkippableState():Boolean { 
			if(_ad != null) {
				return _ad.adSkippableState;
			}
			return false;
		}		
		
		public function get adRemainingTime():Number {
			if(_ad != null) {
				return _ad.adRemainingTime; 
			}
			return 0;
		}
		
		public function get adVolume():Number {
			if(_ad != null) {
				return _ad.adVolume; 
			}
			return 0;
		}
		
		public function set adVolume(value:Number):void {
			if(_ad != null) {
				_ad.adVolume = value;
			}
		} 
		
		public function get adCompanions():String {
			if(_ad != null) {
				return _ad.adCompanions;
			}
			return null;
		}
		
		public function get adIcons():Boolean {
			if(_ad != null) {
				return _ad.adIcons;
			}
			return false;
		}

		// Versioning & Introspection
		
		protected function vpaidAdIsWrapped(ad:*, accessorMethodName:String, classInfo:XML=null):Boolean {
			return adHasMethod(ad, accessorMethodName); 
		}
		
		protected function getAdClassPackage(ad:*):String {
			var qualifiedName:String = getQualifiedClassName(ad);
			if(qualifiedName != null) {
				return qualifiedName.substr(0, qualifiedName.indexOf("::"));
			}
			return "";
		}
		
		protected function adHasMethod(ad:*, methodName:String):Boolean { 
			if(ad != null) {
				try {
					return (ad[methodName] != undefined);				
				}
				catch(e:Error) {
					CONFIG::debugging { doLog("Exception thrown trying to determine if VPAID ad has " + methodName + "() method", Debuggable.DEBUG_VPAID); }
				}
			}
			return false;
		}
		
		public function isV100():Boolean {
			return adHasMethod(_ad, "initVPAIDVersion") && adHasMethod(_ad, "init");	
		}
		
		public function isV110():Boolean {
			return adHasMethod(_ad, "handshakeVersion") && adHasMethod(_ad, "initAd");	
		}
		
		// VPAID 1.0.0 Methods

		public function initVPAIDVersion(playerVPAIDVersion:String):String {
			if(_ad != null) {
				return _ad.initVPAIDVersion(playerVPAIDVersion);
			}
			return "0.0.0";
		}

		// VPAID 1.1.0 Methods
		
		public function handshakeVersion(playerVPAIDVersion:String):String { 
			if(_ad != null) {
				return _ad.handshakeVersion(playerVPAIDVersion);
			}
			return "0.0.0";
		}

		public function initAd(width:Number, height:Number, viewMode:String, desiredBitrate:Number, creativeData:String, environmentVars : String):void {
			if(_ad != null) {
				var fixedWidth:int = parseInt(width.toFixed(0));
				var fixedHeight:int = parseInt(height.toFixed(0));
				_currentWidth = fixedWidth;
				_currentHeight = fixedHeight;
				_ad.initAd(fixedWidth, fixedHeight, viewMode, desiredBitrate, creativeData, environmentVars);
			}
		}
		
		public function resizeAd(width:Number, height:Number, viewMode:String):void {
			try {
				var fixedWidth:int = parseInt(width.toFixed(0));
				var fixedHeight:int = parseInt(height.toFixed(0));
				if((_currentWidth != fixedWidth) || (_currentHeight != fixedHeight)) {
					_currentWidth = fixedWidth;
					_currentHeight = fixedHeight;
					_ad.resizeAd(fixedWidth, fixedHeight, viewMode);				
					CONFIG::debugging { doLog("VPAID ad has been resized to " + fixedWidth + "x" + fixedHeight + " - viewMode is '" + viewMode + "'", Debuggable.DEBUG_VPAID); }
				}
			}
			catch(e:Error) {
				CONFIG::debugging { doLog("Exception in VPAIDWrapper::resizeAd() - " + e.message, Debuggable.DEBUG_VPAID); }
			}
		} 
		
		public function startAd():void {
			if(_ad != null) {
				if(_muteOnStartup) {
					CONFIG::debugging { doLog("Muting the VPAID Ad on startup", Debuggable.DEBUG_VPAID); }
					_ad.adVolume = 0;
				}
				else if(_playerVolumeOnStartup > -1) {
					CONFIG::debugging { doLog("Setting VPAID Ad volume to player volume level '" + _playerVolumeOnStartup + "'", Debuggable.DEBUG_VPAID); }
					_ad.adVolume = _playerVolumeOnStartup;
				}
				_ad.startAd();
			}
		} 
		
		public function stopAd():void {
			if(_ad != null) {
				_ad.stopAd();			
			}
		} 
		
		public function pauseAd():void {
			if(_ad != null) {
				_ad.pauseAd();
			}
		} 
		
		public function resumeAd():void {
			if(_ad != null) {
				_ad.resumeAd();
			}
		} 
		
		public function skipAd():void {
			if(_ad != null) {
				_ad.skipAd(); 
			}
		}		
		
		public function expandAd():void {
			if(_ad != null) {
				_ad.expandAd();
			}
		} 
		
		public function collapseAd():void {
			if(_ad != null) {
				_ad.collapseAd();
			}
		}
		
		// EventDispatcher overrides

		public override function addEventListener(type:String, listener:Function, useCapture:Boolean=false, priority:int=0, useWeakReference:Boolean=false):void {
			if(_ad != null) {
				_ad.addEventListener(type, listener, useCapture, priority, useWeakReference);			
			}
			else {
				CONFIG::debugging { doLog("Unable to addEventListener('" + type + "') - ad is null", Debuggable.DEBUG_VPAID); }
			}
		}
			
		public override function removeEventListener(type:String, listener:Function, useCapture:Boolean=false):void {
			if(_ad != null) {
				_ad.removeEventListener(type, listener, useCapture);
			}
			else {
				CONFIG::debugging { doLog("Unable to removeEventListener('" + type + "') - ad is null", Debuggable.DEBUG_VPAID); }
			}
		}
		
		public override function dispatchEvent(event:Event):Boolean {
			if(_ad != null) {
				return _ad.dispatchEvent(event); 
			}
			else {
				CONFIG::debugging { doLog("Unable to dispatch event - ad is null", Debuggable.DEBUG_VPAID); }
			}

			return false;
		}
		
		public override function hasEventListener(type:String):Boolean {
			if(_ad != null) {
				return _ad.hasEventListener(type);
			}
			return false;
		}

		public override function willTrigger(type:String):Boolean {
			if(_ad != null) {
				return _ad.willTrigger(type);
			}
			return false;
		}

		// JS API support
		
		public function toRuntimeStateJSObject():Object {
			var result:Object = new Object();
			result["adExpanded"] = this.adExpanded;
			result["adLinear"] = this.adLinear;
			result["adRemainingTime"] = this.adRemainingTime;
			result["adVolume"] = this.adVolume;
			return result;
		}

		// INTERNAL DEBUGGING

		CONFIG::debugging
		protected function doLog(data:String, level:int=1):void {
			Debuggable.getInstance().doLog(data, level);
		}
	}
}