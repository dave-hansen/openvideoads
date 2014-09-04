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
	import org.openvideoads.regions.view.FlashMedia;
	import org.openvideoads.vast.events.OverlayAdDisplayEvent;
	import org.openvideoads.vast.events.VideoAdDisplayEvent;

	/**
	 * @author Paul Schulz
	 */
	public class NonLinearFlashAd extends NonLinearVideoAd implements FlashMedia {
		
		public function NonLinearFlashAd() {
			super();
		}

		public function signalLoadError(errorMessage:String):void {
		}

		public function get swfURL():String {
			if(hasCode()) {
				return _codeBlock;			
			}
			return _url.getQualifiedStreamAddress();
		}

		public override function get content():String {
			return swfURL;
		}

		public function shouldMaintainAspectRatio():Boolean {
			return this.maintainAspectRatio;
		}

		public function get recommendedWidth():int {
			return _width;
		}
		
		public function get recommendedHeight():int {
			return _height;
		}

		public override function clicked():void {
			if(isInteractive()) {
			}
			else super.clicked();
		}

		public override function close():void {
			super.close();
		}		
	}
}