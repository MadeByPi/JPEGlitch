package madebypi.minimalcomps {
	
	/**
	 * ...
	 * @author Mike Almond - MadeByPi
	 */
	
	import madebypi.minimalcomps.Style;
	import flash.display.DisplayObjectContainer;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.filters.DropShadowFilter;
	
	import madebypi.minimalcomps.icons.IconButton_camera;
	import madebypi.minimalcomps.icons.IconButton_camera_add;
	import madebypi.minimalcomps.icons.IconButton_camera_delete;
	
	import madebypi.minimalcomps.Label;
	import madebypi.minimalcomps.Panel;
	import madebypi.minimalcomps.PushButton;
	
	
	import madebypi.snapshot.ISnapshot;
	import madebypi.snapshot.ISnapshotConfigurable;
	
	public class SnapshotCollectionUI extends Panel {
		
		private var _target			:ISnapshotConfigurable;
		private var _list			:DropdownListSelector;
		
		private var _icons			:Sprite;
		private var _store_ico		:IconButton_camera;
		private var _add_ico		:IconButton_camera_add;
		private var _delete_ico		:IconButton_camera_delete;
		
		public function SnapshotCollectionUI(target:ISnapshotConfigurable, parent:DisplayObjectContainer=null, xpos:Number=0, ypos:Number=0, title:String="Snapshots") {
			_target = target;
			super(parent, xpos, ypos);
			shadow = false;
		}
		
		override protected function init():void{
			addChildren();
			_width = _icons.x + 59;
			_height = 20;
			invalidate();
		}
		
		override protected function addChildren():void {
			super.addChildren();
			
			_list = new DropdownListSelector(content, 0, 0, onDropdown, "Snapshots...");
			_list.dataProvider = _target.snapshotCollection.dataProvider;
			_list.label.toolTip.text = "Select a snapshot";
			_list.label.toolTip.enabled = true;
			
			_icons = new Sprite();
			content.addChild(_icons);
			_icons.x 	 = _list.width-11;
			_icons.y 	 = 2;
			
			_store_ico 	 = new IconButton_camera(_icons, 0, -1, onIconButton);
			_store_ico.toolTip.text = "store";
			_store_ico.toolTip.enabled = true;
			_add_ico 	 = new IconButton_camera_add(_icons, 20, 0, onIconButton);
			_add_ico.toolTip.text = "add";
			_add_ico.toolTip.enabled = true;
			_delete_ico  = new IconButton_camera_delete(_icons, 40, 0, onIconButton);
			_delete_ico.toolTip.text = "delete";
			_delete_ico.toolTip.enabled = true;
		}
		
		override public function draw():void {
			
			_icons.x = _list.width - 8;
			_width   = _icons.x + _icons.width + 4;
			_height	 = (_list.expanded) ? _list.height : 20;
			
			content.graphics.clear();
			content.graphics.lineStyle(1, Style.BACKGROUND - 0x111111, 1);
			content.graphics.drawRect(0, -1, width - 1, height);
			
			super.draw();
		}
		
		private function onIconButton(e:Event):void{
			switch(e.target) {
				case _store_ico:
				if(_list.selectedIndex > -1){
					_target.snapshotCollection.updateSnapshot(_target.createSnapshot(_list.selectedItem.label, false));
				} else {
					//if nothing selected, add new item and select it
					_target.createSnapshot();
					dataProviderChanged();
					_list.selectedIndex = _list.numItems;
				}
				break;
				
				case _add_ico:
				_target.createSnapshot();
				dataProviderChanged();
				_list.selectedIndex = _list.numItems;
				break;
				
				case _delete_ico:
				if (_list.selectedIndex > 0 && _list.numItems > 1) { // can't delete first entry - default values
					_target.snapshotCollection.deleteSnapshot(_list.selectedIndex);
					_list.selectedIndex--;
					dataProviderChanged();
				}
				break;
			}
		}
		
		private function dataProviderChanged():void{
			_list.dataProvider = _target.snapshotCollection.dataProvider;
			invalidate();
		}
		
		private function onDropdown(e:Event):void {
			switch(e.type) {
				case Event.OPEN:
				case Event.CLOSE:
				break;
				case Event.CHANGE:
				_target.applySnapshot(_target.snapshotCollection.getSnapshotAt(_list.selectedIndex));
				break;
			}
			invalidate();
		}
		
		public function get list():DropdownListSelector { return _list; }
	}
}