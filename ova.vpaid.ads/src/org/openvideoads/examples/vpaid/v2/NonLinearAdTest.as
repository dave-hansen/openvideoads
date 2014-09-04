package org.openvideoads.examples.vpaid.v2 {
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	import org.openvideoads.vpaid.VPAIDBase;
	import org.openvideoads.vpaid.VPAIDEvent;
	
	public class NonLinearAdTest extends VPAIDBase {	
		protected var _timer:Timer = null;
		protected var _canvas:Sprite;
		protected var _canScale:Boolean = false;
		protected var _scalingFactor:Number = 1;
					
		public function NonLinearAdTest() {
			super();
			_adWidth = 300;
			_adHeight = 50;
			_adDuration = 20;
			_canvas = new Sprite();
			_canvas.mouseEnabled = true;
			_canvas.addEventListener(MouseEvent.CLICK, onClick);
			addChild(_canvas);
			if(loaderInfo.parameters.hasOwnProperty("scalable")) {
				_canScale = Boolean(loaderInfo.parameters.scalable);
			}
		}

		// VPAID INTERFACES

		public override function set adWidth(adWidth:Number):void {
		}
		
		public override function set adHeight(adHeight:Number):void {
		}
		
        public override function startAd():void {
        	super.startAd();
        	startTimer();
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
        
        protected function onClick(event:MouseEvent):void {
        	if(_adExpanded) {
	        	doLog("VPAID AD clicked - collapsing");
	        	collapseAd();
        	}
        	else {
	        	doLog("VPAID AD clicked - expanding");
        		expandAd();
        	}
        	renderAd();
        }
        
        public override function expandAd():void { 
    		_adWidth = 300 * _scalingFactor;
    		_adHeight = 250 * _scalingFactor;	
        	super.expandAd();      	
        	fireTestEvents();
        }
        
        public override function collapseAd():void {
    		_adWidth = 300 * _scalingFactor;
    		_adHeight = 50 * _scalingFactor;	
        	super.collapseAd();
        }        

        public override function resizeAd(width:Number, height:Number, viewMode:String):void {
        	if(_canScale) {
        		_scalingFactor = width / 300;
        		doLog("VPAID AD scaling factor set to " + _scalingFactor);
        	}
        	renderAd();
        }
        
        protected override function renderAd():void {
        	var color1:Number = 0x00FF00;
        	var color2:Number = 0x0000FF;

			_canvas.graphics.lineStyle(3,color1);
			_canvas.graphics.beginFill(color2);
			_canvas.graphics.drawRect(0, 0, adWidth, adHeight);
			_canvas.graphics.endFill();
        } 

		// TEST HARNESS

		protected function fireTestEvents():void {
			dispatchEvent(new VPAIDEvent(VPAIDEvent.AdLinearChange));			
			dispatchEvent(new VPAIDEvent(VPAIDEvent.AdRemainingTimeChange));			
			dispatchEvent(new VPAIDEvent(VPAIDEvent.AdVolumeChange));			
			dispatchEvent(new VPAIDEvent(VPAIDEvent.AdVideoStart));			
			dispatchEvent(new VPAIDEvent(VPAIDEvent.AdVideoFirstQuartile));			
			dispatchEvent(new VPAIDEvent(VPAIDEvent.AdVideoMidpoint));			
			dispatchEvent(new VPAIDEvent(VPAIDEvent.AdVideoThirdQuartile));			
			dispatchEvent(new VPAIDEvent(VPAIDEvent.AdVideoComplete));			
			dispatchEvent(new VPAIDEvent(VPAIDEvent.AdClickThru));			
			dispatchEvent(new VPAIDEvent(VPAIDEvent.AdPaused));			
			dispatchEvent(new VPAIDEvent(VPAIDEvent.AdPlaying));
			dispatchEvent(new VPAIDEvent(VPAIDEvent.AdError));			
			dispatchEvent(new VPAIDEvent(VPAIDEvent.AdUserAcceptInvitation));			
			dispatchEvent(new VPAIDEvent(VPAIDEvent.AdUserMinimize));			
			dispatchEvent(new VPAIDEvent(VPAIDEvent.AdExpandedChange));			
			dispatchEvent(new VPAIDEvent(VPAIDEvent.AdUserClose));			
		}
	}
}