// AABB
module geometry.aabb;

import std.format;
import utils.bits;
import maths.utils;
import maths.vec3;


struct AABB
{
    Vec3 origin;
    Vec3 extents;

    /// create an aabb with extents being one
    /// Returns: AABB
    static AABB one(float x, float y, float z)
    {
        AABB result;

        result.origin.x = x;
        result.origin.y = y;
        result.origin.z = z;

        result.extents.x = 1.0f;
        result.extents.y = 1.0f;
        result.extents.z = 1.0f;

        return result; 
    }

    /// create an aabb from 'min and 'max points
    /// Returns: AABB
    static AABB fromMinMax(Vec3 min, Vec3 max)
    {
        auto p1 = min.added(max).scaled(0.5);
        auto p2 = min.subbed(max).scaled(0.5);

        AABB result;

        result.origin.x = p1.x;
        result.origin.y = p1.y;
        result.origin.z = p1.z;

        result.extents.x = p2.x;
        result.extents.y = p2.y;
        result.extents.z = p2.z;

        return result;
    }

    // create an aabb from the combined aabb's of 'a and 'b
    /// Returns: AABB
    static AABB fromCombined(AABB a, AABB b)
    {
        auto ptMin = Vec3.fromMin(a.min(), b.min());
        auto ptMax = Vec3.fromMax(a.max(), b.max());

        return AABB.fromMinMax(ptMin, ptMax);
    }

    /// return vec3 of 'this aabb min point
    /// Returns: Vec3
    Vec3 min()
    {
        auto p1 = origin.added(extents);
        auto p2 = origin.subbed(extents);

        return Vec3.fromMin(p1, p2);
    }

    /// return vec3 of 'this aabb max point
    /// Returns: Vec3
    Vec3 max()
    {
        auto p1 = origin.added(extents);
        auto p2 = origin.subbed(extents);

        return Vec3.fromMax(p1, p2);
    }

    /// returns point on aabb that is closest to given point
    /// Returns: Vec3
    Vec3 closestPt(Vec3 pt)
    {
        auto pMin = min();
        auto pMax = max();

        Vec3 result;

        for(size_t i = 0; i < 3; i++)
        {
            auto v = pt.at(i);
            v = minF(v, pMin.at(i));
            v = maxF(v, pMax.at(i));
            result.set(i, v);
        }

        return result;
    }    
    
    /// returns array of vec3's of all corners of 'this aabb
    /// Returns: Vec3[8]
    Vec3[8] corners()
    {
        auto p1 = min();
        auto p2 = max();

        Vec3[8] result;

        result[0] = Vec3(p1.x, p1.y, p1.z);
        result[1] = Vec3(p2.x, p1.y, p1.z);
        result[2] = Vec3(p2.x, p2.y, p1.z);
        result[3] = Vec3(p1.x, p2.y, p1.z);
        result[4] = Vec3(p2.x, p1.y, p2.z);
        result[5] = Vec3(p2.x, p1.y, p2.z);
        result[6] = Vec3(p2.x, p2.y, p2.z);
        result[7] = Vec3(p1.x, p2.y, p2.z);

        return result;
    }

    /// Returns: AABB
    AABB combined(AABB other)
    {
        auto p1 = Vec3.fromMin(min(), other.min());
        auto p2 = Vec3.fromMax(max(), other.max());

        return AABB.fromMinMax(p1, p2);
    }

    /// return an aabb of 'this aabb that has been expanded 'by float value
    /// Returns: AABB
    AABB expanded(float by)
    {
        auto v3 = Vec3(by, by, by);
        auto p1 = min().subbed(v3);
        auto p2 = max().added(v3);

        return AABB.fromMinMax(p1, p2);
    }

    /// return an aabb with the origin shifted 'by vec3
    /// Returns: AABB
    AABB shifted(Vec3 by)
    {
        auto p1 = min().added(by);
        auto p2 = max().added(by);

        return AABB.fromMinMax(p1, p2);
    }

    /// return perimeter of 'this aabb
    /// Returns: float
    float perimeter()
    {
        auto ptMin = min();
        auto ptMax = max();
        auto d = ptMax.subbed(ptMin);
        auto xy = d.x * d.y;
        auto yz = d.y * d.z;
        auto zx = d.z * d.x;
        return 2.0f * (xy + yz + zx);
    }

    /// check if 'this aabb is isDegenerate
    /// Returns: bool
    bool isDegenerate()
    {
        auto p1 = min();
        auto p2 = max();

        auto cx = isEquilF(p1.x, p2.x);
        auto cy = isEquilF(p1.y, p2.y);
        auto cz = isEquilF(p1.z, p2.z);

        return cx && cy && cz;
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

        tmp = floatToBits(extents.x);
        result = prime * result + (tmp ^ (tmp >>> 32));

        tmp = floatToBits(extents.y);
        result = prime * result + (tmp ^ (tmp >>> 32));

        tmp = floatToBits(extents.z);
        result = prime * result + (tmp ^ (tmp >>> 32));

        return result;
    }

    bool opEquals(ref const AABB other) const pure
    {
        auto checkO = isEquilF(origin.x, other.origin.x) &&
                isEquilF(origin.y, other.origin.y) &&
                isEquilF(origin.z, other.origin.z);

        auto checkE = isEquilF(extents.x, other.extents.x) &&
                isEquilF(extents.y, other.extents.y) &&
                isEquilF(extents.z, other.extents.z);

        return checkO && checkE;
    }

    string toString() const pure
    {
        return format(
            "AABB [[%.2f, %.2f, %.2f], [%.2f, %.2f, %.2f]]", 
            origin.x, origin.y, origin.z, 
            extents.x, extents.y, extents.z
        );
    }
}
