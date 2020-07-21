////////////////////////////////////////////////////////////////////////////////////////////////////////
////// Introduction

1+1

(
11 + 11;
22 * 1.0;
"Hello World"
)

// will cause an error...
(
1 + 3
Hello World
)


"Hello" //this is a string.



////////////////////////////////////////////////////////////////////////////////////////////////////////
////// Basic Concepts Variables and Functions


(
var apple = "I am a red apple";
apple.postln;
)


(
var apple;
apple.postln
)


(
var apple = "big apple";
var appleColor = "red, and juicy";
("I am a " ++ apple ++ " " ++ appleColor)
)


"hello" ++ "world"

// will cause an error
(
var a = 1;
var b = 2;
var sum = a ++ b;
sum
)


(
var lorem = "lorem ipsum dolor sit amet",
ipsum = "consectetur adipisicing elit";
lorem ++ " " ++ ipsum
)


{ } //this is a function


(
y = {
	a = 10;//integer
	b = 20;
	a / b;
}
);
/* Function y will be used in the next function x */
(
x = {
	arg foo;
	var bar = 100;
	y.value / foo * bar; //see y func
};
);

x.value(0.5);


(
a = {
	arg freq = 0.5,
	amp = 0.35;
	//operations
	freq / amp;
}
)
a.value



////////////////////////////////////////////////////////////////////////////////////////////////////////
////// SynthDefs

s.boot; // boot the server

(
SynthDef(\mySynth, {|out = 0, amp = 0.6|
	var sig; sig = SinOsc.ar([120.0, 121.0]); // a two output sine oscillator synth.
	sig = sig / 2;
	Out.ar(out, sig * amp);
}).add;
)

Synth(\mySynth);

// Cmd-. to stop sound

Env.new([0, 1, 0.9, 0], [0.1, 0.5, 1],[-5, 0, -5]).plot;


(
SynthDef(\myEnvSynth, {|out = 0, amp = 0.3|
	var sig, env;
	env = Env.new([0, 1, 0.9, 0], [0.1, 0.5, 1],[-5, 0, -5]);
	sig = SinOsc.ar([120.0, 121.0]);
	sig = sig *  EnvGen.kr(env, doneAction: 2);
	Out.ar(out, sig * amp);
}).add;
)

Synth(\myEnvSynth);

(
x = Synth(\myEnvSynth); // x now is our Synth and can be used anywhere in our program as it is a global variable.
x.set(\amp, 0.1); // the set message requires the name of the parameter and a value.
)



////////////////////////////////////////////////////////////////////////////////////////////////////////
////// Patterns

1.next; // do this lots of times ;-)

// Patterns are a template which can be used to create any number of more interesting streams. They have names beginning with P.

a = Prand([1, 2, 3], inf).asStream; // an infinite stream of a random choice of 1, 2, or 3.
a.next; // do this many times

// Event patterns make streams of events. Events are parameter names and parameters (which can themselves be streams), and some info on what to do with those parameters. The default event type is called a 'note' and plays a synth.

s.boot; // this starts the Server app which processes audio

Pbind().play; // an endless string of middle Cs. Note that this assumes a lot of defaults. 1 second, default synthdef, middle C.

// More interestingly, we can use our own synthdefs, and/or specify interesting parameter streams

// Simple example
Pbind(\midinote, Pseq([60, 61, 62], 1), \dur, 0.2).play

// nested
(
Pbind(
	\degree, Pseq([Pseq([2, 1, 0], 2), Pseq([4, 3, 3, 2], 2)], 1), // |: Mi Re Do :||: So Fafa Mi :|
	\dur, Pseq([Pfin(6, 0.5), Pseq([0.5, 0.375, 0.125, 0.5], 2)]) // 0.5 secs 6 times, then |: 0.5 0.375 0.125 0.5 :|
).play;
)


