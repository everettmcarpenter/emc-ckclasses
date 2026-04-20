public class PointSourceDecoder extends GCircle
{
    // ambisonic component
    MonoDecode3 ambiDecoder;
    // rate of change for azimuth and zenith
    float dAzi;
    float dElev;
    // rad2degree
    (180.0 / pi) => static float rad2degree;

    fun void PointSourceDecoder()
    {
        // randomize
        Math.randomf() * 5.0 => dAzi;
        Math.randomf() * 1.0 => dElev;
        // update method
        spork ~ update();
    }

    fun void update()
    {
        while( true )
        {
            // move
            this.position( ambiDecoder.azi() + dAzi, ambiDecoder.elev() + dElev );
            // move
            GG.nextFrame() => now;
        }
    }

    // position
    fun void position( vec3 spherical ) { ambiDecoder.pos( rad2degree * spherical.y, rad2degree * spherical.z ); -0.5 * spherical2cartesian( spherical.y, spherical.z ) => this.pos; }

    // position overload
    fun void position( float azimuth, float elevation ) { ambiDecoder.pos( azimuth, elevation ); -0.5 * spherical2cartesian( azimuth, elevation ) => this.pos; }

    // calculate normalized vector given spherical coordinates
    fun vec3 spherical2cartesian( float azi, float elev ) 
    { 
        return @( Math.cos( azi * pi / 180.0 ) * Math.cos( elev * pi / 180.0 ), 
                  Math.sin( azi * pi / 180.0 ) * Math.cos( elev * pi / 180.0 ),
                  Math.sin( elev * pi / 180.0 ));
    }

    // overload for radial
    fun vec3 spherical2cartesian( float r, float azi, float elev ) 
    { 
        return @( r * Math.cos( azi * pi / 180.0 ) * Math.cos( elev * pi / 180.0 ), 
                  r * Math.sin( azi * pi / 180.0 ) * Math.cos( elev * pi / 180.0 ),
                  r * Math.sin( elev * pi / 180.0 ));
    }

    // cartesian to spherical
    fun vec3 cartesian2spherical( vec3 cartesian )
    {
        return @( cartesian.magnitude(), 
                  Math.atan2( cartesian.y, cartesian.x ), 
                  Math.atan2( cartesian.z , Math.sqrt( ( cartesian.x * cartesian.x ) + ( cartesian.y * cartesian.y ) ) ) );
    }

    // return the object to patch in and out of
    fun MonoDecode3 decoder() { return ambiDecoder; }
}