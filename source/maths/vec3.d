/// Vec3
module maths.vec3;


import std.format;
import maths.utils;


struct Vec3
{
    float x, y, z;

    /// create a one vec3
    /// Returns: Vec3
    static Vec3 one()
    {
        Vec3 result;

        result.x = 1.0f;
        result.y = 1.0f;
        result.z = 1.0f;

        return result;
    }

    /// create a zero vec3
    /// Returns: Vec3
    static Vec3 zero()
    {
        Vec3 result;

        result.x = 0.0f;
        result.y = 0.0f;
        result.z = 0.0f;

        return result;
    }

    /// create a vec3 that is the min values of ever 'a or 'b
    /// Returns: Vec3
    static Vec3 fromMin(Vec3 a, Vec3 b)
    {
        Vec3 result;

        result.x = minF(a.x, b.x);
        result.y = minF(a.y, b.y);
        result.z = minF(a.z, b.z);

        return result;
    }

    /// create a vec3 that is the max values of ever 'a or 'b
    /// Returns: Vec3
    static Vec3 fromMax(Vec3 a, Vec3 b)
    {
        Vec3 result;

        result.x = maxF(a.x, b.x);
        result.y = maxF(a.y, b.y);
        result.z = maxF(a.z, b.z);

        return result;
    }

    /// create a vec3 from an array of floats that is of length 3
    /// Returns: Vec3
    static Vec3 fromArray(float[] arr)
    {
        assert(arr.length == 3);

        Vec3 result;

        result.x = arr[0];
        result.y = arr[1];
        result.z = arr[2];

        return result;
    }

    /// Return value at 0..2
    /// Returns: float
    float at(int idx) const
    {
        assert(isInRangeI(idx, 0, 2));

        switch(idx)
        {
            case 0:
                return x;
            case 1:
                return y;
            case 2:
                return z;
            default:
                assert(0);
        }
    }

    /// Set value at 0..2
    void set(int idx, float value)
    {
        assert(isInRangeI(idx, 0, 2));

        switch(idx)
        {
            case 0:
                x = value;
                return;
            case 1:
                y = value;
                return;
            case 2:
                z = value;
                return;
            default:
                assert(0);
        }
    }

    /// return sum of 'this vec3 components
    /// Returns: float
    float sum() const
    {
        return x + y + z;
    }

    /// return dot product between 'this and 'other vec3
    /// Returns: float
    float dot(Vec3 other)
    {
        auto xx = x * other.x;
        auto yy = y * other.y;
        auto zz = z * other.z;

        return xx + yy + zz;
    }

    /// return length sqr of 'this vec3
    /// Returns: float
    float lengthSq()
    {
        auto x2 = sqrF(x);
        auto y2 = sqrF(y);
        auto z2 = sqrF(z);

        return x2 + y2 + z2;
    }

    /// return length of 'this vec3
    /// Returns: float
    float length()
    {
        auto x2 = sqrF(x);
        auto y2 = sqrF(y);
        auto z2 = sqrF(z);

        return sqrtF(x2 + y2 + z2);
    }

    /// returns the angle in radians between 'this and 'other
    /// Returns: float
    float angleBetween(Vec3 other)
    {
        auto d = sqrtF(lengthSq() * other.lengthSq());

        if(isZeroF(d))
        {
            return PHI;
        }

        auto t = dot(other) / d;

        return acosF(clampF(t, -1.0f, 1.0f));
    }

    /// return a negated copy of 'this
    /// Returns: Vec3
    Vec3 negated()
    {
        Vec3 result;

        result.x = -x;
        result.y = -y;
        result.z = -z;

        return result;
    }

    /// return 'this vec3 scaled scaled 'by float value
    /// Returns: Vec3
    Vec3 scaled(float by)
    {
        Vec3 result;

        result.x = x * by;
        result.y = y * by;
        result.z = z * by;

        return result;
    }


    /// return 'this vec3 added to 'other
    /// Returns: Vec3
    Vec3 added(Vec3 other)
    {
        Vec3 result;

        result.x = x + other.x;
        result.y = y + other.y;
        result.z = z + other.z;

        return result;
    }

    /// return 'this vec3 subbed from 'other
    /// Returns: Vec3
    Vec3 subbed(Vec3 other)
    {
        Vec3 result;

        result.x = x - other.x;
        result.y = y - other.y;
        result.z = z - other.z;

        return result;
    }

    /// return vec3 with absolute values
    /// Returns: Vec3
    Vec3 abs()
    {
        Vec3 result;

        result.x = absF(x);
        result.y = absF(y);
        result.z = absF(z);

        return result;
    }

