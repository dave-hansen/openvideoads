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
	import org.openvideoads.vast.model.NonLinearVideoAd;

	/**
	 * @author Paul Schulz
	 */
	public class FlashAdTemplate extends AdTemplate {
		
		public function FlashAdTemplate(displayMode:String="flash", template:String=null) {
			super(displayMode, (template != null) ? template : 
			    (displayMode == "html5" 
			                       ? createObjectEmbedCode()
			                       : ""
			    )
			);
		}

        protected function createObjectEmbedCode():String {
        	var html:String = "";
			html = '<object codebase="http://download.macromedia.com/pub/shockwave/cabs/flash/swflash.cab#version=6,0,40,0" _dimensions_ id="non-linear-_id_">';
			html += '<param name="movie" value="_url_">';
			html += '<param name="allowScriptAccess" value="always">';
			html += '<param name="FlashVars" value="clickTag=_clickTag_&clickTAG=_clickTag_&clicktag=_clickTag_"/>';
			html += '<embed name="non-linear_id_" src="_url_" _dimensions_ allowScriptAccess="always" allowFullScreen="true"';
			html += ' pluginspage="http://www.macromedia.com/go/getflashplayer"';
			html += ' flashvars="clickTag=_clickTag_&clickTAG=_clickTag_&clicktag=_clickTag_">';
			html += '</embed>';
			html += '</object>';
			return html;
        }
		
		public override function getContent(nonLinearVideoAd:NonLinearVideoAd):String {
			if(nonLinearVideoAd != null) {
				if(nonLinearVideoAd.hasCode()) {
					return nonLinearVideoAd.codeBlock;
//					return replace(_template, "code", nonLinearVideoAd.codeBlock);				
				}
				else {
					if(nonLinearVideoAd.url != null) {
						var result:String = replace(_template, "url", nonLinearVideoAd.url.url);
						var dimensions:String = "";
						if(nonLinearVideoAd.hasWidth() && nonLinearVideoAd.hasHeight()) {
							dimensions = 'width="' + nonLinearVideoAd.width + '" height="' + nonLinearVideoAd.height + '"';
						}
						result = replace(result, "dimensions", dimensions);		
						if(nonLinearVideoAd.hasClickThroughURL()) {
							result = replace(result, "clicktag", nonLinearVideoAd.getClickThroughURLString());
						}
						return result;	
					}
					else return "";
				}
			}
			return "Non-linear video ad not available";
		}
	}
}