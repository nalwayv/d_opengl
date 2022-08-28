/// Color
module color;

import maths.vec3;

struct Color
{
    float r;
    float g;
    float b;

    Vec3 vec3()
    {
        Vec3 result;

        result.x = r;
        result.y = g;
        result.z = b;

        return result;
    }
}