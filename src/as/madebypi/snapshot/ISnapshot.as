package madebypi.snapshot {
	
	/**
	 * ...
	 * @author Mike Almond - MadeByPi
	 */
	public interface ISnapshot {
		
		function get name():String;
		function set name(value:String):void;
		
		function get data():XML;
		function set data(data:XML):void;
		
		function setFromSource(value:*, name:String = "default"):void;
	}
}