@import "SiteShape.ck"

public class SiteListener 
{
    // HID objects
    OscIn oin;
    OscMsg msg;

    // change
    Event change;

    // default port
    6449 => int port;

    // how many objects
    int objCount;
    int lastPersonChanged;
    SiteShape @ objects[];
    
    fun void SiteListener( int numObj, int nport )
    {
        nport => port;
        if( !oin.port(port) ) { <<< "SiteListener : Constructor failed, port could not be opened." >>>; me.exit(); }

        // listen
        oin.listenAll();

        // 
        SiteShape obj[numObj];
        obj @=> objects;
        numObj => objCount;

        // start listening
        spork ~ update();
    }

    fun void SiteListener( int numObj )
    {
        if( !oin.port(port) ) { <<< "SiteListener : Constructor failed, port could not be opened." >>>; me.exit(); }

        // listen 
        oin.listenAll();

        // 
        SiteShape obj[numObj];
        obj @=> objects;
        numObj => objCount;

        // start listening
        spork ~ update();
    }

    fun int lastPerson() { return lastPersonChanged; }

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
                if( msg.address == "/Object/state" )
                {
                    msg.getInt( 0 ) => int who;

                    if( who < objCount ) 
                    {
                        msg.getInt( 1 ) => objects[who].type;
                        msg.getInt( 2 ) => objects[who].color;
                        msg.getInt( 3 ) => objects[who].pattern;
                        msg.getInt( 4 ) => objects[who].exploded;
                        msg.getInt( 5 ) => objects[who].moving;
                        
                        who => lastPersonChanged;
                        change.broadcast();
                    }

                }
            }
        }
    }
}