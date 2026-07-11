@import "DJMidi.ck"
public class SOSCDJMidi
{
    // interpreters
    OscOut oout;
    MidiIn midin; MidiMsg midimsg;

    // destination host name
    "localhost" => string hostname;
    // destination port number
    6449 => int port;

    // aim the transmitter at destination
    oout.dest( hostname, port );

    // overloaded constructor
    fun void SOSCDJMidi( int device )
    {
        // storage
        device => this.midiDevice;
        // open the device
        if( !midin.open( this.midiDevice ) ) me.exit();
        // print out device that was opened
        <<< "MIDI device:", midin.num(), " -> ", midin.name() >>>;
        // aim the transmitter at destination
        oout.dest( hostname, port );
        // update
        spork ~ update();
    }

    // overloaded constructor
    fun void SOSCDJMidi( int device, string hostname, int port )
    {
        // hostname
        hostname => this.hostname;
        // port
        port => this.port;
        // storage
        device => this.midiDevice;
        // open the device
        if( !midin.open( this.midiDevice ) ) me.exit();
        // print out device that was opened
        <<< "MIDI device:", midin.num(), " -> ", midin.name() >>>;
        // aim the transmitter at destination
        oout.dest( hostname, port );
        // update
        spork ~ update();
    }

    fun void oscSend( string address, int cc, int value )
    {
        // start message
        oout.start( address );
        // add cc
        oout.add( cc );
        // add value
        oout.add( value );
        // send message
        oout.send();
    }

    // listen and update internal data
    fun void update()
    {
        while( true )
        {
            midin => now;
            while( midin.recv( midimsg ) )
            {
                // save cc and value
                midimsg.data2 => int cc;
                midimsg.data3 => int value;
                // send it out
                oscSend( "BCD/", cc, value );
            }
            1::ms => now; // buffer
        }
    }
}