(
// a SynthDef
SynthDef(\blippy, { | out = 0, freq = 440, amp = 0.1, nharms = 10, pan = 0, gate = 1 |
    var audio = Blip.ar(freq, nharms, amp);
    var env = Linen.kr(gate, doneAction: 2);
    OffsetOut.ar(out, Pan2.ar(audio, pan, env) );
}).add;
)

(
Pbind(
	\instrument, \blippy,
	\freq, Prand([1, 1.2, 2, 2.5, 3, 4], inf) * 200, // use freq instead of degree
	\nharms, Pseq([4, 10, 40], inf),
	\dur, 0.1
).play;
)


(
SynthDef(\pingy,
	{ arg out=0, freq=440, sustain=0.05, amp=0.1, pan;
		var env;
		env = EnvGen.kr(Env.perc(0.01, sustain), doneAction:2) * amp;
		Out.ar(out, Splay.ar(SinOsc.ar({freq * Rand(0.98, 1.02) } ! 20 , 0, env))) // make 20 detuned sines and pan them across the stereo field
}).add;

// and another using a simple physical model

SynthDef(\ring, { arg out=0, freq, decay = 1, amp = 1;
    var ring;
	ring = Ringz.ar(Decay.ar(Impulse.ar(0), 0.03, ClipNoise.ar(0.01)), freq, decay);
	DetectSilence.ar(ring, doneAction:2);
	Out.ar(out, Pan2.ar(ring * amp, Rand(-1, 1)));
}).add;
)

Pbind(\instrument, \pingy, \dur, 0.125, \degree, Pbrown(0, 8, 1, 20).round, \scale, Scale.melodicMinor).play; // 20 notes then finish

// calling play on a pattern returns an EventStreamPlayer
// we can stop or start this

~streamplayer = Pbind(\instrument, \pingy, \dur, 0.125, \degree, Pseq([0, 1, 2, 3, 4, 5, 6, 7], inf).stutter(2), \scale, Scale.melodicMinor).play; //infinite

~streamplayer.stop;

~streamplayer.resume;

~streamplayer.stop;

~streamplayer.start; // restart from beginning

~streamplayer.reset; // reset to start while playing

// add another layer
Pbind(\instrument, \ring, \dur, 0.25, \decay, 2, \octave, 4, \degree, Pbrown(0, 8, 1, 10).round, \scale, Scale.melodicMinor, \amp, 0.5).play;


//////////////// Pdefs

// A Pdef is a placeholder for a pattern
// you can start and stop it like an EventStreamPlayer

Pdef(\stutt, Pbind(\instrument, \pingy, \dur, 0.125, \degree, Pseq([0, 1, 2, 3, 4, 5, 6, 7], inf).stutter(2), \scale, Scale.melodicMinor)).play

Pdef(\stutt).pause

Pdef(\stutt).resume

// more excitingly, you can swap its source stream while it's playing!

Pdef(\stutt, Pbind(\instrument, \pingy, \dur, 0.125, \degree, Pseq([0, 1, 2, 3, 4, 5, 6, 7], inf).stutter(5), \scale, Scale.melodicMinor));

Pdef(\stutt, Pbind(\instrument, \pingy, \dur, 1/6, \octave, 6, \degree, Prand([0, 1, 2, 3, 4, 5, 6, 7], inf).stutter(6), \scale, Scale.melodicMinor));

Pdef(\klangs, Pbind(\instrument, \ring, \dur, 10, \degree, Pfunc({ [0, 1, 2, 3, 4, 5, 6, 7].scramble.keep(4) }).trace, \decay, 15, \octave, 4, \amp, 0.5)).play;

// a typical pattern would be to take a chunk of code and repeatedly modify and re-execute it
// try changing the number of stutters, dur, octave, degrees, etc. in the following

Pdef(\stutt, Pbind(\instrument, \pingy, \dur, 1/7, \octave, 6, \degree, Prand([0, 1, 2, 3, 4, 5, 6, 7], inf).stutter(6), \scale, Scale.melodicMinor));

