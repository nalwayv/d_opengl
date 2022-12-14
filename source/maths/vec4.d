/// Vec4
module maths.vec4;


import std.format;
import maths.utils;
import maths.vec3;


struct Vec4
{
    float x, y, z, w;
    
    /// create a one vec4
    /// Returns: Vec4
    static Vec4 one()
    {
        Vec4 result;

        result.x = 1.0f;
        result.y = 1.0f;
        result.z = 1.0f;
        result.w = 1.0f;

        return result;
    }

    /// create a zero vec4
    /// Returns: Vec4
    static Vec4 zero()
    {
        Vec4 result;

        result.x = 0.0f;
        result.y = 0.0f;
        result.z = 0.0f;
        result.w = 0.0f;

        return result;
    }

    /// create a vec4 that is the min values of ever 'a or 'b
    /// Returns: Vec4
    static Vec4 fromMin(Vec4 a, Vec4 b)
    {
        Vec4 result;

        result.x = minF(a.x, b.x);
        result.y = minF(a.y, b.y);
        result.z = minF(a.z, b.z);
        result.w = minF(a.w, b.w);

        return result;
    }

    /// create a vec4 that is the max values of ever 'a or 'b
    /// Returns: Vec4
    static Vec4 fromMax(Vec4 a, Vec4 b)
    {
        Vec4 result;

        result.x = maxF(a.x, b.x);
        result.y = maxF(a.y, b.y);
        result.z = maxF(a.z, b.z);
        result.w = maxF(a.w, b.w);

        return result;
    }


    /// create a vec4 from an array of floats that is of length 4
    /// Returns: Vec4
    static Vec4 fromArray(float[] arr)
    {
        assert(arr.length == 4);

        const X = 0, Y = 1, Z = 2, W = 3;
        
        Vec4 result;

        result.x = arr[X];
        result.y = arr[Y];
        result.z = arr[Z];
        result.w = arr[W];

        return result;
    }


    /// Return value at 0..3
    /// Returns: float
    float at(int idx) const
    {
        assert(isInRangeI(idx, 0, 3));

        switch(idx)
        {
            case 0:
                return x;
            case 1:
                return y;
            case 2:
                return z;
            case 3:
                return w;
            default:
                assert(0);
        }
    }

    /// Set value at 0..3
    void set(int idx, float value)
    {
        assert(isInRangeI(idx, 0, 3));

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
            case 3:
                w = value;
                return;
            default:
                assert(0);
        }
    }

    /// return sum of 'this vec4 components
    /// Returns: float
    float sum() const
    {
        return x + y + z + w;
    }

    /// return dot product between 'this and 'other vec4
    /// Returns: float
    float dot(Vec4 other)
    {
        auto xx = x * other.x;
        auto yy = y * other.y;
        auto zz = z * other.z;
        auto ww = w * other.w;

        return xx + yy + zz + ww;
    }

    /// return length sqr of 'this vec4
    /// Returns: float
    float lengthSq()
    {
        auto x2 = sqrF(x);
        auto y2 = sqrF(y);
        auto z2 = sqrF(z);
        auto w2 = sqrF(w);

        return x2 + y2 + z2 + w2;
    }

    /// return length of 'this vec4
    /// Returns: float
    float length()
    {
        auto x2 = sqrF(x);
        auto y2 = sqrF(y);
        auto z2 = sqrF(z);
        auto w2 = sqrF(w);

        return sqrtF(x2 + y2 + z2 + w2);
    }

    /// return a scaled copy of 'this vec4
    /// Returns: Vec4
    Vec4 scaled(float by)
    {
        Vec4 result;

        result.x = x * by;
        result.y = y * by;
        result.z = z * by;
        result.w = w * by;

        return result;
    }

    /// return a copy of 'this vec4 with 'other vec4's compoenents added
    /// Returns: Vec4
    Vec4 added(Vec4 other)
    {
        Vec4 result;

        result.x = x + other.x;
        result.y = y + other.y;
        result.z = z + other.z;
        result.w = w + other.w;
        
        return result;
    }

    /// return a copy of 'this vec4 with 'other vec4's compoenents subbed
    /// Returns: Vec4
    Vec4 subbed(Vec4 other)
    {
        Vec4 result;

        result.x = x - other.x;
        result.y = y - other.y;
        result.z = z - other.z;
        result.w = w - other.w;

        return result;
    }

    /// return a copy of 'this vec4 with absolute values
    /// Returns: Vec4
    Vec4 abs()
    {
        Vec4 result;

        result.x = absF(x);
        result.y = absF(y);
        result.z = absF(z);
        result.w = absF(w);

        return result;
    }

    /// return lerp vec4 between 'this and 'to by 'weight value
    /// Returns: Vec4
    Vec4 lerp(Vec4 to, float weight)
    {
        Vec4 result;

        result.x = lerpF(x, to.x, weight);
        result.x = lerpF(y, to.y, weight);
        result.x = lerpF(z, to.z, weight);
        result.x = lerpF(w, to.w, weight);

        return result;
    }

    /// return a normalized copy of 'this vec4
    /// Returns: Vec4
    Vec4 normalized()
    {
        auto lsq = lengthSq();
        Vec4 result;


        if(isZeroF(lsq))
        {
            result.x = 0.0f;
            result.y = 0.0f;
            result.z = 0.0f;
            result.w = 0.0f;
        }
        else if(isOneF(lsq))
        {
            result.x = x;
            result.y = y;
            result.z = z;
            result.w = w;
        }
        else 
        {
            auto inv = invSqrtF(lsq);
            
            result.x = x * inv;
            result.y = y * inv;
            result.z = z * inv;
            result.w = w * inv;
        }

        return result;
    }

    /// return a negated copy of 'this
    /// Returns: Vec4
    Vec4 negated()
    {
        Vec4 result;

        result.x = -x;
        result.y = -y;
        result.z = -z;
        result.w = -w;

        return result;
    }

    /// return projection vec4 between 'this and 'other
    /// Returns: Vec4
    Vec4 projection(Vec4 other)
    {
        auto by = dot(other) / other.lengthSq();

        Vec4 result;

        result.x = other.x * by;
        result.y = other.y * by;
        result.z = other.z * by;
        result.w = other.w * by;
        
        return result;
    }

    /// return rejection vec3 between 'this and 'other
    /// Returns: Vec3
    Vec4 reject(Vec4 other)
    {
        auto p = projection(other);

        Vec4 result;

        result.x = x - p.x;
        result.y = y - p.y;
        result.z = z - p.z;
        result.w = w - p.w;
        
        return result;
    }

    /// return the xyz components of 'this vec4 as a vec3
    /// Returns: Vec3
    Vec3 xyz()
    {
        Vec3 result;

        result.x = x;
        result.y = y;
        result.z = z;

        return result;
    }

    /// check for equility between 'this and 'other
    /// Returns: bool
    bool isEquil(Vec4 other) const
    {
        if(x != other.x) return false;
        if(y != other.y) return false;
        if(z != other.z) return false;
        if(w != other.w) return false;

        return true;
    }

    /// check if 'this vec4 is normalized
    /// Returns: bool
    bool isNormal()
    {
        return isOneF(lengthSq());
    }  

    float[4] toArray()
    {
        const X = 0, Y = 1, Z = 2, W = 3;
        
        float[4] result;

        result[X] = x;
        result[Y] = y;
        result[Z] = z;
        result[W] = w;
        
        return result;
    }

    // -- override

    string toString() const pure
    {
        return format("V4 [%.2f, %.2f, %.2f, %.2f]", x, y, z, w);
    }
}