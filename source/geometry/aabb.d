// AABB
module geometry.aabb;


import std.format;
import utils.bits;
import maths.utils;
import maths.vec3;
import maths.vec4;
import maths.mat3;
import maths.mat4;


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

    /// create an aabb from 'pMin and 'pMax points
    /// Returns: AABB
    static AABB fromMinMax(Vec3 pMin, Vec3 pMax)
    {
        Vec3 p1 = pMin.added(pMax).scaled(0.5);
        Vec3 p2 = pMin.subbed(pMax).scaled(0.5);

        AABB result;

        result.origin.x = p1.x;
        result.origin.y = p1.y;
        result.origin.z = p1.z;

        result.extents.x = p2.x;
        result.extents.y = p2.y;
        result.extents.z = p2.z;

        return result;
    }

    /// create an aabb from the combined aabb's of 'a and 'b
    /// Returns: AABB
    static AABB fromCombined(AABB a, AABB b)
    {
        Vec3 pMin = Vec3.fromMin(a.min(), b.min());
        Vec3 pMax = Vec3.fromMax(a.max(), b.max());

        return AABB.fromMinMax(pMin, pMax);
    }

    /// create an aabb from min max based on array of vec3 values
    /// Returns: AABB
    static AABB fromArray(const Vec3* arr, int length)
    {
        Vec3 pMin = Vec3(MAXFLOAT, MAXFLOAT, MAXFLOAT);
        Vec3 pMax = Vec3(MINFLOAT, MINFLOAT, MINFLOAT);
    
        for(int i = 0; i < length; i++)
        {
            Vec3 v3 = arr[i];
            
            if(v3.x < pMin.x)
            {
                pMin.x = v3.x;
            }
            if(v3.x > pMax.x)
            {
                pMax.x = v3.x;
            }
            
            if(v3.y < pMin.y)
            {
                pMin.y = v3.y;
            }
            if(v3.y > pMax.y)
            {
                pMax.y = v3.y;
            }

            if(v3.z < pMin.z)
            {
                pMin.z = v3.z;
            }
            if(v3.z > pMax.z)
            {
                pMax.z = v3.z;
            }
        }

        return AABB.fromMinMax(pMin, pMax);
    }

    /// return vec3 of 'this aabb min point
    /// Returns: Vec3
    Vec3 min()
    {
        Vec3 p1 = origin.added(extents);
        Vec3 p2 = origin.subbed(extents);

        return Vec3.fromMin(p1, p2);
    }

    /// return vec3 of 'this aabb max point
    /// Returns: Vec3
    Vec3 max()
    {
        Vec3 p1 = origin.added(extents);
        Vec3 p2 = origin.subbed(extents);

        return Vec3.fromMax(p1, p2);
    }

    /// returns point on aabb that is closest to given point
    /// Returns: Vec3
    Vec3 closestPoint(Vec3 pt)
    {
        Vec3 pMin = min();
        Vec3 pMax = max();

        float x, y, z;

        if(pt.x < pMin.x) x = pMin.x;
        if(pt.x > pMax.x) x = pMax.x;
        if(pt.y < pMin.y) y = pMin.y;
        if(pt.y > pMax.y) y = pMax.y;
        if(pt.z < pMin.z) z = pMin.z;
        if(pt.z > pMax.z) z = pMax.z;

        Vec3 result;

        result.x = x;
        result.y = y;
        result.z = z;

        return result;
    }    
    
    /// returns array of vec3's of all corners of 'this aabb
    /// Returns: Vec3[8]
    Vec3[8] getCorners()
    {
        Vec3 p1 = min();
        Vec3 p2 = max();

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
        Vec3 p1 = Vec3.fromMin(min(), other.min());
        Vec3 p2 = Vec3.fromMax(max(), other.max());

        return AABB.fromMinMax(p1, p2);
    }

    /// return an aabb of 'this aabb that has been expanded 'by float value
    /// Returns: AABB
    AABB expanded(float by)
    {
        Vec3 v3 = Vec3(by, by, by);
        Vec3 p1 = min().subbed(v3);
        Vec3 p2 = max().added(v3);

        return AABB.fromMinMax(p1, p2);
    }

    /// return an aabb with the origin shifted 'by vec3
    /// Returns: AABB
    AABB shifted(Vec3 by)
    {
        Vec3 p1 = min().added(by);
        Vec3 p2 = max().added(by);

        return AABB.fromMinMax(p1, p2);
    }

    /// Returns: AABB
    AABB transformed(Mat4 m4)
    {
        Vec3 pMin = min();
        Vec3 pMax = max();
        auto corners = getCorners();

        for(auto i = 0; i < corners.length; i++)
        {
            Vec3 corner = corners[i];

            Vec3 pTr = m4.transform(corner);
            
            pMin = Vec3.fromMin(pMin, pTr);
            pMax = Vec3.fromMax(pMax, pTr);
        }

        return AABB.fromMinMax(pMin, pMax);
    }

    /// return perimeter of 'this aabb
    /// Returns: float
    float perimeter()
    {
        Vec3 pMin = min();
        Vec3 pMax = max();
        Vec3 d = pMax.subbed(pMin);

        auto xy = d.x * d.y;
        auto yz = d.y * d.z;
        auto zx = d.z * d.x;

        return 2.0f * (xy + yz + zx);
    }

    /// resturn the sqr distance between 'this aabb and 'pt
    /// Returns: float
    float sqDistPoint(Vec3 pt)
    {
        Vec3 pMax = max();
        Vec3 pMin = min();

        float result = 0.0f;

        if(pt.x < pMin.x) result += sqrF(pMin.x - pt.x);
        if(pt.x > pMax.x) result += sqrF(pt.x - pMax.x);
        if(pt.y < pMin.y) result += sqrF(pMin.y - pt.y);
        if(pt.y > pMax.y) result += sqrF(pt.y - pMax.y);
        if(pt.z < pMin.z) result += sqrF(pMin.z - pt.z);
        if(pt.z > pMax.z) result += sqrF(pt.z - pMax.z);

        return result;
    }

    /// check if 'this aabb is isDegenerate
    /// Returns: bool
    bool isDegenerate()
    {
        Vec3 p1 = min();
        Vec3 p2 = max();

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
        if(!isEquilF(origin.x, other.origin.x)) return false;
        if(!isEquilF(origin.y, other.origin.y)) return false;
        if(!isEquilF(origin.z, other.origin.z)) return false;

        if(!isEquilF(extents.x, other.extents.x)) return false;
        if(!isEquilF(extents.y, other.extents.y)) return false;
        if(!isEquilF(extents.z, other.extents.z)) return false;

        return true;
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
