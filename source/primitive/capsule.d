/// Capsule mesh
module primitive.capsule;


import maths.utils;
import maths.vec3;


class CapsuleMesh
{
    private
    {
        Vec3[] points;
        int[] indices;
    }

    this(float radius, float height, int radialSegments, int rings)
    {
        float x;
        float y;
        float z;
        float u;
        float v;
        float w;

        int previousRow;
        int currentRow;
        int point;

        point = 0;

        // top
        currentRow = 0;
        previousRow = 0;
        for(auto j = 0; j <= (rings + 1); j++) 
        {
            v = cast(float)j;

            v /= (cast(float)rings + 1);
            w = sinF(0.5f * PI * v);
            y = radius * cosF(0.5f * PI * v);

            for (auto i = 0; i <= radialSegments; i++) 
            {
                u = cast(float)i;
                u /= cast(float)radialSegments;

                x = -sinF(u * TAU);
                z = cosF(u * TAU);

                Vec3 p = Vec3(x * radius * w, y, z * radius * w);
                points ~= p.added(Vec3(0.0f, 0.5f * height - radius, 0.0f));
                point++;

                if (i > 0 && j > 0) 
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

        // cylinder
        currentRow = point;
        previousRow = 0;
        for (auto j = 0; j <= (rings + 1); j++) 
        {
            v = cast(float)j;
            v /= (cast(float)rings + 1.0f);

            y = (height - 2.0f * radius) * v;
            y = (0.5f * height - radius) - y;

            for (auto i = 0; i <= radialSegments; i++) {
                u = cast(float)i;
                u /= cast(float)radialSegments;

                x = -sinF(u * TAU);
                z = cosF(u * TAU);

                points ~= Vec3(x * radius, y, z * radius);
                point++;

                if (i > 0 && j > 0) 
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

        // bottom
        currentRow = point;
        previousRow = 0;
        for (auto j = 0; j <= (rings + 1); j++) 
        {
            v = cast(float)j;
            v /= (cast(float)rings + 1);
            v += 1.0f;

            w = sinF(0.5f * PI * v);
            y = radius * cosF(0.5f * PI * v);

            for (auto i = 0; i <= radialSegments; i++) 
            {
                float u2 = cast(float)i;
                u2 /= cast(float)radialSegments;

                x = -sinF(u2 * TAU);
                z = cosF(u2 * TAU);

                Vec3 p = Vec3(x * radius * w, y, z * radius * w);
                points ~= p.added(Vec3(0.0f, -0.5f * height + radius, 0.0f));
                point++;

                if (i > 0 && j > 0) 
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