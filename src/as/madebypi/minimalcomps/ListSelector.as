package madebypi.minimalcomps {
	
	/**
	 * ...
	 * @author Mike Almond - MadeByPi
	 */
	
	import madebypi.minimalcomps.Component;
	import madebypi.minimalcomps.Label;
	import madebypi.minimalcomps.Style;
	import flash.display.DisplayObjectContainer;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
		
	[Event(name = "change", type = "flash.events.Event")]
	public class ListSelector extends Component{
		
		protected var _itemsContainer		:Sprite;
		protected var _selector				:Sprite;
		
		protected var _dataProvider			:Array;
		protected var _numItems				:int;
		protected var _selectedIndex		:int;
		protected var _shadow				:Boolean;
		
		/**
		 * Constructor
		 * @param parent The parent DisplayObjectContainer on which to add this ListSelector.
		 * @param xpos The x position to place this component.
		 * @param ypos The y position to place this component.
		 * @param label String containing the label for this component.
		 * @param defaultHandler The event handling function to handle the default event for this component (change in this case).
		 */
		public function ListSelector(parent:DisplayObjectContainer = null, xpos:Number = 0, ypos:Number =  0, defaultHandler:Function = null){
			_selectedIndex 	= -1
			_shadow = false;
			_dataProvider = [];
			super(parent, xpos, ypos);
			if(defaultHandler != null) addEventListener(Event.CHANGE, defaultHandler, false, 0, true);
		}
		
		/**
		 * Initializes the component.
		 */
		override protected function init():void{
			super.init();
			setSize(60, 24);
		}
		
		/**
		 * Creates the children for this component
		 */
		override protected function addChildren():void{
			_itemsContainer		= new Sprite();
			_itemsContainer.x 	= 0;
			_itemsContainer.y 	= 0;
			addChild(_itemsContainer);
		}
		
		/**
		 * Removes old items.
		 */
		protected function reset():void{
			while(_itemsContainer.numChildren > 0) _itemsContainer.removeChildAt(0);
		}
		
		///////////////////////////////////
		// public methods
		///////////////////////////////////
		
		/**
		 * Draws the visual ui of the component.
		 */
		override public function draw():void{
			super.draw();
			
			reset();
			
			// bg fill
			opaqueBackground = Style.PANEL;
			
			var i:int = -1;
			var l:SelectableLabel;
			while (++i < _numItems) {
				l 			= new SelectableLabel(_itemsContainer, 2, i * 18, _dataProvider[i].label, onLabelSelect);
				l.index 	= i;
				l.selected 	= (i == _selectedIndex);
				_itemsContainer.addChild(l);
			}
			
			filters = _shadow ? [getShadow(2)] : [];
		}
		
		protected function onLabelSelect(e:Event):void{
			selectedIndex = SelectableLabel(e.target).index;
		}
		
		
		///////////////////////////////////
		// event handler
		///////////////////////////////////
		protected function onLabelClick(event:Event):void {
			if (selectedIndex > -1)
			selectedIndex = SelectableLabel(event.target).index;
		}
		
		
		///////////////////////////////////
		// getter/setters
		///////////////////////////////////
		
		/**
		 * Gets / sets the available items - [{name:null, value:null, ...}, ...]
		 */
		public function set dataProvider(value:Array):void {
			_dataProvider = value;
			_numItems	  = value.length;
			draw();
		}
		public function get dataProvider():Array{ return _dataProvider; }
		
		/**
		 * Gets / sets the currently selected item, keeping it in range of 0 to numItems - 1.
		 */
		public function set selectedIndex(value:int):void {
			if(value!=_selectedIndex){
				_selectedIndex = int(Math.max(0, Math.min(_numItems - 1, value)));
				invalidate();
				dispatchEvent(new Event(Event.CHANGE));
			}
		}
		public function get selectedIndex():int{ return _selectedIndex; }
		//
		public function get selectedItem():Object{ return _dataProvider[_selectedIndex]; }
		
		public function get shadow():Boolean { return _shadow; }
		public function set shadow(value:Boolean):void {
			if (value != _shadow) {
				_shadow = value;
				invalidate();
			}
		}
		
		public function get numItems():int { return _numItems; }
	}
}