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
	import org.openvideoads.regions.config.RegionViewConfig;

	public class SkipAdRegionViewConfig extends RegionViewConfig {
		public function SkipAdRegionViewConfig(customConfig:Object, baseConfig:Object) {
			var finalConfig:Object = {};
			if(customConfig == null) {
				finalConfig = baseConfig;
			}
			else {
				finalConfig = 
					{
						id: (customConfig.id != undefined) ? customConfig.id : baseConfig.id,
						verticalAlign: (customConfig.verticalAlign != undefined) ? customConfig.verticalAlign : baseConfig.verticalAlign, 
						horizontalAlign: (customConfig.horizontalAlign != undefined) ? customConfig.horizontalAlign : baseConfig.horizontalAlign, 
						width: (customConfig.width != undefined) ? customConfig.width : baseConfig.width, 
						height: (customConfig.height != undefined) ? customConfig.height : baseConfig.height, 
						backgroundColor: (customConfig.backgroundColor != undefined) ? customConfig.backgroundColor : baseConfig.backgroundColor,
						clickable: (customConfig.clickable != undefined) ? customConfig.clickable : baseConfig.clickable,
			        	closeButton: (customConfig.closeButton != undefined) ? customConfig.closeButton : baseConfig.closeButton,
						keepAfterClick: (customConfig.keepAfterClick != undefined) ? customConfig.keepAfterClick : baseConfig.keepAfterClick,
						image: (customConfig.image != undefined) ? customConfig.image : baseConfig.image,
						swf: (customConfig.swf != undefined) ? customConfig.swf : baseConfig.swf,
						html: (customConfig.html != undefined) ? customConfig.html : baseConfig.html,
						autoHide: false
					}
				if(customConfig.styleSheetAddress != undefined) finalConfig.styleSheetAddress = customConfig.styleSheetAddress;
				if(customConfig.style != undefined) finalConfig.style = customConfig.style;
				if(customConfig.border != undefined) finalConfig.border = customConfig.border;
				if(customConfig.borderRadius != undefined) finalConfig.borderRadius = customConfig.borderRadius;
				if(customConfig.borderWidth != undefined) finalConfig.borderWidth = customConfig.borderWidth;
				if(customConfig.borderColor != undefined) finalConfig.borderColor = customConfig.borderColor;
				if(customConfig.background != undefined) finalConfig.background = customConfig.background;
				if(customConfig.backgroundGradient != undefined) finalConfig.backgroundGradient = customConfig.backgroundGradient;
				if(customConfig.backgroundImage != undefined) finalConfig.backgroundImage = customConfig.backgroundImage;
				if(customConfig.backgroundRepeat != undefined) finalConfig.backgroundRepeat = customConfig.backgroundRepeat;
				if(customConfig.backgroundColor != undefined) finalConfig.backgroundColor = customConfig.backgroundColor;
				if(customConfig.opacity != undefined) finalConfig.opacity = customConfig.opacity;
				if(customConfig.padding != undefined) finalConfig.padding = customConfig.padding;
				if(customConfig.canScale != undefined) finalConfig.canScale = customConfig.canScale;
				if(customConfig.scaleRate != undefined) finalConfig.scaleRate = customConfig.scaleRate;
				if(customConfig.autoHide != undefined) finalConfig.autoHide = customConfig.autoHide;
			}
			super(finalConfig);
		}
	}
}