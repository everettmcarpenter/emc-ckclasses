@import "SiteShape.ck"
@import "GrainSwarm.ck"
@import "AudioFile.ck"

public class SiteListener 
{
    // HID objects
    OscIn oin;
    OscMsg msg;

    // change
    Event change;
    0 => int start;
    1 => int currentStage;

    // default port
    6449 => int port;

    // how many objects
    int objCount;
    int lastPersonChanged;
    SiteShape @ objects[];
    GrainSwarm @ swarms[];
    AudioFile file;

    // subdivisions for patterns in beginning
    [ 0.125, 0.00125, 0.25, 0.5, 1, 2, 0.0125 ] @=> float subdivisions[];

    // seconds time stamps of audio segments
    [ 0.0,
      42.85,
      85.7,
      114.8,
      157.7,
      197.1,
      239.1,
      280.0,
      316.0,
      343.7,
      382.0
    ] @=> float timestamps[];

    // base grain size calculated by handhelds
    1.0 => float baseGrainSize;
    //
    1.0 => float randomGrainSize;
    // max grain size
    850.0 => float grainSizeModifier; 
    
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
    fun void init( int types[] ) 
    { 
        for( int i; i < objects.size(); i++) 
        {
            types[i%types.size()] => objects[i].type; 
            swarms[i].pitch( subdivisions[Math.random2(0, subdivisions.size()-1 )] );
        }
    }

    // get last person
    fun int lastPerson() { return lastPersonChanged; }

    // map hprizontal difference to grain size 
    fun void handheldWidth( float left, float right ) 
    { 
        Math.fabs( left - right ) * grainSizeModifier + 1.0 => baseGrainSize;

        for( int i; i < swarms.size(); i++ )
        {
            swarms[i].grainSize( baseGrainSize );
        } 
    }

    // map difference and summation on hands' height to pitch
    fun void handheldHeight( float left, float right ) 
    { 
        float pitches[2]; 
        Std.scalef( Math.clampf( Math.fabs( left - right ), 0.0, 1.0 ), 0.0, 1.0, 0.0, 4.0 ) => pitches[0]; 
        Std.scalef( Math.clampf( Math.fabs( left + right ), 0.0, 1.0 ), 0.0, 1.0, 0.0, 4.0 ) => pitches[1];
        // <<< pitches[0], pitches[1] >>>;
        for( int i; i < swarms.size(); i++ ) { swarms[i].pitch( pitches[i%pitches.size()] ); }
    }

    // silence
    fun void silence()
    {
        for( int i; i < swarms.size(); i++ )
        {
            swarms[i].off();
        }
        swarms[0].off() => now;
        <<< "All swarms quiet" >>>;
    }

    // print swarm info
    fun void printSwarms()
    {
        for( int i; i < swarms.size(); i++ )
        {
            <<< "Swarm ", i, " pitch ", swarms[i].pitch() >>>;
            <<< "       ", "size ", swarms[i].grainSize() >>>;
            <<< "       ", "position ", swarms[i].position() >>>;
        }
    }

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
    
    // source file
    fun void loadFile( string filename ) { for( int i; i < objCount; i++ ) swarms[i].fileSwap( filename ); file.loadFile( filename ); }

    // reset everything
    fun void reset()
    {
        for( int i; i < swarms.size(); i++ )
        {
            swarms[i].off();
            swarms[i].position( 0.0 );
            swarms[i].pitch( 1.0 );
            swarms[i].grainSize( 58.0 );
        }
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
            msg.getInt( 0 ) => start;
        }

        if( start ) { me.exit(); }
    }

    // listen for the signal
    fun void listenForPrayer()
    {
        OscIn on;
        OscMsg omsg;

        on.port( port );
        on.addAddress( "/prayer/start" );

        on => now;
        while( on.recv( msg ) )
        {
            // reset
            reset();
        }
    }

    // gametrack handling
    fun void updateShape()
    {
        <<< "waiting for signal" >>>;
        while( !start )
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
                // set all grain sizes ( not working great right now )
                else if( msg.address == "/pattern/all" )
                {
                    msg.getInt( 0 ) => int newPattern;
                    for( int i; i < swarms.size(); i++ )
                    {
                        newPattern => objects[i].pattern;
                        swarms[i].grainSize( subdivisions[objects[lastPersonChanged].pattern] * baseGrainSize );
                    }
                }
            }
            // buffer 
            10::ms => now;
        }
    }

    // map parameters here
    fun void updateGrain()
    {
        while( !start )
        {
            <<< "I am waiting " >>>;
            500::ms => now;
        }
        while( true )
        {
            change => now;
            if( !swarms[lastPersonChanged].onOff ) { swarms[lastPersonChanged].on(); <<< lastPersonChanged, " on" >>>; }
            // if exploded
            if( objects[lastPersonChanged].exploded ) 
            {
                // set a grain size that is static
                swarms[lastPersonChanged].grainSize( Math.random2f( 14.0, 89.0 ) );
                // randomize pitch when you explode
                swarms[lastPersonChanged].randomPitch( objects[lastPersonChanged].exploded * Math.random2f( 1.0, 8.0 ) );
            }
            // if not exploded
            else 
            {
                // pattern is a subdivision of the user's wingspan 
                swarms[lastPersonChanged].grainSize( subdivisions[objects[lastPersonChanged].pattern] * baseGrainSize );    
                // color == position
                swarms[lastPersonChanged].position( file.normalizedPosition( timestamps[objects[lastPersonChanged - 1].color] ) );
            }
            // a buffer will save you some day
            50::ms => now;
            // <<<  file.normalizedPosition( timestamps[objects[lastPersonChanged - 1].color] ) >>>;
        }
    }
}