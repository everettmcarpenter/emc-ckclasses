public class SampleBank extends Chugraph
{
    SndBuf @ sample[];
    Envelope @ env[];
    1 => int count;

    fun void SampleBank(string paths[])
    {
        paths.size() => count;
        new SndBuf[count] @=> sample; // create n number of samplers
        new Envelope[count] @=> env;
        NRev rev(0.125);
        for(int i; i < count; i++)
        {
            sample[i].read(paths[i]); // read files
            sample[i].rate(0.0);
            // error check
            if(!sample[i].ready()) <<< "SampleBank error: Sampler ", i, " failed to open file path: ", paths[i] >>>;
            env[i].duration(10::ms);
            sample[i] => env[i] => outlet; // patch
        }
    }

    fun void SampleBank()
    {
        new SndBuf[count] @=> sample;
        new Envelope[count] @=> env;
    }

    fun void play(int n)
    {
        if(n >= 0 && n < count) { sample[n].play(1.0); env[n].keyOn(); sample[n].length() => now; env[n].keyOff(); sample[n].pos(0); }
        else <<< "SampleBank error: Sampler ", n, " does not exist" >>>;
    }

    fun void play(int n, float p)
    {
        if(n >= 0 && n < count) { sample[n].play(p); env[n].keyOn(); sample[n].length() => now; env[n].keyOff(); sample[n].pos(0); }
        else <<< "SampleBank error: Sampler ", n, " does not exist" >>>;
    }

    fun dur length(int n)
    {
        return sample[n].length();
    }
}