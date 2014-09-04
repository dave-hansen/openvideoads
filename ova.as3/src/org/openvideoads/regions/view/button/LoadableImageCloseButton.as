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
	import org.openvideoads.base.Debuggable;
	import org.openvideoads.regions.config.CloseButtonConfig;
	import org.openvideoads.regions.view.RegionView;

	import flash.display.Loader;
	import flash.net.URLRequest;

	/**
	 * @author Paul Schulz
	 */
	public class LoadableImageCloseButton extends CloseButton {
		
		public function LoadableImageCloseButton(id:String=null, parentView:RegionView=null, closeButtonConfig:CloseButtonConfig=null) {
			super(id, parentView, closeButtonConfig.width, closeButtonConfig.height);
			if(closeButtonConfig != null) {
				CONFIG::debugging { doLog("Loading a custom image for the overlay close button from " + closeButtonConfig.imageURL, Debuggable.DEBUG_DISPLAY_EVENTS); }
				var imageLoader:Loader = new Loader();
				var image:URLRequest = new URLRequest(closeButtonConfig.imageURL);
				imageLoader.load(image);
				addChild (imageLoader);
				imageLoader.x = 0; 
				imageLoader.y = 0; 			
			}
		}

        public override function calculateLayoutPosition(width:int, borderRadius:int):void {
			x = width - buttonWidth - (borderRadius/5);
			y = ((borderRadius > 0) ? 0 + borderRadius/5 : 0);
        }
	}
}