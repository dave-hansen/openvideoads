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
	import org.openvideoads.vast.model.NonLinearTextAd;
	import org.openvideoads.vast.model.NonLinearVideoAd;

	/**
	 * @author Paul Schulz
	 */
	public class TextAdTemplate extends AdTemplate  {

		public function TextAdTemplate(displayMode:String="flash", template:String=null) {
			super(
				displayMode, 
				(template != null) ? 
					template : 
					(displayMode == "flash" ?
		         		"<body>" + 
		         			"<p align='left' class='title'>_title_</p>" + 
		         			"<p align='left' class='description'>_description_</p>" + 
		         			"<p align='left' class='callToActionTitle'>_callToActionTitle_</p>" +
		         			"</body>" : 
						"<div class='textAdContainer'>" +
					        "<div class='textAdTitle'>_title_</div>" + 
		         			"<div class='textAdDescription'>_description_</div>" + 
		         			"<div class='textAdCallToActionTitle'>_callToActionTitle_</div>" +
		         			"</div>"
					)
			);
		}

		public override function getContent(nonLinearVideoAd:NonLinearVideoAd):String {
			if(nonLinearVideoAd != null) {
				var result:String = replace(_template, "title", (nonLinearVideoAd as NonLinearTextAd).title);
				result = replace(result, "description", (nonLinearVideoAd as NonLinearTextAd).description);
				result = replace(result, "callToActionTitle", (nonLinearVideoAd as NonLinearTextAd).callToActionTitle);
				return result;
			}
			else return "Non-linear video ad not available";
		}
	}
}