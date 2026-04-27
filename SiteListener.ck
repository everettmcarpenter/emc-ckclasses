@import "SiteShape.ck"
@import "GrainSwarm.ck"

public class SiteListener 
{
    // HID objects
    OscIn oin;
    OscMsg msg;

    // change
    Event change;
    0 => int go;

    // default port
    6449 => int port;

    // how many objects
    int objCount;
    int lastPersonChanged;
    SiteShape @ objects[];
    GrainSwarm @ swarms[];

    // subdivisions for patterns in beginning
    [ 0.2, 0.125, 0.25, 0.5, 1, 2, 2.5 ] @=> float subdivisions[];

    // normalized time stamps of audio segments
    [ 0.0, // offwhite
    0.1299, // orange
    0.2598, // grey 
    0.3350, // purple 
    0.4648, // yellow 
    0.5811, // green 
    0.7111, // pink
    0.8324  // brown
    ] @=> float timestamps[];

    // base grain size calculated by handhelds
    1.0 => float baseGrainSize;
    // max grain size
    1026.0 => float grainSizeModifier; 
    
    fun void SiteListener( int numObj, int nport )
    {
        nport => port;
        if( !oin.port(port) ) { <<< "SiteListener : Constructor failed, port could not be opened." >>>; me.exit(); }

        // listen
        oin.listenAll();

        // allocate and assign swarms and objects
        SiteShape obj[numObj];
        GrainSwarm swar[numObj];
        obj @=> objects;
        swar @=> swarms;
        numObj => objCount;

        // silent beginning
        for( int i; i < objCount; i++ ) { swar[i].off(); }

        // start listening
        spork ~ listenForSignal();
        spork ~ updateShape();
        spork ~ updateGrain();
    }

    fun void SiteListener( int numObj )
    {
        if( !oin.port(port) ) { <<< "SiteListener : Constructor failed, port could not be opened." >>>; me.exit(); }

        // listen 
        oin.listenAll();

        // allocate and assign swarms 9 shapes
        SiteShape obj[numObj];
        GrainSwarm swar[numObj];
        obj @=> objects;
        swar @=> swarms;
        numObj => objCount;

        // silent beginning
        for( int i; i < objCount; i++ ) { swar[i].off(); }

        // start listening
        spork ~ listenForSignal();
        spork ~ updateShape();
        spork ~ updateGrain();
    }

    // set all types
    fun void init( int types[] ) { for( int i; i < objects.size(); i++) types[i%types.size()] => objects[i].type; }

    // get last person
    fun int lastPerson() { return lastPersonChanged; }

    fun void handheldWidth( float left, float right ) { Math.fabs( left - right ) * grainSizeModifier + 1.0 => baseGrainSize; }

    // map difference in height to pitch
    fun void handheldHeight( float left, float right ) { Math.fabs( left - right ); }

    // source file
    fun void loadFile( string filename ) { for( int i; i < objCount; i++ ) swarms[i].fileSwap( filename ); }

    // print last person changed
    fun void print()
    {
        <<< "Last person changed: ", lastPersonChanged, 
                                     objects[lastPersonChanged].color, 
                                     objects[lastPersonChanged].type, 
                                     objects[lastPersonChanged].pattern, 
                                     objects[lastPersonChanged].exploded,
                                     objects[lastPersonChanged].moving,
                                     objects[lastPersonChanged].state >>>;
    }
    
    // listen for the signal
    fun void listenForSignal()
    {
        OscIn on;
        OscMsg omsg;

        on.port( port );
        on.addAddress( "/data/start" );

        on => now;
        while( on.recv( msg ) )
        {
            msg.getInt( 0 ) => go;
        }

        if( go ) me.exit();
    }

    // gametrack handling
    fun void updateShape()
    {
        <<< "waiting for signal" >>>;
        while( !go )
        {
            for( int i; i < 10; i++ )
            {
                cherr <= " . ";
                500::ms => now;
            }
            cherr <= IO.nl();
        }

        <<< "let us begin. . . " >>>;
        while( true )
        {
            // wait on osc as event
            oin => now;
            
            // messages received
            while( oin.recv( msg ) )
            {
                // check
                if( msg.address == "/Object/state" )
                {
                    msg.getInt( 0 ) - 1 => int who;
                    // if this is an object we know, update it
                    if( who < objCount ) 
                    {
                        msg.getInt( 1 ) => objects[who].type;
                        msg.getInt( 2 ) => objects[who].color;
                        msg.getInt( 3 ) => objects[who].pattern;
                        msg.getInt( 4 ) => objects[who].exploded;
                        msg.getInt( 5 ) => objects[who].moving;
                        // this was the last person changed
                        who => lastPersonChanged;
                        change.broadcast();
                    }
                }
            }
        }
    }

    // map parameters here
    fun void updateGrain()
    {
        while( true )
        {
            change => now;
            if( !swarms[lastPersonChanged].onOff ) { swarms[lastPersonChanged].on(); <<< lastPersonChanged, " on" >>>; }
            // pattern is a subdivision of the user's wingspan 
            swarms[lastPersonChanged].grainSize( subdivisions[objects[lastPersonChanged].pattern] * baseGrainSize );
            swarms[lastPersonChanged].position( timestamps[objects[lastPersonChanged - 1].color] );
        }
    }
}