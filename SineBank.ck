public class SineBank extends Chugraph
{
    // a reference to the bank
    SinOsc @ bank[];
    Gain summate => BiQuad antiAlias => outlet; 
    // size
    16 => int msize;
    // sample rate
    second / samp => float srate;
    // nyquist
    srate / 2.0 => float nyquist;
    // magnitude targets
    float magnitudeTargets[ msize ];
    // frequency targets
    float frequencyTargets[ msize ];
    // phase targets
    float phaseTargets[ msize ];

    // constructors
    fun void SineBank()
    {
        configure();
    }

    fun void SineBank( int nsize )
    {
        // store new size
        nsize => msize;
        configure();
    }

    // general init 
    fun void configure()
    {
        // default size is 16
        new SinOsc[msize] @=> bank;
        // reset and resize targets
        frequencyTargets.reset(); magnitudeTargets.reset(); phaseTargets.reset();
        frequencyTargets.size( msize ); magnitudeTargets.size( msize ); phaseTargets.size( msize );
        // patch in
        bank => summate;
        summate.gain( ( 1.0 / (msize/256.0) ) );
        // config filter
        butterAntiAlias( antiAlias, nyquist, 0.707 );
        // set spec
        for( int i; i < msize; i++ ) { ( (i + 1) *  (nyquist / msize) ) => frequencyTargets[i]; 1.0 => magnitudeTargets[i]; }
        // start interpolation
        spork ~ interpolateFrequency();
        spork ~ interpolateMagnitude();
        spork ~ interpolatePhase();
    }

    // assumes values are for the 
    fun void spectrum( complex spect[] )
    {
        if(spect.size() == msize)
        {
            for( int i; i < msize; i++ )
            {
                // cast complex to polar
                spect[i] $ polar => polar pol;
                // set magnitude
                bank[i].gain( pol.mag );
                // set phase
                bank[i].phase( pol.phase / ( 2.0 * pi ) );
            }
        } 
        else cherr <= "Given array size does not match internal spectrum size." <= IO.nl();
    }

    // stretch spectrum
    fun void pitch( float factor )
    {
        for( int i; i < msize; i++ ) { frequencyTargets[i] * factor => frequencyTargets[i]; }
    }

    // interpolate magnitude
    fun void interpolateMagnitude()
    { 
        // the slew
        0.05 => float slew;
        // go
        while( true )
        {
            // slew
            for( int i; i < msize; i++ ) { ( (magnitudeTargets[i] - bank[i].gain()) * slew + bank[i].gain() ) => bank[i].gain; }
            // wait
            msize::samp => now;
        }
    }

    // interpolate volume
    fun void interpolateFrequency()
    { 
        // the slew
        0.01 => float slew;
        // go
        while( true )
        {
            // slew
            for( int i; i < msize; i++ ) { ( (frequencyTargets[i] - bank[i].freq()) * slew + bank[i].freq() ) => bank[i].freq; }
            // wait
            msize::samp => now;
        }
    }

    // interpolate phase
    fun void interpolatePhase()
    {
        // the slew
        0.05 => float slew;
        // go
        while( true )
        {
            // slew
            for( int i; i < msize; i++ ) { ( (phaseTargets[i] - bank[i].phase()) * slew + bank[i].phase() ) => bank[i].phase; }
            // wait
            msize::samp => now;
        }
    }

    fun int size() { return msize; }

    // configure biquad for anti aliasing
    fun void butterAntiAlias( BiQuad filt, float cutoff, float q )
    {
        2.0 * pi * cutoff / srate => float omega;
        Math.sin(omega) => float sn;
        Math.cos(omega) => float cs;
        sn / (2.0 * q) => float alpha;
        
        // coefficients
        (1.0 - cs) / 2.0 => float b0;
        1.0 - cs => float b1;
        (1.0 - cs) / 2.0 => float b2;
        1.0 + alpha => float a0;
        -2.0 * cs => float a1;
        1.0 - alpha => float a2;
        
        // norm 
        b0 / a0 => filt.b0;
        b1 / a0 => filt.b1;
        b2 / a0 => filt.b2;
        1.0 => filt.a0;
        a1 / a0 => filt.a1;
        a2 / a0 => filt.a2;
    }
}