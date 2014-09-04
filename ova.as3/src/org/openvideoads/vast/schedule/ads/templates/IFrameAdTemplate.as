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
package org.openvideoads.vast.schedule.ads.templates {
	import org.openvideoads.base.Debuggable;
	import org.openvideoads.vast.model.NonLinearVideoAd;

	/**
	 * @author Paul Schulz
	 */
	public class IFrameAdTemplate extends AdTemplate {
		
		public function IFrameAdTemplate(displayMode:String="flash", template:String=null) {
			super(displayMode);
			_template = (template != null) ? template : null;
		}

		protected function formContent(url:String, width:Number, height:Number):String {
			var result:String;
			if(width > -1 && height > -1) {
				result = replace((_template == null) ? "<iframe src='_code_' hspace=0 vspace=0 frameborder=0 marginheight=0 marginwidth=0 scrolling=no width=_width_ height=_height_><p>Your browser does not support iframes.</p></iframe>" : _template, "code", url);
				result = replace(result, "width", width.toString());
				result = replace(result, "height", height.toString());
			}
			else {
				result = replace((_template == null) ? "<iframe src='_code_' hspace=0 vspace=0 frameborder=0 marginheight=0 marginwidth=0 scrolling=no><p>Your browser does not support iframes.</p></iframe>" : _template, "code", url);
			}
			return result;			
		}		
		
		public override function getContent(nonLinearVideoAd:NonLinearVideoAd):String {
			if(nonLinearVideoAd != null) {
				if(nonLinearVideoAd.hasCode()) {
					return nonLinearVideoAd.codeBlock;
				}
				else {
					if(nonLinearVideoAd.url != null) {
						return formContent(nonLinearVideoAd.url.url, nonLinearVideoAd.width, nonLinearVideoAd.height);
					}
					else return "";
				}
			}
			else return "Non-linear video ad not available";
		}
	}
}