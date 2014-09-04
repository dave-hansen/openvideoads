package org.openvideoads.regions.view.button {
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	
	import org.openvideoads.base.Debuggable;
	import org.openvideoads.regions.view.RegionView;

	/**
	 * @author Paul Schulz
	 */
	public class CloseButton extends Sprite {
		private var _id:String;
		private var _parentView:RegionView=null;
		protected var _buttonWidth:int = 0;
		protected var _buttonHeight:int = 0;

		public function CloseButton(id:String=null, parentView:RegionView=null, buttonWidth:int=0, buttonHeight:int=0) {
			_id = id;
			_parentView = parentView;
			_buttonWidth = buttonWidth;
			_buttonHeight = buttonHeight;
            drawButton();
            addEventListener(MouseEvent.ROLL_OVER, onMouseOver);
			addEventListener(MouseEvent.ROLL_OUT, onMouseOut);
			addEventListener(MouseEvent.CLICK, onMouseClick);
            buttonMode = true;
            this.mouseChildren = true;
		}
          
        public function set buttonWidth(buttonWidth:int):void {
        	_buttonWidth = buttonWidth;
        }
        
        public function get buttonWidth():int {
        	return _buttonWidth;	
        }
        
        public function set buttonHeight(buttonHeight:int):void {
        	_buttonHeight = buttonHeight;
        }
        
        public function get buttonHeight():int {
        	return _buttonHeight;	
        }
        
        public function calculateLayoutPosition(width:int, borderRadius:int):void {
			x = width - buttonWidth - (borderRadius/5);
			y = ((borderRadius > 0) ? buttonHeight + borderRadius/5 : buttonHeight);
        }
        
        protected function drawButton():void {
        }
 
		protected function onMouseOut(event:MouseEvent):void {
			CONFIG::debugging { doLog("CROSS button out", Debuggable.DEBUG_MOUSE_EVENTS); }
			this.alpha = 0.7;
		}

		protected function onMouseOver(event:MouseEvent):void {
			CONFIG::debugging { doLog("CROSS button over", Debuggable.DEBUG_MOUSE_EVENTS); }
			this.alpha = 1;
		}

		protected function onMouseClick(event:MouseEvent):void {
			CONFIG::debugging { doLog("CROSS button clicked to close", Debuggable.DEBUG_MOUSE_EVENTS); }
			event.stopPropagation();
			if(_parentView != null) _parentView.onCloseClicked();
		}
		
		// DEBUG METHODS
		
		CONFIG::debugging
		protected function doLog(data:String, level:int=1):void {
			Debuggable.getInstance().doLog(data, level);
		}
		
		CONFIG::debugging
		protected function doTrace(o:Object, level:int=1):void {
			Debuggable.getInstance().doTrace(o, level);
		}
	}
}