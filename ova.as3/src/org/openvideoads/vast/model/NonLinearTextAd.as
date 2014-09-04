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
	import flash.xml.*;

	/**
	 * @author Paul Schulz
	 */
	public class NonLinearTextAd extends NonLinearVideoAd {
		protected var _title:String = null;
		protected var _description:String = null;
		protected var _callToActionTitle:String = null;
		
		public function NonLinearTextAd() {
		}
		
		public override function set codeBlock(codeBlock:String):void {
			_codeBlock =  "<TextAd>";
			_codeBlock += codeBlock;
			_codeBlock += "</TextAd>";
			parse();
		}
		
		/**
		 * <Code>
		 *     <Title>Title goes in here</Title>
		 *     <Description>Descriptive text goes in here</Description>
		 *     <ClickThroughLinkText>Put some text as the title for the click through link/ClickThroughLinkText>
		 * </Code> 
		 */
		protected function parse():void {
	      	var xmlData:XML = new XML(_codeBlock);
 			if(xmlData.length() > 0) {
 				if(xmlData.Title != undefined) {
 					_title = xmlData.Title.text();
 				}
 				if(xmlData.Description != undefined) {
 					_description = xmlData.Description.text();
 				}
 				if(xmlData.CallToAction != undefined) { 
 					_callToActionTitle = xmlData.CallToAction.text();
 				}
 			}			
		}
		
		public function get title():String {
			return _title;
		}
		
		public function get description():String {
			return _description;
		}
		
		public function get callToActionTitle():String {
			return _callToActionTitle;
		}

		public override function rawContentAsObject():Object {
			return { 
				type: "TEXT",
				format: "TEXT",
				content: {
					title: title,
					description: description,
					callToActionTitle: callToActionTitle
				}
			};
		}
	}
}