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
package org.openvideoads.vast.schedule.ads {
	import org.openvideoads.vast.VASTController;
	import org.openvideoads.vast.events.VideoAdDisplayEvent;
	import org.openvideoads.vast.schedule.StreamSequence;
	import org.openvideoads.vast.config.Config;

	/**
	 * @author Paul Schulz
	 */
	public class StaticAdSlot extends AdSlot {
		protected var _html:String = null;
		protected var _startPoint:String = "relative";

//		public function StaticAdSlot(parent:StreamSequence, owner:AdSchedule, vastController:VASTController, key:int=0, associatedStreamIndex:int=0, id:String=null, zone:String=null, position:String=null, applyToParts:Array=null, duration:String=null, startTime:String="00:00:00", notice:Object=null, disableControls:Boolean=true, width:int=-1, height:int=-1, defaultLinearRegions:Array=null, companionDivIDs:Array=null, regionsPluginName:String=null, startPoint:String=null, html:String=null) {
//			super(parent, owner, vastController, key, associatedStreamIndex, id, zone, position, applyToParts, duration, duration, startTime, notice, disableControls, width, height, defaultLinearRegions, companionDivIDs, regionsPluginName);
		public function StaticAdSlot(parent:StreamSequence, owner:AdSchedule, vastController:VASTController, key:int=0, associatedStreamIndex:int=0, id:String=null, zone:String=null, position:String=null, applyToParts:Array=null, duration:String=null, startTime:String="00:00:00", notice:Object=null, disableControls:Boolean=true, defaultLinearRegions:Array=null, companionDivIDs:Array=null, regionsPluginName:String=null, startPoint:String=null, html:String=null) {
			super(parent, owner, vastController, key, associatedStreamIndex, id, zone, position, applyToParts, duration, duration, startTime, notice, disableControls, defaultLinearRegions, companionDivIDs, regionsPluginName);
			_html = html;
			if(_startPoint != null) _startPoint = startPoint;
		}

		public function set html(html:String):void {
			_html = html;
		}
		
		public function get html():String {
			return _html;
		}
		
		public function set startPoint(startPoint:String):void {
			_startPoint = startPoint;
		}		
		
		public function get startPoint():String {
			return _startPoint;
		}
		
		public function startPointIsRelative():Boolean {
			return (_startPoint.toUpperCase() == "RELATIVE");
		}
/*
		override protected function createNonLinearDisplayEvent():VideoAdDisplayEvent { 
		 	var displayEvent:VideoAdDisplayEvent = super.createDisplayEvent(); 
		 	displayEvent.customData.staticAdSlot = this;
			return displayEvent;
		}
*/
		override public function hasVideoAd():Boolean {
			return false;
		}
		
		override public function isNonLinear():Boolean {
			return true;
		}


	 	protected function actionStartStaticAd(player:Object=null, config:Config=null):void {
	 	}

	 	protected function actionStopStaticAd(player:Object=null, config:Config=null):void {	 		
	 	}
	}
}