package madebypi.parameter {
	
	/**
	 * ...
	 * @author Mike Almond  - MadeByPi
	 */
	
	import madebypi.parameter.Parameter;
	
    public interface IParameterObserver {
		
		/**
		 *
		 * @param	parameter	The parameter that's changed
		 * @return	Boolean informing if the parameter requires handling (not yet processed by subclasses)
		 */
		function onParameterChange(parameter:Parameter):void;
    }
}
