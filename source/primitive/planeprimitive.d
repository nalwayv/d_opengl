module primitive.planeprimitive;


import maths.utils;
import maths.vec2;
import maths.vec3;


enum : int
{
    PLANE_ORIENTATION_X = 1 << 0,
    PLANE_ORIENTATION_Y = 1 << 1,
    PLANE_ORIENTATION_Z = 1 << 2
}


class PlanePrimitive
{
    private
    {
        Vec3[] points;
        int[] indices;
    }

    this(float width, float height, int subWidth, int subHeight, int orientationEnum)
    {
        Vec2 size = Vec2(width, height);
        Vec3 offset;

        float x;
        float z;

        int prevrow;
        int thisrow;
        int point;

        int subdivide_w = subWidth;
        int subdivide_d = subHeight;
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
        thisrow = point;
        prevrow = 0;
        for (auto j = 0; j <= (subdivide_d + 1); j++)
        {
            x = startAt.x;

            for (auto i = 0; i <= (subdivide_w + 1); i++)
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
                    indices ~= prevrow + i - 1;
                    indices ~= prevrow + i;
                    indices ~= thisrow + i - 1;
                    indices ~= prevrow + i;
                    indices ~= thisrow + i;
                    indices ~= thisrow + i - 1;
                }

                x += size.x / (subdivide_w + 1.0);
            }

            z += size.y / (subdivide_d + 1.0);
            prevrow = thisrow;
            thisrow = point;
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