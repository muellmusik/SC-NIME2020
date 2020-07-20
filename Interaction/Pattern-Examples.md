
# Table of Contents

1.  [Controlling SynthDefs with Patterns](#orgec9bae0)
    1.  [Live coding techniques](#org0957372)


<a id="orgec9bae0"></a>

# Controlling SynthDefs with Patterns

SC has great support for patterns and streams. A stream is a stream of something. You can ask streams for their next value with the next method. All objects are trivially a stream of themselves

    1.next; // do this lots of times ;-)
    
    // Patterns are a template which can be used to create any number of more interesting streams. They have names beginning with P.
    
    a = Prand([1, 2, 3], inf).asStream; // an infinite stream of a random choice of 1, 2, or 3.
    a.next; // do this many times
    
    // Event patterns make streams of events. Events are parameter names and parameters (which can themselves be streams), and some info on what to do with those parameters. The default event type is called a 'note' and plays a synth.
    
    s.boot; // this starts the Server app which processes audio
    
    Pbind().play; // an endless string of middle Cs. Note that this assumes a lot of defaults. 1 second, default synthdef, middle C.
    
    // More interestingly, we can use our own synthdefs, and/or specify interesting parameter streams
    (
    Pbind(
    	\degree, Pseq([Pseq([2, 1, 0], 2), Pseq([4, 3, 3, 2], 2)], 1), // |: Mi Re Do :||: So Fafa Mi :|
    	\dur, Pseq([Pfin(6, 0.5), Pseq([0.5, 0.375, 0.125, 0.5], 2)]) // 0.5 secs 6 times, then |: 0.5 0.375 0.125 0.5 :|
    ).play;
    )

Notice that the above makes a bunch of assumptions. There&rsquo;s a default sound (actually a SynthDef called &rsquo;default&rsquo;), degree refers to a major scale, etc.

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


<a id="org0957372"></a>

## Live coding techniques

First a new SynthDef, using the perc style envelope

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

