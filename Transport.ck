@import { "GrainSwarm", "GameTrak" }

public class Transport
{
    0.0025 => float sens;
    
    // given a loop setting, gametrak and collection of swarms, control the swarms via the trak
    fun void mainTransport(GameTrak t, GrainSwarm swarms[], int loop)
    {
        // step increments over a constant time
        float steps[2];

        // update step sizes
        while( true )
        {
            if( Math.fabs(t.lastAxis[1] - t.axis[1]) > 1.0) 0.125 => sens;
                else 0.0025 => sens;
            // x axis position for left and right controls
            t.axis[1] * sens => steps[0];
            t.axis[4] * sens => steps[1];
            for(int t; t < swarms.size(); t++) 
            {
                transport(swarms[t], steps[t%2], loop);
            }
            //<<< steps[0], steps[1] >>>;
            250::ms => now;
        }
    }

    // version that allows various loop settings
    fun void mainTransport(GameTrak t, GrainSwarm swarms[], int loops[])
    {
        // step increments over a constant time
        float steps[2];

        // update step sizes
        while( true )
        {
            // x axis position for left and right controls
            t.axis[1] * sens => steps[0];
            t.axis[4] * sens => steps[1];
            for(int t; t < swarms.size(); t++) 
            {
                transport(swarms[t], steps[t%2], loops[t%loops.size()]);
            }
            //<<< steps[0], steps[1] >>>;
            250::ms => now;
        }
    }

    fun void transport(GrainSwarm swarm, float step, int loop)
    {
        1 => int flipFlop;
        // move through the swarm's file
        if(loop == 2) 
        {
            // if we were going backwards flip around 
            if(swarm.position() <= 0.001) { 1 => flipFlop; }
            // else flip the other way
            else if(swarm.position() >= 1.0) { -1 => flipFlop; }
            // move
            swarm.position(Math.clampf(swarm.position() + (flipFlop * (step/2.0)), 0.0, 1.0));
        }

        // else if go back to the beginning
        else if(loop == 1)
        {
            swarm.position(0.0);
            swarm.position(swarm.position() + (flipFlop * (step/2.0)));
            swarm.position(Math.clampf(swarm.position() + (flipFlop * (step/2.0)), 0.0, 1.0));
        }
        
        else if(loop == 0)
        {
            swarm.position(swarm.position() + (flipFlop * (step/2.0)));
            swarm.position(Math.clampf(swarm.position() + (flipFlop * (step/2.0)), 0.0, 1.0));
        }
        
        <<< swarm.position() >>>;
    }
}