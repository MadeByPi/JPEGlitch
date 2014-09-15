package madebypi.parameter.mapping {
	
	/**
	 * ...
	 * @author Mike Almond  - MadeByPi
	 */
	public class MapBoolean implements IMapping{
	
		private var _default:Boolean;
		
		public function MapBoolean(defaultValue:Boolean = false) {
			_default = defaultValue;
		}
		
		public function map(normalizedValue:Number):Number{
            return normalizedValue > 0.5 ? 1 : 0;
		}
		
        public function mapInverse(value:Number):Number{
			return value ? 1 : 0;
		}
		
		public function get type():uint { return MapFactory.MAP_BOOLEAN; }
		public function get min():Number{ return 0; }
		public function get max():Number { return 1; }
		public function get defaultValue():Number { return _default?1:0; }
		public function set defaultValue(value:Number):void { _default = (value==1) ? true : false; }
		
		public function toString():String {
			return "[MapBoolean] defaultValue:" + defaultValue;
		}
	}
}
