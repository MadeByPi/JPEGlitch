package madebypi.snapshot {
	
	/**
	 * ...
	 * @author Mike Almond - MadeByPi
	 */
		
	public interface ISnapshotConfigurable {
		
		function createSnapshot(name:String = "unnamed", addToSnapshotCollection:Boolean = true):ISnapshot;
		
		function applySnapshot(snapshot:ISnapshot):void;
		
		function get snapshotCollection():SnapshotCollection;
	}
}