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
package org.openvideoads.regions.config {
	import flash.display.Bitmap;
	import flash.display.Loader;
	
	import org.openvideoads.base.Debuggable;
	import org.openvideoads.util.StringUtils;
	
	/**
	 * @author Paul Schulz
	 */
	public class BaseRegionConfig extends Debuggable {
		protected var _styleSheetAddress:String;
		protected var _style:String = null;
		protected var _id:String = null;
		protected var _border:String = null;
		protected var _borderRadius:int = -1;
		protected var _borderWidth:int = -1;
		protected var _borderColor:String = null;
		protected var _background:String = null;
		protected var _originalBackground:String = null;
		protected var _backgroundGradient:* = null;
		protected var _backgroundImage:String = null;
		protected var _backgroundRepeat:String = null;
		protected var _backgroundColor:String = null;
		protected var _originalBackgroundColor:String = null;
		protected var _closeButton:CloseButtonConfig = new CloseButtonConfig();
		protected var _opacity:Number = -1;
		protected var _padding:String = "5 5 5 5";
		protected var _scaleRate:Number = 1;
		protected var _html:String = null;
		protected var _image:* = null;
		protected var _swf:* = null;
		
		public function BaseRegionConfig(config:Object=null) {
			setup(config);
		}

		public function setup(config:Object):void {
			if(config != null) {
				if(config.id != undefined) id = config.id;
				if(config.stylesheet != undefined) stylesheet = config.stylesheet;
				if(config.style != undefined) style = config.style;
				if(config.border != undefined) border = config.border;
				if(config.borderRadius != undefined) {
				 	borderRadius = config.borderRadius;
				}
				if(config.borderColor != undefined) {
				 	borderColor = config.borderColor;
				}
				if(config.borderWidth != undefined) {
				 	borderWidth = config.borderWidth;
				}
				if(config.backgroundGradient != undefined) {
					backgroundGradient = config.backgroundGradient;
				}
				if(config.background != undefined) {
					background = config.background;
				}
				if(config.backgroundImage != undefined) {
					backgroundImage = StringUtils.revertSingleQuotes(config.backgroundImage, "%27");
				}
				if(config.backgroundRepeat != undefined) {
					backgroundRepeat = config.backgroundRepeat;
				}
				if(config.backgroundColor != undefined) {
					backgroundColor = config.backgroundColor;
				}
				if(config.closeButton != undefined) {
					if(config.closeButton is CloseButtonConfig) {
						_closeButton = config.closeButton;					
					}
					else _closeButton = new CloseButtonConfig(config.closeButton);
				}
				if(config.padding != undefined) {
					padding = config.padding;
				}
				if(config.opacity != undefined) {
					opacity = config.opacity;
				}
				if(config.html != undefined) html = StringUtils.revertSingleQuotes(config.html, "'");
				if(config.image != undefined) {
					image = config.image;
				}
				if(config.swf != undefined) {
					swf = config.swf;
				}
			}
		}

		public function set id(id:String):void {
			_id = id;
		}
		
		public function get id():String {
			return _id;
		}
		
		public function set style(style:String):void {
			_style = style;
		}
		
		public function get style():String {
			return _style;
		}
		
		public function set stylesheet(stylesheet:String):void {
			_styleSheetAddress = stylesheet;
		}
		
		public function get stylesheet():String {
			return _styleSheetAddress;
		}
		
		public function set html(html:String):void {
			_html = html;
		}
		
		public function get html():String {
			return _html;
		}

		public function set borderRadius(borderRadius:int):void {
			_borderRadius = borderRadius;
		}
		
		public function get borderRadius():int {
			return _borderRadius;
		}
		
		public function hasBorderRadius():Boolean {
			return (_borderRadius > -1);
		}

		public function set borderWidth(borderWidth:int):void {
			_borderWidth = borderWidth;
		}
		
		public function get borderWidth():int {
			return _borderWidth;
		}
		
		public function hasBorderWidth():Boolean {
			return (_borderWidth > -1);
		}
		
		public function set border(border:String):void {
			_border = border;
		}
		
		public function get border():String {
			return _border;
		}
		
		public function hasBorder():Boolean {
			return _border != null;
		}
		
		public function set borderColor(borderColor:String):void {
			_borderColor = borderColor;
		}
		
		public function get borderColor():String {
			return _borderColor;
		}
		
		public function hasBorderColor():Boolean {
			return (_borderColor != null);
		}		

		public function set background(background:String):void {
			_background = background;
			_originalBackground = background;
		}
		
		public function get background():String {
			return _background;
		}
		
		public function hasBackground():Boolean {
			return (_background != null);
		}		

		public function set backgroundTransparent(transparent:Boolean):void {
			if(transparent) {
				makeBackgroundTransparent();
			}
			else restoreOriginalBackground();
		}

		public function makeBackgroundTransparent():void {
			_background = "transparent";
			_backgroundColor = "transparent";
		}

		public function restoreOriginalBackground():void {
			_background = _originalBackground;
			_backgroundColor = _originalBackgroundColor;
		}

		public function set backgroundRepeat(backgroundRepeat:String):void {
			_backgroundRepeat = backgroundRepeat;
		}
		
		public function get backgroundRepeat():String {
			return _backgroundRepeat;
		}
		
		public function hasBackgroundRepeat():Boolean {
			return (_backgroundRepeat != null);
		}
		
		public function set backgroundGradient(backgroundGradient:*):void {
			_backgroundGradient = backgroundGradient;
		}
		
		public function get backgroundGradient():* {
			return _backgroundGradient;
		}
		
		public function hasBackgroundGradient():Boolean {
			return (_backgroundGradient != null);
		}

		public function set backgroundImage(backgroundImage:String):void {
			_backgroundImage = backgroundImage;
		}
		
		public function get backgroundImage():String {
			return _backgroundImage;
		}
		
		public function hasBackgroundImage():Boolean {
			return _backgroundImage != null;
		}
		
		public function set backgroundColor(backgroundColor:String):void {
			_backgroundColor = backgroundColor;
			_originalBackgroundColor = backgroundColor;
		}
		
		public function get backgroundColor():String {
			return _backgroundColor;
		}
		
		public function hasBackgroundColor():Boolean {
			return (_backgroundColor != null);
		}		
		
		public function set opacity(opacity:Number):void {
			_opacity = opacity;
		}
		
		public function get opacity():Number {
			return _opacity;
		}

		public function hasOpacity():Boolean {
			return (_opacity > -1);			
		}
		
		public function set padding(padding:String):void {
			_padding = padding;
		}
		
		public function get padding():String {
			return _padding;
		}
		
		public function set scaleRate(scaleRate:Number):void {
			_scaleRate = scaleRate;
		}
		
		public function get scaleRate():Number {
			return _scaleRate;
		}
		
		public function set image(image:*):void {
			_image = image;
		}
		
		public function get image():* {
			return _image;
		}
		
		public function hasImage():Boolean {
			return (_image != null);
		}
		
		public function imageIsBitmap():Boolean {
			return (_image is Bitmap);
		}
		
		public function imageIsLoader():Boolean {
			return (_image is Loader);
		}
		
		public function set swf(swf:*):void {
			_swf = swf;
		}
		
		public function get swf():* {
			return _swf;
		}
		
		public function hasSWF():Boolean {
			return (_swf != null);
		}

		public function get properties():Object {
			var props:Object = new Object();
			props.id = id;
			props.border = border;
			props.borderRadius = borderRadius;
			props.backgroundGradient = backgroundGradient;
			props.backgroundImage = backgroundImage;
			props.backgroundColor = backgroundColor;
			props.closeButton = closeButton;
			props.opacity = opacity;
			props.stylesheet = stylesheet;
			props.style = style;
			props.scaleRate = scaleRate;
			props.image = image;
			props.swf = swf;
			return props;
		}

		public function set closeButton(closeButton:CloseButtonConfig):void {
			_closeButton = closeButton;
		}
		
		public function get closeButton():CloseButtonConfig {
			return _closeButton;
		}
		
		public function canShowCloseButton():Boolean {
			return (_closeButton != null) ? _closeButton.enabled : true;
		}		
	}
}