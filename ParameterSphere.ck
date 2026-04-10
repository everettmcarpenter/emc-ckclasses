public class ParameterSphere 
{
    // this is the sphere
    GSphere mesh --> GG.scene();

    // camera
    GOrbitCamera cam;

    // number of parameters
    4 => int N;

    // markers that we've initialized the circles
    int inWorld[N];
    // positions of parameters
    vec3 positionTargets[N];

    // parameter circles
    GCircle circles[N];

    // constructors
    fun void ParameterSphere( int n )
    {
        // yup
        n => N;
        // setup the camera
        cameraSetup();
        // create the sphere
        createSpace();
        // create objects
        createObjects( N );
        // start updating
        spork ~ update();
    }

    fun void ParameterSphere()
    {
        // setup the camera
        cameraSetup();
        // create the sphere
        createSpace();
        // create objects
        createObjects( N );
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
        mesh.pos( @( 0,0,0 ) );
        wire.color( @( 0,0,0 ) );
        mesh.sca( 2.0 );
        mesh.mat( wire );
    }

    // create objects to represent parameters
    fun void createObjects( int num )
    {
        GCircle circles[num];
        circles @=> this.circles;

        vec3 positionTargets[num];
        positionTargets @=> this.positionTargets;

        for( GCircle circle : this.circles ) 
        {
            // Set random scale
            Math.random2f(0.05, 0.3) => float scale;
            @(scale, scale, 0.) => circle.sca;

            // Set random color
            circle.color( @( Math.randomf(), Math.randomf(), Math.randomf() ) );
        }
    }

    // update a specific circle's position
    fun void newPosition( int which, vec3 nposition )
    {
        if( which < N && which >= 0 ) 
        { 
            if( !inWorld[which] ) { circles[which] --> mesh; 1 => inWorld[which]; }
            nposition => positionTargets[which]; 
        }
        else { <<< "ParameterSphere : .newPosition() : Given index out of bounds. " >>>; }
    }

    // update a given circle with the center point of the camera
    fun void center( int which )
    {
        if( which < N && which >= 0 ) 
        { 
            if( !inWorld[which] ) { circles[which] --> mesh; 1 => inWorld[which]; }
            
            cam.posWorld() * mesh.rot() => positionTargets[which]; positionTargets[which].normalize();
        }
        else { <<< "ParameterSphere : .center() : Given index out of bounds. " >>>; }
    }

    fun void rotate( float xrota, float yrota )
    {
        GG.dt() * xrota => mesh.rotateY;  // rotate on Y axis
        GG.dt() * yrota => mesh.rotateX;  // rotate on Y axis
    }

    // update regularly
    fun void update()
    {
        0.125 => float slew;
        while( true ) 
        {
            for( int i; i < N; i++ )
            {
                ((positionTargets[i] - circles[i].pos()) * slew + circles[i].pos()) => circles[i].pos;
                circles[i].lookAt( @( 0.0, 0.0, 0.0 ) );
            }
            // move
            GG.nextFrame() => now;
        }
    }
}