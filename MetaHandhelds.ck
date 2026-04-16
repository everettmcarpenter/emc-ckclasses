public class MetaHandhelds
{
    // HID objects
    OscIn oin;
    OscMsg msg;
    // default port
    6449 => int port;

    // timestamps
    time leftLastTime;
    time leftCurrentTime;
    time rightLastTime;
    time rightCurrentTime;

    // foot pedal events
    Event pedal;
    Event movement;
    int pedalState;
    
    // previous axis data
    vec3 deltaLeftVelocity;
    vec3 deltaRightVelocity;

    // current axis data
    vec3 leftVelocity;
    vec3 rightVelocity;

    // z^-1 Velocity
    vec3 lastLeft;
    vec3 lastRight;
    
    fun void MetaHandhelds( int nport )
    {
        nport => port;
        if( !oin.port(port) ) { <<< "MetaHandelds : Constructor failed, port could not be opened." >>>; me.exit(); }
        oin.listenAll();

        // start listening
        spork ~ update();
    }

    fun void MetaHandhelds()
    {
        if( !oin.port(port) ) { <<< "MetaHandelds : Constructor failed, port could not be opened." >>>; me.exit(); }
        oin.listenAll();

        // start listening
        spork ~ update();
    }

    fun void print()
    {
        <<< leftVelocity, rightVelocity >>>;
    }
    
    // gametrack handling
    fun void update()
    {
        while( true )
        {
            // wait on HidIn as event
            oin => now;
            
            // messages received
            while( oin.recv( msg ) )
            {
                if( msg.numArgs() == 3 )
                {
                    
                    // joystick axis motion
                    if( msg.address == "/left/gyroscope" )
                    {
                        // check if fresh
                        if( now > leftCurrentTime )
                        {
                            // time stamp
                            leftCurrentTime => leftLastTime;
                            // set
                            now => leftCurrentTime;
                        }

                        // memory shift
                        leftVelocity => lastLeft;
                        rightVelocity => lastRight;

                        // listen to new value
                        msg.getFloat( 0 ) => leftVelocity.x;
                        msg.getFloat( 1 ) => leftVelocity.y;
                        msg.getFloat( 2 ) => leftVelocity.z;

                        // delta
                        (leftVelocity - lastLeft) => deltaLeftVelocity;
                        (rightVelocity - lastRight) => deltaRightVelocity;
                    }              
                    
                    else if( msg.address == "/right/gyroscope" )
                    {
                        // check if fresh
                        if( now > rightCurrentTime )
                        {
                            // time stamp
                            rightCurrentTime => rightLastTime;
                            // set
                            now => rightCurrentTime;
                        }

                        // memory shift
                        rightVelocity => lastRight;

                        // listen to new value
                        msg.getFloat( 0 ) => rightVelocity.x;
                        msg.getFloat( 1 ) => rightVelocity.y;
                        msg.getFloat( 2 ) => rightVelocity.z;

                        // delta
                        (rightVelocity - lastRight) => deltaRightVelocity;
                    }              
                }
            }
        }
    }

}