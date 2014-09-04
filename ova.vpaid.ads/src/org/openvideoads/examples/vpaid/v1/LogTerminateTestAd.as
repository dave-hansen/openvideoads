package org.openvideoads.examples.vpaid.v1 {	
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	
	import org.openvideoads.vpaid.VPAIDBase;
	
	public class LogTerminateTestAd extends VPAIDBase {	
		protected var _canvas:Sprite;
					
		public function LogTerminateTestAd() {
			super();
			_adWidth = 10;
			_adHeight = 10;
			_adDuration = 20;
			_canvas = new Sprite();
			_canvas.mouseEnabled = true;
			_canvas.addEventListener(MouseEvent.CLICK, onClick);
			addChild(_canvas);
		}

		// VPAID INTERFACES
		
        public override function startAd():void {
        	super.startAd();
        }
        
        // AD IMPLEMENTATION

        protected function onClick(event:MouseEvent):void {
        	doLog("CLICK! Firing AdLog event with error text 'errorEvent: No ads'");
        	logAd("'errorEvent: No ads'");
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