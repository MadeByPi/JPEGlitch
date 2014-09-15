package madebypi.minimalcomps {
	
	/**
	 * ...
	 * @author Mike Almond - MadeByPi
	 */
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.Graphics;
	import flash.display.PixelSnapping;
	import flash.display.Shape;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import madebypi.minimalcomps.Component;
	
	[Event(name = "click", type = "flash.events.MouseEvent")]
	public class AbstractIconButton extends Component {
		
		protected var _display		:Bitmap;
		
		protected var _over			:Boolean;
		protected var _down			:Boolean;
		protected var _isToggle		:Boolean;
		protected var _selected		:Boolean;
		protected var _enabled		:Boolean;
		private var _defaultHandler	:Function;
		
		public function AbstractIconButton(parent:DisplayObjectContainer, xpos:int, ypos:int, defaultHandler:Function = null, enabled:Boolean = true) {
			_display = new Bitmap(null, PixelSnapping.ALWAYS, false);
			_width = _height = 16;
			_selected = _isToggle = false;
			
			super(parent, xpos, ypos);
			this.enabled = enabled;
			
			_defaultHandler = defaultHandler;
		}
		
		override public function draw():void {
			super.draw();
			
			if (_enabled) {
				if (_down) {
					_display.filters = [getShadow(2, true)]; // mouse down
				}else if (_over) {
					_display.filters = [getShadow(2)]; // mouse over
				} else {
					_display.filters = [getShadow(1)]; // mouse up+out
				}
			}else {
				_display.filters = [getShadow(1, true)]; // disabled
			}
			
			_display.width  = _width;
			_display.height = _height;
			_display.alpha	= _enabled ? 1 : 0.5;
		}
		
		override protected function addChildren():void {
			addChild(_display);
			// set _display.bitmapData here
		}
		
		public function get enabled():Boolean { return _enabled; }
		public function set enabled(value:Boolean):void {
			_enabled = buttonMode = mouseEnabled = value;
			_down = _over = false;
			
			if (value) {
				addEventListener(MouseEvent.ROLL_OVER, onMouse, false, 0, true);
				addEventListener(MouseEvent.ROLL_OUT, onMouse, false, 0, true);
				addEventListener(MouseEvent.MOUSE_DOWN, onMouse, false, 0, true);
				addEventListener(MouseEvent.CLICK, onMouse, false, 0, true);
			}else{
				removeEventListener(MouseEvent.ROLL_OVER, onMouse);
				removeEventListener(MouseEvent.ROLL_OUT, onMouse);
				removeEventListener(MouseEvent.MOUSE_DOWN, onMouse);
				removeEventListener(MouseEvent.CLICK, onMouse);
				if(stage) stage.removeEventListener(MouseEvent.MOUSE_UP, onMouse);
			}
			
			invalidate();
		}
		
		public function get selected():Boolean { return _selected; }
		public function set selected(value:Boolean):void { _selected = value; }
		
		public function get isToggle():Boolean { return _isToggle; }
		public function set isToggle(value:Boolean):void { _isToggle = value; }
		
		private function onMouse(e:MouseEvent):void {
			switch(e.type) {
				case MouseEvent.ROLL_OVER:
				_over = true;
				break;
				
				case MouseEvent.ROLL_OUT:
				_over = false;
				break;
				
				case MouseEvent.MOUSE_DOWN:
				stage.addEventListener(MouseEvent.MOUSE_UP, onMouse, false, 0, true);
				_down = true;
				break;
				
				case MouseEvent.MOUSE_UP:
				stage.removeEventListener(MouseEvent.MOUSE_UP, onMouse);
				_down = false;
				break;
				
				case MouseEvent.CLICK:
				selected = !selected;
				if (_defaultHandler != null) _defaultHandler.apply(null, [e]);
				break;
			}
			
			invalidate();
		}
	}
}