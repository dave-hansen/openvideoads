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
package org.openvideoads.util {
	import flash.display.Sprite;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	import org.openvideoads.base.Debuggable;
	
	/**
	 * @author Paul Schulz
	 */	
	public class Animator extends Debuggable {
		protected var _target:Sprite = null;
		protected var _timer:Timer = null;
		protected var _alphaReductionFactor:Number = 0;

		public function Animator() {
		}

		public function stop():void {
			if(_timer != null) {
				_timer.stop();
				_timer = null;
			}
		}
		
		public function fade(target:Sprite, properties:Object):void {
			if(target != null) {
				if(properties != null) {
					if(_timer != null) {
						_timer.stop();
					}
					_target = target;
					_alphaReductionFactor = ((properties.alpha - target.alpha) / properties.times);
					_timer = new Timer(properties.rate, properties.times);
					_timer.addEventListener(TimerEvent.TIMER,
						function onTimer(timerEvent:TimerEvent):void {
							_target.alpha += _alphaReductionFactor;
						}
					);
					_timer.addEventListener(TimerEvent.TIMER_COMPLETE,
						function onTimerComplete(timerEvent:TimerEvent):void {
							_target.alpha = properties.alpha;
							if(properties.onComplete != undefined) {
								properties.onComplete();
							}
						}
					);
					_timer.start();				
				}
			}
		}
	}
}