package madebypi.parameter.ui {
	
	/**
	 * ...
	 * @author Mike Almond - MadeByPi
	 */
	
	import flash.display.DisplayObjectContainer;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.utils.getQualifiedClassName;
	import madebypi.minimalcomps.AbstractIconButton;
	import madebypi.minimalcomps.icons.IconButton_arrow_refresh;
	import madebypi.minimalcomps.icons.IconButton_arrow_undo;
	import madebypi.minimalcomps.icons.IconButton_bomb;
	import madebypi.minimalcomps.icons.IconButton_connect;
	import madebypi.minimalcomps.icons.IconButton_connect_IconAsset;
	import madebypi.minimalcomps.icons.IconButton_disconnect_IconAsset;
	import madebypi.minimalcomps.MultiIconButton;
	import madebypi.parameter.mapping.MapIntLinear;
		
	import madebypi.minimalcomps.Label;
	import madebypi.minimalcomps.CheckBox;
	import madebypi.minimalcomps.HUISlider;
	import madebypi.minimalcomps.Component;
	import madebypi.minimalcomps.Knob;
	import madebypi.minimalcomps.Panel;
	import madebypi.minimalcomps.PushButton;
	import madebypi.minimalcomps.UISlider;
	import madebypi.minimalcomps.Window;
	
	import madebypi.utils.checkAbstract;
	
	import madebypi.snapshot.ISnapshotConfigurable;
	import madebypi.minimalcomps.SnapshotCollectionUI;
	
	import madebypi.parameter.IParameterObserver;
	import madebypi.parameter.Parameter;
	import madebypi.parameter.ParameterCollection;
	import madebypi.parameter.mapping.MapFactory;
	import madebypi.parameter.mapping.MapBoolean;
	
	public class AbstractParameterUI extends Window implements IParameterObserver {
		
		protected var _parameters	:ParameterCollection;
		protected var _observer		:IParameterObserver;
		protected var _label		:Label;
		
		protected var _enabledToggle:MultiIconButton;
		protected var _resetButton	:AbstractIconButton;
		
		protected var _nextY		:int;
		protected var _nextX		:int;
		
		protected var _snapshotUI	:SnapshotCollectionUI;
		protected var _yIncrement	:int;
		
		protected var _snapshotsEnabled:Boolean;
		protected var _randomiseButton:AbstractIconButton;
		
		public function AbstractParameterUI(parent:DisplayObjectContainer, observer:IParameterObserver, xpos:Number=0, ypos:Number=0, title:String="AbstractParameterUI") {
			checkAbstract(this, AbstractParameterUI);
			
			_observer 		= observer;
			_parameters 	= new ParameterCollection();
			_nextY 			= 0;
			_nextX			= 5;
			_yIncrement		= 16;
			
			super(parent, xpos, ypos, title);
			this.enabled = false;
		}
		
		override protected function init():void {
			super.init();
			setupSnapshots();
			setupSnapshotUI();
			_snapshotsEnabled = true;
		}
		
		override protected function addChildren():void {
			super.addChildren();
			hasMinimizeButton = true;
			
			var p:Parameter;
			p = new Parameter("enabled", MapFactory.getMapping(MapFactory.MAP_BOOLEAN, 0, 1, 1), this);
			_enabledToggle = setupParameterMultiIconButton(p, [new IconButton_disconnect_IconAsset().bitmapData, new IconButton_connect_IconAsset().bitmapData]);
			_enabledToggle.x = 5;
			_enabledToggle.y = 5;
			
			_resetButton = new IconButton_arrow_refresh(content, 26, 5, resetToDefaults);
			_resetButton.name = _resetButton.toolTip.text = "reset";
			_resetButton.toolTip.enabled = true;
			
			_randomiseButton = new IconButton_bomb(content, _nextX+44, 5, randomiseParameters);
			_randomiseButton.name = _randomiseButton.toolTip.text = "randomise";
			_randomiseButton.toolTip.enabled = true;
			
			_nextY = 5;
		}
		
		public function randomiseParameters(e:Event = null, ignoreEnabled:Boolean = true):void {
			parameters.randomiseValues(null, ignoreEnabled?["enabled"]:null); // don't affect the enabled parameter
		}
		
		private function setupSnapshotUI():void {
			_snapshotUI = new SnapshotCollectionUI(_parameters, this, 0, 20);
			_snapshotUI.list.addEventListener(Component.DRAW, onSnapshotListChange, false, 0, true);
		}
		
		override public function draw():void {
			_snapshotUI.x = Math.max(content.width - _snapshotUI.width + 10, _width - _snapshotUI.width - 10);
			_width = _snapshotUI.x + _snapshotUI.width;
			super.draw();
		}
		
		protected function onSnapshotListChange(e:Event):void {
			width = _snapshotUI.x + _snapshotUI.width;
		}
		
		protected function setupSnapshots():void {
			parameters.createSnapshot("default");
		}
		public function selectSnapshot(index:uint):void {
			parameters.applySnapshot(_parameters.snapshotCollection.getSnapshotAt(index));
		}
		public function selectSnapshotByName(name:String):void {
			parameters.applySnapshot(_parameters.snapshotCollection.getSnapshotByName(name));
		}
		
		override public function set minimized(value:Boolean):void {
			super.minimized = value;
			if (_snapshotsEnabled) {
				if (value) {
					if(_snapshotUI.parent) removeChild(_snapshotUI);
				} else {
					if(!_snapshotUI.parent) addChild(_snapshotUI);
				}
			}
		}
		
		protected function get nextY():int{
			return _nextY += _yIncrement;
		}
		protected function get nextX():int {
			return _nextX;
		}
		
		public function getParameterComponent(name:String):Component {
			return Component(content.getChildByName(name));
		}
		
		/**
		 * IconButton setup
		 * @param	parameter
		 * @param	defaultHandler
		 * @return
		 */
		protected function setupIconButton(parameter:Parameter, ButtonClass:Class):AbstractIconButton {
			var b:AbstractIconButton = new ButtonClass(content, nextX, nextY, onButtonClick);
			b.name = parameter.name;
			b.toolTip.text = parameter.name;
			b.toolTip.enabled = true;
			return b;
		}
		protected function setupParameterIconButton(p:Parameter, ButtonClass:Class):AbstractIconButton {
			addParameter(p);
			return setupIconButton(p, ButtonClass);
		}
		
		/**
		 * IconButton setup
		 * @param	parameter
		 * @param	defaultHandler
		 * @return
		 */
		protected function setupMultiIconButton(parameter:Parameter, icons:Array):MultiIconButton {
			var b:MultiIconButton = new MultiIconButton(content, nextX, nextY, onButtonToggle);
			b.setIcons(icons);
			b.toolTip.enabled = true;
			b.toolTip.text = parameter.name;
			b.name 		= parameter.name;
			b.isToggle 	= true;
			b.selected 	= parameter.mapping.defaultValue == 1.0;
			return b;
		}
		
		protected function setupParameterMultiIconButton(p:Parameter, icons:Array):MultiIconButton {
			addParameter(p);
			return setupMultiIconButton(p, icons);
		}
		
		/**
		 * Toggle setup
		 * @param	parameter
		 * @param	defaultHandler
		 * @return
		 */
		protected function setupToggle(parameter:Parameter):CheckBox {
			var t:CheckBox = new CheckBox(content, nextX, nextY, parameter.name, onToggleChange);
			t.name = parameter.name;
			t.toolTip.enabled = true;
			t.toolTip.text = parameter.name;
			t.selected = parameter.mapping.defaultValue == 1.0;
			return t;
		}
		protected function setupParameterToggle(p:Parameter):CheckBox {
			addParameter(p);
			return setupToggle(p);
		}
		
		/**
		 * HUISlider setup
		 * @param	parameter
		 * @return
		 */
		protected function setupSlider(p:Parameter):HUISlider{
			var slider:HUISlider 		= new HUISlider(content, nextX, nextY, p.name, onSliderChange, p.mapping.defaultValue);
			slider.name					= p.name;
			slider.toolTip.text			= p.name;
			slider.toolTip.enabled		= true;
			slider.minimum 				= p.mapping.min;
			slider.maximum 				= p.mapping.max;
			slider.labelPrecision 		= (p.mapping is MapIntLinear) ? 0 : 3;
			slider.value				= p.mapping.defaultValue;
			slider.tick			 		= 0.001;
			return slider;
		}
		protected function setupParameterSlider(p:Parameter):HUISlider {
			addParameter(p);
			return setupSlider(p);
		}
		
		/**
		 * Knob setup
		 * @return
		 */
		protected function setupKnob(p:Parameter):Knob {
			var knob:Knob 		= new Knob(content, nextX, nextY, p.name, onKnobChange, p.mapping.defaultValue);
			knob.name			= p.name;
			knob.toolTip.text	= p.name;
			knob.toolTip.enabled= true;
			knob.minimum 		= p.mapping.min;
			knob.maximum 		= p.mapping.max;
			knob.value			= p.mapping.defaultValue;
			knob.labelPrecision = (p.mapping is MapIntLinear) ? 0 : 3;
			return knob;
		}
		protected function setupParameterKnob(p:Parameter):Knob {
			addParameter(p);
			return setupKnob(p);
		}
		
		private function addParameter(p:Parameter):void{
			p.addObserver(_observer, false, -1);
			p.addObserver(this, false);
			_parameters.addParameter(p);
		}
		
		protected function onToggleChange(e:Event):void {
			_parameters.getParameter(CheckBox(e.currentTarget).label).toggleBoolean(true);
		}
		protected function onSliderChange(e:Event):void {
			_parameters.getParameter(HUISlider(e.target).label).setValue(HUISlider(e.target).value, false, true);
		}
		protected function onKnobChange(e:Event):void {
			_parameters.getParameter(Knob(e.target).label).setValue(Knob(e.target).value, false, true);
		}
		protected function onButtonClick(e:Event):void {
			_parameters.getParameter(AbstractIconButton(e.target).name).setValue(AbstractIconButton(e.target).selected?1:0, true, true);
		}
		protected function onButtonToggle(e:Event):void {
			_parameters.getParameter(Component(e.target).name).setValue(_enabledToggle.selected ? 1 : 0, true, true);
		}
		
		protected function removeParamterAndControl(name:String):void{
			parameters.removeParameter(parameters.getParameter(name));
			content.removeChild(getParameterComponent(name));
		}
		
		public function onParameterChange(parameter:Parameter):void {
			
			const v:Number = parameter.getValue();
			
			//if it's a parameter change not triggered by the component, set the component value
			if(!parameter.fromUI){
				const c:Component = getParameterComponent(parameter.name);
				if (c is MultiIconButton) {
					MultiIconButton(c).selected = (v == 1);
				}else if (c is CheckBox) {
					CheckBox(c).selected = (v == 1);
				}else if (c is UISlider) {
					UISlider(c).value = v;
				}else if (c is Knob) {
					Knob(c).value = v;
				}
			}
			
			switch(parameter.name) {
				case "enabled":
				parameter.handled = true;
				break;
			}
		}
		
		public function resetToDefaults(e:Event=null):void {
			selectSnapshotByName("default");
			if(_snapshotUI) _snapshotUI.list.selectedIndex = 0;
		}
		
		public function setParameterDefault(name:String, value:Number, componentClass:Class):void {
			parameters.getParameter(name).mapping.defaultValue = value;
			parameters.getParameter(name).reset();
			componentClass(getParameterComponent(name)).defaultValue  = value;
			parameters.snapshotCollection.updateSnapshot(parameters.createSnapshot("default", false));
		}
		
		public function dispose():void {
			//clean up all parameters
			_parameters.dispose();
			_parameters = null;
			_observer 	= null;
			
			while (content.numChildren > 0) content.removeChild(content.getChildAt(0));
			if (parent) parent.removeChild(this);
		}
		
		public function get parameters():ParameterCollection { return _parameters; }
		
		public function get enabled():Boolean { return _parameters.getParameter("enabled").getValue() == 1; }
		public function set enabled(value:Boolean):void {
			_parameters.getParameter("enabled").setValue(value ? 1 : 0);
			_enabledToggle.selected = value;
		}
		
		public function get snapshotsEnabled():Boolean { return _snapshotsEnabled; }
		public function set snapshotsEnabled(value:Boolean):void {
			if (value != _snapshotsEnabled) {
				_snapshotsEnabled = value;
				if (value) {
					if (!_snapshotUI.parent) addChild(_snapshotUI);
				} else {
					if (_snapshotUI.parent) removeChild(_snapshotUI);
				}
			}
		}
	}
}