
# Table of Contents

1.  [Examples using other Protocols](#org51c8873)
2.  [HID](#org5eebdbc)
3.  [Serial](#orgdcc4425)
    1.  [Arduino read example from the help file](#org78f4a41)



<a id="org51c8873"></a>

# Examples using other Protocols

Notional rather than working examples it&rsquo;s often more convenient to use higher level approaches (e.g. Modality) to these


<a id="org5eebdbc"></a>

# HID

<https://en.wikipedia.org/wiki/Human_interface_device>

    HID.postAvailable; // check which devices are attached
    ~myhid = HID.open( 1103, 53251 ); // open the Run 'N' Drive game controller, put your own values here.
    
    s.boot; // boot the server
    
    Ndef(\sinewave, { |freq=500, amp=0.1| SinOsc.ar( freq, 0, amp * 0.2 ) } );
    Ndef(\sinewave ).play;
    
    HIDdef.usage( \freq, { |value| Ndef( \sinewave ).set(\freq, value.linexp( 0, 1, 500, 5000 ) ); }, \X );
    HIDdef.usage( \amp, { |value| Ndef( \sinewave ).set(\amp, value ); }, \Y );


<a id="orgdcc4425"></a>

# Serial


<a id="org78f4a41"></a>

## Arduino read example from the help file

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

