package org.openvideoads.examples.vpaid.v1 {
	import flash.events.TimerEvent;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.utils.Timer;
	import flash.display.Sprite;
	import flash.external.ExternalInterface;
	
	import org.openvideoads.vpaid.VPAIDBase;
	
	public class SimpleCountdownExample extends VPAIDBase {	
		protected var _timer:Timer = null;
					
		public function SimpleCountdownExample() {
        	ExternalInterface.call("console.log", ">>> COUNTDOWN EXAMPLE Build 3");     
			super();
			_adDuration = 10;
		}

		// VPAID INTERFACES
		
        public override function startAd():void {
        	super.startAd();
        	startTimer();
        }

        public override function pauseAd():void {  
        	ExternalInterface.call("console.log", ">>> PAUSING AD");     
        	if(_timer != null) {
        		if(_timer.running) _timer.stop();
        	}
            super.pauseAd();
        }
        
        public override function resumeAd():void {       	
        	ExternalInterface.call("console.log", ">>> RESUMING AD");     
        	if(_timer != null) {
        		_timer.start();
        	}
        	super.resumeAd();
        }        
        
        // AD IMPLEMENTATION
        
        protected function startTimer():void {
           _timer = new Timer(1000, _adDuration);
           _timer.addEventListener(TimerEvent.TIMER, onTimer);
           _timer.addEventListener(TimerEvent.TIMER_COMPLETE, timerComplete);
           _timer.start();        	
        }
        
        protected function stopTimer():void {
           if(_timer) {
              _timer.removeEventListener(TimerEvent.TIMER, onTimer);
              _timer.removeEventListener(TimerEvent.TIMER_COMPLETE, timerComplete);
              _timer = null;
           }        	
        }
        
        protected function onTimer(timerEvent:TimerEvent):void {
        	_remainingTime--;
        }
        
        protected function timerComplete(timerEvent:TimerEvent):void {
        	stopAd();        	
        }
        
        protected override function renderAd():void {
        	var color1:Number = 0x00FF00;
        	var color2:Number = 0x0000FF;

			graphics.lineStyle(3,color1);
			graphics.beginFill(color2);
			graphics.drawRect(0, 0, adWidth, adHeight);
			graphics.endFill();
        }        
	}
}