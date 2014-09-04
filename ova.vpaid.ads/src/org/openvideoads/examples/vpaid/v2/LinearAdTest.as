package org.openvideoads.examples.vpaid.v2 {
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	import org.openvideoads.vpaid.VPAIDBase;
	import org.openvideoads.vpaid.VPAIDEvent;
	
	public class LinearAdTest extends VPAIDBase {	
		protected var _timer:Timer = null;
					
		public function LinearAdTest() {
			super();
			_adDuration = 10;
			logAd("VPAID 2 Linear Test Ad constructed");
		}

		// VPAID INTERFACES
		
        public override function startAd():void {
        	super.startAd();
        	startTimer();
        }
        
        // AD IMPLEMENTATION
        
        protected function startTimer():void {
			dispatchEvent(new VPAIDEvent(VPAIDEvent.AdPlaying));

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
			dispatchEvent(new VPAIDEvent(VPAIDEvent.AdRemainingTimeChange));
        }
        
        protected function timerComplete(timerEvent:TimerEvent):void {
       		fireOtherEvents();
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
        
		// TEST HARNESS

		protected function fireOtherEvents():void {
			dispatchEvent(new VPAIDEvent(VPAIDEvent.AdPaused));
			dispatchEvent(new VPAIDEvent(VPAIDEvent.AdLinearChange));			
			dispatchEvent(new VPAIDEvent(VPAIDEvent.AdVolumeChange));			
			dispatchEvent(new VPAIDEvent(VPAIDEvent.AdVideoStart));			
			dispatchEvent(new VPAIDEvent(VPAIDEvent.AdVideoFirstQuartile));			
			dispatchEvent(new VPAIDEvent(VPAIDEvent.AdVideoMidpoint));			
			dispatchEvent(new VPAIDEvent(VPAIDEvent.AdVideoThirdQuartile));			
			dispatchEvent(new VPAIDEvent(VPAIDEvent.AdVideoComplete));			
			dispatchEvent(new VPAIDEvent(VPAIDEvent.AdClickThru));			
			dispatchEvent(new VPAIDEvent(VPAIDEvent.AdUserAcceptInvitation));			
			dispatchEvent(new VPAIDEvent(VPAIDEvent.AdUserMinimize));			
			dispatchEvent(new VPAIDEvent(VPAIDEvent.AdExpandedChange));			
			dispatchEvent(new VPAIDEvent(VPAIDEvent.AdUserClose));
			dispatchEvent(new VPAIDEvent(VPAIDEvent.AdLog));			
			dispatchEvent(new VPAIDEvent(VPAIDEvent.AdError));	
			dispatchEvent(new VPAIDEvent(VPAIDEvent.AdSkippableStateChange));
			dispatchEvent(new VPAIDEvent(VPAIDEvent.AdSkipped));		
			dispatchEvent(new VPAIDEvent(VPAIDEvent.AdDurationChange));
			dispatchEvent(new VPAIDEvent(VPAIDEvent.AdSizeChange));
			dispatchEvent(new VPAIDEvent(VPAIDEvent.AdInteraction));
		}
	}
}