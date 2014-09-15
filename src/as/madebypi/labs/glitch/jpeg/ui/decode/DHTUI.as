package madebypi.labs.glitch.jpeg.ui.decode {
	
	import flash.display.DisplayObjectContainer;
	import madebypi.labs.glitch.ui.ByteArrayGlitchUI;
	import madebypi.parameter.IParameterObserver;
	
	/**
	 * ...
	 * @author Mike Almond - MadeByPi
	 */
	
	public class DHTUI extends ByteArrayGlitchUI{
		
		public function DHTUI(parent:DisplayObjectContainer = null, observer:IParameterObserver = null, ypos:Number = 0, index:uint = 0) {
			super(parent, observer, 5, ypos, "DHT");
			title = "DHT " + index;
			minimized = true;
		}
		
		override protected function setupSnapshots():void {
			super.setupSnapshots();
			
			/*var data:XML = <parameters name="example">
				<parameter name="glitchD" nValue="0"/>
				<parameter name="glitchC" nValue="0"/>
				<parameter name="yBlockOffset" nValue="0.115"/>
				<parameter name="xBlockOffset" nValue="0.0885"/>
				<parameter name="glitchB" nValue="0.00725"/>
				<parameter name="glitchAMod" nValue="0.5125"/>
				<parameter name="glitchA" nValue="1"/>
				<parameter name="quality" nValue="0.20289898989898988"/>
				<parameter name="downsample" nValue="0.04387096774193548"/>
				<parameter name="enabled" nValue="1"/>
			</parameters>;
			
			parameters.snapshotCollection.addSnapshot(ParameterCollectionSnapshot.fromData(data));*/
		}
	}
}