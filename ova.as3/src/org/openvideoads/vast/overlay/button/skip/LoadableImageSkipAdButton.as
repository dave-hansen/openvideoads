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
	import flash.display.Loader;
	import flash.net.URLRequest;

	import org.openvideoads.regions.config.CloseButtonConfig;
	import org.openvideoads.vast.config.groupings.SkipAdConfig;
	
	public class LoadableImageSkipAdButton extends SkipAdRegionViewConfig {
		public function LoadableImageSkipAdButton(skipAdConfig:SkipAdConfig=null) {
			super(skipAdConfig.region,
				{
					id:'reserved-skip-ad-button-image',
					verticalAlign: 5, 
					horizontalAlign: 'right', 
					width: (skipAdConfig.width > 0) ? skipAdConfig.width : 70, 
					height: (skipAdConfig.height > 0) ? skipAdConfig.height : 20, 
					backgroundColor: 'transparent',
					clickable: true,
		        	closeButton: new CloseButtonConfig({ enabled: false }),
					keepAfterClick: false,
					image: new Loader(),
					swf: null,
					html: null
				}
			);
			image.load(new URLRequest(skipAdConfig.image));
			image.x = 0; 
			image.y = 0; 			
		}
	}
}