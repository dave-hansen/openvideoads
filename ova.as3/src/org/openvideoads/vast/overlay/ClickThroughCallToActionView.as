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
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	import org.openvideoads.base.Debuggable;
	import org.openvideoads.regions.RegionController;
	import org.openvideoads.regions.config.RegionViewConfig;
	import org.openvideoads.regions.view.TextSign;
	import org.openvideoads.util.Animator;
	import org.openvideoads.util.DisplayProperties;
	import org.openvideoads.vast.config.groupings.ClickSignConfig;	
	    	
	/**
	 * @author Paul Schulz
	 */
	public class ClickThroughCallToActionView extends OverlayView {
		protected var _callToActionSign:TextSign;
		protected var _timeoutTimer:Timer = null;
		protected var _animator:Animator = null;
		protected var _originalAlpha:Number = 0;
		protected static var _TIMEOUT:Number = 3000;
		
		public function ClickThroughCallToActionView(controller:RegionController, regionConfig:RegionViewConfig, clickSignConfig:ClickSignConfig, displayProperties:DisplayProperties) {
			super(controller, regionConfig, displayProperties); //, false);
			_animator = new Animator();		
			_callToActionSign = new TextSign(clickSignConfig, displayProperties);
            _callToActionSign.visible = false;
            _originalAlpha = this.alpha;
			addChild(_callToActionSign);
			setChildIndex(_callToActionSign, this.numChildren-1);	
		}
		
		protected function startTimer():void {
			if(!timerActive()) {
				_timeoutTimer = new Timer(_TIMEOUT, 1);
				_timeoutTimer.addEventListener(TimerEvent.TIMER_COMPLETE, onTimer);
				_timeoutTimer.start();				
			}
		}

		protected function onTimer(timerEvent:TimerEvent):void {
			_animator.fade(this, { alpha:0, rate:50, times:15, onComplete:function():void { _callToActionSign.visible = false; }});
			_timeoutTimer = null;
		}

		protected function stopTimer():void {
			if(_timeoutTimer != null) _timeoutTimer.stop();
			_timeoutTimer = null;
		}

		protected function timerActive():Boolean {
			return (_timeoutTimer != null);	
		}
		
		public override function resize(resizeProperties:DisplayProperties=null):void {
			super.resize(resizeProperties);
			if(_callToActionSign != null) _callToActionSign.resize(resizeProperties);
		}
		
		protected override function onMouseOver(event:MouseEvent):void {
			CONFIG::debugging { doLog("ClickableMouseOverOverlayView: MOUSE OVER!", Debuggable.DEBUG_MOUSE_EVENTS); }
			_animator.stop();
			this.alpha = _originalAlpha;
			startTimer();
			_callToActionSign.visible = true;
		}

		protected override function onMouseOut(event:MouseEvent):void {
			CONFIG::debugging { doLog("ClickableMouseOverOverlayView: MOUSE OUT!", Debuggable.DEBUG_MOUSE_EVENTS); }
			_animator.stop();
			stopTimer();
			_callToActionSign.visible = false;
		}

		protected override function onClick(event:MouseEvent):void {
			CONFIG::debugging { doLog("ClickableMouseOverOverlayView: ON CLICK", Debuggable.DEBUG_MOUSE_EVENTS); }
			_animator.stop();
			stopTimer();
			(_controller as OverlayController).onLinearAdClickThroughCallToActionViewClicked(activeAdSlot); 
		}
	}
}