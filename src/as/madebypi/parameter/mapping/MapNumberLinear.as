package madebypi.parameter.mapping {
	
	/**
	 * ...
	 * @author Mike Almond  - MadeByPi
	 */
	public class MapNumberLinear implements IMapping {
		
		private var _min	:Number;
		private var _max	:Number;
		private var _default:Number;
		
		public function MapNumberLinear(min:Number = Number.MIN_VALUE, max:Number = Number.MAX_VALUE, defaultValue:Number = 0) {
			_min = min;
			_max = max;
			_default = defaultValue;
		}
		
		/**
		 *
		 * @param	normalisedValue (0-1)
		 * @return	A mapped value in the range of min-max
		 */
		public function map(normalisedValue:Number):Number{
			return _min + normalisedValue * ( _max - _min );
		}
		
		/**
		 *
		 * @param	value	A value in the range of min-max
		 * @return	Normalised value (0-1)
		 */
		public function mapInverse(value:Number):Number{
			return ( value - _min ) / ( _max - _min );
		}
		
		public function get type():uint { return MapFactory.MAP_NUMBER_LINEAR; }
		public function get min():Number{ return _min; }
		public function get max():Number{ return _max; }
		public function get defaultValue():Number{ return _default; }
		public function set defaultValue(value:Number):void { _default = value; }
		
		public function toString():String {
			return "[MapNumberLinear] min:" + _min + ", max:" + _max + ", defaultValue:" + defaultValue;
		}
	}
}
