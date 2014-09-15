package madebypi.parameter.mapping {
	
	/**
	 * ...
	 * @author Mike Almond  - MadeByPi
	 */
	
	public class MapIntLinear implements IMapping {
		
		private var _min	:int;
		private var _max	:int;
		private var _default:int;

		public function MapIntLinear(min:int = int.MIN_VALUE, max:int = int.MAX_VALUE, defaultValue:int = 0) {
			_min = min;
			_max = max;
			_default = defaultValue;
		}
		
		public function map(normalisedValue:Number):Number {
			var value:Number = _min + normalisedValue * ( _max - _min );
			return value > 0.0 ? int(value + 0.5) : -int( -value + 0.5 );
		}
		
		public function mapInverse(value:Number):Number{
			return (value - _min ) / ( _max - _min );
		}
		
		public function get type():uint { return MapFactory.MAP_INT_LINEAR; }
		public function get min():Number{ return _min; }
		public function get max():Number{ return _max; }
		public function get defaultValue():Number { return _default; }
		public function set defaultValue(value:Number):void {
			if (value > max) value = max;
			if (value < min) value = min;
			_default = value;
		}
		
		public function toString():String {
			return "[MapIntLinear] min:" + _min + ", max:" + _max + ", defaultValue:" + defaultValue;
		}
	}
}
