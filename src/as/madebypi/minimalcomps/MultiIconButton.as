package madebypi.minimalcomps {
	
	/**
	 * ...
	 * @author Mike Almond - MadeByPi
	 */
	
	import flash.display.BitmapData;
	import flash.display.DisplayObjectContainer;
	
	public class MultiIconButton extends AbstractIconButton{
		
		protected var _stateIcons:Array;
		
		public function MultiIconButton(parent:DisplayObjectContainer, xpos:int, ypos:int, defaultHandler:Function = null, enabled:Boolean = true) {
			super(parent, xpos, ypos, defaultHandler, enabled);
			_isToggle = true;
		}
		
		public function setIcons(icons:Array):void {
			_stateIcons = icons;
			invalidate();
		}
		
		override public function draw():void {
			_display.bitmapData = _stateIcons ? _stateIcons[selected ? 1 : 0] : null;
			_width = _display.width;
			_height = _display.width;
			super.draw();
		}
		
		override public function set selected(value:Boolean):void {
			super.selected = value;
			toolTip.text = name + " : " + _selected;
			draw();
		}
	}
}