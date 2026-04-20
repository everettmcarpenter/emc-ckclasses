public class DJMidi
{
    // interpreters
    MidiIn midin; MidiMsg midimsg;
    // device number
    int midiDevice; 
    // rotary controls // wheels (-1, 0, 1) // faders
    int rotary[18]; int wheel[2]; int faders[5];

    // constructor
    fun void DJMidi() 
    {
        // open the device
        if( !midin.open( midiDevice ) ) me.exit();
        // print out device that was opened
        <<< "MIDI device:", midin.num(), " -> ", midin.name() >>>;
    }

    // overloaded constructor
    fun void DJMidi( int device )
    {
        // storage
        device => this->midiDevice;
        // open the device
        if( !midin.open( midiDevice ) ) me.exit();
        // print out device that was opened
        <<< "MIDI device:", midin.num(), " -> ", midin.name() >>>;
    }

    // listen and update internal data
    fun void update()
    {
        while( true )
        {
            midin => now;
            while( midin.recv( midimsg ) )
            {
                if( midimsg.data2 >= 0 && midimsg.data2 < 2 ) midimsg.data3 => faders[midimsg.data2];
            }
        }
    }
}