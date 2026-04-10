public class GameTrak
{
    // HID objects
    Hid trak;
    HidMsg msg;

    fun void GameTrak(int device)
    {
        // open joystick 0, exit on fail
        if( !trak.openJoystick( device ) ) me.exit();

        // print
        <<< "joystick '" + trak.name() + "' ready", "" >>>;
        
        // start listening
        spork ~ update();
    }

    // timestamps
    time lastTime;
    time currTime;
    float DEADZONE;

    // foot pedal events
    Event pedal;
    Event movement;
    int pedalState;
    
    // previous axis data
    float lastAxis[6];
    vec3 leftVelocity;
    vec3 rightVelocity;

    // current axis data
    float axis[6];
    vec3 leftPosition;
    vec3 rightPosition;
    
    // gametrack handling
    fun void update()
    {
        while( true )
        {
            // wait on HidIn as event
            trak => now;
            movement.broadcast();
            
            // messages received
            while( trak.recv( msg ) )
            {
                // joystick axis motion
                if( msg.isAxisMotion() )
                {            
                    // check which
                    if( msg.which >= 0 && msg.which < 6 )
                    {
                        // check if fresh
                        if( now > currTime )
                        {
                            // time stamp
                            currTime => lastTime;
                            // set
                            now => currTime;
                        }
                        // save last
                        axis[msg.which] => lastAxis[msg.which];
                        // the z axes map to [0,1], others map to [-1,1]
                        if( msg.which != 2 && msg.which != 5 )
                        { msg.axisPosition => axis[msg.which]; }
                        else
                        {
                            1 - ((msg.axisPosition + 1) / 2) - DEADZONE => axis[msg.which];
                            if( axis[msg.which] < 0 ) 0 => axis[msg.which];
                        }
                        // set vectors
                        leftPosition.set(axis[0], axis[1], axis[2]);
                        rightPosition.set(axis[3], axis[4], axis[5]);

                        leftVelocity.set((axis[0] - lastAxis[0]), (axis[1] - lastAxis[1]), (axis[2] - lastAxis[2]));
                        rightVelocity.set((axis[3] - lastAxis[3]), (axis[4] - lastAxis[4]), (axis[5] - lastAxis[5]));
                    }
                }
                
                // joystick button down
                else if( msg.isButtonDown() )
                {
                    1 => pedalState;
                    pedal.broadcast();
                }
                
                // joystick button up
                else if( msg.isButtonUp() )
                {
                    0 => pedalState;
                    pedal.broadcast();
                }
            }
        }
    }

}