    /// return lerp vec3 between 'this and 'to
    /// Returns: Vec3
    Vec3 lerp(Vec3 to, float weight)
    {
        Vec3 result;

        result.x = lerpF(x, to.x, weight);
        result.y = lerpF(y, to.y, weight);
        result.z = lerpF(z, to.z, weight);

        return result;
    }

    /// return a cubic interpolation between 'this and 'to
    /// Returns: Vec3
    Vec3 smoothStep(Vec3 to, float weight)
    {
        weight = clampF(weight, 0.0f, 1.0f);
        auto by = sqrF(weight) * (3.0f - (2.0f * weight));

        Vec3 result;

        result.x = x + ((to.x - x) * by);
        result.y = y + ((to.y - y) * by);
        result.z = z + ((to.z - z) * by);

        return result;
    }

    /// return linear vec3 between 'this and 'to by time
    /// Returns: Vec3
    Vec3 linear(Vec3 to, float dt)
    {
        auto by = 1.0f - dt;

        Vec3 result;

        result.x = (to.x - x) * by;
        result.y = (to.y - y) * by;
        result.z = (to.z - z) * by;

        return result;
    }

    /// return a normalized vec3 of 'this vec3
    /// Returns: Vec3
    Vec3 normalized()
    {
        auto lsq = lengthSq();
        Vec3 result;

        if(isZeroF(lsq))
        {
            result.x = 0.0f;
            result.y = 0.0f;
            result.z = 0.0f;
        }
        else if(isOneF(lsq))
        {
            result.x = x;
            result.y = y;
            result.z = z;
        }
        else 
        {
            auto inv = invSqrtF(lsq);

            result.x = x * inv;
            result.y = y * inv;
            result.z = z * inv;
        }

        return result;
    }

    /// return cross product between vec3 'this and vec3 'other
    /// Returns: Vec3
    Vec3 cross(Vec3 other)
    {
        Vec3 result;

        result.x = (y * other.z) - (z * other.y);
        result.y = (z * other.x) - (x * other.z);
        result.z = (x * other.y) - (y * other.x);

        return result;
    }

    /// return projection vec3 between 'this and 'other
    /// Returns: Vec3
    Vec3 projection(Vec3 other)
    {
        auto by = dot(other) / other.lengthSq();

        Vec3 result;

        result.x = other.x * by;
        result.y = other.y * by;
        result.z = other.z * by;

        return result;
    }

    /// return rejection vec3 between 'this and 'other
    /// Returns: Vec3
    Vec3 reject(Vec3 other)
    {
        auto p = projection(other);

        Vec3 result;

        result.x = x - p.x;
        result.y = y - p.y;
        result.z = z - p.z;

        return result;
    }


    /// return a rotated vec3 by 'rad along the 'unitAxis
    /// Returns: Vec3
    Vec3 rotateAxis(float rad, Vec3 unitAxis)
    {
        if(!unitAxis.isNormal())
        {
            unitAxis = unitAxis.normalized();
        }

        auto c = acosF(rad);
        auto s = asinF(rad);

        auto ux = unitAxis.x;
        auto uy = unitAxis.y;
        auto uz = unitAxis.z;

        auto nc = 1.0f - c;

        auto vaX = c + sqrF(ux) * nc;
        auto vaY = ux * uy * nc - uz * s;
        auto vaZ = ux * uz * nc + uy * s;
        Vec3 va = Vec3(vaX, vaY, vaZ);

        auto vbX = uy * ux * nc + uz * s;
        auto vbY = c + sqrF(uy) * nc;
        auto vbZ = uy * uz * nc - ux * s;
        Vec3 vb = Vec3(vbX, vbY, vbZ);

        auto vcX = uz * uy * nc - uy * s;
        auto vcY = uz * uy * nc + ux * s;
        auto vcZ = c + sqrF(uz) * nc;
        Vec3 vc = Vec3(vcX, vcY, vcZ);

        Vec3 result;

        result.x = dot(va);
        result.y = dot(vb);
        result.z = dot(vc);

        return result;
    }

    /// check for equility between 'this and 'other
    /// Returns: bool
    bool isEquil(Vec3 other) const
    {
        auto checkX = isEquilF(x, other.x);
        auto checkY = isEquilF(y, other.y);
        auto checkZ = isEquilF(z, other.z);

        return checkX & checkY & checkZ;
    }

    /// check if 'this vec3 is normalized
    /// Returns: bool
    bool isNormal()
    {
        return isOneF(lengthSq());
    }

    float[3] toArray()
    {
        float[3] result;

        result[0] = x;
        result[1] = y;
        result[2] = z;
        
        return result;
    }

    // -- override

    string toString() const pure
    {
        return format("V3 [%.2f, %.2f, %.2f]", x, y, z);
    }
}
