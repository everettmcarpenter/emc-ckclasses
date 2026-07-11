@import "DJMidi.ck"
public class ROSCDJMidi extends DJMidi
{
    // interpreters
    OscIn oin; OscMsg omsg;
    DJMidi @ myMidi; // personal midi storage

    // destination host name
    "localhost" => string hostname;
    // destination port number
    6449 => int port;

    // aim the transmitter at destination
    oin.addAddress( "BCD/" );

    // overloaded constructor
    fun void ROSCDJMidi()
    {
        // print out device that was opened
        <<< "MIDI device:", midin.num(), " -> ", midin.name() >>>;
        // aim the transmitter at destination
        oin.port( port );
        // update
        spork ~ update();
    }

    // overloaded constructor
    fun void ROSCDJMidi( int port )
    {
        // port
        port => this.port;
        // print out device that was opened
        <<< "MIDI device:", midin.num(), " -> ", midin.name() >>>;
        // aim the transmitter at destination
        oin.port( port );
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
        // infinite event loop
        while( true )
        {
            // wait for event to arrive
            oin => now;

            // grab the next message from the queue. 
            while( oin.recv( omsg ) )
            {
                if( omsg.address == "BCD/" )
                {
                    if( myMidi ) myMidi.update( omsg.getInt( 0 ), omsg.getInt( 1 ) );
                }
            }
        }
    }
}