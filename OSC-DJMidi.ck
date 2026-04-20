@import "DJMidi.ck"
public class OSCDJMidi extends DJMidi
{
    // interpreters
    OscOut oout;

    // destination host name
    "localhost" => string hostname;
    // destination port number
    6449 => int port;

    // aim the transmitter at destination
    oout.dest( hostname, port );

    // overloaded constructor
    fun void OSCDJMidi( int device )
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
    fun void OSCDJMidi( int device, string hostname, int port )
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

    fun void oscSend( string address, float value )
    {
        // start message
        oout.start( address );
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
            if( midimsg.data2 >= 0 && midimsg.data2 < 2 )
            {
                midimsg.data3 => faders[midimsg.data2];
                oscSend( "BCD/slider/" + midimsg.data2, faders[midimsg.data2] );
            }
        }
    }
}