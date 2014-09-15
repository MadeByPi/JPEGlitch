package madebypi.parameter {
	
	/**
	 * ...
	 * @author Mike Almond - MadeByPi
	 */
	
	import madebypi.snapshot.ISnapshot;
	import madebypi.snapshot.ISnapshot;
	import madebypi.utils.Logger;
	
	public class ParameterCollectionSnapshot implements ISnapshot{
		
		protected var _data:XML;
		
		/**
		 *
		 * @param	parameters	ParameterCollection to store
		 * @param	name		name of the snapshot
		 */
		public function ParameterCollectionSnapshot(parameters:ParameterCollection = null, name:String = "default") {
			if(parameters) setFromSource(parameters, name);
		}
		
		/**
		 * Create ParameterCollectionSnapshot from previously saved xml data
		 * @param	value
		 * @return A new ParameterCollectionSnapshot
		 */
		public static function fromData(value:XML):ParameterCollectionSnapshot {
			var s:ParameterCollectionSnapshot = new ParameterCollectionSnapshot();
			s.data = value;
			return s;
		}
		
		/**
		 * set / overwrite the snapshot
		 * @param	value	The ParameterCollection to store
		 * @param	name	The name of the snapshot
		 */
		public function setFromSource(value:*, presetName:String = "default"):void {
			if (value is ParameterCollection) {
				_data = <parameters name={presetName}/>;
				var pc	:ParameterCollection = ParameterCollection(value);
				var p	:Parameter;
				var n	:int = pc.length;
				while (--n > -1) {
					p = pc.getParameterAt(n);
					_data.appendChild(<parameter name={p.name} nValue={p.getValue(true)}/>);
				}
			} else {
				_data = null;
				throw new ReferenceError("Was expecting parameter of type ParameterCollection, got " + value);
			}
			
			Logger.log(toString());
		}
		
		public function get data():XML { return _data; }
		public function set data(value:XML):void { _data = value; }
		public function get name():String { return _data.@name; }
		public function set name(value:String):void { _data.@name = value; }
		public function toString():String { return "[ParameterCollectionSnapshot]\n" + _data.toString(); }
		
	}
}