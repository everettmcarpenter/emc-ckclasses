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
    1 => int start;
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
    [ 0.125, 0.05, 0.25, 0.5, 1, 2, 0.0125 ] @=> float subdivisions[];

    // seconds time stamps of audio segments
    [ 0.0,
      42.85,
      85.7,
      114.8,
      157.7,
      197.1,
      239.1,
      280.0,
      320.0, // sky crazy 1
      343.7, // sky crazy 2
      382.0 // bits
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
    }

    fun void SiteListener( int numObj )
    {
        if( !oin.port( port ) ) { <<< "SiteListener : Constructor failed, port could not be opened." >>>; me.exit(); }

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
            updateGrainSize( swarms[i], objects[i] );
        } 
    }

    // map difference and summation on hands' height to pitch
    fun void handheldHeight( float left, float right ) 
    { 
        float pitches[2]; 
        Std.scalef( Math.clampf( Math.fabs( left - right ), 0.0, 1.0 ), 0.0, 1.0, 0.8, 4.0 ) => pitches[0] => pitches[1]; 
        // Std.scalef( Math.clampf( Math.fabs( left + right ), 0.0, 1.0 ), 0.0, 1.0, 0.0, 4.0 ) => pitches[1];
        // <<< pitches[0], pitches[1] >>>;
        for( int i; i < swarms.size(); i++ ) { swarms[i].pitch( pitches[i%pitches.size()] ); }
    }

    // silence
    fun void silence()
    {
        for( 1 => int i; i < swarms.size(); i++ )
        {
            spork ~ swarms[i].off();
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
            // turn all swarms off
            swarms[i].off();
            swarms[i].position( 0.0 );
            swarms[i].pitch( 1.0 );

            // reset audio side objects
            objects[i].init();
        }
    }

    // derandomize size
    fun void derandomizeSize()
    {
        for( int i; i < swarms.size(); i++ )
        {
            swarms[i].randomGrainSize( 0.0 );
        }
    }

    // randomize size
    fun void randomizeSize()
    {
        for( int i; i < swarms.size(); i++ )
        {
            swarms[i].randomGrainSize( 3000.0 );
        }
    }

    // derandomize position 
    fun void derandomizePosition()
    {
        for( int i; i < swarms.size(); i++ )
        {
            swarms[i].randomPosition( 0.0 );
        }
    }

    // randomize position 
    fun void randomizePosition()
    {
        for( int i; i < swarms.size(); i++ )
        {
            swarms[i].randomPosition( 800.0 );
        }
    }

    // derandomize all
    fun void derandomizePitch()
    {
        for( int i; i < swarms.size(); i++ )
        {
            swarms[i].randomPitch( 0.0 );
        }
    } 

    // randomize all
    fun void randomizePitch()
    {
        for( int i; i < swarms.size(); i++ )
        {
            swarms[i].randomPitch( 4.0 );
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
            1::ms => now;
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
                        
                        <<< "updated,", who >>>;
                        if( objects[who].color() ) 
                        {
                            updateGrain( swarms[who], objects[who] );
                            <<< "updated grain ", who >>>;
                        }
                        // print
                        2 => int totalOn;
                        // dynamically set volume
                        for( int i; i < objects.size(); i++ )
                        {
                            if( objects[i].color() ) 1 +=> totalOn;
                        }
                        for( 0 => int i; i < swarms.size(); i++ )
                        {
                            swarms[i].volume( 1.0 / totalOn );
                            // <<< 1.0 / totalOn, totalOn >>>;
                        }
                        change.broadcast();
                    }
                }
                // set all grain sizes ( not working great right now )
                else if( msg.address == "/pattern/all" )
                {
                    msg.getInt( 0 ) => int newPattern;
                    for( int i; i < swarms.size(); i++ )
                    {
                        // pattern
                        objects[i].pattern( newPattern );
                        // update
                        if( objects[i].color() ) 
                        {
                            updateGrain( swarms[i], objects[i] );
                            <<< "updated grain ", i >>>;
                        }
                    }
                }
                // sky change
                else if( msg.address == "/stage/start" )
                {
                    for( int i; i < 20; i++ )
                    {
                        // random grains
                        // Math.random2( 0, objects.size() - 1 ) => int randomGuy;
                        // lock
                        objects[i].lock();
                        // print
                        <<< "Grain ", i, "locked." >>>;
                        // set grain size
                        swarms[i].grainSize( Math.random2f( 4023.0, 5000.0 ) );
                        // set pitch
                        swarms[i].pitch( 0.8 );
                        // set position
                        swarms[i].position( Math.random2f( file.normalizedPosition( timestamps[8] ), file.normalizedPosition( timestamps[8] + 10.0 ) ) );
                    }
                }
            }
            // buffer 
            10::ms => now;
        }
    }

    // map parameters here
    fun void updateGrain( GrainSwarm subject, SiteShape object )
    {
        if( !subject.onOff ) 
        { 
            subject.on(); <<< " on." >>>; 
        }
        // if exploded
        if( object.exploded() ) 
        {
            // set a grain size that is static
            subject.grainSize( Math.random2f( 2051.0, 2589.0 ) );
            // randomize position
            subject.randomPosition( 50.0 );
            // randomize grain length
            subject.randomGrainSize( 200.0 );
            // randomize pitch when you explode
            subject.position( file.normalizedPosition( Math.random2f( timestamps[10], timestamps[10] + 24.0 ) ) );
            <<< "exploded guy" >>>;
        }
        // if not exploded
        else
        {
            // pattern is a subdivision of the user's wingspan 
            subject.grainSize( subdivisions[object.pattern()] * baseGrainSize ); 
            // <<< "set grain ", subdivisions[object.pattern()] >>>;   
            // color == position
            subject.position( file.normalizedPosition( timestamps[object.color() - 1] ) );
        }
        // <<<  file.normalizedPosition( timestamps[objects[lastPersonChanged - 1].color] ) >>>;
    }

    // update only the grain size (used in the handheld spork)
    fun void updateGrainSize( GrainSwarm subject, SiteShape object )
    {
        if( object.exploded() ) 
        {
            // set a grain size that is static
            subject.grainSize( Math.random2f( 414.0, 489.0 ) );
        }
        // if not exploded
        else
        {
            // pattern is a subdivision of the user's wingspan 
            subject.grainSize( subdivisions[object.pattern()] * baseGrainSize ); 
        }
    }

}