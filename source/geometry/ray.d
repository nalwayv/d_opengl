/// Ray
module geometry.ray;


import std.format;
import utils.bits;
import maths.utils;
import maths.vec3;
import geometry.shapetypes;


struct Ray
{
    Vec3 origin;
    Vec3 direction;

    static Ray fromPoints(Vec3 a, Vec3 b)
    {
        Vec3 o = a;
        Vec3 d = b.subbed(a).normalized();

        Ray result;

        result.origin = o;
        result.direction = d;
        
        return result;
    }

    static Ray fromValues(float x, float y, float z, float dx, float dy, float dz)
    {
        Ray result;

        result.origin.x = x;
        result.origin.y = y;
        result.origin.z = z;

        result.direction.x = dx;
        result.direction.y = dy;
        result.direction.z = dz;

        result = result.normalized();

        return result;
    }

    /// Returns: Ray
    Ray normalized()
    {
        Vec3 o = origin;
        Vec3 d = direction;

        if(!d.isNormal())
        {
            d = d.normalized();
        }

        Ray result;

        result.origin = o;
        result.direction = d;
        
        return result;
    }

    /// returns point on ray that is closest to given point
    /// Returns: Vec3
    Vec3 closestPoint(Vec3 pt)
    {
        Vec3 op = pt.subbed(origin);
        auto dis = op.dot(direction);
        auto t = maxF(dis, 0.0f);

        Vec3 result;

        result.x = origin.x + direction.x * t;
        result.y = origin.y + direction.y * t;
        result.z = origin.z + direction.z * t;

        return result;
    }

    /// return hit point based on t from ray casts.
    /// Returns: Vec3
    Vec3 getHit(float t)
    {
        Vec3 result;

        result.x = origin.x + direction.x * t;
        result.y = origin.y + direction.y * t;
        result.z = origin.z + direction.z * t;

        return result;
    }

    int type()
    {
        return SHAPE_RAY;
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


        tmp = floatToBits(direction.x);
        result = prime * result + (tmp ^ (tmp >>> 32));

        tmp = floatToBits(direction.y);
        result = prime * result + (tmp ^ (tmp >>> 32));

        tmp = floatToBits(direction.z);
        result = prime * result + (tmp ^ (tmp >>> 32));


        return result;
    }

    bool opEquals(ref const Ray other) const pure
    {
        if(!isEquilF(origin.x, other.origin.x)) return false;
        if(!isEquilF(origin.y, other.origin.y)) return false;
        if(!isEquilF(origin.z, other.origin.z)) return false;

        if(!isEquilF(direction.x, other.direction.x)) return false;
        if(!isEquilF(direction.y, other.direction.y)) return false;
        if(!isEquilF(direction.z, other.direction.z)) return false;

        return true;
    }

    /// Returns: string
    string toString() const pure
    {
        return format(
            "Ray [[%.2f, %.2f, %.2f], [%.2f, %.2f, %.2f]]",
            origin.x, origin.y, origin.z,
            direction.x, direction.y, direction.z,
        );
    }
}