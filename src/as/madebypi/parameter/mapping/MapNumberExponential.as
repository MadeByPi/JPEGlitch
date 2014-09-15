package madebypi.parameter.mapping {
	
	/**
	 * ...
	 * @author Mike Almond  - MadeByPi
	 */
	public class MapNumberExponential implements IMapping {
		
		private var _min	:Number;
		private var _max	:Number;
		private var _default:Number;
		
		private var _t0		:Number;
        private var _t1		:Number;
        private var _t2		:Number;

		public function MapNumberExponential(min:Number = Number.MIN_VALUE, max:Number = Number.MAX_VALUE, defaultValue:Number = 0) {
			_default = defaultValue;
			
			_t2 = 0;
			if (min <= 0) { _t2 = 1 + min * -1; }
			
			_min = min + _t2;
			_max = max + _t2;
			
			_t0 = Math.log( _max / _min );
			_t1 = 1.0 / _t0;
		}
		
		/**
		 *
		 * @param	normalisedValue (0-1)
		 * @return	A mapped value in the range of min-max
		 */
		public function map(normalisedValue:Number):Number {
			return _min * Math.exp( (normalisedValue) * _t0 ) - _t2;
		}
		
		/**
		 *
		 * @param	value	A value in the range of min-max
		 * @return	Normalised value (0-1)
		 */
		public function mapInverse(value:Number):Number {
			return Math.log((value + _t2) / _min) * _t1;
		}
		
		public function get type():uint { return MapFactory.MAP_NUMBER_EXPONENTIAL; }
		public function get min():Number{ return _min; }
		public function get max():Number { return _max; }
		public function get defaultValue():Number{ return _default; }
		public function set defaultValue(value:Number):void { _default = value; }
		
		public function toString():String {
			return "[MapNumberExponential] min:" + _min + ", max:" + _max + " defaultValue:" + defaultValue;
		}
	}
}
