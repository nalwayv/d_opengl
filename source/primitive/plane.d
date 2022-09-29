/// Plane mesh
module primitive.plane;


import maths.utils;
import maths.vec2;
import maths.vec3;


enum : int
{
    PLANE_ORIENTATION_X = 1 << 0,
    PLANE_ORIENTATION_Y = 1 << 1,
    PLANE_ORIENTATION_Z = 1 << 2
}


class PlaneMesh
{
    private
    {
        Vec3[] points;
        int[] indices;
    }

    this(float width, float height, int subWidth, int subHeight, int orientationEnum)
    {
        Vec2 size = Vec2(width, height);

        float x;
        float z;

        int prevoiusRow;
        int currentRow;
        int point;

        int subdivideW = subWidth;
        int subdivideD = subHeight;
        int orientation = orientationEnum;

        Vec2 startAt = size.scaled(-0.5f);
        Vec3 normal = Vec3(0,0,1);

        switch(orientation)
        {
            case PLANE_ORIENTATION_X:
                normal = Vec3(1,0,0);
                break;

            case PLANE_ORIENTATION_Y:
                normal = Vec3(0,1,0);
                break;

            case PLANE_ORIENTATION_Z:
                normal = Vec3(0,0,1);
                break;

            default:
                assert(0);
        }

    	z = startAt.y;
        currentRow = point;
        prevoiusRow = 0;
        for (auto j = 0; j <= (subdivideD + 1); j++)
        {
            x = startAt.x;

            for (auto i = 0; i <= (subdivideW + 1); i++)
            {

                switch(orientation)
                {
                    case PLANE_ORIENTATION_X:
                        points ~= Vec3(0.0f, z, x);
                        break;

                    case PLANE_ORIENTATION_Y:
                        points ~= Vec3(-x, 0.0f, z);
                        break;

                    case PLANE_ORIENTATION_Z:
                        points ~= Vec3(-x, -z, 0.0f);
                        break;

                    default:
                        assert(0);
                }
                point++;

                if (i > 0 && j > 0) 
                {
                    indices ~= prevoiusRow + i - 1;
                    indices ~= prevoiusRow + i;
                    indices ~= currentRow + i - 1;
                    indices ~= prevoiusRow + i;
                    indices ~= currentRow + i;
                    indices ~= currentRow + i - 1;
                }

                x += size.x / (cast(float)subdivideW + 1.0);
            }

            z += size.y / (cast(float)subdivideD + 1.0);
            prevoiusRow = currentRow;
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