package madebypi.labs.glitch.jpeg.ui {
	
	/**
	 * ...
	 * @author Mike Almond - MadeByPi
	 */
	
	import flash.events.Event;
	import flash.events.MouseEvent;
	import madebypi.labs.glitch.jpeg.JPEGData;
	import madebypi.labs.glitch.jpeg.ui.decode.DHTUI;
	import madebypi.labs.glitch.jpeg.ui.decode.DQTUI;
	import madebypi.labs.glitch.jpeg.ui.decode.SOSUI;
	import madebypi.labs.glitch.ui.ByteArrayGlitchUI;
	import madebypi.minimalcomps.AbstractIconButton;
	import madebypi.minimalcomps.CheckBox;
	import madebypi.minimalcomps.HUISlider;
	import flash.display.DisplayObjectContainer;
	import madebypi.minimalcomps.icons.IconButton_arrow_refresh;
	import madebypi.minimalcomps.icons.IconButton_bomb;
	import madebypi.minimalcomps.Label;
	import madebypi.minimalcomps.UISlider;
	import madebypi.parameter.mapping.MapFactory;
	import madebypi.parameter.Parameter;
	import madebypi.parameter.ui.AbstractParameterUI;
	import madebypi.parameter.IParameterObserver;
	
	public class DecodeParameterUI extends AbstractParameterUI{

		private var _SOSUI:SOSUI;
		private var _DQTUI:Vector.<ByteArrayGlitchUI>;
		//private var _DHTUI:Vector.<ByteArrayGlitchUI>;
		
		public function DecodeParameterUI(parent:DisplayObjectContainer, observer:IParameterObserver, jpegData:JPEGData) {
			_DQTUI = new Vector.<ByteArrayGlitchUI>(jpegData.DQTCount, true);
			//_DHTUI = new Vector.<ByteArrayGlitchUI>(jpegData.DHTCount, true);
			super(parent, observer, 0, 0, "Decode Glitching");
			snapshotsEnabled = false;
			setSize(250, 580);
			
			// set up the default starting parameters / ui
			UISlider(getParameterComponent("SOFWidth")).defaultValue 	= jpegData.SOFImageWidth;
			UISlider(getParameterComponent("SOFHeight")).defaultValue 	= jpegData.SOFImageHeight;
			UISlider(getParameterComponent("DRI")).defaultValue 		= jpegData.getDRI();
			
			parameters.getParameter("SOFWidth").mapping.defaultValue  	= jpegData.SOFImageWidth;
			parameters.getParameter("SOFHeight").mapping.defaultValue 	= jpegData.SOFImageHeight;
			parameters.getParameter("DRI").mapping.defaultValue 	  	= jpegData.getDRI();
			parameters.getParameter("SOFWidth").reset();
			parameters.getParameter("SOFHeight").reset();
			parameters.getParameter("DRI").reset();
			
			parameters.setAsDefaultSnapshot();
			resetToDefaults();
		}
		
		override protected function addChildren():void {
			super.addChildren();
			
			var p:Parameter;
			var s:HUISlider;
			
			p = new Parameter("SOFWidth", MapFactory.getMapping(MapFactory.MAP_INT_LINEAR, 1, 8192, 512));
			s = setupParameterSlider(p);
			s.width = 240;
			
			p = new Parameter("SOFHeight", MapFactory.getMapping(MapFactory.MAP_INT_LINEAR, 1, 8192, 512));
			s = setupParameterSlider(p);
			s.width = 240;
			
			p = new Parameter("DRI", MapFactory.getMapping(MapFactory.MAP_INT_LINEAR, 0, 1024, 0));
			s = setupParameterSlider(p);
			s.width = 240;
			//
			//
			_nextY += 20;
			
			var ui:ByteArrayGlitchUI;
			
			// SOS
			_SOSUI = new SOSUI(content, _observer, _nextY);
			_SOSUI.addEventListener(Event.RESIZE, onPanelResize, false, 0, true);
			_nextY += _SOSUI.height + 5;
			
			// DQT
			var  i:int = -1;
			var  n:int = _DQTUI.length;
			while (++i < n) {
				ui = new DQTUI(content, _observer, _nextY, i);
				ui.addEventListener(Event.RESIZE, onPanelResize, false, 0, true);
				_DQTUI[i] = ui;
				_nextY += ui.height + 5;
			}
			
			// DHT
			/*i = -1;
			n = _DHTUI.length;
			while (++i < n) {
				ui = new DHTUI(content, _observer, _nextY, i);
				ui.addEventListener(Event.RESIZE, onPanelResize, false, 0, true);
				_DHTUI[i] = ui;
				_nextY += ui.height + 5;
			}*/
		}
		
		private function onPanelResize(e:Event):void {
			invalidate();
		}
		
		override public function draw():void {
			super.draw();
			//position child panels
			var ny	:int = _SOSUI.y + _SOSUI.height + 5;
			var i	:int = -1;
			var n	:int = _DQTUI.length;
			
			while (++i < n) {
				_DQTUI[i].y = ny;
				ny += _DQTUI[i].height + 5;
			}
			
			/*i = -1;
			n = _DHTUI.length;
			while (++i < n) {
				_DHTUI[i].y = ny;
				ny += _DHTUI[i].height + 5;
			}*/
			
			height = ny + 20;
		}
		
		override public function resetToDefaults(e:Event = null):void {
			super.resetToDefaults(e);
			
			if (MouseEvent(e) && MouseEvent(e).ctrlKey) {
				_SOSUI.resetToDefaults();
				var i:int = _DQTUI.length;
				while (--i > -1) _DQTUI[i].resetToDefaults();
				/*i = _DHTUI.length;
				while (--i > -1) _DHTUI[i].resetToDefaults();*/
			}
		}
		
		override public function randomiseParameters(e:Event = null, ignoreEnabled:Boolean = true):void {
			super.randomiseParameters(e, ignoreEnabled);
			
			if(MouseEvent(e) && MouseEvent(e).ctrlKey){
				_SOSUI.randomiseParameters(e,ignoreEnabled);
				
				var i:int = _DQTUI.length;
				while (--i > -1) _DQTUI[i].randomiseParameters(e, ignoreEnabled);
				
				/*i = _DHTUI.length;
				while (--i > -1) _DHTUI[i].randomiseParameters(e,ignoreEnabled);*/
			}
		}
		
		override public function dispose():void {
			_SOSUI.dispose();
			
			var n:int = _DQTUI.length;
			while (--n > -1) _DQTUI[n].dispose();
			
			/*n = _DHTUI.length
			while (--n > -1) _DHTUI[n].dispose();*/
			
			super.dispose();
		}
		
		public function get sosUI():SOSUI { return _SOSUI; }
		public function get dqtUI():Vector.<ByteArrayGlitchUI> { return _DQTUI; }
		//public function get dhtUI():Vector.<ByteArrayGlitchUI> { return _DHTUI; }
	}
}