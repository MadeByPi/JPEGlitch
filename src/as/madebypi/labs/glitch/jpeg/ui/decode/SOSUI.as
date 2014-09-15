package madebypi.labs.glitch.jpeg.ui.decode {
	
	import flash.display.DisplayObjectContainer;
	import madebypi.labs.glitch.ui.ByteArrayGlitchUI;
	import madebypi.parameter.IParameterObserver;
	import madebypi.parameter.ParameterCollectionSnapshot;
	
	/**
	 * ...
	 * @author Mike Almond - MadeByPi
	 */
	
	public class SOSUI extends ByteArrayGlitchUI{
		
		public function SOSUI(parent:DisplayObjectContainer = null, observer:IParameterObserver = null, ypos:Number = 0) {
			super(parent, observer, 5, ypos, "SOS", true);
			minimized = true;
		}
		
		override protected function setupSnapshots():void {
			super.setupSnapshots();
			
			var data:XML = <parameters name="example">
				<parameter name="reverseSOSBlocksMax" nValue="1"/>
				<parameter name="reverseSOSBlocksMin" nValue="0"/>
				<parameter name="reverseSOSBlocksItt" nValue="0.06331250000000001"/>
				<parameter name="randomFillSOSBlocksMax" nValue="0.11865079365079365"/>
				<parameter name="randomFillSOSBlocksMin" nValue="0"/>
				<parameter name="randomFillSOSBlocksProb" nValue="0.17500000000000002"/>
				<parameter name="randomFillSOSBlocksItt" nValue="0.2388125"/>
				<parameter name="shuffleSOSBlocksMax" nValue="1"/>
				<parameter name="shuffleSOSBlocksMin" nValue="0"/>
				<parameter name="shuffleSOSBlocksItt" nValue="0.035687500000000004"/>
				<parameter name="enabled" nValue="1"/>
			</parameters>;
			
			parameters.snapshotCollection.addSnapshot(ParameterCollectionSnapshot.fromData(data));
		}
	}
}