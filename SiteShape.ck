public class SiteShape
{
    // enumerated colors
    // 0 = default, 1 = offwhite, 2 = grayish orange, 3 = pinkish grey, 4 = grey purple, 5 = yellow, 6 = green, 7 = pink, 8 = grey brown
    0 => int ncolor;
    // enumerated patterns
    // 0 = none, 1 = dots, 2 = vlines, 3 = hlines, 4 = slant, 5 = triangles, 6 = circles
    int npattern;
    // enumerated types
    // 0 = sun, 1 = stars, 2 = mountains, 3 = river, 4 = sky-others, 5 = tree
    int ntype;
    // has exploded
    int nexploded;
    // is moving
    int nmoving;
    // state (has something changed)
    int nstate;
    // lock
    int nlock;

    fun void color( int ncolor ) { if( !nlock ) ncolor => this.ncolor; }
    fun int color() { return ncolor; }

    fun void pattern( int npattern ) { if( !nlock ) npattern => this.npattern; }
    fun int pattern() { return npattern; }

    fun void type( int ntype ) { if( !nlock ) ntype => this.ntype; }
    fun int type() { return ntype; }

    fun void exploded( int nexploded ) { if( !nlock ) nexploded => this.nexploded; }
    fun int exploded() { return nexploded; }

    fun void moving( int nmoving ) { if( !nlock ) nmoving => this.nmoving; }
    fun int moving() { return nmoving; }

    fun void state( int nstate ) { if( !nlock ) nstate => this.nstate; }
    fun int state() { return nstate; }

    fun void lock() { 1 =>  this.nlock; }
    fun void unlock() { 0 => this.nlock; }
    fun int lockStatus() { return nlock; }

    fun void init()
    {
        color( 0 );
        pattern( 0 );
        type( 0 );
        exploded( 0 );
        moving( 0 );
        state( 0 );
        unlock();
    }

}