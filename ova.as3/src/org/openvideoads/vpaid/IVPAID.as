/*
 * VPAID events that a VPAID 2 SWF can dispatch.  This class does not need to be used for any VPAID SWFs, 
 * but it can help make coding easier.  This source can be found in the VPAID specification: 
 * http://www.iab.net/media/file/VPAIDFINAL51109.pdf
 */
package org.openvideoads.vpaid {
    public interface IVPAID {
        
        // Properties
        
        function get adLinear():Boolean;
		function get adWidth():Number; 
		function get adHeight():Number;
        function get adExpanded():Boolean;
        function get adRemainingTime():Number;
        function get adVolume():Number;
        function get adDuration():Number;
        function get adSkippableState():Boolean;
        function get adCompanions():String; 
        function get adIcons():Boolean;

        function set adVolume(value:Number):void;
        
        // Methods
        
        function handshakeVersion(playerVPAIDVersion:String):String;
        function initAd(width:Number, height:Number, viewMode:String, desiredBitrate:Number, creativeData:String, environmentVars:String):void;
        function resizeAd(width:Number, height:Number, viewMode:String):void;
        function startAd():void;
        function stopAd():void;
        function pauseAd():void;
        function resumeAd():void;
        function expandAd():void;
        function collapseAd():void;
        function skipAd():void;
    }
}