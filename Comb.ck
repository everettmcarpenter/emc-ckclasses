// -------------------------------------------------------------------------------------------------
//
//      name: comb.ck (class)
//      author: everett m. carpenter
//      desc: comb filter taken from Ken Steiglitz book "A Digital Signal Processing Primer"
//
// -------------------------------------------------------------------------------------------------

public class Comb extends Chugraph
{
    DelayL shift; // delay
    Gain r; // scale
    int blockSize; // how long is delay in samps
    float res; // current resonance value

    inlet => outlet;
    outlet => shift => r => outlet;

    fun void Comb(int n)
    {
        n => blockSize;
        shift.delay(n::samp);
        Math.pow(0.5,blockSize) => res;
        r.gain(res); // default r value is 0.5
    }

    fun void Comb(int n, float reso)
    {
        n => blockSize;
        shift.delay(n::samp);
        Math.pow(reso,blockSize) => res;
        r.gain(res); // default r value is 0.5
    }

    fun void reso(float reso)
    {
        Math.pow(reso,blockSize) => res;
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
        Math.pow(res,blockSize) => res;
    }

    fun int size()
    {
        return blockSize;
    }
}