// you can improvise very easily with this, and as always, record the output and use it in a DAW or elsewhere

// Pdefs also have a handy GUI which lets you start and stop, or even recreate the source code (in most cases)

PdefAllGui();



////////////////////////////////////////////////////////////////////////////////////////////////////////
////// Input Sources

//// MIDI

MIDIIn.connectAll;
MIDIFunc.trace;
MIDIFunc.trace(false);


MIDIdef.cc(\test1, {arg ...args; args.postln}, 1);
MIDIdef.cc(\test1, {arg ...args; args.postln}, 1);
MIDIdef.cc(\test2, {arg ...args; args.postln}, 1, 1);
MIDIdef.cc(\test3, {arg ...args; args.postln}, (1..10));
MIDIdef.noteOn(\test4, {arg ...args; args.postln});


MIDIdef.cc(\fader1, {|val| Ndef(\choppy).set(\rate, 4 * (val/127))}).learn;
MIDIdef.cc(\fader2, {|val| Ndef(\choppy).set(\pos, val/127)}).learn; //Execute then move the fader.
MIDIdef.cc(\fader3, {|val| Ndef(\choppy).set(\pulseRate, 8 * (val/127))}).learn;
MIDIdef.cc(\button1, {|val| if(val > 0, {Ndef(\choppy).set(\t_trig, 1)})}).learn; // press a button


// load the default soundfile
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


//// OSC

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


(
Ndef(\sin).free;
OSCdef(\freq).free;
OSCdef(\amp).free;
)



////////////////////////////////////////////////////////////////////////////////////////////////////////
////// Modality Examples

MKtl.find;

//make a new Modality controller object for the korg nanocontrol2
k = MKtl('midi_1_nanoko', "korg-nanokontrol2");

//make a gui for the device:
k.gui;


k.trace;
//turn it off
k.trace(false);


k.postElements;

// Post the output of the first knob
k.elAt(\kn, 0).action_({ |el| [el.name, el.value.postcs] });
	
	
k.elAt(\kn, 0).resetAction;

Ndef(\harms, { Splay.ar(8.collect({|i| SinOsc.ar(200 * (i + 1), mul: ("amp-" ++ i).asSymbol.kr(0)) }).scramble) }).play;

k.elAt('sl').action = { |...args| Ndef(\harms).set("amp-" ++ args[0].index, args[0].value) };
	
	
//// Nintendo Switch Pro Controller example

