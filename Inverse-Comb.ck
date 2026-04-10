// -------------------------------------------------------------------------------------------------
//
//      name: inverse-comb.ck (class)
//      author: everett m. carpenter
//      desc: inverse comb filter taken from Ken Steiglitz book "A Digital Signal Processing Primer"
//
// -------------------------------------------------------------------------------------------------

public class InvComb extends Chugraph
{
    DelayL shift; // delay
    Gain r; // scale
    int blockSize; // how long is delay in samps
    float res; // current resonance value

    inlet => outlet;
    inlet => shift => r => outlet;

    fun void InvComb(int n)
    {
        n => blockSize;
        shift.delay(n::samp);
        -1*Math.pow(0.5,blockSize) => res;
        r.gain(res); // default r value is 0.5
    }

    fun void InvComb(int n, float reso)
    {
        n => blockSize;
        shift.delay(n::samp);
        -1*Math.pow(reso,blockSize) => res;
        r.gain(res); // default r value is 0.5
    }

    fun void reso(float reso)
    {
        -1*Math.pow(res,blockSize) => res;
        r.gain(res); // default r value is 0.5
    }

    fun float reso()
    {
        return res;
    }

    fun void size(int n)
    {
        n => blockSize;
        shift.delay(blockSize::samp);
        -1*Math.pow(res,blockSize) => res;
    }

    fun int size()
    {
        return blockSize;
    }
}