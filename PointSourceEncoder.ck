public class PointSourceEncoder extends GCircle
{
    // ambisonic component
    Encode3 ambiEncoder( 0.0, 0.0 );
    (180.0 / pi) => static float rad2degree;

    // position
    fun void position( vec3 spherical ) { ambiEncoder.pos( rad2degree * spherical.y, rad2degree * spherical.z ); -0.5 * spherical2cartesian( spherical.y, spherical.z ) => this.pos; }

    // position overload
    fun void position( float azimuth, float elevation ) { ambiEncoder.pos( azimuth, elevation ); -0.5 * spherical2cartesian( azimuth, elevation ) => this.pos; }

    // calculate normalized vector given spherical coordinates
    fun vec3 spherical2cartesian( float azi, float elev ) 
    { 
        return @( Math.cos( azi * pi / 180.0 ) * Math.cos( elev * pi / 180.0 ), 
                  Math.sin( azi * pi / 180.0 ) * Math.cos( elev * pi / 180.0 ),
                  Math.sin( elev * pi / 180.0 ) );
    }

    // overload for radial
    fun vec3 spherical2cartesian( float r, float azi, float elev ) 
    { 
        return @( r * Math.cos( azi * pi / 180.0 ) * Math.cos( elev * pi / 180.0 ), 
                  r * Math.sin( azi * pi / 180.0 ) * Math.cos( elev * pi / 180.0 ),
                  r * Math.sin( elev * pi / 180.0 ) );
    }

    // cartesian to spherical
    fun vec3 cartesian2spherical( vec3 cartesian )
    {
        return @( cartesian.magnitude(), 
                  Math.atan2( cartesian.y, cartesian.x ), 
                  Math.atan2( cartesian.z , Math.sqrt( ( cartesian.x * cartesian.x ) + ( cartesian.y * cartesian.y ) ) ) );
    }

    // return the object to patch in and out of
    fun Encode3 encoder() { return ambiEncoder; }
}