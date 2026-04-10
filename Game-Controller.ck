public class GameController
{
    // HID input and HID message
    Hid hi;
    HidMsg msg;
    float joysticks[4];
    float joystickDelta[4]; // change in joysticks
    time joystickTime[4]; // time stamps of joystick readings
    time joystickPastTime[4]; // time before this time
    int buttonState[9]; // A, B, X, Y, left bumper, right bumper, back button, start button
    int hatState[4]; // left, down, right, up
    
    1 => int print;

    // which joystick
    0 => int device;

    fun void GameController()
    {
        // open joystick 0, exit on fail
        if(!hi.openJoystick(device)) me.exit();
        <<< "joystick '" + hi.name() + "' ready", "" >>>;
        spork ~ update();
    }

    fun void GameController(int dev)
    {
        dev => device;
        // open joystick 0, exit on fail
        if(!hi.openJoystick(device )) me.exit();
        <<< "joystick '" + hi.name() + "' ready", "" >>>;
        spork ~ update();
    }

    fun void update()
    {
        // infinite event loop
        while( true )
        {
            // wait on HidIn as event
            hi => now;

            // messages received
            while( hi.recv( msg ) )
            {
                // joystick axis motion
                if( msg.isAxisMotion() )
                {
                    // delta
                    msg.axisPosition - joysticks[msg.which-1] => joystickDelta[msg.which-1];
                    // update
                    msg.axisPosition => joysticks[msg.which-1];
                    joystickTime[msg.which-1] => joystickPastTime[msg.which-1];
                    now => joystickTime[msg.which-1];
                    if(print) <<< "joystick axis", msg.which, ":", joysticks[msg.which-1], " delta: ", joystickDelta[msg.which-1],
                                  " time reported: ", joystickTime[msg.which-1], " delta time: ", joystickTime[msg.which-1], joystickPastTime[msg.which-1] >>>;
                }
                
                // joystick button down
                else if( msg.isButtonDown() )
                {
                    1 => buttonState[msg.which-1];
                    if(print) <<< "joystick button", msg.which, buttonState[msg.which-1] >>>;
                }
                
                // joystick button up
                else if( msg.isButtonUp() )
                {
                    0 => buttonState[msg.which-1];
                    if(print) <<< "joystick button", msg.which, buttonState[msg.which-1] >>>;
                }
                
                // joystick hat/POV switch/d-pad motion
                else if( msg.isHatMotion() )
                {
                    if(!msg.idata) {hatState.zero(); cherr <= "d-pad left: " <= hatState[0] <= IO.nl() 
                                                           <= "d-pad down: " <= hatState[1] <= IO.nl() 
                                                           <= "d-pad right: " <= hatState[2] <= IO.nl() 
                                                           <= "d-pad up: " <= hatState[3] <= IO.nl();}
                    else if(msg.idata == 8) {1 => hatState[0]; <<< "d-pad left: ", hatState[0] >>>;}
                    else if(msg.idata == 4) {1 => hatState[1]; <<< "d-pad down: ", hatState[1] >>>;}
                    else if(msg.idata == 2) {1 => hatState[2]; <<< "d-pad right: ", hatState[2] >>>;}
                    else if(msg.idata == 1) {1 => hatState[3]; <<< "d-pad up: ", hatState[3] >>>;}
                }
            }
        }
    }
}