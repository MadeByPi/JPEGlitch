package madebypi.labs.glitch.jpeg.ui.decode {
	
	import flash.display.DisplayObjectContainer;
	import madebypi.labs.glitch.ui.ByteArrayGlitchUI;
	import madebypi.parameter.IParameterObserver;
	import madebypi.parameter.ParameterCollectionSnapshot;
	
	/**
	 * ...
	 * @author Mike Almond - MadeByPi
	 */
	
	public class DQTUI extends ByteArrayGlitchUI{
		
		public function DQTUI(parent:DisplayObjectContainer = null, observer:IParameterObserver = null, ypos:Number = 0, index:uint = 0) {
			super(parent, observer, 5, ypos, "DQT");
			title = "DQT " + index;
			minimized = true;
		}
		
		override protected function setupSnapshots():void {
			super.setupSnapshots();
			
			var data:XML = <parameters name="example">
				<parameter name="reverseDQTBlocksMax" nValue="0.4929523809523809"/>
				<parameter name="reverseDQTBlocksMin" nValue="0.11014285714285714"/>
				<parameter name="reverseDQTBlocksItt" nValue="0.1265625"/>
				<parameter name="randomFillDQTBlocksMax" nValue="1"/>
				<parameter name="randomFillDQTBlocksMin" nValue="0"/>
				<parameter name="randomFillDQTBlocksProb" nValue="0.14"/>
				<parameter name="randomFillDQTBlocksItt" nValue="0.04475"/>
				<parameter name="enabled" nValue="1"/>
			</parameters>;
			
			parameters.snapshotCollection.addSnapshot(ParameterCollectionSnapshot.fromData(data));
		}
	}
}