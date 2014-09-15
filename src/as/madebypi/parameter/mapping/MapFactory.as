package madebypi.parameter.mapping {
	
	/**
	 * ...
	 * @author Mike Almond  - MadeByPi
	 */
	public class MapFactory {
		
		public static const MAP_BOOLEAN				:uint = 0;
		public static const MAP_INT_LINEAR			:uint = 1;
		public static const MAP_NUMBER_LINEAR		:uint = 2;
		public static const MAP_NUMBER_EXPONENTIAL	:uint = 3;
		
		public function MapFactory(l:Lock) {
			
		}
		
		public static function getMapping(mapType:uint, min:*= null, max:*= null, defaultValue:*= null):IMapping {
			switch(mapType) {
				case MAP_BOOLEAN: return new MapBoolean(Boolean(defaultValue));
				break;
				
				case MAP_INT_LINEAR: return new MapIntLinear(int(min), int(max), defaultValue);
				break;
				
				case MAP_NUMBER_LINEAR: return new MapNumberLinear(Number(min), Number(max), defaultValue);
				break;
				
				case MAP_NUMBER_EXPONENTIAL: return new MapNumberExponential(Number(min), Number(max), defaultValue);
				break;
				
				default: trace("mappingType not allowed!");
				break;
			}
			return null;
		}
	}
}
internal class Lock{}
