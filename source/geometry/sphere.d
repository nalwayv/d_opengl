/// Sphere
module geometry.sphere;


import std.format;
import utils.bits;
import maths.utils;
import maths.vec3;
import maths.mat4;
import geometry.shapetypes;
import geometry.aabb;


struct Sphere
{
    Vec3 origin;
    float radius;
    
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
    Vec3 closestPoint(Vec3 pt)
    {
        Vec3 p = pt.subbed(origin);
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

    /// Returns: Vec3
    Vec3 farthestPoint(Vec3 direction, Mat4 m4)
    {
        if(!direction.isNormal())
        {
            direction = direction.normalized();
        }

        Vec3 c = m4.transform(origin);

        Vec3 result;

        result.x = c.x += radius * direction.x;
        result.y = c.y += radius * direction.y;
        result.z = c.z += radius * direction.z;
        
        return result;
    }

    /// Returns: AABB
    AABB computeAABB()
    {
        Vec3 pMin = Vec3(origin.x - radius, origin.y - radius, origin.z - radius);
        Vec3 pMax = Vec3(origin.x + radius, origin.y + radius, origin.z + radius);

        return AABB.fromMinMax(pMin, pMax);
    }

    int type()
    {
        return SHAPE_SPHERE;
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
        if(!isEquilF(origin.x, other.origin.x)) return false;
        if(!isEquilF(origin.y, other.origin.y)) return false;
        if(!isEquilF(origin.z, other.origin.z)) return false;

        if(!isEquilF(radius, other.radius)) return false;

        return true;
    }

    /// Returns: string
    string toString() const pure
    {
        return format("Sph [[%.2f, %.2f, %.2f], %.2f]", origin.x, origin.y, origin.z, radius);
    }
}