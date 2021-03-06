// MIDI

MIDIIn.connectAll; // connect all available MIDI interfaces
MIDIFunc.trace; // post all incoming MIDI messages
MIDIFunc.trace(false); // turn it off later...

MIDIdef.cc(\test1, {arg ...args; args.postln}, 1); // match cc 1
MIDIdef.cc(\test2, {arg ...args; args.postln}, 1, 1); // match cc1, chan 1
MIDIdef.cc(\test3, {arg ...args; args.postln}, (1..10)); // match cc 1-10
MIDIdef.noteOn(\test4, {arg ...args; args.postln}); // match any noteOn

// Make a cc MIDIdef to do something, and then tell it to learn.
MIDIdef.cc(\fader1, {|val| Ndef(\choppy).set(\rate, 4 * (val/127))}).learn; // execute then move the fader

MIDIdef.cc(\fader2, {|val| Ndef(\choppy).set(\pos, val/127)}).learn; // execute then move the fader

MIDIdef.cc(\fader3, {|val| Ndef(\choppy).set(\pulseRate, 8 * (val/127))}).learn;


MIDIdef.cc(\button1, {|val| if(val > 0, {Ndef(\choppy).set(\t_trig, 1)})}).learn; // press a button

// load the example soundfile
p = Platform.resourceDir +/+ "sounds/a11wlk01.wav";
b = Buffer.read(s, p);

// an Ndef to play it
(
Ndef(\choppy, {|pos = 0, rate = 1, loop = 0, t_trig = 0, pulseRate = 1|
	var pb;
	pb = PlayBuf.ar(b.numChannels, b, BufRateScale.kr(b)  * rate, t_trig, pos  * BufSampleRate.kr(b), loop); // pos in seconds
	pb * LFPulse.kr(pulseRate).range(0, 1);
}).play;
)

// Open Sound Control (OSC)

// we'll try an example with a custom OSC interface

thisProcess.openUDPPort(9000); // listen on port address that you OSC controller sends messages *to*
OSCFunc.trace(hideStatusMsg:true); // post incoming OSC to see what you're getting., ignoring Server status messages
OSCFunc.trace(false); // turn posting off when you don't want the stream of messages

// you'll need to configure your OSC controller to be on the same network, and send to your computer's addr and port

// something to control
(
Ndef(\sin, {|freq = 440, amp = 0|
	SinOsc.ar(freq, mul:amp)
}).play;
)

// now a couple of OSCdefs
(
// this will respond to the top left red knob
OSCdef(\freq, {|msg|
	// msg consists of path plus any params, i.e. [oscpath, param1, param2, ...]
	Ndef(\sin).set(\freq, msg[1].linexp(0, 1, 20, 20000)); // scale input range of 0-1 to sensible
}, "/slider1"); // the OSC path we'll respond to

// this will respond to the red fader
OSCdef(\amp, {|msg|
	Ndef(\sin).set(\amp, msg[1]); // no need to scale as 0-1 is okay here
}, "/slider2"); // the OSC path we'll respond to
)

//cleanup
(
Ndef(\sin).free;
OSCdef(\freq).free;
OSCdef(\amp).free;
)