// make a Modality definition
~proswitch = (
name: \procontroller,
idInfo: "Pro Controller_Unknown",

protocol: 'hid',
deviceName: "Nintendo Pro Controller",
deviceType: 'joystick',
elementTypes: [\joystick, \button],
status: (
	linux: "unknown",
	osx: "Seems to Work - Sam Pluta 05/13/20",
	win: "unknown"
),

deviceInfo: (
	vendorURI: "https://www.nintendo.com/",
	manualURI: "",
	longName: "Nintendo Switch Pro",
	// description: "",
	// features: [],
	// notes: "",

	hasScribble: false
),

elementsDesc: (
	elements: [
		(
			key: \bt,
			shared: ('hidUsagePage': 9, 'elementType': 'button',
				'ioType': 'in', 'spec': \hidBut ),
			elements: [
				(key: '1', 'hidUsage': 1, 'style': (row: 2.5, column: 4)),
				(key: '2', 'hidUsage': 2, 'style': (row: 2, column: 4.8)),
				(key: '3', 'hidUsage': 3, 'style': (row: 2, column: 3.2)),
				(key: '4', 'hidUsage': 4, 'style': (row: 1.5, column: 4)),
				(key: '5', 'hidUsage': 5, 'style': (row: 1, column: 0)),
				(key: '6', 'hidUsage': 6, 'style': (row: 1, column: 6)),
				(key: '7', 'hidUsage': 7, 'style': (row: 0, column: 0)),
				(key: '8', 'hidUsage': 8, 'style': (row: 0, column: 6)),
				(key: '9', 'hidUsage': 9, 'style': (row: 0, column: 2)),
				(key: '10', 'hidUsage': 10, 'style': (row: 0, column: 2.8)),
				(key: '11', 'hidUsage': 11, 'style': (row: 3.2, column: 1.2)),
				(key: '12', 'hidUsage': 12, 'style': (row: 3.2, column: 5.2)),
				(key: '13', 'hidUsage': 13, 'style': (row: 0.8, column: 2.8)),
				(key: '14', 'hidUsage': 14, 'style': (row: 0.8, column: 2))
			],
		),
		(
			key: \joy,
			shared: ('hidUsagePage': 1, 'elementType': 'joyAxis', 'ioType': 'in', 'spec': \cent1),
			elements: [
				(key: \x1, 'hidUsage': 48, 'style': (row: 4, column: 0.2, height: 1, width: 2)),
				(key: \y1, 'hidUsage': 49, spec:[1.0,0.0], 'style': (row: 3, column: 2, height: 2, width: 1)),
				(key: \x2, 'hidUsage': 51, 'style': (row: 4, column: 4.2, height: 1, width: 2)),
				(key: \y2, 'hidUsage': 52, spec:[1.0,0.0], 'style': (row: 3, column: 6, height: 2, width: 1))
			]
		),
		(key: \arrows,
			elements: [(hidUsage: 57, 'hidUsagePage': 1, spec:[0.0,8/7,\lin,1/7], 'ioType': 'in', 'elementType': 'slider', 'style': (row: 5, column: 2.5, height: 1, width: 2))]
		)
	]
)
);~proswitch = (
name: \procontroller,
idInfo: "Pro Controller_Unknown",

protocol: 'hid',
deviceName: "Nintendo Pro Controller",
deviceType: 'joystick',
elementTypes: [\joystick, \button],
status: (
	linux: "unknown",
	osx: "Seems to Work - Sam Pluta 05/13/20",
	win: "unknown"
),

deviceInfo: (
	vendorURI: "https://www.nintendo.com/",
	manualURI: "",
	longName: "Nintendo Switch Pro",
	// description: "",
	// features: [],
	// notes: "",

	hasScribble: false
),

elementsDesc: (
	elements: [
		(
			key: \bt,
			shared: ('hidUsagePage': 9, 'elementType': 'button',
				'ioType': 'in', 'spec': \hidBut ),
			elements: [
				(key: '1', 'hidUsage': 1, 'style': (row: 2.5, column: 4)),
				(key: '2', 'hidUsage': 2, 'style': (row: 2, column: 4.8)),
				(key: '3', 'hidUsage': 3, 'style': (row: 2, column: 3.2)),
				(key: '4', 'hidUsage': 4, 'style': (row: 1.5, column: 4)),
				(key: '5', 'hidUsage': 5, 'style': (row: 1, column: 0)),
				(key: '6', 'hidUsage': 6, 'style': (row: 1, column: 6)),
				(key: '7', 'hidUsage': 7, 'style': (row: 0, column: 0)),
				(key: '8', 'hidUsage': 8, 'style': (row: 0, column: 6)),
				(key: '9', 'hidUsage': 9, 'style': (row: 0, column: 2)),
				(key: '10', 'hidUsage': 10, 'style': (row: 0, column: 2.8)),
				(key: '11', 'hidUsage': 11, 'style': (row: 3.2, column: 1.2)),
				(key: '12', 'hidUsage': 12, 'style': (row: 3.2, column: 5.2)),
				(key: '13', 'hidUsage': 13, 'style': (row: 0.8, column: 2.8)),
				(key: '14', 'hidUsage': 14, 'style': (row: 0.8, column: 2))
			],
		),
		(
			key: \joy,
			shared: ('hidUsagePage': 1, 'elementType': 'joyAxis', 'ioType': 'in', 'spec': \cent1),
			elements: [
				(key: \x1, 'hidUsage': 48, 'style': (row: 4, column: 0.2, height: 1, width: 2)),
				(key: \y1, 'hidUsage': 49, spec:[1.0,0.0], 'style': (row: 3, column: 2, height: 2, width: 1)),
				(key: \x2, 'hidUsage': 51, 'style': (row: 4, column: 4.2, height: 1, width: 2)),
				(key: \y2, 'hidUsage': 52, spec:[1.0,0.0], 'style': (row: 3, column: 6, height: 2, width: 1))
			]
		),
		(key: \arrows,
			elements: [(hidUsage: 57, 'hidUsagePage': 1, spec:[0.0,8/7,\lin,1/7], 'ioType': 'in', 'elementType': 'slider', 'style': (row: 5, column: 2.5, height: 1, width: 2))]
		)
	]
)
);
	
