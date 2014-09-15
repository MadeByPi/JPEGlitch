package madebypi.labs.glitch.jpeg {
		
	/**
	 * ...
	 * @author Mike Almond - MadeByPi
	 */
	
	import flash.utils.ByteArray;
	import flash.display.DisplayObjectContainer;
	
	import madebypi.parameter.Parameter;
	import madebypi.parameter.IParameterObserver;
	import madebypi.parameter.ui.AbstractParameterUI;

	public class AbstractController implements IParameterObserver{
		
		protected var _enabled		:Boolean;
		protected var _ui	 		:AbstractParameterUI;
		protected var _uiContainer	:DisplayObjectContainer;
		
		public function AbstractController(uiContainer:DisplayObjectContainer) {
			_uiContainer = uiContainer;
		}
		
		/* INTERFACE madebypi.parameter.IParameterObserver */
		public function onParameterChange(parameter:Parameter):void {
			if (parameter.name == "enabled") {
				const e:Boolean = parameter.getValue() == 1;
				if (parameter.fromUI) _enabled = e;
				else enabled = e;
				parameter.handled = true;
			}
		}
		
		public function get enabled():Boolean { return _enabled; }
		public function set enabled(value:Boolean):void {
			_enabled	 = value;
			if(_ui) _ui.enabled  = value;
		}
		
		public function get ui():AbstractParameterUI { return _ui; }
	}
}