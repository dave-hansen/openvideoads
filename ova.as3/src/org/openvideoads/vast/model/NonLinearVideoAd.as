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
	import org.openvideoads.util.NetworkResource;
	import org.openvideoads.util.StringUtils;
	import org.openvideoads.vast.config.groupings.AdSlotRegionConfig;
	import org.openvideoads.vast.events.OverlayAdDisplayEvent;
	import org.openvideoads.vast.events.VideoAdDisplayEvent;

	/**
	 * @author Paul Schulz
	 */
	public class NonLinearVideoAd extends TrackedVideoAd {
		protected var _width:int = -1;
		protected var _height:int = -1;
		protected var _expandedWidth:int = -1;
		protected var _expandedHeight:int = -1;
		protected var _resourceType:String;
		protected var _creativeType:String;
		protected var _apiFramework:String;
		protected var _url:NetworkResource;
		protected var _codeBlock:String;
		protected var _nonLinearClickTrackingExtensions:Array = new Array();
		protected var _activeDisplayRegion:AdSlotRegionConfig = null;
		protected var _resourceHeight:Number = -1;
		protected var _resourceWidth:Number = -1;
		protected var _loaded:Boolean = false;
		protected var _adParameters:String = null;
		
		public function NonLinearVideoAd() {
			super();
		}
		
		public override function unload():void {
			super.unload();
			if(hasNonLinearClickTrackingExtensions()) {
				for(var i:int=0; i < _nonLinearClickTrackingExtensions.length; i++) {
					NetworkResource(_nonLinearClickTrackingExtensions[i]).close();
				}
			}
		}
		
		public function isPermittedCreativeType(mimeTypes:Array):Boolean {
			if(_creativeType == null) return true;
			for(var i:int=0; i < mimeTypes.length; i++) {
				if(StringUtils.matchesIgnoreCase(_creativeType, mimeTypes[i])) return true;
			}
			return false;
		}
		
		public function set width(width:*):void {
			if(typeof width == 'string') {
				_width = parseInt(width);
			}
			else _width = width;
		}
		
		public function get width():int {
			return _width;
		}
		
		public function hasWidth():Boolean {
			return _width > -1;
		}
		
		public function set height(height:*):void {
			if(typeof height == 'string') {
				_height = parseInt(height);
			}
			else _height = height;
		}
		
		public function get height():int {
			return _height;
		}
		
		public function hasHeight():Boolean {
			return _height > -1;
		}
		
		public function set expandedWidth(expandedWidth:*):void {
			if(typeof expandedWidth == 'string') {
				_expandedWidth = parseInt(expandedWidth);
			}
			else _expandedWidth = expandedWidth;
		}
		
		public function get expandedWidth():int {
			return _expandedWidth;
		}
		
		public function hasExpandedWidth():Boolean {
			return _expandedWidth > -1;
		}
		
		public function set expandedHeight(expandedHeight:*):void {
			if(typeof expandedHeight == 'string') {
				_expandedHeight = parseInt(expandedHeight);
			}
			else _expandedHeight = expandedHeight;
		}
		
		public function get expandedHeight():int {
			return _expandedHeight;
		}
		
		public function hasExpandedHeight():Boolean {
			return _expandedHeight > -1;
		}
		
		public function isExpandable():Boolean {
			return hasExpandedWidth() && hasExpandedHeight();
		}

		public function markAsLoading():void {
			_loaded = false;
		}

		public function markAsLoaded():void {
			_loaded = true;
		}

		public function get loaded():Boolean {
			return _loaded;
		}
				
		public function set resourceType(resourceType:String):void {
			_resourceType = ((resourceType != null) ? resourceType.toUpperCase() : resourceType);
		}
		
		public function get resourceType():String {
			return _resourceType;
		}
		
		public function set creativeType(creativeType:String):void {
			_creativeType = ((creativeType != null) ? creativeType.toUpperCase() : creativeType);
		}
		
		public function get creativeType():String {
			if(_creativeType != null) {
				var slashPos:int = _creativeType.indexOf("/");
				if(slashPos > -1 && (slashPos+1 < _creativeType.length)) {
					// change a mime based type like "image/jpg" or "application/x-shockwave-flash" 
					// to strip out the "initial" bit leaving just the basic type
					return _creativeType.substr(slashPos + 1);	
				}
			}
			return _creativeType;
		}

		public function get creativeMimeType():String {
			return _creativeType;
		}
		
		public function hasCreativeType():Boolean {
			return (_creativeType != null);	
		}
		
		public function set apiFramework(apiFramework:String):void {
			_apiFramework = apiFramework;
		}
		
		public function get apiFramework():String {
			return _apiFramework;
		}
		
		public function hasAPIFramework():Boolean {
			return !StringUtils.isEmpty(_apiFramework);
		}

		public function isInteractive():Boolean {
			return false;
		}
		
		public function set url(url:NetworkResource):void {
			_url = url;
		}
		
		public function get url():NetworkResource {
			return _url;
		}
		
		public function set adParameters(adParameters:String):void {
			_adParameters = adParameters;
		}

		public function get adParameters():String {
			return _adParameters;
		}

		public function hasAdParameters():Boolean {
			return (_adParameters != null);
		}
		
		public function hasUrl():Boolean {
			if(_url != null) {
				return _url.hasUrl();	
			}
			return false;
		}
		
		public function set codeBlock(codeBlock:String):void {
			_codeBlock = codeBlock;
		}
		
		public function get codeBlock():String {
			return _codeBlock;
		}
		
		public function hasCode():Boolean {
			if(_codeBlock != null) {
				return (StringUtils.trim(_codeBlock).length > 0);
			}
			return false;
		}
		
		public function isEmpty():Boolean {
			return !hasUrl() && !hasCode();
		}

		public function getContentFormat():String {
			if(hasUrl()) {
				return "URL";
			}
			return "CODE";
		}
		
		public function contentType():String {
			if(isFlash()) {
				if(isInteractive()) {
					return "VPAID";
				}
				return "SWF";
			} 
			if(isHtml()) return "HTML";
			if(isText()) return "TEXT";
			if(isIFrame()) return "IFRAME";
			if(isScript()) return "SCRIPT";
			return "IMAGE";
		}

		public function get content():String {
			if(hasCode()) {
				return _codeBlock;			
			}
			if(hasUrl()) {
				return _url.getQualifiedStreamAddress();			
			}
			return "";
		}
		
		public function rawContentAsObject():Object {
			return { 
				type: contentType(),
				format: (hasCode() ? "CODE" : "URL"),
				content: content
			};
		}
		
		public function isHtml():Boolean {
			return (isHtmlResourceType() || (isStaticResourceType() && isHTMLCreativeType()));
		}
		
		public function isFlash():Boolean {
			return isStaticResourceType() && isSWFCreativeType();
		}

		public function isScript():Boolean {
			return isScriptResourceType() || (isStaticResourceType() && isScriptCreativeType());
		}
		
		public function isImage():Boolean {
			return isStaticResourceType() && isImageCreativeType();
		}
		
		public function isText():Boolean {
			return isTextResourceType();
		}
		
		public function isIFrame():Boolean {
			return isIFrameResourceType();
		}

		public function isTextResourceType():Boolean {
			if(_resourceType != null) {
				return (_resourceType.toUpperCase()	== "TEXT");		
			}
			return false;
		}
		
		public function isHtmlResourceType():Boolean {
			if(_resourceType != null) {
				return (_resourceType.toUpperCase()	== "HTML");		
			}
			return false;
		}

		public function isScriptResourceType():Boolean {
			if(_resourceType != null) {
				return (_resourceType.toUpperCase()	== "SCRIPT");
			}
			return false;
		}
		
		public function isIFrameResourceType():Boolean {
			if(_resourceType != null) {
				return (_resourceType.toUpperCase()	== "IFRAME");						
			}
			return false;
		}
		
		public function isStaticResourceType():Boolean {
			if(_resourceType != null) {
				return (_resourceType.toUpperCase()	== "STATIC");		
			}
			return false;			
		}

		public function onlyStaticResourceTypeDeclared():Boolean {
			return (isStaticResourceType() && (hasCreativeType() == false));
		}
		
		public function isSWFCreativeType():Boolean {
			if(creativeType != null) {
				return (creativeType.toUpperCase() == "APPLICATION/SWF" ||
				        creativeType.toUpperCase() == "SWF" || 
				        creativeType.toUpperCase() == "APPLICATION/X-SHOCKWAVE-FLASH" ||
				        creativeType.toUpperCase() == "X-SHOCKWAVE-FLASH");
			}	
			return false;
		}

		public function isTextCreativeType():Boolean {
			if(creativeType != null) {
				return (creativeType.toUpperCase() == "TEXT");
			}	
			return false;
		}


		public function isHTMLCreativeType():Boolean {
			if(creativeType != null) {
				return (creativeType.toUpperCase() == "HTML" || creativeType.toUpperCase() == "TEXT/HTML");
			}	
			return false;
		}

		public function isScriptCreativeType():Boolean {
			if(creativeType != null) {
				return (creativeType.toUpperCase() == "TEXT/JAVASCRIPT") || 
				       (creativeType.toUpperCase() == "JAVASCRIPT");
			}	
			return false;
		}
		
		public function isImageCreativeType():Boolean {
			return (creativeType == "IMAGE/JPEG" ||
			        creativeType == "JPEG" || 
					creativeType == "IMAGE/JPG" ||
			        creativeType == "JPG" || 
			        creativeType == "IMAGE/GIF" ||
			        creativeType == "GIF" || 
                    creativeType == "IMAGE/PNG" ||
			        creativeType == "PNG");
		}
		
		public function hasAccompanyingVideoAd():Boolean {
			if(parentAdContainer != null) {
				return parentAdContainer.hasLinearAd();
			}
			return false;
		}

		public function matchesSizeAndIndex(width:int, height:int, index:int):Boolean {
			if(matchesSize(width, height)) {
				return index == _index;
			}
			return false;
		}
		
		public function matchesSizeAndResourceType(width:int, height:int, resourceType:String):Boolean {
			if(matchesSize(width, height)) {
				if(resourceType != null && _resourceType != null) {
					return (_resourceType.toUpperCase() == resourceType.toUpperCase());
				}
			}
			return false;
		}
		
		public function matchesSizeAndTypes(width:int, height:int, creativeType:String, resourceType:String=null):Boolean {
			if(matchesSize(width, height)) {
				if(creativeType != null && _creativeType != null) {
					return ((_creativeType.toUpperCase() == creativeType.toUpperCase()) &&
				            (_resourceType.toUpperCase() == resourceType.toUpperCase()));
				}
				return (_resourceType.toUpperCase() == resourceType.toUpperCase());
			}
			return false;
		}
		
		public function matchesSize(width:int, height:int):Boolean {
			if(width == -1 && height == -1) {
				return true;
			}
			else {
				if(width == -1) { // just check the height
					return (height == _height);
				}
				else {
					if(width == _width) {
						return (height == _height);						
					}
					else return false;
				}
			}
		}

		public function matchesAcceptedAdTypes(acceptedAdTypes:Array):Boolean {
			if(acceptedAdTypes != null) {
				if(acceptedAdTypes.length > 0) {
					return (acceptedAdTypes.indexOf(contentType()) > -1);
				}
			}
			return true;
		}

		public function matchesSizeAndAcceptedAdTypes(width:int, height:int, acceptedAdTypes:Array):Boolean {
			if(matchesAcceptedAdTypes(acceptedAdTypes)) {
				return matchesSize(width, height);
			}
			return false;
		}
		
		public function deriveScoreBasedOnEstimatedSizeAndAcceptedAdTypes(playerWidth:int, playerHeight:int, acceptedAdTypes:Array):int {
			if(matchesAcceptedAdTypes(acceptedAdTypes)) {
				if(scale == false) {
					if(isText()) {
						return 0; // Text ads are always considered an exact match
					}
					else {
						if((_height > playerHeight) || (_width > playerWidth)) {
							return -1; // larger than the player dimensions and not scalable
						}
						else {
							if(_width > 0) {
								return playerWidth - _width;
							}
							return -1;
						}
					}
				}
				else return 0; // scalable resource/creative type so return 0 as it will be a good fit
			}
			return -1;
		}
		
		public function set activeDisplayRegion(region:AdSlotRegionConfig):void {
			_activeDisplayRegion = region;
		}
		
		public function get activeDisplayRegion():AdSlotRegionConfig {
			return _activeDisplayRegion;
		}

		public function hasActiveDisplayRegion():Boolean {
			return _activeDisplayRegion != null;
		}
				
		public function getActiveDisplayRegionID():String {
			if(hasActiveDisplayRegion()) {
				return _activeDisplayRegion.getRegionIDBasedOnAdType(contentType());
			}
			return "auto:bottom";
		}
		
		public function clearActiveDisplayRegion():void {
			activeDisplayRegion = null;
		}
		
		public function getRawContent():String {
			if(hasUrl()) {
				return _url.url;
			}
			return _codeBlock;
		}
		
		public function getContent():String {
			if(hasActiveDisplayRegion()) {
				return _activeDisplayRegion.getTemplateBasedOnAdType(contentType()).getContent(this);
			}
			return "";
		}

		public function get enforceRecommendedSizing():Boolean {
			if(hasActiveDisplayRegion()) {
				return _activeDisplayRegion.enforceRecommendedSizing;
			}
			return false;
		}

		public function start(displayEvent:VideoAdDisplayEvent, region:*=null):void {
			activeDisplayRegion = region;
			triggerTrackingEvent(TrackingEvent.EVENT_CREATIVE_VIEW);
			triggerTrackingEvent(TrackingEvent.EVENT_START);
			if(displayEvent.controller != null) {
				displayEvent.controller.onDisplayNonLinearAd(
				           new OverlayAdDisplayEvent(
				                     OverlayAdDisplayEvent.DISPLAY, 
				                     this,
				                     displayEvent.customData.adSlot,
				                     region
				           ));				
			}
		}
		
		public function stop(displayEvent:VideoAdDisplayEvent, region:*=null):void {
			triggerTrackingEvent(TrackingEvent.EVENT_COMPLETE);	
			if(displayEvent.controller != null) {
				displayEvent.controller.onHideNonLinearAd(
				           new OverlayAdDisplayEvent(
				                     OverlayAdDisplayEvent.HIDE, 
				                     this,
				                     displayEvent.customData.adSlot,
				                     activeDisplayRegion
				           ));				
			}
			activeDisplayRegion = null;
		}

		public function addNonLinearClickExtension(clickTrackingExtension:NetworkResource):void {
			_nonLinearClickTrackingExtensions.push(clickTrackingExtension);
		}

        public function addNonLinearClickTrackingExtensionItems(clickList:Array):void {
        	if(clickList != null) {
	        	_nonLinearClickTrackingExtensions = _nonLinearClickTrackingExtensions.concat(clickList);        		
        	}
        }

		public function hasNonLinearClickTrackingExtensions():Boolean {
			return (_nonLinearClickTrackingExtensions.length > 0);	
		}
		
		public function fireNonLinearClickTrackingExtensions():void {
			if(hasNonLinearClickTrackingExtensions()) {	
				for(var i:int = 0; i < _nonLinearClickTrackingExtensions.length; i++) {
					_nonLinearClickTrackingExtensions[i].call();
				}
			}
		}
		
		public function clicked():void {
			fireNonLinearClickTrackingExtensions();
			triggerTrackingEvent(TrackingEvent.EVENT_ACCEPT);
		}

		public function close():void {
			triggerTrackingEvent(TrackingEvent.EVENT_CLOSE);			
		}
		
		public override function clone(subClone:*=null):* {
			var clone:NonLinearVideoAd;
			if(subClone == null) {
				clone = new NonLinearVideoAd();
			}
			else clone = subClone;

			clone.width = _width;
			clone.height = _height;
			clone.expandedWidth = _expandedWidth;
			clone.expandedHeight = _expandedHeight;			
			clone.recommendedMinDuration = _recommendedMinDuration;
			clone.resourceType = _resourceType;
			clone.creativeType = _creativeType;
			clone.apiFramework = _apiFramework;
			clone.url = _url;
			clone.codeBlock = _codeBlock;
			clone.scale = _scale;
			clone.addNonLinearClickTrackingExtensionItems(_nonLinearClickTrackingExtensions);

			return super.clone(clone);
		}

		public override function toJSObject():Object {
			var o:Object = super.toJSObject();
			o.width = _width;
			o.height = _height;
			o.expandedWidth = _expandedWidth;
			o.expandedHeight = _expandedHeight;
			o.scale = _scale;
			o.resourceType = _resourceType;
			o.creativeType = _creativeType;
			o.apiFramework = _apiFramework;
			o.url = ((_url != null) ? _url.url : "");
			o.codeblock = _codeBlock;
			return o;
		}	
	}
}