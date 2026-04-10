public class BodyTriangle
{
    // head, left and right hands
    float vertices[3][3];

    fun float[] normalize(float vector[])
    {
        if(vector.size() != 3) me.exit;
        // new vector
        float norm[3];
        // length of input vector
        float scale;
        // calculate length
        vector[0] * vector[0] +=> scale;
        vector[1] * vector[1] +=> scale;
        vector[2] * vector[2] +=> scale;
        // normalize
        Math.sqrt(scale) => scale;
        // check for null vector
        if(scale == 0.0) me.exit();
        // normalize (finally)
        vector[0] / scale => norm[0];
        vector[1] / scale => norm[1];
        vector[2] / scale => norm[2];
        // finish up
        return norm;
    }
}