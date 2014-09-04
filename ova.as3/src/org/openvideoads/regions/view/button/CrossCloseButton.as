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
package org.openvideoads.regions.view.button {
	import flash.display.BlendMode;
	import flash.text.AntiAliasType;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	
	import org.openvideoads.regions.view.RegionView;
	import org.openvideoads.regions.config.CloseButtonConfig;
	import org.openvideoads.util.GraphicsUtils;
	import org.openvideoads.base.Debuggable;

	/**
	 * @author Paul Schulz
	 */
	public class CrossCloseButton extends CloseButton {		
		protected var _color:String = "#FFFFFF";
		
		public function CrossCloseButton(id:String=null, parentView:RegionView=null, closeButtonConfig:CloseButtonConfig=null) {
			if(closeButtonConfig != null) {
				_color = closeButtonConfig.color;
			}
			super(id, parentView, 5, 5);
		}
          
        protected override function drawButton():void {
            this.graphics.clear();
			this.graphics.beginFill(0,0);
			this.graphics.drawCircle(0,0,10);
			this.graphics.endFill();
			var _text:TextField = GraphicsUtils.createFlashTextField(false, null, 14, true, GraphicsUtils.hexStringToUint(_color));
			_text.blendMode = BlendMode.LAYER;
			_text.autoSize = TextFieldAutoSize.CENTER;
			_text.wordWrap = false;
			_text.multiline = false;
			_text.antiAliasType = AntiAliasType.ADVANCED;
			_text.condenseWhite = true;
			_text.mouseEnabled = false;
            _text.text = "+";
            _text.x = -9;
            _text.y = -10;
            _text.selectable = false;
            _text.mouseEnabled = true;
            this.addChild(_text)
        }
	}
}