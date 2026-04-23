@import "emc-ckclasses/PointSourceEncoder"
@import "emc-ckclasses/PointSourceDecoder"

public class SoundSphere 
{
    // this is the sphere
    GSphere mesh --> GG.scene();

    // ambisonics
    OrderGain3 summation;
    OrderGain2 resum( 1.0 );

    // camera
    GOrbitCamera cam;

    // number of parameters
    1 => int N;

    // mouse state
    int rightMouseState;

    // encoders
    PointSourceEncoder encoders[N];
    // decoders
    PointSourceDecoder decoders[N];
    // reencoders
    Encode2 reencoders[N];
    // pitch shifters
    PitShift shifters[N];
    // base speed
    float speed;

    // constructors
    fun void SoundSphere( int n )
    {
        // yup
        n => N;
        // setup the camera
        cameraSetup();
        // create the sphere
        createSpace();
        // create objects
        createEncoders( N );
        // start updating
        spork ~ update();
    }

    fun void SoundSphere()
    {
        // setup the camera
        cameraSetup();
        // create the sphere
        createSpace();
        // create objects
        createEncoders( N );
        // start updating
        spork ~ update();
    }

    // initialize orbit camera
    fun void cameraSetup()
    {
        cam --> GG.scene();
        GWindow.mouseMode( GWindow.MouseMode_Disabled );
        GG.scene().camera( cam );
        GG.scene().ambient( Color.DARKBROWN );
        GG.scene().backgroundColor( Color.DARKGREEN );
        GWindow.fullscreen();
    }

    // arrange sphere and setup
    fun void createSpace()
    {
        WireframeMaterial wire;
        wire.thickness( 2 );
        wire.topology( Material.Topology_LineList );
        mesh.pos( @( 0, 0, 0 ) );
        wire.color( @( 0, 0, 0 ) );
        mesh.sca( 2.0 );
        mesh.mat( wire );
    }

    // create objects to represent parameters
    fun void createEncoders( int num )
    {
        PointSourceEncoder encoders[num];
        encoders @=> this.encoders;

        for( PointSourceEncoder circle : this.encoders ) 
        {
            // Set random scale
            Math.random2f( 0.05, 0.3 ) => float scale;
            @(scale, scale, 0.) => circle.sca;
        }
    }

    // create a dot given an initial position
    fun void createEncoder( vec3 initPos )
    {
        PointSourceEncoder n;
        // append to internal array
        this.encoders << n;
        // we have an increased number of objects now
        encoders.size() => N;
        // attach it to the sphere
        encoders[N - 1] --> mesh;
        // place it somewhere
        n.pos( initPos );
        // size
        n.sca( 0.125 );
        // color of course
        n.color( @( Math.randomf(), Math.randomf(), Math.randomf() ) );
    }

    // create a dot given an initial position and viewing direction
    fun void createEncoder( vec3 initPos, vec3 lookAt )
    {
        PointSourceEncoder n;
        // append to internal array
        this.encoders << n;
        // we have an increased number of objects now
        encoders.size() => N;
        // attach it to the sphere
        encoders[N - 1] --> mesh;
        // place it somewhere
        n.pos( initPos );
        // lookAt this place
        n.lookAt( lookAt );
        // size
        n.sca( 0.125 );
        // color of course
        n.color( @( Math.randomf(), Math.randomf(), Math.randomf() ) );
    }

    // create a dot given an initial position
    fun void createDecoder( vec3 initPos )
    {
        PointSourceDecoder n;
        PitShift pit;
        Encode2 renc;
        summation => n.ambiDecoder => pit => renc => resum; // patch
        // append to internal array
        this.decoders << n;
        this.reencoders << renc;
        this.shifters << pit;
        // gain
        dac.gain( 1.0 / this.decoders.size() );
        // we have an increased number of objects now
        decoders.size() => N;
        //
        resum.gain( 1.0 / N );
        // attach it to the sphere
        decoders[N - 1] --> mesh;
        // place it somewhere
        n.pos( initPos );
        // size
        n.sca( 0.125 );
        // color of course
        n.color( @( Math.randomf(), Math.randomf(), Math.randomf() ) );
        // shift and mix
        pit.mix( 0.6 );
        pit.shift( Math.randomf() * -1.0 * n.color().x * 12.0 );
    }

