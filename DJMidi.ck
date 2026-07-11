// a utility data class for the Behringer BCD2000
public class DJMidi 
{
    // rotary controls // wheels (-1, 0, 1) // faders
    int deckA[4]; // deck A low, mid, high and gain CC's (3-6)
    int deckB[4]; // deck B low, mid, high and gain CC's (7-10)
    int fx[4]; // A, B, C, D cc's (13-16)
    int output; // output knob CC 17
    int deckBScratch; // -1, 0, 1 CC 18
    int deckAScratch; // -1, 0, 1 CC 19
    int deckAPitch; // CC 11
    int deckAVolume; // CC 0
    int crossFade; // CC 1
    int deckBPitch; // CC 12
    int deckBVolume; // CC 2

    // last cc changed
    int lastCC;

    // listen and update internal data
    fun void update( int value, int cc )
    {
        // deck A volume ?
        if( cc == 0 ) value => deckAVolume;
        // crossfade ?
        else if( cc == 1 ) value => crossFade;
        // deck B volume?
        else if( cc == 2 ) value => deckBVolume;
        // deck A ?
        else if( cc >= 3 && cc <= 6 ) value => deckA[cc - 3]; 
        // deck B ?
        else if( cc >= 7 && cc <= 10 ) value => deckB[cc - 7];
        // deck A pitch ?
        else if( cc == 11 ) value => deckAPitch;
        // deck B pitch ?
        else if( cc == 12 ) value => deckBPitch;
        // fx ?
        else if( cc >= 13 && cc <= 16 ) value => fx[cc - 13];
        // output knob ?
        else if( cc == 17 ) value => output;
        // scratch ?
        else if( cc == 18 ) value => deckBScratch;
        // scratch A ?
        else if( cc == 19 ) value => deckAScratch;
        // the last cc 
        cc => this.lastCC;
    }
}