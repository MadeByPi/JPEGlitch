package madebypi.utils {
	
	/**
	 * ...
	 * @author Mike Almond - MadeByPi
	 */
	
	import flash.external.ExternalInterface;
	import flash.utils.getTimer;
	
	public class Logger {
		
		public static const TYPE_FLASHTRACE	:uint 	= 0x01;
		public static const TYPE_FIREBUG	:uint 	= 0x02;
		
		public static const LEVEL_DEBUG		:uint 	= 0x04;// "debug";
		public static const LEVEL_INFO		:uint 	= 0x08;// "info";
		public static const LEVEL_WARN		:uint 	= 0x10;// "warn";
		public static const LEVEL_ERROR		:uint	= 0x20;// "error";
		
		
		// defualt to use all types of trace and all log levels
		private static var _type			:uint	= TYPE_FLASHTRACE | TYPE_FIREBUG;
		private static var _level			:uint	= LEVEL_DEBUG | LEVEL_INFO | LEVEL_WARN | LEVEL_ERROR;
		
		public function Logger(l:Lock) { }
		
		public static function log(value:*, level:uint = Logger.LEVEL_DEBUG):void {
			if (_level & level) { // is the log level currently enabled?
				value = String(value);
				if (_type & TYPE_FLASHTRACE) trace("(" + getLevelName(level) + ") " + value);
				if ((_type & TYPE_FIREBUG) && ExternalInterface.available) {
					try {
						ExternalInterface.call("console." + getLevelName(level), timeStr + String(value));
					} catch (err:Error) {}
				}
			}
		}
		
		static private function getLevelName(level:uint):String {
			if (level == LEVEL_DEBUG) return "debug";
			if (level == LEVEL_INFO) return "info";
			if (level == LEVEL_WARN) return "warn";
			if (level == LEVEL_ERROR) return "error";
			return null;
		}
		
		static private function get timeStr():String{
			return MathUtils.round(getTimer() * 0.001, 4) + " : ";
		}
		
		static public function get type():uint { return _type; }
		static public function set type(value:uint):void { _type = value; }
		
		static public function get enabledLogLevels():uint { return _level; }
		static public function set enabledLogLevels(value:uint):void {
			_level = value;
		}
	}
}
internal class Lock { };