package madebypi.minimalcomps {
	
	/**
	 * ...
	 * @author Mike Almond - MadeByPi
	 */
	
	import flash.utils.setTimeout;
	import madebypi.minimalcomps.Component;
	import madebypi.minimalcomps.Label;
	import madebypi.minimalcomps.Style;
	
	import flash.display.DisplayObjectContainer;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	[Event(name = "open", type = "flash.events.Event")]
	[Event(name = "close", type = "flash.events.Event")]
	public class DropdownListSelector extends ListSelector {
		
		protected var _label		:Label;
		protected var _defaultLabel	:String;
		protected var _handle		:Sprite;
		protected var _expanded		:Boolean;
		
		/**
		 * Constructor
		 * @param parent The parent DisplayObjectContainer on which to add this DropdownListSelector.
		 * @param xpos The x position to place this component.
		 * @param ypos The y position to place this component.
		 * @param defaultHandler The event handling function to handle the events for this component (open/close/change).
		 * @param label String containing the label for this component.
		 */
		public function DropdownListSelector(parent:DisplayObjectContainer = null, xpos:Number = 0, ypos:Number =  0, defaultHandler:Function = null, defaultLabel:String = "---"){
			_defaultLabel = defaultLabel;
			_expanded = false;
			super(parent, xpos, ypos, defaultHandler);
			if (defaultHandler != null) {
				addEventListener(Event.OPEN, defaultHandler, false, 0, true);
				addEventListener(Event.CLOSE, defaultHandler, false, 0, true);
			}
		}
		
		override protected function addChildren():void {
			
			_label = new Label(this, 2, 0, _defaultLabel);
			_label.autoSize = true;
			_label.mouseEnabled = true;
			_label.mouseChildren = true;
			_label.buttonMode = true;
			_label.addEventListener(MouseEvent.CLICK, handleClick, false, 0, true);
			
			_handle = new Sprite();
			_handle.graphics.beginFill(0, 0);
			_handle.graphics.drawRect(-10, -10, 20, 20);
			_handle.graphics.endFill();
			_handle.graphics.beginFill(0, .35);
			_handle.graphics.moveTo(-5, -3);
			_handle.graphics.lineTo(5, -3);
			_handle.graphics.lineTo(0, 4);
			_handle.graphics.lineTo(-5, -3);
			_handle.graphics.endFill();
			_handle.buttonMode = true;
			_handle.y = _label.height - 9;
			_handle.addEventListener(MouseEvent.CLICK, handleClick, false, 0, true);
			addChild(_handle);
			
			super.addChildren();
			_itemsContainer.y = 19;
		}
		
		private function handleClick(e:MouseEvent):void {
			expanded = !_expanded;
		}
		
		override public function draw():void {
			
			_label.text = (_selectedIndex == -1) ? _defaultLabel : _dataProvider[_selectedIndex].label;
			_label.draw();
			
			super.draw();
			graphics.clear();
			
			var w:Number = Math.max(_label.width, _itemsContainer.width);
			
			if (_expanded) {
				if (!_itemsContainer.parent) addChild(_itemsContainer);
				graphics.lineStyle(1, Style.BACKGROUND, 1);
				graphics.moveTo(2, _label.height);
				graphics.lineTo(w + 3, _label.height);
				_height = _itemsContainer.y + _itemsContainer.height + 2;
			} else {
				if (_itemsContainer.parent) removeChild(_itemsContainer);
				_height = 24;
			}
			//
			_handle.rotation = _expanded ? 0 : -90;
			_handle.x = w + 10;
			
			_width = Math.max(_itemsContainer.width, _handle.x + _handle.width);
		}
		
		override public function set selectedIndex(value:int):void {
			if(value!=_selectedIndex) expanded = false;
			super.selectedIndex = value;
		}
		
		public function get defaultLabel():String { return _defaultLabel; }
		public function set defaultLabel(value:String):void {
			_defaultLabel = value;
			draw();
		}
		
		public function get expanded():Boolean { return _expanded; }
		public function set expanded(value:Boolean):void {
			value = value && (_dataProvider.length > 0);
			if (_expanded != value) {
				_expanded = value;
				draw();
				dispatchEvent(new Event(value ? Event.OPEN : Event.CLOSE));
				dispatchEvent(new Event(Event.RESIZE));
				
				if (value) addEventListener(Event.ENTER_FRAME, addStageListener, false, 0, true);
			}
		}
		
		private function addStageListener(e:Event):void {
			removeEventListener(Event.ENTER_FRAME, addStageListener);
			if(!stage.hasEventListener(MouseEvent.CLICK)) stage.addEventListener(MouseEvent.CLICK, onStageLeave, false, 0, true);
			if(!stage.hasEventListener(Event.MOUSE_LEAVE)) stage.addEventListener(Event.MOUSE_LEAVE, onStageLeave, false, 0, true);
		}
		
		private function onStageLeave(e:Event):void {
			stage.removeEventListener(MouseEvent.CLICK, onStageLeave);
			stage.removeEventListener(Event.MOUSE_LEAVE, onStageLeave);
			expanded = false;
		}
		
		public function get label():Label { return _label; }
	}
}