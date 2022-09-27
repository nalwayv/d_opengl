/// Sphere primitive
module primitive.sphere;


import maths.utils;
import maths.vec3;


class SpherePrimitive
{
    private
    {
        Vec3[] points;
        int[] indices;
    }

    this(float radius, float height, int radialSegments, int rings)
    {
        int previousRow;
        int currentRow;
        int point = 0;
        float x;
        float y;
        float z;

        float scale = height;

        currentRow = 0;
        previousRow = 0;
        for(auto j = 0; j <= (rings + 1); j++)
        {
            float v = cast(float)j;
            float w;

            v /= (rings + 1.0f);
            w = sinF(PI * v);
            y = scale * cosF(PI * v);

            for(auto i = 0; i <= radialSegments; i++)
            {
                float u = cast(float)i;
                u /= radialSegments;

                x = sinF(u * TAU);
                z = cosF(u * TAU);

                points ~= Vec3(x * radius * w, y, -z * radius * w);
                point++;

                if(i > 0 && j > 0)
                {
                    indices ~= previousRow + i - 1;
                    indices ~= previousRow + i;
                    indices ~= currentRow + i - 1;

                    indices ~= previousRow + i;
                    indices ~= currentRow + i;
                    indices ~= currentRow + i - 1;
                }
            }

            previousRow = currentRow;
            currentRow = point;
        }
    }

    public Vec3[] getPoints()
    {
        return points;
    }

    public int[] getIndices()
    {
        return indices;
    }
}