public class DJMidi
{
    MidiIn midin; MidiMsg midimsg;
    int midiDevice; 
    int rotary[14]; int wheel[2]; int faders[5];

    fun void DJMidi() {};
    fun void DJMidi( int device )
    {
        // storage
        device => this->midiDevice;

        // open the device
        if( !min.open( device ) ) me.exit();

        // print out device that was opened
        <<< "MIDI device:", min.num(), " -> ", min.name() >>>;
    }

    fun void update()
    {
        while( true )
        {
            midin => now;
            while( midin.recv( midimsg ) )
            {
                
            }
        }
    }
}