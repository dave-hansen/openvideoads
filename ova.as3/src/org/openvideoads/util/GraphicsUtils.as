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
package org.openvideoads.util {
	import flash.display.BlendMode;
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.GradientType;
	import flash.display.Graphics;
	import flash.display.Shape;
	import flash.geom.Matrix;
	import flash.system.Capabilities;
	import flash.text.AntiAliasType;
	import flash.text.Font;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	import org.openvideoads.base.Debuggable;
	/**
	 * @author Paul Schulz
	 */
	public class GraphicsUtils extends Debuggable {
			
		public static function createFlashTextField(embedded:Boolean, font:String = null, fontSize:int = 12, bold:Boolean = false, color:uint=0xffffff):TextField {
			var field:TextField = new TextField();
			var format:TextFormat = new TextFormat();
			field.blendMode = BlendMode.LAYER;
			if(font != null) {
				format.font = font;
				field.antiAliasType = AntiAliasType.ADVANCED;
			}
			else {
				if(Capabilities.os.indexOf("Windows") == 0) {
					var fontPreferences:Array = ["Lucida Grande", "Lucida Sans Unicode", "Bitstream Vera", "Verdana", "Arial", "_sans", "_serif"];					
					var available:Array = Font.enumerateFonts(true);
					format.font = "_sans";
					for (var i:Number = 0; i < fontPreferences.length; i++) {
						for (var j:Number = 0; j < available.length; j++) {
							if (Font(available[j]).fontName == fontPreferences[i]) {
								format.font = fontPreferences[i];
								j = available.length;
								i = fontPreferences.length;
							}
						}
					}
				} 
				else {		
					format.font = "Lucida Grande, Lucida Sans Unicode, Bitstream Vera, Verdana, Arial, _sans, _serif";
					field.antiAliasType = AntiAliasType.ADVANCED;
				}
			}
			format.size = fontSize;
			format.color = color; //0xffffff;
			format.bold = bold;
			field.embedFonts = embedded;
			field.defaultTextFormat = format;
			return field;
		}

		public static function beginGradientFill(graphics:Graphics, width:Number, height:Number, color1:Number, color2:Number, alpha:Number = 1):void {
			var colors:Array = [color1, color2, color1];
			var matrix:Matrix = new Matrix();
			matrix.createGradientBox(width, height, Math.PI/2);
			graphics.beginGradientFill(GradientType.LINEAR, colors, [alpha, alpha, alpha], [0, 128, 255], matrix);
		}
			
		public static function beginLinearGradientFill(graphics:Graphics, width:Number, height:Number, colors:Array, alphas:Array):void {
			var matrix:Matrix = new Matrix();
			matrix.createGradientBox(width, height, Math.PI/2);
			var ratios:Array = new Array();
			var gap:int = 255/(colors.length - 1)
			for (var i:Number = 0; i < colors.length; i++) {
				ratios.push(i*gap);
			}
			graphics.beginGradientFill(GradientType.LINEAR, colors, alphas, ratios, matrix);
		}
		
		public static function drawRoundRectangle(graphics:Graphics, x:Number, y:Number, width:Number, height:Number, borderRadius:Number):void {
			if (borderRadius > 0) {
				graphics.drawRoundRect(x, y, width, height, borderRadius, borderRadius);
			} 
			else {
				graphics.drawRect(x, y, width, height);
			}
		}

		public static function addGradient(parent:DisplayObjectContainer, index:int, gradientAlphas:Array, borderRadius:Number, x:Number = 0, y:Number = 0):void {
			removeGradient(parent);
			var gradientHolder:Shape = new Shape();
			gradientHolder.name = "_gradient";
			parent.addChildAt(gradientHolder, index);
			gradientHolder.graphics.clear();
			beginFill(gradientHolder.graphics, gradientAlphas, parent.width, parent.height);
			GraphicsUtils.drawRoundRectangle(gradientHolder.graphics, x, y, parent.width, parent.height, borderRadius);
			gradientHolder.graphics.endFill();
		}
		
		public static function removeGradient(parent:DisplayObjectContainer):void {
			var gradientHolder:DisplayObject = parent.getChildByName("_gradient");
			if (gradientHolder) {
				parent.removeChild(gradientHolder);
			}
		}

		private static function beginFill(graph:Graphics, alphas:Array, width:Number, height:Number):void {
			var color:Array = new Array();
			for (var i:Number = 0; i < alphas.length; i++) {
				color.push(0xffffff);
			}
			beginLinearGradientFill(graph, width, height, color, alphas);
		}
		
		public static function hexStringToUint(colorString:String):uint {
		    var r:RegExp=new RegExp(/#/g);		
     		return uint(String(colorString).replace(r,"0x"));			
		}		
	}
}
