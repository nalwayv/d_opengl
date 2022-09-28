/// Box mesh
module primitive.box;


import maths.vec3;


class BoxMesh
{
    private 
    {
        Vec3[] points;
        int[] indices;
    }

    this(float width, float height, float depth, int subWidth, int subHeight, int subDepth)
    {
        Vec3 size = Vec3(width, height, depth);

        float x;
        float y;
        float z;
        int subdivideW = subWidth;
        int subdivideH = subHeight;
        int subdivideD = subDepth;
        int previousRow;
        int currentRow;
        int point;

        Vec3 startPos = size.scaled(-0.5f);

        point = 0;

        // front  back
        y = startPos.y;
        currentRow = point;
        previousRow = 0;
        for (auto j = 0; j <= subdivideH + 1; j++) 
        {

            x = startPos.x;

            for (auto i = 0; i <= subdivideW + 1; i++) 
            {
                // front
                points ~= Vec3(x, -y, startPos.z);
                point++;

                // back
                points ~= Vec3(-x, -y, -startPos.z);
                point++;

                if (i > 0 && j > 0)
                {
                    int i2 = i * 2;

                    // front
                    indices ~= previousRow + i2 - 2;
                    indices ~= previousRow + i2;
                    indices ~= currentRow + i2 - 2;
                    indices ~= previousRow + i2;
                    indices ~= currentRow + i2;
                    indices ~= currentRow + i2 - 2;

                    // back
                    indices ~= previousRow + i2 - 1;
                    indices ~= previousRow + i2 + 1;
                    indices ~= currentRow + i2 - 1;
                    indices ~= previousRow + i2 + 1;
                    indices ~= currentRow + i2 + 1;
                    indices ~= currentRow + i2 - 1;
                }

                x += size.x / (subdivideW + 1.0f);
            }

            y += size.y / (subdivideH + 1.0f);
            previousRow = currentRow;
            currentRow = point;
        }

        // left  right
        y = startPos.y;
        currentRow = point;
        previousRow = 0;
        for (auto j = 0; j <= subdivideH + 1; j++) 
        {

            z = startPos.z;

            for (auto i = 0; i <= (subdivideD + 1); i++) 
            {
                // right
                points ~= Vec3(-startPos.x, -y, z);
                point++;

                // left
                points ~= Vec3(startPos.x, -y, -z);
                point++;

                if (i > 0 && j > 0) 
                {
                    int i2 = i * 2;

                    // right
                    indices ~= previousRow + i2 - 2;
                    indices ~= previousRow + i2;
                    indices ~= currentRow + i2 - 2;
                    indices ~= previousRow + i2;
                    indices ~= currentRow + i2;
                    indices ~= currentRow + i2 - 2;

                    // left
                    indices ~= previousRow + i2 - 1;
                    indices ~= previousRow + i2 + 1;
                    indices ~= currentRow + i2 - 1;
                    indices ~= previousRow + i2 + 1;
                    indices ~= currentRow + i2 + 1;
                    indices ~= currentRow + i2 - 1;
                }

                z += size.z / (subdivideD + 1.0f);
            }

            y += size.y / (subdivideH + 1.0f);
            previousRow = currentRow;
            currentRow = point;
        }

        // top  bottom
        z = startPos.z;
        currentRow = point;
        previousRow = 0;
        for (auto j = 0; j <= subdivideD + 1; j++) 
        {
            x = startPos.x;
            for (auto i = 0; i <= (subdivideW + 1); i++) 
            {
                // top
                points ~= Vec3(-x, -startPos.y, z);
                point++;

                // bottom
                points ~= Vec3(x, startPos.y, z);
                point++;

                if (i > 0 && j > 0) 
                {
                    int i2 = i * 2;

                    // top
                    indices ~= previousRow + i2 - 2;
                    indices ~= previousRow + i2;
                    indices ~= currentRow + i2 - 2;
                    indices ~= previousRow + i2;
                    indices ~= currentRow + i2;
                    indices ~= currentRow + i2 - 2;

                    // bottom
                    indices ~= previousRow + i2 - 1;
                    indices ~= previousRow + i2 + 1;
                    indices ~= currentRow + i2 - 1;
                    indices ~= previousRow + i2 + 1;
                    indices ~= currentRow + i2 + 1;
                    indices ~= currentRow + i2 - 1;
                }

                x += size.x / (subdivideW + 1.0f);
            }

            z += size.z / (subdivideD + 1.0f);
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