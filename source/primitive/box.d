module primitive.box;


import maths.vec3;


struct Box
{
    Vec3 size;
    int subWidth;
    int subHeight;
    int subDepth;

    void createMesh(ref Vec3[] points, ref int[] indices)
    {
        float x;
        float y;
        float z;

        Vec3 startAt = size.scaled(0.5f);

        int pt = 0;

        // front back
        y = startAt.y;
        auto currentRow = pt;
        auto prevRow = 0;

        for(auto j = 0; j <= subHeight + 1; j++)
        {
            x = startAt.x;

            for(auto i = 0; i <= subWidth + 1; i++)
            {
                // f
                points ~= Vec3(x, -y, -startAt.z);
                pt++;
                // b
                points ~= Vec3(-x, -y, startAt.z);
                pt++;

                if(i > 0 && j > 0)
                {
                    auto i2 = i * 2;
                    // f
                    indices ~= prevRow    + i2 - 2;
                    indices ~= prevRow    + i2;
                    indices ~= currentRow + i2 - 2;
                    indices ~= prevRow    + i2;
                    indices ~= currentRow + i2;
                    indices ~= currentRow + i2 - 2;
                    // b
                    indices ~= prevRow    + i2 - 1;
                    indices ~= prevRow    + i2 + 1;
                    indices ~= currentRow + i2 - 1;
                    indices ~= prevRow    + i2 + 1;
                    indices ~= currentRow + i2 + 1;
                    indices ~= currentRow + i2 - 1;
                }

                x += size.x / (subWidth + 1);
            }

            y += size.y / (subHeight + 1);
            prevRow = currentRow;
            currentRow = pt;

        }

        // right left
        y = startAt.y;
        currentRow = pt;
        prevRow = 0;

        for(auto j = 0; j <= subHeight + 1; j++)
        {
            z = startAt.z;

            for(auto i = 0; i < subWidth + 1; i++)
            {
                // r
                points ~= Vec3(-startAt.x, -y, -z);
                pt++;
                // l
                points ~= Vec3(startAt.x, -y, z);
                pt++;

                if(i > 0 && j > 0)
                {
                    auto i2 = i * 2;
                    // right
                    indices ~= prevRow    + i2 - 2;
                    indices ~= prevRow    + i2;
                    indices ~= currentRow + i2 - 2;
                    indices ~= prevRow    + i2;
                    indices ~= currentRow + i2;
                    indices ~= currentRow + i2 - 2;
                    // left
                    indices ~= prevRow    + i2 - 1;
                    indices ~= prevRow    + i2 + 1;
                    indices ~= currentRow + i2 - 1;
                    indices ~= prevRow    + i2 + 1;
                    indices ~= currentRow + i2 + 1;
                    indices ~= currentRow + i2 - 1; 
                }

                z += size.z / (subDepth + 1);
            }

            y += size.y / (subHeight + 1);
            prevRow = currentRow;
            currentRow = pt;

        }

        // top bottom
        z = startAt.z;
        currentRow = pt;
        prevRow = 0;

        for(auto j = 0; j <= subDepth + 1; j++)
        {
            x = startAt.x;

            for(auto i = 0; i < subWidth + 1; i++)
            {
                // t
                points ~= Vec3(-x, -startAt.y, -z);
                pt++;
                // b
                points ~= Vec3(x, startAt.y, -z);
                pt++;

		        if (i > 0 && j > 0) 
                {
                    int i2 = i * 2;

                    // top
                    indices ~= prevRow    + i2 - 2;
                    indices ~= prevRow    + i2;
                    indices ~= currentRow + i2 - 2;
                    indices ~= prevRow    + i2;
                    indices ~= currentRow + i2;
                    indices ~= currentRow + i2 - 2;
                    // bottom
                    indices ~= prevRow    + i2 - 1;
                    indices ~= prevRow    + i2 + 1;
                    indices ~= currentRow + i2 - 1;
                    indices ~= prevRow    + i2 + 1;
                    indices ~= currentRow + i2 + 1;
                    indices ~= currentRow + i2 - 1;
			    }

                x += size.x / (subWidth + 1);
            }

            z += size.z / (subDepth + 1);
            prevRow = currentRow;
            currentRow = pt;
        }
    }
}