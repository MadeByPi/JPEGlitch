package madebypi.minimalcomps {
	
	/**
	 * ...
	 * @author Mike Almond - MadeByPi
	 */
	
	import flash.display.InteractiveObject;
	import flash.events.IEventDispatcher;
	import flash.events.MouseEvent;
	
	public class ToolTip {
		
		private var _uiTarget	:InteractiveObject;
		private var _enabled	:Boolean;
		private var _text		:String;
		
		public function ToolTip(uiTarget:InteractiveObject) {
			_uiTarget = uiTarget;
			enabled = false;
		}
		
		private function onMouse(e:MouseEvent):void {
			(e.type != MouseEvent.ROLL_OVER && e.type != MouseEvent.MOUSE_DOWN) ? ToolTipManager.hide(this) : ToolTipManager.show(this);
		}
		
		public function set text(value:String):void {
			_text = value;
			ToolTipManager.updateText(this, value);
		}
		public function get text():String { return _text; }
		
		public function get enabled():Boolean { return _enabled; }
		public function set enabled(value:Boolean):void {
			_enabled = value;
			if(value){
				_uiTarget.addEventListener(MouseEvent.ROLL_OVER, onMouse, false, 0, true);
				_uiTarget.addEventListener(MouseEvent.ROLL_OUT, onMouse, false, 0, true);
				_uiTarget.addEventListener(MouseEvent.MOUSE_DOWN, onMouse, false, 0, true);
			} else {
				_uiTarget.removeEventListener(MouseEvent.ROLL_OVER, onMouse);
				_uiTarget.removeEventListener(MouseEvent.ROLL_OUT, onMouse);
				_uiTarget.removeEventListener(MouseEvent.MOUSE_DOWN, onMouse);
				ToolTipManager.hide(this);
			}
		}
		
		public function get uiTarget():InteractiveObject { return _uiTarget; }
	}
}