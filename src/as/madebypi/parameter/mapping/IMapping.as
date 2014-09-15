package madebypi.parameter.mapping {
	
	/**
	 * ...
	 * @author Mike Almond  - MadeByPi
	 */
	
	public interface IMapping {
		
		/**
		 * @param	normalisedValue (0-1)
		 * @return	A mapped value in the range of min-max
		 */
		function map(normalisedValue:Number):Number;
		
		/**
		 * @param	value	A value in the range of min-max
		 * @return	Normalised value (0-1)
		 */
		function mapInverse(value:Number):Number;
		
		function get type():uint;
		function get min():Number;
		function get max():Number;
		function get defaultValue():Number;
		function set defaultValue(value:Number):void;
		function toString():String;
	}
}
