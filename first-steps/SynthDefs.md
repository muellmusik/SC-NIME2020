
# Table of Contents

1.  [Envelopes and SynthDefs](#orgfe96301)
2.  [Discussion: anatomy of a SynthDef](#org19a96d5)

A SynthDef provides the interface to create sound synthesis modules in
SuperCollider. It also offers a set of interaction capabilities to alter the
musical parameters of the sound synthesis on a higher level. To create it we
type SynthDef, it has to have a unique name, once is created we need to load it
on the Server using the message &rsquo;.add&rsquo;. Now is a good time to boot the Server.

    s.boot; // boot the server. you can also do this from the Server menu in the IDE
    
    SynthDef(\mySynth, {|out = 0, amp = 0.6|
    	var sig; sig = SinOsc.ar([120.0, 121.0]); // a two output sine oscillator synth.
    	sig = sig / 2;
    	Out.ar(out, sig * amp);
    }).add;
    
    Synth(\mySynth);

Our SynthDef is a (two output) sine oscillator synthesizer with fixed values
(leftChannel:120.0, rightChannel:121.0), and it takes advantage of *multichannel
expansion* in SC which is implemented using an array. This is one of the
strenghts of SC as multiple ugens can be used to create complex sound engines.
To hear the SynthDef we need to use another class names Synth, which is used to
create an instance of the SynthDef which is loaded on the Server. You can also
pass default values to a SynthDef like &rsquo;amp&rsquo;. Sometimes we need to do more
manipulation on the signal i.e., add a filter in the signal chain but is better
to keep SynthDefs simple  and create other ones for extra manipulation.

To stop the synth use hold down Cmd(on Mac)/Ctrl(on Windows and Linux) and press . We call this pressing Cmd-period.


<a id="orgfe96301"></a>

# Envelopes and SynthDefs

To apply ADSR properties to a SynthDef we use an Env specification. To be able
to retrigger the envelope we use an EnvGen. Run this line below and
see how the envelope of the synthesizer will look like.

    Env.new([0, 1, 0.9, 0], [0.1, 0.5, 1],[-5, 0, -5]).plot;

Apply an Envelope on our previous SynthDef.

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

Assuming the previous SynthDef is loaded we can assign the Synth class to a variable like this below:

    x = Synth(\myEnvSynth); // x now is our Synth and can be used anywhere in our program as it is a global variable.
    x.set(\amp, 0.1); // the set message requires the name of the parameter and a value.


<a id="org19a96d5"></a>

# Discussion: anatomy of a SynthDef

A SynthDef is the sound engine of our program or instrument we are building. It
provides a set of interaction messages, such as .set .free and is a good idea to
be started through another class named Synth and using the name of the SynthDef.
Make sure to load SynthDefs using a method called .add; Each SynthDef can
contain different oscillators and/or implement different synthesis techniques
(e.g. granular).

