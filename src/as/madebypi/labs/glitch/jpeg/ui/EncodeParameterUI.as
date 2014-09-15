package madebypi.labs.glitch.jpeg.ui {
	
	/**
	 * ...
	 * @author Mike Almond - MadeByPi
	 */
	
	import madebypi.minimalcomps.CheckBox;
	import madebypi.minimalcomps.HUISlider;
	import madebypi.minimalcomps.Label;
	import flash.events.Event;
	import madebypi.labs.glitch.jpeg.JPEGlitchEncoder;
	import madebypi.minimalcomps.MultiIconButton;
	import madebypi.parameter.mapping.MapFactory;
	import madebypi.parameter.Parameter;
	import madebypi.parameter.ParameterCollectionSnapshot;
 	import madebypi.parameter.ui.AbstractParameterUI;
	import flash.display.DisplayObjectContainer;
	import madebypi.parameter.IParameterObserver;

	public class EncodeParameterUI extends AbstractParameterUI{
		
		public function EncodeParameterUI(parent:DisplayObjectContainer, observer:IParameterObserver, xpos:Number = 0, ypos:Number = 0, title:String = "Encode Glitching") {
			super(parent, observer, xpos, ypos, title);
			setSize(250, 185);
		}
		
		override public function onParameterChange(parameter:Parameter):void {
			super.onParameterChange(parameter);
		}
		
		override protected function addChildren():void {
			super.addChildren();
			
			var p:Parameter;
			var s:HUISlider;

			p = new Parameter("downsample", MapFactory.getMapping(MapFactory.MAP_NUMBER_LINEAR, 1, 32, 2));
			s = setupParameterSlider(p);
			s.width = 240;
			
			p = new Parameter("quality", MapFactory.getMapping(MapFactory.MAP_INT_LINEAR, 1, 100, 20));
			s = setupParameterSlider(p);
			s.width = 240;
			
			p = new Parameter("glitchA", MapFactory.getMapping(MapFactory.MAP_NUMBER_LINEAR, 0, 4, 0));
			s = setupParameterSlider(p);
			s.width = 240;
			
			p = new Parameter("glitchAMod", MapFactory.getMapping(MapFactory.MAP_NUMBER_LINEAR, -1, 1, 0.1));
			s = setupParameterSlider(p);
			s.width = 240;
			
			p = new Parameter("glitchB", MapFactory.getMapping(MapFactory.MAP_NUMBER_LINEAR, 0, 8, 0));
			s = setupParameterSlider(p);
			s.width = 240;
			
			p = new Parameter("xBlockOffset", MapFactory.getMapping(MapFactory.MAP_NUMBER_LINEAR, 0, 8, 0));
			s = setupParameterSlider(p);
			s.width = 240;
			
			p = new Parameter("yBlockOffset", MapFactory.getMapping(MapFactory.MAP_NUMBER_LINEAR, 0, 8, 0));
			s = setupParameterSlider(p);
			s.width = 240;
			
			_nextX = 6;
			_nextY += 10;
			var c:CheckBox;
			p = new Parameter("glitchC", MapFactory.getMapping(MapFactory.MAP_BOOLEAN, null, null, 0));
			c = setupParameterToggle(p);

			_nextX = 60;
			_nextY = c.y - _yIncrement;
			p = new Parameter("glitchD", MapFactory.getMapping(MapFactory.MAP_BOOLEAN, null, null, 0));
			c = setupParameterToggle(p);
		}
		
		override protected function setupSnapshots():void {
			super.setupSnapshots();
			
			var data:XML = <parameters name="example">
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
			
			parameters.snapshotCollection.addSnapshot(ParameterCollectionSnapshot.fromData(data));
		}
	}
}