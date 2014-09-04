package org.openvideoads.examples.vpaid.v1 {
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	import org.openvideoads.vpaid.VPAIDBase;
	
	public class ExpandableNonLinearExample extends VPAIDBase {	
		protected var _timer:Timer = null;
		protected var _canvas:Sprite;
		protected var _canScale:Boolean = false;
		protected var _scalingFactor:Number = 1;
					
		public function ExpandableNonLinearExample() {
			super();
			_adWidth = 300;
			_adHeight = 50;
			_adDuration = 20;
			_canvas = new Sprite();
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
	}
}