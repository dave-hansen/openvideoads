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
package org.openvideoads.vast.events {
	import org.openvideoads.vast.model.CompanionAd;
	
	import flash.events.Event;
	
	/**
	 * @author Paul Schulz
	 */
	public class CompanionAdDisplayEvent extends NonLinearAdDisplayEvent {
		public static const DISPLAY:String = "display-companion";
		public static const HIDE:String = "hide-companion";
		
		protected var _divID:String = null;
		protected var _content:String = null;
		
		public function CompanionAdDisplayEvent(type:String, companionAd:CompanionAd, bubbles:Boolean = false, cancelable:Boolean = false) {
			super(type, companionAd, bubbles, cancelable);
		}

		public function get companionAd():CompanionAd {
			return this.nonLinearVideoAd as CompanionAd;
		}
				
		public function set divID(divID:String):void {
			_divID = divID;	
		}
		
		public function get divID():String {
			return _divID;
		}
		
		public function set content(content:String):void {
			_content = content;
		}
		
		public function get content():String {
			return _content;
		}
		
		public function contentIsHTML():Boolean {
			return true;	
		}
		
		public function contentIsSWF():Boolean {
			return false; // NOT USED - SWF RESOURCE TYPES FORMATED USING OBJECT TAGS AS "HTML"	
		}

		public override function clone():Event {
			var cde:CompanionAdDisplayEvent = new CompanionAdDisplayEvent(type, nonLinearVideoAd as CompanionAd, bubbles, cancelable);
			cde.divID = _divID;
			cde.content = _content;
			return cde;
		}
	}
}