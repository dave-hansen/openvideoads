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
	public class ScriptAdTemplate extends AdTemplate {
import org.openvideoads.base.Debuggable;
		public function ScriptAdTemplate(displayMode:String="flash", template:String=null) {
			super(displayMode, (template != null) ? template : null);
		}
		
		public override function getContent(nonLinearVideoAd:NonLinearVideoAd):String {
			if(nonLinearVideoAd != null) {
				if(nonLinearVideoAd.hasCode()) {
					return replace((_template == null) ? "_code_" : _template, "code", nonLinearVideoAd.codeBlock);				
				}
				else {
					if(nonLinearVideoAd.url != null) {
						return replace("<script type='text/javascript' src='_code_'></script>", "code", nonLinearVideoAd.url.url);				
					}
					else return "<script type='text/javascript' src=''></script>";
				}
			}
			else return "Non-linear video ad not available";
		}
	}
}