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
package org.openvideoads.regions.view {
	import flash.display.*;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.MouseEvent;
	import flash.net.URLRequest;
	import flash.system.ApplicationDomain;
	import flash.system.LoaderContext;
	import flash.system.Security;
	import flash.system.SecurityDomain;
	import flash.text.AntiAliasType;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	
	import org.openvideoads.base.Debuggable;
	import org.openvideoads.regions.RegionController;
	import org.openvideoads.regions.config.RegionViewConfig;
	import org.openvideoads.regions.view.button.CloseButton;
	import org.openvideoads.regions.view.button.CrossCloseButton;
	import org.openvideoads.regions.view.button.LoadableImageCloseButton;
	import org.openvideoads.regions.view.button.StandardImageCloseButton;
	import org.openvideoads.util.DisplayProperties;
	import org.openvideoads.util.GraphicsUtils;
	import org.openvideoads.util.NumberUtils;
	import org.openvideoads.util.StyleUtils;
 	
	/**
	 * @author Paul Schulz
	 */
	public class RegionView extends Sprite {
		protected var _controller:RegionController;
		protected var _config:RegionViewConfig;
		protected var _displayProperties:DisplayProperties;
		protected var _stylesheet:LoadableStyleSheet = null;
		protected var _text:TextField;
		protected var _textMask:Sprite;
		protected var _closeButton:CloseButton = null;
		protected var _autoHide:Boolean = true;
		protected var _contentLoader:Loader = null;
		protected var _border:Sprite;
		protected var _width:Number = 0;
		protected var _height:Number = 0;
		protected var _autoSizing:Boolean = false;
		protected var _activeFlashMedia:FlashMedia = null;
		protected var _maskShape:Shape = null;
		protected var _loadedImage:Bitmap = null;
		protected var _scalable:Boolean = true;
		protected var _minimized:Boolean = false;
		protected var _expanded:Boolean = false;
		
		public function RegionView(controller:RegionController, regionConfig:RegionViewConfig, displayProperties:DisplayProperties) { //, autoHide:Boolean=true) {
            super();
			visible = false;
			buttonMode = true;
			mouseChildren = true; 
			_controller = controller;
			_config = regionConfig;
			_displayProperties = displayProperties;
			_autoHide = regionConfig.autoHide; //autoHide;
            if(regionConfig.stylesheet != null) {
            	_stylesheet = new LoadableStyleSheet(regionConfig.stylesheet, onStyleSheetLoaded);
            }
            if(regionConfig.style != null) {
            	if(_stylesheet == null) _stylesheet = new LoadableStyleSheet();
            	_stylesheet.parseCSS(regionConfig.style);
            }
			if(_config.canShowCloseButton()) {
				createCloseButton();
			}
			addListeners();
			if(_config.html) html = _config.html;
			resize();
			redraw();
		}

		public function isAutoSizing():Boolean {
			return this.autoSizing;
		}
		
		public function set autoSizing(autoSizing:Boolean):void {
			if(_config == null) _config = new RegionViewConfig();
			_config.autoSizing = autoSizing;
		}
		
		public function get autoSizing():Boolean {
			if(_config != null) {
				return _config.autoSizing;			
			}
			return false;
		}
		
		public function set scalable(scalable:Boolean):void {
			_scalable = scalable;
		}
		
		public function get scalable():Boolean {
			return _scalable;
		}

		protected function createCloseButton():void {
			switch(_config.closeButton.type) {
				case "STANDARD":
					_closeButton = new StandardImageCloseButton(null, this);
					break;
				case "CROSSHAIR":
					_closeButton = new CrossCloseButton(null, this, _config.closeButton);
					break;
				case "CUSTOM":
					_closeButton = new LoadableImageCloseButton(null, this, _config.closeButton);
					break;
				case "SKINNED":
					break;
			}
			addChild(_closeButton);			
		}

		public override function get width():Number {
            if (scaleX > 1) {
	            return _width * scaleX;
            }
			return _width || super.width;
		}
		
		public override function set width(value:Number):void {
			setSize(value, _height);
		}
		
		public function set configuredWidth(value:Number):void {
			if(_config != null) {
				_config.width = value;
			}
			setSize(value, _height, false);			
		}

		public override function get height():Number {
            if (scaleY > 1) {
            	return _height * scaleY;
            }
			return _height || super.height;
		}
		
		public override function set height(value:Number):void {
			setSize(_width, value);
		}

		public function set configuredHeight(value:Number):void {
			if(_config != null) {
				_config.height = value;
			}
			setSize(_width, value, false);
		}

		public function setSize(newWidth:Number, newHeight:Number, redrawNow:Boolean=true):void {
			_width = newWidth;
			_height = newHeight;
			onResize();
			if(redrawNow) redraw();
		}		

		public function set borderRadius(borderRadius:int):void {
			if(_config != null) _config.borderRadius = borderRadius;
		}
		
		public function get borderRadius():int {
			return ((_config != null) ? _config.borderRadius : -1);
		}
		
		public function hasBorderRadius():Boolean {
			return ((_config != null) ? _config.hasBorderRadius() : false);
		}

		public function getBorderRadiusAsInt():int {
			if(hasBorderRadius() == false) {
				return 5;
			}
			return NumberUtils.toPixels(borderRadius);
		}

		public function set borderWidth(borderWidth:int):void {
			if(_config != null) _config.borderWidth = borderWidth;
		}
		
		public function get borderWidth():int {
			return ((_config != null) ? _config.borderWidth : -1);
		}
		
		public function hasBorderWidth():Boolean {
			return ((_config != null) ? _config.hasBorderWidth() : false);
		}

		public function set borderColor(borderColor:String):void {
			if(_config != null) _config.borderColor = borderColor;
		}
		
		public function get borderColor():String {
			return ((_config != null) ? _config.borderColor : null);
		}
		
		public function hasBorderColor():Boolean {
			return ((_config != null) ? _config.hasBorderColor() : false);
		}
		
		public function set border(border:String):void {
			if(_config != null) _config.border = border;
		}
		
		public function get border():String {
			return (_config != null) ? _config.border : null;
		}
		
		public function hasBorder():Boolean {
			return ((_config != null) ? _config.hasBorder() : false);			
		}

		public function getBorderWidthAsNumber():Number {
			if(hasBorderWidth()) {
				return NumberUtils.toPixels(borderWidth);
			}
			if(hasBorder() == false) {
				return 0;
			}
			return NumberUtils.toPixels(StyleUtils.toElements(border)[0]);
		}

		public function getBorderColorAsUInt():uint {
			if(hasBorderColor()) {
				return StyleUtils.toColorValue(borderColor);
			}
			if(hasBorder()) {
				return StyleUtils.toColorValue(StyleUtils.toElements(border)[2]);
			}
			return 0xffffff;
		}

        public function parseCSS(cssText:String):void {
           	if(_stylesheet == null) _stylesheet = new LoadableStyleSheet();
            _stylesheet.parseCSS(cssText);
        	CONFIG::debugging { doLog("Stylesheet settings have been updated to include: " + cssText, Debuggable.DEBUG_DISPLAY_EVENTS); }           
        }
        
		public function set background(background:String):void {
			if(_config != null) _config.background = background;
		}
		
		public function get background():String {
			return (_config != null) ? _config.background : null;
		}
		
		public function hasBackground():Boolean {
			return ((_config != null) ? _config.hasBackground() : false);			
		}
		
		public function set backgroundGradient(backgroundGradient:*):void {
			if(_config != null) _config.backgroundGradient = backgroundGradient;
		}
		
		public function get backgroundGradient():* {
			return (_config != null) ? _config.backgroundGradient : null;
		}
		
		public function hasBackgroundGradient():Boolean {
			return ((_config != null) ? _config.hasBackgroundGradient() : false);						
		}

		public function getBackgroundGradientAsArray():Array {
			if(hasBackgroundGradient()) {
				if(backgroundGradient is String) {
					switch(backgroundGradient) {
						case "none":
							return null;
						case "high":
							return [1.0, 0.5, 0.1, 0.3];
						case "medium":
							return [0.6, 0.21, 0.21];
						case "low":
							return [0.4, 0.15, 0.15];
					}
					return [0.4, 0.15, 0.15];
				}	
				return backgroundGradient;
			}
			return null;
		}

		public function makeBackgroundTransparent():void {
			if(_config != null) {
				_config.makeBackgroundTransparent();
				redraw();
			}
		}
		
		public function restoreOriginalBackground():void {
			if(_config != null) {
				_config.restoreOriginalBackground();
				redraw();
			}
		}

		public function set backgroundTransparent(backgroundTransparent:Boolean):void {
			if(_config != null) _config.backgroundColor = (backgroundTransparent) ? "transparent" : null;
		}
		
		public function isBackgroundTransparent():Boolean {
			if(hasBackgroundColor() == false) {
				return false;
			}
			return (backgroundColor.toUpperCase() == "TRANSPARENT");
		}

		public function set backgroundColor(backgroundColor:String):void {
			if(_config != null) _config.backgroundColor = backgroundColor;
		}
		
		public function get backgroundColor():String {
			return (_config != null) ? _config.backgroundColor : null;
		}
		
		public function hasBackgroundColor():Boolean {
			return (_config != null) ? _config.hasBackgroundColor() : false;
		}
		
		public function getBackgroundColorAsUInt():uint {
			if(hasBackgroundColor()) { 
				return StyleUtils.toColorValue(backgroundColor);
			}
			if(hasBackground()) { 
				var props:Array = StyleUtils.toElements(backgroundColor);
				if (String(props[0]).indexOf("#") == 0) {
					return StyleUtils.toColorValue(props[0]);
				}
			}
			return 0x333333;
		}
		
		public function set opacity(opacity:Number):void {
			if(_config != null) _config.opacity = opacity;
		}
		
		public function get opacity():Number {
			return (_config != null) ? _config.opacity : 1.0;
		}
		
		public function hasOpacity():Boolean {
			return (_config != null) ? _config.hasOpacity() : false;			
		}

		public function hideCloseButton():void {
			if(_closeButton != null) {
				_closeButton.visible = false;
			}
		}
		
		public function canShowCloseButton():Boolean {
			return (_config != null) ? _config.canShowCloseButton() : false;
		}		

        public function set padding(padding:String):void {
        	if(_config != null) _config.padding = padding;
        }
        
        public function get padding():String {
			return (_config != null) ? _config.padding : null;
        }
        
		public function get template():String {
			return (_config != null) ? _config.template : null;
		}

		public function hasTemplate():Boolean {
			return (_config != null) ? _config.hasTemplate() : false;
		}
				
		public function get contentTypes():String {
			return (_config != null) ? _config.contentTypes : null;
		}
		
		public function hasContentTypes():Boolean {
			return (_config != null) ? _config.hasContentTypes() : false;
		}

        protected function onStyleSheetLoaded():void {
        	CONFIG::debugging { doLog("Stylesheet has been loaded", Debuggable.DEBUG_DISPLAY_EVENTS); }
        }

		public function get id():String {
			return (_config != null) ? _config.id : "none";
		}

		private function addListeners():void {
			if(_config.clickable) {
				addEventListener(MouseEvent.ROLL_OVER, onMouseOver);
				addEventListener(MouseEvent.ROLL_OUT, onMouseOut);
				addEventListener(MouseEvent.CLICK, onClick);
			}
		}
		
		private function removeListeners():void {
			if(_config.clickable) {
				removeEventListener(MouseEvent.ROLL_OVER, onMouseOver);
				removeEventListener(MouseEvent.ROLL_OUT, onMouseOut);
				removeEventListener(MouseEvent.CLICK, onClick);	
			}
		}
		
		public function setWidth():Boolean {
			var originalWidth:Number = width;
			if(expanded && _config.hasExpandedSizing()) {
				width = _config.expandedWidth;
				return true;
			}
			else {
				var requiredWidth:* = _config.width;
				if(typeof requiredWidth == "string") { // it's a percentage
					if(requiredWidth.indexOf("pct") != -1) {
						var parentWidth:int = _displayProperties.displayWidth;
						var widthPercentage:int = parseInt(requiredWidth.substring(0,requiredWidth.indexOf("pct")));
						width = ((parentWidth / 100) * widthPercentage);
						CONFIG::debugging { doLog("Width is to be set to a percentage of the parent - " + requiredWidth + " setting to " + width, Debuggable.DEBUG_REGION_FORMATION); }
					}
					else {
						CONFIG::debugging { doLog("Region width is a string value " + requiredWidth + " for region " + id, Debuggable.DEBUG_REGION_FORMATION); }
						width = parseInt(requiredWidth);			
					}
				}
				else if(requiredWidth is Number) {
					CONFIG::debugging { doLog("Region width is defined as a number " + requiredWidth + " for region " + id, Debuggable.DEBUG_REGION_FORMATION); }
					width = requiredWidth;
				}
				else {
					CONFIG::debugging { doLog("FATAL: Bad type '" + (typeof requiredWidth) + "' for width value '" + requiredWidth + "' of region " + id, Debuggable.DEBUG_REGION_FORMATION); }
				}
			}
			return (width != originalWidth);
		}
		
		public function setHeight():Boolean {
			var originalHeight:Number = height;
			if(expanded) {
				// TO COMPLETE
			}
			else {
				var requiredHeight:* = _config.height;	
				if(typeof requiredHeight == "string") { 
					if(requiredHeight.indexOf("pct") != -1) { 
						var parentHeight:int = 0; 
						if(_config.hasAdditionalHeight() && minimized == false){
							var additionalHeight:Number = 0;
							if(_config.additionalHeightIsRestricted()) {
								if(_config.additionalHeightRestrictionsMet(_displayProperties)) {
									additionalHeight = _config.calculateAdditionalHeight(_displayProperties);
									CONFIG::debugging { doLog("Taking additional height (" + additionalHeight + " with restrictions) into considertion when sizing region " + id, Debuggable.DEBUG_REGION_FORMATION); }
								}
							}
							else {
								additionalHeight = _config.calculateAdditionalHeight(_displayProperties);
								CONFIG::debugging { doLog("Taking additional height (" + additionalHeight + " without restrictions) into considertion when sizing region " + id, Debuggable.DEBUG_REGION_FORMATION);	}					
							}
							parentHeight = _displayProperties.getMarginAdjustedHeight(_config.useOverrideMargin) + additionalHeight;
						}
						else {
							parentHeight = _displayProperties.getMarginAdjustedHeight(_config.useOverrideMargin);						
						}
						var heightPercentage:int = parseInt(requiredHeight.substring(0,requiredHeight.indexOf("pct")));
						height = ((parentHeight / 100) * heightPercentage);
						CONFIG::debugging { doLog("Height for " + id + " calculated as % (" + requiredHeight + ") of parent " + parentHeight + " = " + height, Debuggable.DEBUG_REGION_FORMATION); }
					}
					else {
						CONFIG::debugging { doLog("Region height is a string value " + requiredHeight + " for region " + id, Debuggable.DEBUG_REGION_FORMATION); }
						height = parseInt(requiredHeight);
					}
				}
				else if(requiredHeight is Number) {
					CONFIG::debugging { doLog("Region height is defined as a number " + requiredHeight + " for region " + id, Debuggable.DEBUG_REGION_FORMATION); }
					height = requiredHeight;
				}
				else {
					CONFIG::debugging { doLog("FATAL: Bad type '" + (typeof requiredHeight) + "' for height value '" + requiredHeight + "' of region " + id, Debuggable.DEBUG_REGION_FORMATION); }
				}	
			}
			return (height != originalHeight);
		}
		
		public function setVerticalAlignment():Boolean {
			var originalY:Number = y;
			var parentHeight:int = (_displayProperties.displayHeight * scaleY);
			if(_config.verticalAlignPosition is String) {
				if(_config.verticalAlignPosition == "TOP") {
					y = 0 + _config.verticalAlignOffset;
				}
				else if(_config.verticalAlignPosition == "BOTTOM") {
					y = (parentHeight - height) + _config.verticalAlignOffset; 
				}
				else if(_config.verticalAlignPosition == "CENTER") {
					y = ((parentHeight - height) / 2) + _config.verticalAlignOffset;
				}
				else { // must be a number
					y = new Number(_config.verticalAlignPosition + _config.verticalAlignOffset);
				}	
				CONFIG::debugging { doLog("Vertical alignment set to " + y + " for region " + id, Debuggable.DEBUG_REGION_FORMATION);	}
			}
			else {
				y = _config.verticalAlignPosition as Number;
				y += _config.verticalAlignOffset;
				CONFIG::debugging { doLog("Vertical alignment set to " + y + " for region " + id, Debuggable.DEBUG_REGION_FORMATION);	}	
			}
			
			return (y != originalY);
		}

		public function setHorizontalAlignment():Boolean {
			var originalX:Number = x;
			var align:* = _config.horizontalAlign;
			var parentWidth:int = (_displayProperties.displayWidth * scaleX);
			if(typeof align == "string") {
				align = align.toUpperCase();
				if(align == "LEFT") {
					x = 0;
				}
				else if(align == "RIGHT") {
					x = parentWidth-width;
				}		
				else if(align == "CENTER") {
					x = ((parentWidth-width) / 2);
				}
				else { // must be a number
					x = new Number(align);
				}	
				CONFIG::debugging { doLog("Horizontal alignment set to " + x + " for region " + id, Debuggable.DEBUG_REGION_FORMATION);	}	
			}
			else if(typeof align == "number") {
				x = align;
				CONFIG::debugging { doLog("Horizontal alignment set to " + x + " for region " + id, Debuggable.DEBUG_REGION_FORMATION); }		
			}
			else {
				CONFIG::debugging { doLog("Bad horizontal alignment value " + align + " on region " + id, Debuggable.DEBUG_REGION_FORMATION); }
			} 
			
			return (x != originalX);
		}

		public function set minimized(minimized:Boolean):void {
			_minimized = minimized;
		}

		public function get minimized():Boolean {
			return _minimized;
		}
		
		public function minimize():void {
			_minimized = true;
			makeBackgroundTransparent();
			resize();
		}
		
		public function restore():void {
			if(_minimized) {
				_minimized = false;
				restoreOriginalBackground();
				resize();
			}
		}
		
		public function set expanded(expanded:Boolean):void {
			_expanded = expanded;
		}
		
		public function get expanded():Boolean {
			return _expanded;
		}
		
		public function expand():void {
			if(expanded == false) {
				CONFIG::debugging { doLog("RegionView expanded" + id, Debuggable.DEBUG_REGION_FORMATION); }		
				expanded = true;
				resize(_displayProperties);
			}
		}
		
		public function contract():void {
			if(expanded) {
				CONFIG::debugging { doLog("RegionView contracted" + id, Debuggable.DEBUG_REGION_FORMATION); }		
				expanded = false;
				makeBackgroundTransparent();
				resize(_displayProperties);
			}
		}
		
		public function resize(resizeProperties:DisplayProperties=null):void {
			if(resizeProperties != null) {
				_displayProperties = resizeProperties;

				// calculate the scaling factors if the region is scalable
				scaleX  = _config.canScale ? resizeProperties.scaleX : 1;
				scaleY  = _config.canScale ? resizeProperties.scaleY : 1;
				CONFIG::debugging { doLog("Scaling set to X: " + scaleX + " Y: " + scaleY, Debuggable.DEBUG_REGION_FORMATION); }
			}
			if(_displayProperties != null) {
				var widthChanged:Boolean = setWidth();
				var heightChanged:Boolean = setHeight();
				setVerticalAlignment();
				setHorizontalAlignment();
  				if(hasActiveScalableFlashMedia() && (widthChanged || heightChanged)) {
  					assessFlashMediaScaling();
  				}
			}
		}

		public function set autoHide(autoHide:Boolean):void {
			_autoHide = autoHide;
		}
		
		public function get autoHide():Boolean {
			return _autoHide;
		}

		public function set html(htmlText:String):void {
			if(_config != null) {
				_config.html = ((htmlText == null) ? "" : htmlText);
				CONFIG::debugging { doLog("Set region HTML to " + _config.html, Debuggable.DEBUG_REGION_FORMATION);	}			
				createTextField();
				arrangeCloseButton();
			}
		}

		public function get html():String {
			return ((_config != null) ? _config.html : null);
		}
		
		public function resizeDimensions(newWidth:Number, newHeight:Number):void {
			_config.width = newWidth;
			_config.height = newHeight;
			setWidth();
			setHeight();		
			setVerticalAlignment();
			setHorizontalAlignment();
		}
					
		protected function hasActiveScalableFlashMedia():Boolean {
			if(_activeFlashMedia != null && _contentLoader != null) {
				return _activeFlashMedia.scale; 
			}
			return false;
		}
		
		protected function modifyActiveFlashMediaDimensions(intendedWidth:Number, intendedHeight:Number):void {
			if(_activeFlashMedia.maintainAspectRatio) {
				var scalingFactor:Number = 1.0;
				if((intendedWidth > _width) && (Math.abs(intendedWidth - _width) > Math.abs(intendedHeight - _height))) {
					// the SWF width is proportionally larger than the height so use that as the scaling factor
					scalingFactor = intendedWidth / _width;
				}
				else {
					// the SWF height is proportially larger than the width so use that as the scaling factor
					scalingFactor = intendedHeight / _height;
				}
				CONFIG::debugging { doLog("Scaling the loaded SWF but maintaining the aspect ratio - the scaling factor is " + scalingFactor, Debuggable.DEBUG_VPAID); }
				_contentLoader.width = Math.floor(intendedWidth / scalingFactor);
				_contentLoader.height = Math.floor(intendedHeight / scalingFactor);
			}
			else {
				CONFIG::debugging { doLog("Mapping the loaded SWF width and height directly - the aspect ratio does not need to be maintained", Debuggable.DEBUG_VPAID); }
				if(intendedWidth > _width) {
					_contentLoader.width = _width;
				}
				if(intendedHeight > _height) {
					_contentLoader.height = _height;
				}
			}
			CONFIG::debugging { doLog("The SWF dimensions have been re-calculated as " + _contentLoader.width + "X" + _contentLoader.height, Debuggable.DEBUG_VPAID);	}	
		}
		
		protected function assessFlashMediaScaling():void {
			if(scalable) {
				if(_activeFlashMedia != null && _contentLoader != null) {
					doLog("enforceRecommendedSizing = " + _activeFlashMedia.enforceRecommendedSizing + ", scale = " + _activeFlashMedia.scale + " recommendedWidth = " + _activeFlashMedia.recommendedWidth + " recommendedHeight = " + _activeFlashMedia.recommendedHeight, Debuggable.DEBUG_VPAID);
					if(_activeFlashMedia.loaded) {
						if(_activeFlashMedia.scale) {
							if(_activeFlashMedia.enforceRecommendedSizing) {
								if(_activeFlashMedia.recommendedHeight > _height || _activeFlashMedia.recommendedWidth > _width) {
									CONFIG::debugging { doLog("Scaling the loaded SWF based on VAST dimensions - the width and height (" + _activeFlashMedia.recommendedWidth + "X" + _activeFlashMedia.recommendedHeight + ") does not fit within the region (" + _width + "X" + _height + ")", Debuggable.DEBUG_VPAID); }
									modifyActiveFlashMediaDimensions(_activeFlashMedia.recommendedWidth, _activeFlashMedia.recommendedHeight);
								}
							}
							else {
								if(_contentLoader.height > _height || _contentLoader.width > _width) {
									CONFIG::debugging { doLog("Scaling the loaded SWF based on actual SWF dimensions - width and height (" + _contentLoader.width + "X" + _contentLoader.height + ") does not fit within the region (" + _width + "X" + _height + ")", Debuggable.DEBUG_VPAID); }
									modifyActiveFlashMediaDimensions(_contentLoader.width, _contentLoader.height);
								}
							}
							
							// finally, with the adjusted sizing, if the SWF is smaller than this region, then resize the region if
							// it is an autoSizing region, otherwise center the SWF in it (adjust the x and y accordingly)
							
							if(isAutoSizing()) {
								resizeDimensions(_contentLoader.width, _contentLoader.height);
							}
							else {
								if(_contentLoader.width > 0 && _contentLoader.width < _width) {
									CONFIG::debugging { doLog("The loaded SWF X position has been adjusted to " + (0 + Math.floor((_width - _contentLoader.width) / 2)) + " based on 0 + Math.floor((" + _width + " - " + _contentLoader.width + ") / 2)'", Debuggable.DEBUG_VPAID); }
//									_contentLoader.x = _contentLoader.x + Math.floor((_width - _contentLoader.width) / 2);								
									_contentLoader.x = 0 + Math.floor((_width - _contentLoader.width) / 2);								
								}
								if(_contentLoader.height > 0 && _contentLoader.height < _height) {
									CONFIG::debugging { doLog("The loaded SWF Y position has been adjusted to " + (0 + (_height - _contentLoader.height)) + " based on 0 + Math.floor((" + _height + " - " + _contentLoader.height + ") / 2)'", Debuggable.DEBUG_VPAID); }
//									_contentLoader.y = _contentLoader.y + (_height - _contentLoader.height);
									_contentLoader.y = 0 + Math.floor((_height - _contentLoader.height) / 2);
								}								
							}
						}
					}
					else {	
						CONFIG::debugging { doLog("Not scaling the loaded flash media - scalable='false'", Debuggable.DEBUG_VPAID); }
					}
				}
			}
			else {
				CONFIG::debugging { doLog("Not scaling the flash media - scaling has been disabled", Debuggable.DEBUG_VPAID); }
			}
		}

		protected function loadScalableImageContent(url:String, expectedWidth:Number, expectedHeight:Number, recommendedWidth:Number, recommendedHeight:Number, scaleToDeclaredSize:Boolean, maintainAspectRatio:Boolean, allowDomains:String):void {
			if(url != null) {
			  	 clearDisplayContent();
				 CONFIG::debugging { doLog("Loading Image resource from " + url, Debuggable.DEBUG_DISPLAY_EVENTS); }
				 CONFIG::debugging { doLog("Security.allowDomain() has been set to " + allowDomains, Debuggable.DEBUG_DISPLAY_EVENTS); }
			  	 Security.allowDomain(allowDomains);
			  	 Security.allowInsecureDomain(allowDomains);
				 _contentLoader = new Loader();
				 _contentLoader.contentLoaderInfo.addEventListener(flash.events.IOErrorEvent.IO_ERROR, 
				 	function(event:Event):void {
				 		CONFIG::debugging { doLog("IO Error loading external image", Debuggable.DEBUG_DISPLAY_EVENTS); }
				    }
				 );
				 _contentLoader.contentLoaderInfo.addEventListener(flash.events.SecurityErrorEvent.SECURITY_ERROR, 
				 	function(event:Event):void {
				 		CONFIG::debugging { doLog("Security Error loading external image", Debuggable.DEBUG_DISPLAY_EVENTS); }
				    }
				 );
			 	 _contentLoader.contentLoaderInfo.addEventListener(Event.COMPLETE,
				 	function(event:Event):void {
						CONFIG::debugging { doLog("External image (load size is " + _contentLoader.width + "x" + _contentLoader.height + ", recommended size is " + recommendedWidth + "x" + recommendedHeight + ") successfully loaded from " + url, Debuggable.DEBUG_DISPLAY_EVENTS); }
						_loadedImage = Bitmap(_contentLoader.content);

						// Position the image at the top left corner of the region
						_loadedImage.x = 0;
						_loadedImage.y = 0;

						if(scalable) {
							// Now scale the image size to fit the maxWidth
						 	var scaleWidth:Number = recommendedWidth / _loadedImage.width;
						    var scaleHeight:Number = recommendedHeight / _loadedImage.height;
						    if(scaleToDeclaredSize) {
						    	_loadedImage.scaleX = scaleWidth;
						    	_loadedImage.scaleY = scaleHeight;
						    }
						    else if(scaleWidth < scaleHeight) {
						    	if(maintainAspectRatio) {
							        _loadedImage.scaleX = _loadedImage.scaleY = scaleWidth;
						    	}
						        else _loadedImage.scaleX = scaleWidth;
						    }
						    else {
						    	if(maintainAspectRatio) {
							        _loadedImage.scaleX = _loadedImage.scaleY = scaleHeight;
						    	}
						    	else _loadedImage.scaleX = scaleHeight;
						    }
						    CONFIG::debugging { doLog("Image scaling is - scaleX: " + _loadedImage.scaleX + ", scaleY: " + _loadedImage.scaleY + ", scaleToDeclaredSize: " + scaleToDeclaredSize + ", maintainAspectRatio: " + maintainAspectRatio, Debuggable.DEBUG_DISPLAY_EVENTS); }

							// resize the height of this region to the recommended image height if this is an autosizing region
							if(isAutoSizing()) {
								resizeDimensions(_loadedImage.width, _loadedImage.height);
							}
						}
						else {
							CONFIG::debugging { doLog("Image will not be scaled - 'enableScaling' is false", Debuggable.DEBUG_DISPLAY_EVENTS); }
						} 
						
					    // Finally add the image to the sprite and show it
						addChild(_loadedImage);
						arrangeCloseButton();
						_loadedImage.visible = true;
						_contentLoader = null;
					}
				 );
				 _contentLoader.load(new URLRequest(url), new LoaderContext(true, ApplicationDomain.currentDomain, SecurityDomain.currentDomain));
			}
		}

		public function loadFlashContent(media:FlashMedia, allowDomains:String, blockMouseActions:Boolean=false):void {
		  	 clearDisplayContent();
			 CONFIG::debugging { doLog("Loading Flash resource from " + media.swfURL, Debuggable.DEBUG_VPAID); }
			 CONFIG::debugging { doLog("Security.allowDomain() has been set to " + allowDomains, Debuggable.DEBUG_VPAID); }
		  	 Security.allowDomain(allowDomains);
		  	 Security.allowInsecureDomain(allowDomains);

			 _contentLoader = new Loader();
		 	 _activeFlashMedia = media;
		 	 _activeFlashMedia.markAsLoading();
			 var urlReq:URLRequest = new URLRequest(media.swfURL);
			 _contentLoader.contentLoaderInfo.addEventListener(flash.events.IOErrorEvent.IO_ERROR, 
			 	function(event:Event):void {
			 		CONFIG::debugging { doLog("IO Error loading external SWF", Debuggable.DEBUG_VPAID); }
			 		if(_activeFlashMedia != null) _activeFlashMedia.signalLoadError("IO Error loading external SWF");
			    }
			 );
			 _contentLoader.contentLoaderInfo.addEventListener(flash.events.SecurityErrorEvent.SECURITY_ERROR, 
			 	function(event:Event):void {
			 		CONFIG::debugging { doLog("Security Error loading external SWF", Debuggable.DEBUG_VPAID); }
			 		if(_activeFlashMedia != null) _activeFlashMedia.signalLoadError("Security Error loading external SWF");
			    }
			 );
		 	 _contentLoader.contentLoaderInfo.addEventListener(Event.COMPLETE,
			 	function(event:Event):void {
			 	    _activeFlashMedia.markAsLoaded();
					CONFIG::debugging { doLog("External SWF (load size is " + _contentLoader.width + "x" + _contentLoader.height + ") successfully loaded from " + media.swfURL, Debuggable.DEBUG_VPAID); }
					assessFlashMediaScaling();

					// Create the mask for the region

					_maskShape = new Shape();
				 	_maskShape.graphics.beginFill(0x000000); 
				 	_maskShape.graphics.drawRect(0, 0, width, height);
					_maskShape.graphics.endFill();
					addChild(_maskShape);
					_contentLoader.visible = true;
					_contentLoader.mask = _maskShape;
					CONFIG::debugging { doLog("Flash content masked with a rectangle " + width + "x" + height, Debuggable.DEBUG_VPAID); }

					onFlashContentLoaded();
				}
			 );
			 _contentLoader.mouseChildren = !blockMouseActions;
 			 _contentLoader.mouseEnabled = !blockMouseActions; 
			 _contentLoader.visible = false;
			 
			 addChild(_contentLoader);
			 _contentLoader.load(urlReq, new LoaderContext(true, new ApplicationDomain(), SecurityDomain.currentDomain));			 
			 arrangeCloseButton();
		}
		
		protected function onFlashContentLoaded():void {
		}
		
		public function clearDisplayContent():void {
			if(_contentLoader != null) {
				try {		
					this.removeChild(_contentLoader);
					_contentLoader.unload();
					CONFIG::debugging { doLog("** loader.unload() called on Flash object", Debuggable.DEBUG_VPAID); }
				}
				catch(ae:ArgumentError) {
				}
				_contentLoader = null;
			}
			else if(_loadedImage != null) {
				this.removeChild(_loadedImage);	
				_loadedImage = null;
			}
			_maskShape = null;
		}
		
		private function createTextField():void {
			if(_text) removeChild(_text);
			_text = GraphicsUtils.createFlashTextField(false, null, 12, false);
			_text.blendMode = BlendMode.NORMAL; //LAYER; 
			_text.autoSize = TextFieldAutoSize.CENTER;
			_text.wordWrap = true;
			_text.multiline = true;
			_text.antiAliasType = AntiAliasType.ADVANCED;
			_text.condenseWhite = true;
			_text.mouseEnabled = false;
			if(_stylesheet != null) {
				_text.styleSheet = _stylesheet.stylesheet;
			}
			if(html != null) {
				_text.htmlText = html;
			}
			addChild(_text);
			_textMask = createMask();
			addChild(_textMask);
			_text.mask = _textMask;
			arrangeText();
		}

		private function arrangeText():void {
			if(_text) {
				var result:Array = new Array();
				if (padding.indexOf(" ") > 0) {
					var pads:Array = padding.split(" ");
					_text.y = NumberUtils.toPixels(pads[0]);
					_text.x = NumberUtils.toPixels(pads[3]);
					_text.height = Math.round(_height - NumberUtils.toPixels(pads[0]) - NumberUtils.toPixels(pads[2]));
					_text.width = Math.round(_width - NumberUtils.toPixels(pads[1]) - NumberUtils.toPixels(pads[3]));
				}
				else {
					var paddingInPixles:int = NumberUtils.toPixels(padding);
					_text.y = Math.round(paddingInPixles[0]);
					_text.x = Math.round(paddingInPixles[3]);
					_text.height = Math.round(_height - paddingInPixles[0] - paddingInPixles[2]);
					_text.width = Math.round(_width - paddingInPixles[1] - paddingInPixles[3]);
				}
				CONFIG::debugging { doLog("Arranging text (" + _text.htmlText + ") to sit at X:" + _text["y"] + " Y:" + _text["x"] + " height:" + _text["height"] + " width:" + _text["width"], Debuggable.DEBUG_REGION_FORMATION); }
			}
		}
		
		protected function onResize():void {
			arrangeCloseButton();
			if(_textMask) {
				_textMask.width = _width;
				_textMask.height = _height;
			}
			if(_maskShape != null) {
				_maskShape.width = _width;
				_maskShape.height = _height;
			}
			this.x = 0;
			this.y = 0;
		}

		protected function onRedraw():void {
			arrangeText();
			arrangeCloseButton();
		}
		
		private function arrangeCloseButton():void {
			if (_closeButton) {
				_closeButton.calculateLayoutPosition(width, borderRadius);
				if(numChildren > 0) setChildIndex(_closeButton, numChildren-1);
			}
		}

		public function onCloseClicked():void {
			hide();
			_controller.onRegionCloseClicked(this);			
		}

		public function show():void {
			addListeners();
			this.visible = true;	
		}	
			
		public function hide():void {
			removeListeners();
			this.visible = false;
		}
		
		protected function onMouseOver(event:MouseEvent):void {
			CONFIG::debugging { doLog("RegionView: mouse over", Debuggable.DEBUG_MOUSE_EVENTS); }
		}

		protected function onMouseOut(event:MouseEvent):void {
			CONFIG::debugging { doLog("RegionView: mouse out", Debuggable.DEBUG_MOUSE_EVENTS); }
		}

		protected function onClick(event:MouseEvent):void {
			CONFIG::debugging { doLog("RegionView: on click", Debuggable.DEBUG_MOUSE_EVENTS); }
			if(autoHide) {
				hide();
			}
			_controller.onRegionClicked(this, event);
		}
				
		private function redraw():void {
			drawBackground();
			drawBorder();
			onRedraw();
		}

		private function drawBackground():void {
			graphics.clear();
			if(hasOpacity()) alpha = opacity;
			if (isBackgroundTransparent() == false) {
				graphics.beginFill(getBackgroundColorAsUInt());
			} 
			else graphics.beginFill(0,0);
			GraphicsUtils.drawRoundRectangle(graphics, 0, 0, _width, _height, borderRadius);
			graphics.endFill();
			if (backgroundGradient) {
				GraphicsUtils.addGradient(this, 0,  backgroundGradient, borderRadius);
			} 
			else GraphicsUtils.removeGradient(this);
		}
		
		protected function createMask():Sprite {
			var mask:Sprite = new Sprite();
			mask.graphics.beginFill(0);
			GraphicsUtils.drawRoundRectangle(mask.graphics, 0, 0, width, height, borderRadius);
			return mask;
		}

		private function drawBorder():void {
			if (_border && _border.parent == this) {
				removeChild(_border);
			}
			if (borderWidth <= 0) return;
			_border = new Sprite();
			addChild(_border);
			_border.graphics.lineStyle(borderWidth, getBorderColorAsUInt());
			GraphicsUtils.drawRoundRectangle(_border.graphics, 0, 0, width, height, borderRadius);
		}		
					
		// DEBUG METHODS
		
		CONFIG::debugging
		protected function doLog(data:String, level:int=1):void {
			Debuggable.getInstance().doLog(data, level);
		}
		
		CONFIG::debugging
		protected function doTrace(o:Object, level:int=1):void {
			Debuggable.getInstance().doTrace(o, level);
		}
	}
}