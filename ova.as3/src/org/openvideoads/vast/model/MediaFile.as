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
	import org.openvideoads.util.StringUtils;
	
	/**
	 * @author Paul Schulz
	 */
	public class MediaFile extends Debuggable {
		protected var _url:AdNetworkResource = null;
		protected var _id:String;
		protected var _bandwidth:String; // high, medium, low, custom
		protected var _delivery:String;  // streaming, progressive
		protected var _scale:Boolean = false; 
		protected var _maintainAspectRatio:Boolean = true;
		protected var _mimeType:String;     
		protected var _bitRate:int = -1;
		protected var _width:String;
		protected var _height:String;
		protected var _apiFramework:String = null;
		protected var _adParameters:String = null;
		protected var _parentAd:TrackedVideoAd = null;
		
		public function MediaFile() {
			super();
		}
		
		public function unload():void {
		}
		
		public function set id(id:String):void {
			_id = id;
		}
		
		public function get id():String {
			return _id;
		}
		
		public function set parentAd(parentAd:TrackedVideoAd):void {
			_parentAd = parentAd;
		}
		
		public function get parentAd():TrackedVideoAd {
			return _parentAd;
		}
		
		public function set url(url:AdNetworkResource):void {
			_url = url;
		}
		
		public function get url():AdNetworkResource {
			return _url;
		}
		
		public function set bandwidth(bandwidth:String):void {
			_bandwidth = bandwidth;
		}
		
		public function get bandwidth():String {
			return _bandwidth;
		}
		
		public function get duration():String {
			if(_parentAd != null) {
				return _parentAd.duration;
			}
			return "00:00:00";
		}
		
		public function durationAsInt():int {
			return 0;
		}
		
		public function set delivery(delivery:String):void {
			_delivery = delivery;
		}
		
		public function get delivery():String {
			return _delivery;
		}

		public function set apiFramework(apiFramework:String):void {
			_apiFramework = apiFramework;
		}
		
		public function get apiFramework():String {
			return _apiFramework;
		}
		
		public function hasAPIFramework():Boolean {
			return (_apiFramework != null);
		}

		public function set adParameters(adParameters:String):void {
			_adParameters = adParameters;
		}
		
		public function get adParameters():String {
			return _adParameters;
		}
		
		public function hasAdParameters():Boolean {
			return !StringUtils.isEmpty(_adParameters);
		}
		
		public function isProgressive():Boolean {
			if(_delivery != null) {
				return (_delivery.toUpperCase() == "PROGRESSIVE");	
			}
			return false;
		}

		public function isStreaming():Boolean {
			if(_delivery != null) {
				return (_delivery.toUpperCase() == "STREAMING");	
			}
			return false;
		}
		
		public function set scale(scale:*):void {
			if(scale != null) {
				_scale = StringUtils.validateAsBoolean(scale);
			}
		}
		
		public function get scale():Boolean {
			return _scale;
		}
		
		public function set maintainAspectRatio(maintainAspectRatio:*):void {
			if(maintainAspectRatio != null) {
				_maintainAspectRatio = StringUtils.validateAsBoolean(maintainAspectRatio); 
			}
		}
		
		public function get maintainAspectRatio():Boolean {
			return _maintainAspectRatio;
		}

		public function hasMimeType():Boolean {
			return _mimeType != null;
		}
		
		public function set mimeType(mimeType:String):void {
			_mimeType = mimeType;
		}
		
		public function get mimeType():String {
			return _mimeType;
		}
		
		public function isPermittedMimeType(mimeTypes:Array):Boolean {
			if(hasMimeType() == false || mimeTypes == null) return true;
			for(var i:int=0; i < mimeTypes.length; i++) {
				if(StringUtils.matchesIgnoreCase(_mimeType, mimeTypes[i])) return true;
			}
			return false;
		}
		
		public function isInteractive():Boolean {
			if(hasAPIFramework()) {
				if(StringUtils.matchesIgnoreCase(_apiFramework, "VPAID")) {
					if(hasMimeType()) {
						return StringUtils.matchesIgnoreCase(_mimeType, "APPLICATION/X-SHOCKWAVE-FLASH") ||
						       StringUtils.matchesIgnoreCase(_mimeType, "SWF");
					}
					else {
						if(_url != null) {
							return (_url.isStream() == false);
						}
					}
				}
			}
			return false;
		}
		
		public function set bitRate(bitRate:int):void {
			_bitRate = bitRate;
		}
		
		public function get bitRate():int {
			return _bitRate;
		}

		public function hasBitRate():Boolean {
			return _bitRate > -1;
		}
		
		public function set width(width:String):void {
			_width = width;
		}
		
		public function get width():String {
			return _width;
		}
		
		public function set height(height:String):void {
			_height = height;
		}
		
		public function get height():String {
			return _height;
		}

		public function isMimeType(matchMimeType:*):Boolean {
			if(matchMimeType == null) {
				return true;
			}
			if(matchMimeType is Array) {
				return isPermittedMimeType(matchMimeType);
			}				
			return (matchMimeType.toUpperCase() == 'ANY' || _mimeType.toUpperCase() == matchMimeType.toUpperCase());
		}
		
		public function isDeliveryType(deliveryType:String):Boolean {
			if(deliveryType == null) {
				return true;
			}
			return (deliveryType.toUpperCase() == 'ANY' 
			        || _delivery.toUpperCase() == deliveryType.toUpperCase());
		}

		public override function toJSObject():Object {
			var o:Object = new Object();
			o = {
				id: _id,
				uid: _uid,
				bandwidth: _bandwidth,
				delivery: _delivery,
				scale: _scale,
				maintainAspectRatio: _maintainAspectRatio,
				mimeType: _mimeType,
				bitRate: _bitRate,
				width: _width,
				height: _height,
				apiFramework: _apiFramework,
				urlId: (_url != null) ? _url.id : null,
				url: (_url != null) ? _url.url: null,
				adParameters: ((_adParameters != null) ? escape(_adParameters) : null)
			};
			return o;
		}
	}
}