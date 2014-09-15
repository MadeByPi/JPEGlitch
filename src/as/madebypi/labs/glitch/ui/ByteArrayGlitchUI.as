package madebypi.labs.glitch.ui {
	
	import madebypi.minimalcomps.HUISlider;
	import madebypi.parameter.mapping.MapFactory;
	import madebypi.parameter.Parameter;
	import madebypi.parameter.ui.AbstractParameterUI;
	import flash.display.DisplayObjectContainer;
	import madebypi.parameter.IParameterObserver;
	
	/**
	 * ...
	 * @author Mike Almond - MadeByPi
	 */
	public class ByteArrayGlitchUI extends AbstractParameterUI{
		
		private var _shuffle:Boolean;
		private var _randomise:Boolean;
		private var _reverse:Boolean;
		
		public function ByteArrayGlitchUI(parent:DisplayObjectContainer, observer:IParameterObserver, xpos:Number = 0, ypos:Number = 0, title:String = "AbstractParameterUI", shuffle:Boolean = false, randomise:Boolean = true, reverse:Boolean = true) {
			_shuffle	= shuffle;
			_randomise	= randomise;
			_reverse 	= reverse;
			super(parent, observer, xpos, ypos, title);
			hasMinimizeButton = true;
			draggable = false;
			shadow = true;
			setSize(250, content.height + 40);
		}
		
		override public function set shadow(value:Boolean):void {
			super.shadow = value;
			if(value){
				filters = [getShadow(1, false)];
			} else {
				filters = [];
			}
		}
		
		override protected function addChildren():void {
			super.addChildren();
			
			var p:Parameter;
			var s:HUISlider;
			
			if (_shuffle) {
				p = new Parameter("shuffle"+title+"BlocksItt", MapFactory.getMapping(MapFactory.MAP_INT_LINEAR, 0, 16, 0));
				s = setupParameterSlider(p);
				s.width = 240;
				p = new Parameter("shuffle"+title+"BlocksMin", MapFactory.getMapping(MapFactory.MAP_INT_LINEAR, 1, 2048, 64));
				s = setupParameterSlider(p);
				s.width = 240;
				p = new Parameter("shuffle"+title+"BlocksMax", MapFactory.getMapping(MapFactory.MAP_INT_LINEAR, 1, 2048, 1024));
				s = setupParameterSlider(p);
				s.width = 240;
			}
			
			if (_randomise) {
				_nextY += 4;
				p = new Parameter("randomFill"+title+"BlocksItt", MapFactory.getMapping(MapFactory.MAP_INT_LINEAR, 0, 16, 0));
				s = setupParameterSlider(p);
				s.width = 240;
				p = new Parameter("randomFill"+title+"BlocksProb", MapFactory.getMapping(MapFactory.MAP_NUMBER_LINEAR, 0, 1, 0.5));
				s = setupParameterSlider(p);
				s.width = 240;
				p = new Parameter("randomFill"+title+"BlocksMin", MapFactory.getMapping(MapFactory.MAP_INT_LINEAR, 1, 64, 2));
				s = setupParameterSlider(p);
				s.width = 240;
				p = new Parameter("randomFill"+title+"BlocksMax", MapFactory.getMapping(MapFactory.MAP_INT_LINEAR, 1, 64, 16));
				s = setupParameterSlider(p);
				s.width = 240;
			}
			//
			if(_reverse){
				_nextY += 4;
				p = new Parameter("reverse"+title+"BlocksItt", MapFactory.getMapping(MapFactory.MAP_INT_LINEAR, 0, 16, 0));
				s = setupParameterSlider(p);
				s.width = 240;
				p = new Parameter("reverse"+title+"BlocksMin", MapFactory.getMapping(MapFactory.MAP_INT_LINEAR, 1, 64, 2));
				s = setupParameterSlider(p);
				s.width = 240;
				p = new Parameter("reverse"+title+"BlocksMax", MapFactory.getMapping(MapFactory.MAP_INT_LINEAR, 1, 64, 8));
				s = setupParameterSlider(p);
				s.width = 240;
			}
		}
	}
}