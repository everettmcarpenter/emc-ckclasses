@import "string-model.ck"

public class PluckedString extends StringModel
{
    Impulse imp;
    //Noise nose => LPF noiselp(780, 0.0) => Gain lvl(0.25) => Envelope env(820::ms) => inSum;
    imp => inSum;

    fun void strike()
    {
        imp.next(1.0);
    }
/*
    fun void rub(dur length)
    {
        env.keyOn();
        length => now;
        env.keyOff();
        length => now;
    }
*/
}