public class FlightJoystick 
{
    // init device number & print state
    int device;
    int print;

    // HID input and HID message
    Hid hi;
    HidMsg msg;

    // button states
    int buttonStates[11];
    // joystick
    float axes[3]; // third is tiny scroll wheel
    float deltaAxes[3]; 


    fun void FlightJoystick()
    {
        // open joystick 0, exit on fail
        if( !hi.openJoystick( device ) ) me.exit();
        <<< "joystick '" + hi.name() + "' ready", "" >>>;
        spork ~ update();
    }

    fun void FlightJoystick( int dev )
    {
        dev => device;
        // open joystick 0, exit on fail
        if( !hi.openJoystick( device ) ) me.exit();
        <<< "joystick '" + hi.name() + "' ready", "" >>>;
        spork ~ update();
    }

    fun void FlightJoystick( int dev, int doprint )
    {
        dev => device;
        doprint => print;
        // open joystick 0, exit on fail
        if( !hi.openJoystick( device ) ) me.exit();
        <<< "joystick '" + hi.name() + "' ready", "" >>>;
        spork ~ update();
    }

    // left right
    fun float x() { return axes[0]; }
    // front back
    fun float y() { return axes[1]; }
    // up down (yes)
    fun float z() { return axes[2]; }

    // left right
    fun float dx() { return deltaAxes[0]; }
    // front back
    fun float dy() { return deltaAxes[1]; }
    // up down (yes)
    fun float dz() { return deltaAxes[2]; }

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
                    if(print) <<< "joystick axis", msg.which, ":", msg.axisPosition >>>;
                    axes[msg.which] - msg.axisPosition => deltaAxes[msg.which];
                    msg.axisPosition => axes[msg.which];
                }
                
                // joystick button down
                else if( msg.isButtonDown() )
                {
                    if(print) <<< "joystick button", msg.which, "down" >>>;
                    1 => buttonStates[msg.which];
                }
                
                // joystick button up
                else if( msg.isButtonUp() )
                {
                    if(print) <<< "joystick button", msg.which, "up" >>>;
                    0 => buttonStates[msg.which];
                }
                
                // joystick hat/POV switch/d-pad motion
                else if( msg.isHatMotion() )
                {
                    if(print) <<< "joystick hat", msg.which, ":", msg.idata >>>;
                }
            }
        }
    }
}