package madebypi.parameter {
	
	/**
	 * ...
	 * @author Mike Almond  - MadeByPi
	 */
	
	import madebypi.parameter.mapping.IMapping;
	import madebypi.snapshot.ISnapshot;
	import madebypi.snapshot.ISnapshotConfigurable;
	import madebypi.snapshot.SnapshotCollection;
	
	public class ParameterCollection implements ISnapshotConfigurable {
		
		private var _snapshots	:SnapshotCollection;
		private var _params		:Vector.<Parameter>;
		private var _count		:int;
		
		public function ParameterCollection() {
			_count  	= 0;
			_params 	= new Vector.<Parameter>();
			_snapshots 	= new SnapshotCollection();
		}
		//
		public function dispose():void {
			
			_snapshots.dispose();
			_snapshots = null;
			
			var i:int = _count;
			while (--i > -1) {
				_params[i].dispose();
				_params[i] = null;
			}
			_params = null;
			_count  = 0;
		}
		//
		public function reset():void {
			var i:int = _count;
			while (--i > -1) _params[i].reset();
		}
		
		public function randomiseValues(includeNames:Array = null, excludeNames:Array = null):void {
			var i:int = _count;
			
			if (includeNames == null && excludeNames == null) {
				while (--i > -1) {
					_params[i].setValue(Math.random(), true);
				}
				return;
			}
			
			if (includeNames) {
				while (--i > -1) {
					if(includeNames.indexOf(_params[i].name) != -1){
						_params[i].setValue(Math.random(), true);
					}
				}
				return;
			}
			
			if (excludeNames) {
				while (--i > -1) {
					if(excludeNames.indexOf(_params[i].name) == -1){
						_params[i].setValue(Math.random(), true);
					}
				}
				return;
			}
		}
		
		//
		public function addParameter(parameter:Parameter):void {
			_params.push(parameter);
			_count++;
		}
		//
		public function removeParameter(parameter:Parameter):void {
			var i:int = _params.indexOf(parameter);
			if (i > -1) {
				_params[i].dispose();
				_params.splice(i, 1);
				_count--;
			}
		}
		//
		public function getParameter(name:String):Parameter {
			var i:int = _count;
			while (--i > -1) {
				if (_params[i].name == name) {
					return _params[i];
				}
			}
			return null;
		}
		//
		public function getParameterAt(index:uint):Parameter { return _params[index]; }
		//
		public function get length():int { return _count; }
		
		
		/*
		 * ISnapshotConfigurable interface requirements...
		 */
		public function applySnapshot(snapshot:ISnapshot):void {
			
			if (!(snapshot is ParameterCollectionSnapshot)){
				throw new ReferenceError("Parameter 'snapshot' is of wrong type. Should be ParameterCollectionSnapshot, got " + snapshot);
				return;
			}
			
			var xl:XMLList = snapshot.data.parameter;
			var n:int = xl.length();
			var p:Parameter;
			while (--n > -1) {
				p = getParameter(String(xl[n].@name));
				if (p) {
					p.setValue(Number(xl[n].@nValue), true);
				} else {
					throw new Error("Parameter '"+ xl[n].@name +"' not present in this collection");
				}
			}
		}
		//
		public function createSnapshot(name:String = "unnamed", addToSnapshotCollection:Boolean = true):ISnapshot {
			var s:ParameterCollectionSnapshot = new ParameterCollectionSnapshot(this, name);
			if(addToSnapshotCollection) _snapshots.addSnapshot(s);
			return s;
		}
		//
		
		public function setAsDefaultSnapshot():void {
			_snapshots.getSnapshotByName("default").setFromSource(this);
		}
		
		public function get snapshotCollection():SnapshotCollection { return _snapshots; }
	}
}
