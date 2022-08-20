/// Sphere
module geometry.sphere;

import std.format;
import utils.bits;
import maths.utils;
import maths.vec3;


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
            p.normalize();
        }

        Vec3 result;

        result.x = origin.x + p.x * radius;
        result.y = origin.y + p.y * radius;
        result.z = origin.z + p.z * radius;

        return result;
    }

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