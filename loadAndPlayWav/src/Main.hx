package;

import haxe.Timer;
import haxe.CallStack;
import haxe.io.BytesInput;
import haxe.io.Bytes;
import haxe.io.Float32Array;

import lime.app.Application;
import lime.ui.Window;

import format.wav.Data.WAVE;

import peote.view.PeoteView;
import peote.view.Display;
import peote.view.Color;
import peote.view.Load;

import peote.audio.PeoteAudio;
import peote.audio.AudioSource;
import peote.audio.AudioBuffer;


class Main extends Application {
	override function onWindowCreate():Void {
		switch (window.context.type) {
			case WEBGL, OPENGL, OPENGLES:
				try startSample(window)
				catch (_) trace(CallStack.toString(CallStack.exceptionStack()), _);
			default: throw("Sorry, only works with OpenGL.");
		}
	}
	
	// ------------------------------------------------------------
	// --------------- SAMPLE STARTS HERE -------------------------
	// ------------------------------------------------------------	
	
	var peoteView:PeoteView;
	var display:Display;

	public function startSample(window:Window)
	{
		peoteView = new PeoteView(window);
		display = new Display(0, 0, window.width, window.height, Color.BLACK);
		peoteView.addDisplay(display);
		loadSound();
	}

	// ------------------------------------------------------------

	 // all have samplingRate of 11025
	var soundWaveFiles:Array<String> = [
		'assets/sinus.wav',
		'assets/01.wav',
		'assets/02.wav',
		'assets/04.wav',
		'assets/05.wav',
		'assets/06.wav',
		'assets/09.wav',
	];

	// load multiple sound-waves
	function loadSound()
	{
		Load.bytesArray( soundWaveFiles, false, // errorhandling/debug
			// --------------------- progress handler ---------------------
			function(index:Int, loaded:Int, size:Int) {
				trace(' $index progress ' + Std.int(loaded / size * 100) + "%" , ' ($loaded / $size)');
			},
			function(loaded:Int, size:Int) {
				trace(' Progress overall: ' + Std.int(loaded / size * 100) + "%" , ' ($loaded / $size)');
			},
			// --------------------- load handler ---------------------
			// function(index:Int, bytes:Bytes) {trace('$index loaded completely.');},
			onLoadSound
		);
	}

	// ------------------------------------------------------------

	var soundWave = new Array<WAVE>();

	function onLoadSound(bytesArray:Array<Bytes>)
	{
		for (bytes in bytesArray) {			
			var wav = new format.wav.Reader(new BytesInput(bytes)).read();
			trace(wav.data.length , wav.header);	
			soundWave.push(wav);
		}

		#if html5
		window.onMouseDown.add((x, y, button) -> { window.onMouseDown.removeAll(); readyToPlay(); }); // webbrowser needs an initial click!!!
		#else
		readyToPlay();
		#end
	}

	
	function readyToPlay()
	{
		PeoteAudio.init(44100);

		var wav:WAVE = soundWave[0];
		
		var buffer = new AudioBuffer(wav.data.length/44100);

		// convert Int16Arary wav.data to Flaot32Array:
		var wavF = new Float32Array(wav.data.length>>1);
		for (i in 0...wavF.length) {
			var v:Int =  (wav.data.get((i<<1)+1) << 8) | wav.data.get(i<<1);
			if (v & 0x8000 != 0) v = v - 0x10000;
			wavF.set( i, v / 32767 );
		}

		buffer.setData( wavF );
		

		
		var source = new AudioSource(buffer);
		source.play();

		var source1 = new AudioSource(buffer);
		source1.playDelay(5);
		
		var timestamp = Timer.stamp();
		var source2 = new AudioSource(buffer);
		source2.playFromTo(timestamp+2.0, timestamp + 3.0);

		// to test MULTIPLE:
		window.onMouseDown.add((x, y, button) -> {});

	}



	// ------------------------------------------------------------
	// ----------------- LIME EVENTS ------------------------------
	// ------------------------------------------------------------	

	// access embeded assets from here
	// override function onPreloadComplete():Void {}

	// for game-logic update
	override function update(deltaTime:Int):Void {
		PeoteAudio.update();
	}

	// override function render(context:lime.graphics.RenderContext):Void {}
	// override function onRenderContextLost ():Void trace(" --- WARNING: LOST RENDERCONTEXT --- ");		
	// override function onRenderContextRestored (context:lime.graphics.RenderContext):Void trace(" --- onRenderContextRestored --- ");		

	// ----------------- MOUSE EVENTS ------------------------------
	// override function onMouseMove (x:Float, y:Float):Void {}	
	// override function onMouseDown (x:Float, y:Float, button:lime.ui.MouseButton):Void {}	
	// override function onMouseUp (x:Float, y:Float, button:lime.ui.MouseButton):Void {}	
	// override function onMouseWheel (deltaX:Float, deltaY:Float, deltaMode:lime.ui.MouseWheelMode):Void {}
	// override function onMouseMoveRelative (x:Float, y:Float):Void {}

	// ----------------- TOUCH EVENTS ------------------------------
	// override function onTouchStart (touch:lime.ui.Touch):Void {}
	// override function onTouchMove (touch:lime.ui.Touch):Void	{}
	// override function onTouchEnd (touch:lime.ui.Touch):Void {}
	
	// ----------------- KEYBOARD EVENTS ---------------------------
	// override function onKeyDown (keyCode:lime.ui.KeyCode, modifier:lime.ui.KeyModifier):Void {}	
	// override function onKeyUp (keyCode:lime.ui.KeyCode, modifier:lime.ui.KeyModifier):Void {}

	// -------------- other WINDOWS EVENTS ----------------------------
	// override function onWindowResize (width:Int, height:Int):Void { trace("onWindowResize", width, height); }
	// override function onWindowLeave():Void { trace("onWindowLeave"); }
	// override function onWindowActivate():Void { trace("onWindowActivate"); }
	// override function onWindowClose():Void { trace("onWindowClose"); }
	// override function onWindowDeactivate():Void { trace("onWindowDeactivate"); }
	// override function onWindowDropFile(file:String):Void { trace("onWindowDropFile"); }
	// override function onWindowEnter():Void { trace("onWindowEnter"); }
	// override function onWindowExpose():Void { trace("onWindowExpose"); }
	// override function onWindowFocusIn():Void { trace("onWindowFocusIn"); }
	// override function onWindowFocusOut():Void { trace("onWindowFocusOut"); }
	// override function onWindowFullscreen():Void { trace("onWindowFullscreen"); }
	// override function onWindowMove(x:Float, y:Float):Void { trace("onWindowMove"); }
	// override function onWindowMinimize():Void { trace("onWindowMinimize"); }
	// override function onWindowRestore():Void { trace("onWindowRestore"); }
	
}
