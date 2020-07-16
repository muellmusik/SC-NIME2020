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


(
Ndef(\choppy, {|pos = 0, rate = 1, loop = 0, t_trig = 0, pulseRate = 1|
	var pb;
	pb = PlayBuf.ar(b.numChannels, b, BufRateScale.kr(b)  * rate, t_trig, pos  * BufSampleRate.kr(b), loop); // pos in seconds
	pb * LFPulse.kr(pulseRate).range(0, 1);
}).play;
)

// Open Sound Control (OSC)

// we'll try an example with TouchOSC

thisProcess.openUDPPort(8000); // listen on port address for outgoing messages in TouchOSC (could be different)
OSCFunc.trace(hideStatusMsg:true); // post incoming OSC to see what you're getting., ignoring Server status messages
OSCFunc.trace(false); // turn posting off when you don't want the stream of messages

// you'll need to configure TouchOSC to be on the same network, and send to your computer's addr and port
// use page 1 of Mix 2 in the default TouchOSC layouts

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
}, "/1/rotary1"); // the OSC path we'll respond to is /1/rotary1

// this will respond to the red fader
OSCdef(\amp, {|msg|
	Ndef(\sin).set(\amp, msg[1]); // no need to scale as 0-1 is okay here
}, "/1/fader1"); // the OSC path we'll respond to is /1/fader1
)

//cleanup
(
Ndef(\sin).free;
OSCdef(\freq).free;
OSCdef(\amp).free;
)

// now let's use SC to mass construct and connect some controls

// use page 2 of Mix 2 (24 channel multislider) in the default TouchOSC layouts
// set the multifaders to a known state
(
n = NetAddr("169.254.221.230", 9000); // set to the receiving address and port on TouchOSC
// here we evaluate a function 24 times. The value passed as i is number of times evaluated, i.e. from 0-23
24.do({|i|
	// use i to construct the correct path for each fader, e.g. /2/multifader1/1, /2/multifader1/2 ...
	n.sendMsg("/2/multifader1/" ++ (i + 1), 0);
	n.sendMsg("/2/multifader2/" ++ (i + 1), 0);
})
)

(
Ndef(\sines, {
	var amps, wobbles, sines;
	// here we use Array:fill to construct controls for amps and 'wobbles'
	// this is the same as if we had written |amp1 = 0, amp2 = 0, ...| at the top of the func
	amps = Array.fill(24, {|i| ("amps" ++ i).asSymbol.kr(0)});
	wobbles = Array.fill(24, {|i| ("wobbles" ++ i).asSymbol.kr(0)});

	// now collect 24 SinOscs, each with the corresponding amp and wobble control
	sines = 24.collect({|i|
		var freq;
		freq = 200 * (i + 1); // harmonics of 200 Hz
		SinOsc.ar(freq + LFNoise0.kr(5, wobbles[i] * 0.01 * freq), mul: amps[i])
	});

	// spread them across the stereo field
	Splay.ar(sines.scramble) * 0.2;
}).play;

// here we make 48 OSCdefs to respond to the sliders, 24 each for amps and wobbles.
24.do({|i|
	OSCdef((\amp ++ i).asSymbol, {|msg|
		Ndef(\sines).set("amps" ++ i, msg[1]);
	}, "/2/multifader1/" ++ (i + 1)); // /2/multifader1/1, /2/multifader1/2 ...

	OSCdef((\wobbles ++ i).asSymbol, {|msg|
		Ndef(\sines).set("wobbles" ++ i, msg[1]);
	}, "/2/multifader2/" ++ (i + 1)); // /2/multifader2/1, /2/multifader2/2 ...
});
)
