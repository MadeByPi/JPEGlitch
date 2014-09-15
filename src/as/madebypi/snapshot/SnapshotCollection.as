package madebypi.snapshot {
	
	/**
	 * ...
	 * @author Mike Almond - MadeByPi
	 */
	public class SnapshotCollection {
		
		protected var _snapshots	:Vector.<ISnapshot>;
		protected var _unnamedCount	:uint;
		
		public function SnapshotCollection() {
			_snapshots = new Vector.<ISnapshot>();
			_unnamedCount = 1;
		}
		
		public function addSnapshot(value:ISnapshot):uint {
			if (getSnapshotByName(value.name) == null) {
				_snapshots.push(value);
			} else if (value.name == "unnamed") {
				value.name = "unnamed " + (_unnamedCount++);
				_snapshots.push(value);
			} else {
				throw new Error("Shapshot " + value + " already exists in collection");
			}
			return _snapshots.length;
		}
		
		public function getSnapshotAt(index:uint):ISnapshot {
			if (_snapshots[index]) return _snapshots[index];
			return null;
		}
		
		public function getSnapshotByName(name:String):ISnapshot {
			var i:int = getShapshotIndexByName(name);
			if (i != -1) return _snapshots[i];
			return null;
		}
		
		public function getShapshotIndexByName(name:String):int {
			var i:int = _snapshots.length;
			while (--i > -1) {
				if (_snapshots[i].name == name) return i;
			}
			return -1;
		}
		
		public function updateSnapshot(snapshot:ISnapshot):void {
			var i:int = getShapshotIndexByName(snapshot.name);
			if (i != -1) {
				_snapshots[i] = snapshot;
			} else {
				throw new ReferenceError("Can't update. No snapshot exists with name:" + snapshot.name);
			}
		}
		
		public function updateSnapshotAt(snapshot:ISnapshot, index:uint):void {
			if (_snapshots[index]) {
				_snapshots[index] = snapshot;
			} else {
				throw new ReferenceError("Can't update. No snapshot exists at index:" + index);
			}
		}
		
		public function deleteSnapshot(index:uint):void {
			delete _snapshots[index];
			_snapshots.splice(index, 1);
		}
		
		public function dispose():void {
			while (_snapshots.length) deleteSnapshot(0);
			_snapshots = null;
		}
		
		public function get length():uint { return _snapshots.length; }
		
		public function get dataProvider():Array {
			var i:int    = _snapshots.length;
			var dp:Array = new Array(i);
			while (--i > -1) {
				dp[i] = { label:_snapshots[i].name, index:i };
			}
			return dp;
		}
	}
}