d = MKtlDesc.fromDict(~proswitch);

m = MKtl(\procontroller, d);

m.gui;

m.elementGroup;
m.postElements;

m.elAt(\joy, 0).action_({|el| el.value.postln })

x = { Splay.ar(RLPF.ar(Saw.ar(\freq.kr(440, 0.1), mul: 0.1), 1000))}.play;


m.elAt(\joy, 0).action_({ |el|
    x.set(\freq, el.value.linlin(0.13, 0.86, 300.0, 600));
});

m.resetActions;


x = {
	Splay.ar(
		RLPF.ar(Saw.ar(\freq.kr(440, 0.1), mul: 0.1),
			\ffreq.kr(1000, 0.1),
			\rq.kr(0.5, 0.1),
			\mul.kr(0.1, 0.1)
	)) * Env.asr.kr(gate: \env.kr(0))
}.play;

m.elAt(\joy, 1).action_({ |el|
    x.set(\freq, el.value.linlin(0.13, 0.86, 300.0, 600));
});

m.elAt(\joy, 0).action_({ |el|
    x.set(\mul, el.value.linlin(0.13, 0.86, 0, 0.6));
});

m.elAt(\joy, 3).action_({ |el|
    x.set(\ffreq, el.value.linlin(0.13, 0.86, 500, 2000));
});

m.elAt(\joy, 2).action_({ |el|
    x.set(\rq, el.value.linlin(0.13, 0.86, 0.01, 0.2));
});

m.elAt(\bt, 7).action_({ |el|
    x.set(\env, el.value.postln);
});




////////////////////////////////////////////////////////////////////////////////////////////////////////
////// Other Inputs (low level)

// HID
HID.postAvailable; // check which devices are attached
~myhid = HID.open( 1103, 53251 ); // open the Run 'N' Drive game controller, put your own values here.

s.boot; // boot the server

Ndef(\sinewave, { |freq=500, amp=0.1| SinOsc.ar( freq, 0, amp * 0.2 ) } );
Ndef(\sinewave ).play;

HIDdef.usage( \freq, { |value| Ndef( \sinewave ).set(\freq, value.linexp( 0, 1, 500, 5000 ) ); }, \X );
HIDdef.usage( \amp, { |value| Ndef( \sinewave ).set(\amp, value ); }, \Y );


// Serial Port

// Arduino read example from help file

(
p = SerialPort(
    "/dev/tty.usbserial-A800crTT",    // edit to match your port. SerialPort.listDevices
    baudrate: 9600,    // check that baudrate is the same as in arduino sketch
	crtscts: true);    // use hardware flow control
)

// read 10bit serial data sent from Arduino's Serial.println

(
r= Routine({
    var byte, str, res;
    99999.do{|i|
        if(p.read==10, {
            str = "";
            while({byte = p.read; byte !=13 }, {
                str= str++byte.asAscii;
            });
            res= str.asInteger;
            ("read value:"+res).postln;
        });
    };
}).play;
)
