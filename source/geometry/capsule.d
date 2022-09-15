/// Capsule
module geometry.capsule;


import std.format;
import utils.bits;
import maths.utils;
import maths.vec3;


struct Capsule
{
    Vec3 a;
    Vec3 b;
    float radius;

    static Capsule fromHeight(float radius, float height)
    {

        auto hh = height * 0.5;

        Capsule result;

        result.a = Vec3(0, hh, 0);
        result.b = Vec3(0, -hh, 0);
        result.radius = radius;

        return result;

    }

    Vec3 getOrigin()
    {
        // a + ((b - a) * 0.5)
        return a.added(b.subbed(a).scaled(0.5f));

    }

    
    float getHeight()
    {
        return b.subbed(a).length();
    }

    // -- override

    size_t toHash() const nothrow @safe
    {
        const prime = 31;
        size_t result = 1;
        size_t tmp;

        tmp = floatToBits(a.x);
        result = prime * result + (tmp ^ (tmp >>> 32));

        tmp = floatToBits(a.y);
        result = prime * result + (tmp ^ (tmp >>> 32));

        tmp = floatToBits(a.z);
        result = prime * result + (tmp ^ (tmp >>> 32));

        tmp = floatToBits(b.x);
        result = prime * result + (tmp ^ (tmp >>> 32));

        tmp = floatToBits(b.y);
        result = prime * result + (tmp ^ (tmp >>> 32));

        tmp = floatToBits(b.z);
        result = prime * result + (tmp ^ (tmp >>> 32));

        tmp = floatToBits(radius);
        result = prime * result + (tmp ^ (tmp >>> 32));

        return result;
    }

    bool opEquals(ref const Capsule other) const pure
    {
        auto checkA = isEquilF(a.x, other.a.x) &&
                isEquilF(a.y, other.a.y) &&
                isEquilF(a.z, other.a.z);

        auto checkB = isEquilF(b.x, other.b.x) &&
                isEquilF(b.y, other.b.y) &&
                isEquilF(b.z, other.b.z);

        auto checkR = isEquilF(radius, other.radius);

        return checkA && checkB && checkR;
    }

    /// Returns: string
    string toString() const pure
    {
        return format("Cap [[%.2f, %.2f, %.2f], [%.2f, %.2f, %.2f], %.2f]",
            a.x, a.y, a.z, 
            b.x, b.y, b.z, 
            radius
        );
    }


}