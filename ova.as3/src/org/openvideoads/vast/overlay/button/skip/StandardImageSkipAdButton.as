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
package org.openvideoads.vast.overlay.button.skip {
	import flash.display.Bitmap;
	
	import org.openvideoads.regions.config.CloseButtonConfig;
	import org.openvideoads.vast.config.groupings.SkipAdConfig;
	
	public class StandardImageSkipAdButton extends SkipAdRegionViewConfig {

		public function StandardImageSkipAdButton(skipAdConfig:SkipAdConfig=null) {
			var normalButtonImage:Bitmap = null;
			CONFIG::buttons { 
				normalButtonImage = new NormalButtonBitmap; 
			}
			super(
				skipAdConfig.region,
				{
					id:'reserved-skip-ad-button-image',
					verticalAlign: 5, 
					horizontalAlign: 'right', 
					width: 70, 
					height: 20, 
					backgroundColor: 'transparent',
					clickable: true,
		        	closeButton: new CloseButtonConfig({ enabled: false }),
					keepAfterClick: false,
					image: normalButtonImage,
					swf: null,
					html: null
				} 
			);
		}
	}
}