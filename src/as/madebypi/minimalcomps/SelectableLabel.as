package madebypi.minimalcomps {
	
	/**
	 * ...
	 * @author Mike Almond - MadeByPi
	 */
	
 	import madebypi.minimalcomps.Label;
	import madebypi.minimalcomps.Style;
	
	import flash.events.MouseEvent;
	
	import flash.display.DisplayObjectContainer;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;

	public class SelectableLabel extends Label {
		
		private var _index				:uint;
		
		private var  _bg				:Sprite;
		private var  _fg				:Shape;
		
		protected var _selected			:Boolean;
		protected var _mouseOver		:Boolean;
		
		protected var _overColour		:uint;
		protected var _selectedColour	:uint;
		
		/**
		 * Constructor
		 * @param parent The parent DisplayObjectContainer on which to add this SelectableLabel.
		 * @param xpos The x position to place this component.
		 * @param ypos The y position to place this component.
		 * @param text The string to use as the initial text in this component.
		 * @param defaultHandler The event handling function to handle the default event for this component (change in this case).
		 */
		public function SelectableLabel(parent:DisplayObjectContainer = null, xpos:Number = 0, ypos:Number =  0, text:String = "", defaultHandler:Function = null) {
			_overColour 		= 0x0000AA;
			_selectedColour 	= 0x0000EE;
			autoSize 			= true;
			super(parent, xpos, ypos, text);
			mouseEnabled = true;
			if (defaultHandler != null) addEventListener(Event.CHANGE, defaultHandler, false, 0, true);
		}
		
		/**
		 * Initializes the component.
		 */
		override protected function init():void{
			
			_bg = new Sprite();
			_fg = new Shape();
			
			_bg.addEventListener(MouseEvent.ROLL_OVER, onBGMouse, false, 0, true);
			_bg.addEventListener(MouseEvent.ROLL_OUT, onBGMouse, false, 0, true);
			_bg.addEventListener(MouseEvent.CLICK, onBGClick, false, 0, true);
			
			super.init();
			
			mouseEnabled  = true;
			mouseChildren = true;
		}
		
		/**
		 * Creates and adds the child display objects of this component.
		 */
		override protected function addChildren():void{
			super.addChildren();
			addChildAt(_bg, 0);
			addChild(_fg);
		}
		
		
		///////////////////////////////////
		// public methods
		///////////////////////////////////
		
		/**
		 * Draws the visual ui of the component.
		 */
		override public function draw():void {
			super.draw();
			
			//draw bg
			_bg.graphics.clear();
			_bg.graphics.beginFill(Style.PANEL, 0);
			_bg.graphics.drawRect(0,0,width, height);
			_bg.graphics.endFill();
			
			//draw fg selection if selected / mouse over
			_fg.graphics.clear();
			if (_selected || _mouseOver) {
				_fg.graphics.beginFill(_selected ? _selectedColour : _overColour , _selected ? 0.25 : 0.125);
				_fg.graphics.drawRect(2, 2, width - 4, height - 4);
				_fg.graphics.endFill();
			}
		}
		
		
		///////////////////////////////////
		// event handlers
		///////////////////////////////////
		
		private function onBGClick(e:MouseEvent):void {
			selected = true;
		}
		//
		private function onBGMouse(e:MouseEvent):void {
			mouseOver = (e.type == MouseEvent.ROLL_OVER);
		}
		
		
		///////////////////////////////////
		// getter/setters
		///////////////////////////////////
		
		/**
		 * Get / set the selected state
		 */
		public function get selected():Boolean { return _selected; }
		public function set selected(value:Boolean):void {
			if(value != _selected){
				_selected = value;
				invalidate();
				dispatchEvent(new Event(Event.CHANGE));
			}
		}
		
		protected function get mouseOver():Boolean { return _mouseOver; }
		protected function set mouseOver(value:Boolean):void {
			_mouseOver = value;
			invalidate();
		}
		
		public function get overColour():uint { return _overColour; }
		public function set overColour(value:uint):void {
			_overColour = value;
			invalidate();
		}
		
		public function get selectedColour():uint { return _selectedColour; }
		public function set selectedColour(value:uint):void {
			_selectedColour = value;
			invalidate();
		}
		
		//access the background - used for capturing mouse events - set alpha > 0 to see it
		public function get bg():Sprite { return _bg; }
		
		public function get index():uint { return _index; }
		public function set index(value:uint):void { _index = value; }
		
		override public function toString():String {
			return super.toString() + ", index:" + _index;
		}
	}
}