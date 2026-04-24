public class HidInformation
{
    float mouse[2];
    int lastASCII;
    int exit;

    fun float x() { return mouse[0]; }
    fun float y() { return mouse[1]; }

    fun int done() { return exit; }
    fun void done( int i ) { 1 => exit; }

    fun void x( float x ) { x => this.mouse[0]; }
    fun void y( float y ) { y => this.mouse[1]; }
}