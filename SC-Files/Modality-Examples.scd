MKtl.find; // look for available controllers

k = MKtl('midi_1_nanoko', "korg-nanokontrol2"); // make a new Modality controller object for the korg nanocontrol2

k.gui;

// see all output from the device
k.trace;
//turn it off
k.trace(false);

// see a hierarchical tree of all elements
k.postElements;

// post the output of the first knob
k.elAt(\kn, 0).action_({ |el| [el.name, el.value.postcs });

// clear the action
k.elAt(\kn, 0).resetAction;

Ndef(\harms, { Splay.ar(8.collect({|i| SinOsc.ar(200 * (i + 1), mul: ("amp-" ++ i).asSymbol.kr(0)) }).scramble) }).play;

k.elAt('sl').action = { |...args| Ndef(\harms).set("amp-" ++ args[0].index, args[0].value) };

// HID example using a Nintendo Switch Pro Controller
// first we'd need to pair this via bluetooth

// this is what the spec looks like for the device (ht Sam Pluta)
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
