public class AudioFile
{
    string filepath;
    int sr;
    int length; // in samples
    float real_length;

    fun void loadFile( string file )
    {
        SndBuf reader; // you will read the file
        file => filepath; // document file path
        reader.read( filepath ); // read file
        if( reader.ready() == 0 ) <<< "buffer #", "encountered issues" >>>;
        else
        {
            reader.sampleRate() => sr; // document
            reader.samples() => length; // in samples
            (length / sr) => real_length; // calculate into seconds
        }
    }

    fun float normalizedPosition( float positionInMS )
    {
        // <<< (positionInMS / real_length) >>>;
        return (positionInMS / real_length);
    }
}