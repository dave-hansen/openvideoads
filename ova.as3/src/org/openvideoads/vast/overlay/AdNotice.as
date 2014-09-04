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
package org.openvideoads.vast.overlay {
	import flash.utils.Timer;
	
	import org.openvideoads.base.Debuggable;
	import org.openvideoads.regions.view.RegionView;
	
	public class AdNotice extends Debuggable {
		protected var _noticeTemplate:String = null;
		protected var _duration:int = 0;
		protected var _noticeRegion:RegionView = null;
		protected var _timer:Timer = null;
		
		public function AdNotice(noticeTemplate:String, duration:int, noticeRegion:RegionView) {
			_noticeTemplate = noticeTemplate;
			_duration = duration;
			_noticeRegion = noticeRegion;
		}
		
		public function show():void {
			if(isCountdownNotice()) {
				startNoticeTimer();
			}
			else displayStandardNotice();			
		}
		
		public function hide():void {
			clearNotice();
		}
		
		protected function isCountdownNotice():Boolean {
			if(_noticeTemplate != null) {
				return (_noticeTemplate.indexOf("_countdown_") > -1)
			}
			return false;
		}

		protected function startNoticeTimer():void {
			if(_noticeRegion != null) {
				tickCountdownNotice(_duration);
			}
		}
		protected function clearNotice():void {
			if(_timer != null) {
				_timer.stop();
				_timer = null;
			}
			if(_noticeRegion != null) _noticeRegion.hide();
		}
	
	    protected function filloutTemplate(identifier:String, duration:int):String {
			var thePattern:RegExp = new RegExp(identifier, "g");
			return _noticeTemplate.replace(thePattern, duration);
	    }

		protected function displayStandardNotice():void {
			if(_noticeRegion != null) {
				_noticeRegion.hideCloseButton();
				_noticeRegion.html = filloutTemplate("_seconds_", _duration);
				_noticeRegion.visible = true;	
			}
		}
	
		public function tickCountdownNotice(remainingDuration:int):void {	
			if(_noticeRegion != null) {
				_noticeRegion.hideCloseButton();
				_noticeRegion.html = filloutTemplate("_countdown_", remainingDuration);
				_noticeRegion.visible = true;	
			}
		}
	}
}