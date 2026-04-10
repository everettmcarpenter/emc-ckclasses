// -------------------------------------------------------------------------------------------------
//
//      name: allpass.ck (class)
//      author: everett m. carpenter
//      desc: all pass filter taken from Ken Steiglitz book "A Digital Signal Processing Primer"
//
// -------------------------------------------------------------------------------------------------

public class Allpass extends Chugraph
{
    Delay forward;
    Delay back;
    Gain backScale;
    Gain inScale;

    inlet => inScale => outlet;
    inlet => forward => outlet;
    outlet => back => backScale => outlet;

    fun void Allpass(float a)
    {
        inScale.gain(a);
        backScale.gain(-1.0*a);
    }

    fun void a(float a)
    {
        inScale.gain(a);
        backScale.gain(-1.0*a);
    }

    fun float a()
    {
        return inScale.gain();
    }
}