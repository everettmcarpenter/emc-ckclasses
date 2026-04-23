/*
    A SITE specific (ha) grain swarm unit generator
    All that is different from this class and the inherited GrainSwarm is that 
    this class is capable of handling the SiteShape class as input.
    A SiteGrains class can take a SiteShape of any kind and will adjust it's 
    corresponding parameters given a map.
    SiteGrains uses an internal data structure to document the currently used
    data provided by the latest SiteShape input.
    This allows the SiteGrains class to compare it's current data structure with
    the new input, enabling interpolation, and change oriented parameter sequences.
*/

@import "SiteShape"

public class SiteGrains
{
    // internal reference
    SiteShape @ internalShape;
    Event change;

    // overloaded constructor
    fun void SiteGrains( SiteShape init )
    {
        // allocate new shape
        new SiteShape @=> internalShape;
        // copy input shape
        copy( init, internalShape );
    }

    // empty constructor
    fun void SiteGrains() { new SiteShape @=> internalShape; }

    // this is a concurrent process, it waits for the event 'change' to fire and then updates the underlying grain engine
    fun void updateGrain()
    {
        // this is where we need to map object parameters to grain parameters
    }

    // this is a static process, the user must call it to update the shape and thus the grains, it will not be updating regularly unless made to
    fun void updateShape( SiteShape input ) { copy( input, internalShape ); change.broadcast(); }

    // copy utility function
    fun void copy( SiteShape copy, SiteShape paste )
    {
        copy.color => paste.color;
        copy.type => paste.type;
        copy.pattern => paste.pattern;
        copy.exploded => paste.exploded;
        copy.moving => paste.moving;
        copy.state => paste.state;
    }
}
