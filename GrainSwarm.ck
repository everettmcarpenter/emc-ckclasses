@import "Granulator"

public class GrainSwarm extends Chugraph
{
    Granulator grains[1] => Gain sum( 1.0 / ( 1.0 ) ) => Envelope env( 3::second ) => outlet;

    float cvolume; float cpitch; float cposition; float csize; string cfile; int cloop; float crandomsize; float crandompos; float crandompitch; int cspace; int onOff;

    fun void GrainSwarm( string file )
    {
        for(int i; i < grains.size(); i++)
        {
            grains[i].fileChange( file );
            grains[i].grainSize(50.0);
            1.0 => grains[i].rand_grain_duration;
            grains[i].play();
        }
        // begin
        env.value(1.0);
        1 => onOff;
    }

    fun void GrainSwarm()
    {
        for(int i; i < grains.size(); i++)
        {
            grains[i].grainSize(50.0);
            1.0 => grains[i].rand_grain_duration;
            grains[i].play();
            
        }
        // begin
        env.value(1.0);
        1 => onOff;
    }

    // random settings
    fun void randomInit()
    {
        Math.randomf() * 100.0 => this.grainSize;
        Math.randomf() => this.position;
        Math.randomf() * 50.0 => this.randomGrainSize;
    }

    fun void turnOn( int which )
    {
        if( which < grains.size() && which >= 0 ) { grains[which].on(); }
        else { <<< "GrainSwarm : ", " error when turning on grains." >>>; }
    }

    fun void turnOff( int which )
    {
        if( which < grains.size() && which >= 0 ) { grains[which].off(); }
        else { <<< "GrainSwarm : ", " error when turning off grains." >>>; }
    }

    fun void interpolation( int type )
    {
        for(int i; i < grains.size(); i++)
        {
            grains[i].interpolation(type);
        }
    }

    fun void loop( int onOff )
    {
        for(int i; i < grains.size(); i++)
        {
            grains[i].loop(onOff);
        }
        onOff => cloop;
    }

    fun void fileSwap(string nfile)
    {
        for(int i; i < grains.size(); i++)
        {
            grains[i].fileChange(nfile);
        }
        nfile => cfile;
    }

    fun string file() { return cfile; }

    fun void grainSize(float size)
    {
        size => csize;
        for(int i; i < grains.size(); i++)
        {
            grains[i].grainSize(csize);
        }
    }

    fun float grainSize() { return csize; }

    fun void randomGrainSize(float rand)
    {
        if(rand < 0) return;
        rand => crandomsize;
        for(int i; i < grains.size(); i++)
        {
            grains[i].randomGrainSize(rand);
        }
    }

    fun float randomGrainSize() { return crandomsize; }

    fun void pitch(float pitches[])
    {
        for(int i; i < grains.size(); i++)
        {
            grains[i].setPitch(pitches[i%pitches.size()]);
        }
    }

    fun void pitch(float npitch)
    {
        npitch => cpitch;
        for(int i; i < grains.size(); i++)
        {
            grains[i].setPitch(npitch);
        }
    }

    fun float pitch() { return cpitch; }

    fun void volume( float vol )
    {
        if( vol > 0.0 && vol < 1.0 )
        {
            for( int i; i < grains.size(); i++ )
            {
                grains[i].setVolume( vol );
            }
            vol => cvolume;
        }
    }

    fun void position(float nposition)
    {
        if(nposition < 0.0) 0.0 => nposition;
        nposition => cposition;
        for(int i; i < grains.size(); i++)
        {
            grains[i].setPosition(nposition);
        }
    }

    fun float position() { return cposition; }

    fun void randomPosition(float rand)
    {
        if(rand < 0) 0 => rand;
        rand => crandompos;
        for(int i; i < grains.size(); i++)
        {
            grains[i].randomPosition(rand);
        }
    }

    fun float randomPosition() { return crandompos; }

    fun void randomPitch( float amt )
    {
        amt => crandompitch;
        for(int i; i < grains.size(); i++)
        {
            grains[i].randomPitch(crandompitch);
        }
    }

    fun float randomPitch() { return crandompitch; }

    fun int fileSize() { return grains[0].samples; }

    fun void spacer(int space)
    {
        if(space) 1 => cspace;
        else 0 => cspace; 
        for(int i; i < grains.size(); i++)
        {
            cspace => grains[i].spacer;
        }
    }

    fun dur on()
    {
        for( int i; i < grains.size(); i++ ) grains[i].on();
        env.keyOn();
        1 => onOff;
        return env.duration();
    }

    fun dur off()
    {
        for( int i; i < grains.size(); i++ ) grains[i].off();
        env.keyOff();
        0 => onOff;
        return env.duration();
    }
}
