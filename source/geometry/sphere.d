/// Sphere
module geometry.sphere;

import std.format;
import utils.bits;
import maths.utils;
import maths.vec3;
import maths.mat4;


struct Sphere
{
    float radius;
    Vec3 origin;
    
    /// create a sphere with a radius of one
    /// Returns: Sphere
    static Sphere one(float x, float y, float z)
    {
        Sphere result;
        
        result.origin.x = x;
        result.origin.y = y;
        result.origin.z = z;
        result.radius = 1.0f;
        
        return result;
    }

    /// returns point on sphere that is closest to given point
    /// Returns: Vec3
    Vec3 closestPt(Vec3 pt)
    {
        auto p = pt.subbed(origin);
        if(!p.isNormal())
        {
            p = p.normalized();
        }

        Vec3 result;

        result.x = origin.x + p.x * radius;
        result.y = origin.y + p.y * radius;
        result.z = origin.z + p.z * radius;

        return result;
    }
    
    /// Returns: Sphere
    Sphere transformed(Mat4 m4)
    {
        auto a = sqrF(m4.m00) + sqrF(m4.m01) + sqrF(m4.m02);
        auto b = sqrF(m4.m10) + sqrF(m4.m11) + sqrF(m4.m12);
        auto c = sqrF(m4.m20) + sqrF(m4.m21) + sqrF(m4.m22);

        Sphere result;

        result.origin = m4.transform(origin);
        result.radius = sqrtF(maxF(a, b, c));

        return result;
    }

    // -- override

    size_t toHash() const nothrow @safe
    {
        const prime = 31;
        size_t result = 1;
        size_t tmp;

        tmp = floatToBits(origin.x);
        result = prime * result + (tmp ^ (tmp >>> 32));

        tmp = floatToBits(origin.y);
        result = prime * result + (tmp ^ (tmp >>> 32));

        tmp = floatToBits(origin.z);
        result = prime * result + (tmp ^ (tmp >>> 32));

        tmp = floatToBits(radius);
        result = prime * result + (tmp ^ (tmp >>> 32));

        return result;
    }

    bool opEquals(ref const Sphere other) const pure
    {
        auto checkO = isEquilF(origin.x, other.origin.x) &&
                isEquilF(origin.y, other.origin.y) &&
                isEquilF(origin.z, other.origin.z);

        auto checkR = isEquilF(radius, other.radius);

        return checkO && checkR;
    }

    /// Returns: string
    string toString() const pure
    {
        return format("Sph [[%.2f, %.2f, %.2f], %.2f]", origin.x, origin.y, origin.z, radius);
    }
}