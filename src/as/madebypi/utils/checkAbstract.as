package madebypi.utils {
	
	/**
	 * Enforce an Abstract Class
	 * @param	thisClass
	 * @param	AbstractClass
	 */
	
	import flash.errors.IllegalOperationError;
	import flash.utils.getQualifiedClassName;
	
	public function checkAbstract(thisClass:Object, AbstractClass:Class):void{
		if (thisClass.constructor === AbstractClass) {
			throw new IllegalOperationError(getQualifiedClassName(thisClass) + " is an Abstract class and can not be created directly.");
		}
	}
}