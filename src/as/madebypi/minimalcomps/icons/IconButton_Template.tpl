package madebypi.minimalcomps.icons {
	
	/**
	 * ...
	 * @author Mike Almond - MadeByPi
	 */
	
	import flash.display.Bitmap;
	import flash.display.DisplayObjectContainer;
	
	import madebypi.minimalcomps.AbstractIconButton;
	
	public class IconButton_@ASSET_NAME@ extends AbstractIconButton{
		
		[Embed(source='@ASSET_PATH@/@ASSET_NAME@.@ASSET_EXTENSION@')]
		private static var IconAsset:Class;
		
		public function IconButton_@ASSET_NAME@(parent:DisplayObjectContainer, xpos:int, ypos:int, defaultHandler:Function = null, enabled:Boolean = true) {
			super(parent, xpos, ypos, defaultHandler, enabled);
		}
		
		override protected function addChildren():void {
			super.addChildren();
			_display.bitmapData = Bitmap(new IconAsset()).bitmapData;
			_width = _display.width;
			_height= _display.width;
		}
	}
}