    // create a dot given an initial position and viewing direction
    fun void createDecoder( vec3 initPos, vec3 lookAt )
    {
        PointSourceDecoder n;
        PitShift pit;
        Encode2 renc;
        summation => n.ambiDecoder => pit => renc => resum; // patch
        // append to internal array
        this.decoders << n;
        this.reencoders << renc;
        this.shifters << pit;
        // gain
        dac.gain( 1.0 / this.decoders.size() );
        // we have an increased number of objects now
        decoders.size() => N;
        //
        resum.gain( 1.0 / N );
        // attach it to the sphere
        decoders[N - 1] --> mesh;
        // place it somewhere
        n.pos( initPos );
        // look
        n.lookAt( lookAt );
        // size
        n.sca( 0.125 );
        // color of course
        n.color( @( Math.randomf(), Math.randomf(), Math.randomf() ) );
        // shift and mix
        pit.mix( 0.6 );
        pit.shift( Math.randomf() * -1.0 * n.color().x * 12.0 );
    }

    // calculate normalized vector given spherical coordinates
    fun vec3 spherical2cartesian( float azi, float elev ) 
    { 
        return @( Math.cos( azi * pi / 180.0 ) * Math.cos( elev * pi / 180.0 ), 
                  Math.sin( azi * pi / 180.0 ) * Math.cos( elev * pi / 180.0 ),
                  Math.sin( elev * pi / 180.0 ));
    }

    // overload for radial
    fun vec3 spherical2cartesian( float r, float azi, float elev ) 
    { 
        return @( r * Math.cos( azi * pi / 180.0 ) * Math.cos( elev * pi / 180.0 ), 
                  r * Math.sin( azi * pi / 180.0 ) * Math.cos( elev * pi / 180.0 ),
                  r * Math.sin( elev * pi / 180.0 ) );
    }

    // cartesian to spherical
    fun vec3 cartesian2spherical( vec3 cartesian )
    {
        return @( cartesian.magnitude(), 
                  Math.atan2( cartesian.y, cartesian.x ), 
                  Math.atan2( cartesian.z , Math.sqrt( ( cartesian.x * cartesian.x ) + ( cartesian.y * cartesian.y ) ) ) );
    }

    // return camera forward vec
    fun vec3 cameraForward() { return cam.forward(); }

    // return camera position vec
    fun vec3 cameraPosition() { return cam.pos(); }

    // return the summation
    fun OrderGain3 sum() { return summation; }

    // return the re-encoded output
    fun OrderGain2 bformat() { return resum; }

    // number of decoders
    fun int nDecoders() { return decoders.size(); }

    // stop
    fun void stop()
    {
        for( int i; i < decoders.size(); i++)
        {
            decoders[i].speed( 0.0, 0.0 );
        }
    }

    // set decoder position
    fun void decoderPosition( float azi, float zenith, int index )
    {
        if( index >= N || index < 0 )
        {
            <<< "error" >>>;
        }
        else
        {
            decoders[index].position( azi, zenith );
        }
    }

    // set decoder position
    fun void decoderSpeed( float azi, float zenith, int index )
    {
        if( index >= N || index < 0 )
        {
            <<< "error" >>>;
        }
        else
        {
            decoders[index].speed( azi, zenith );
        }
    }

    // rotate the sphere 
    fun void rotate( float xrota, float yrota )
    {
        GG.dt() * xrota => mesh.rotateY;  // rotate on X axis
        GG.dt() * yrota => mesh.rotateX;  // rotate on Y axis
    }

    // update regularly
    fun void update()
    {
        while( true ) 
        {
            // check mouse
            if( GWindow.mouseRight() != rightMouseState ) 
            { 
                GWindow.mouseRight() => rightMouseState; 
                if( rightMouseState ) { this.createDecoder( -0.5 * this.cameraForward(), this.cameraPosition() ); }
            }
            // make everyone look at you
            for( int i; i < decoders.size(); i++ )
            {
                // move
                decoders[i].position( decoders[i].ambiDecoder.azi() + decoders[i].dAzi, decoders[i].ambiDecoder.elev() + decoders[i].dElev );
                reencoders[i].pos( decoders[i].ambiDecoder.azi(), decoders[i].ambiDecoder.elev() );
                // look
                decoders[i].lookAt( mesh.pos() );
            }
            // move
            GG.nextFrame() => now;
        }
    }
}