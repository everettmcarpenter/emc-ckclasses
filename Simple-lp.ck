// ----------------------------------------------------------------------------------------------
//
//      name: simple-lp.ck (class)
//      author: everett m. carpenter
//      desc: the world's simplest low pass filter
//
// ----------------------------------------------------------------------------------------------

public class LP extends Chugraph
{
    Gain half(0.5);
    Delay shift(1::samp);

    inlet => shift => half;
    inlet => half => outlet;
}