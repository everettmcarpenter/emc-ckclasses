@import {"GrainSwarm", "GameTrak"}

public class Transport
{
    // given a loop setting, gametrak and collection of swarms, control the swarms via the trak
    fun void mainTransport(GameTrak t, GrainSwarm swarms[], int loop)
    {
        // step increments over a constant time
        float steps[2];

        for(int t; t < swarms.size(); t++)
        {
            // create a transport for each swarm
            spork ~ transport(swarms[t], steps[t%2],loop);
        }

        // update step sizes
        while(true)
        {
            // x axis position for left and right controls
            t.axis[1] => steps[0];
            t.axis[4] => steps[1];
            50::ms => now;
        }
    }

    // version that allows various loop settings
    fun void mainTransport(GameTrak t, GrainSwarm swarms[], int loops[])
    {
        // step increments over a constant time
        float steps[2];

        for(int t; t < swarms.size(); t++)
        {
            // create a transport for each swarm
            spork ~ transport(swarms[t], steps[t%2], loops[t%loops.size()]);
        }

        // update step sizes
        while(true)
        {
            // x axis position for left and right controls
            t.axis[1] => steps[0];
            t.axis[4] => steps[1];
            50::ms => now;
        }
    }

    fun void transport(GrainSwarm swarm, float step, int loop)
    {
        1 => int flipFlop;
        while(true)
        {
            // move through the swarm's file
            do 
            {
                swarm.position(swarm.position() + (flipFlop * (step/2.0)));
                250::ms => now;
            } until (swarm.position() >= 1.0 || swarm.position() <= 0.0);

            if(loop == 2) 
            {
                // if we were going backwards flip around 
                if(swarm.position() <= 0.001) { 1 => flipFlop; }
                // else flip the other way
                else if(swarm.position() >= 1.0) { -1 => flipFlop; }
            }

            // else if go back to the beginning
            else if(loop == 1)
            {
                swarm.position(0.0);
            }
        } 
    }
}