/// Vec2
module maths.vec2;


import std.format;
import maths.utils;


struct Vec2
{
    float x, y;

    /// create a one vec2
    /// Returns: Vec2
    static Vec2 one()
    {
        Vec2 result;

        result.x = 1.0f;
        result.y = 1.0f;

        return result;
    }

    /// create a zero vec2
    /// Returns: Vec2
    static Vec2 zero()
    {
        Vec2 result;

        result.x = 0.0f;
        result.y = 0.0f;

        return result;
    }

    /// create a vec2 that is the min values of ever 'a or 'b
    /// Returns: Vec2
    static Vec2 fromMin(Vec2 a, Vec2 b)
    {
        Vec2 result;

        result.x = minF(a.x, b.x);
        result.y = minF(a.y, b.y);

        return result;
    }

    /// create a vec2 that is the max values of ever 'a or 'b
    /// Returns: Vec2
    static Vec2 fromMax(Vec2 a, Vec2 b)
    {
        Vec2 result;

        result.x = maxF(a.x, b.x);
        result.y = maxF(a.y, b.y);

        return result;
    }

    /// create a vec2 from an array of floats that is of length 2
    /// Returns: Vec2
    static Vec2 fromArray(float[] arr)
    {
        assert(arr.length == 2);

        const X = 0, Y = 1;

        Vec2 result;

        result.x = arr[X];
        result.y = arr[Y];

        return result;
    }


    /// Return value at 0..1
    /// Returns: float
    float at(int idx) const
    {
        assert(isInRangeI(idx, 0, 1));

        switch(idx)
        {
            case 0:
                return x;
            case 1:
                return y;
            default:
                assert(0);
        }
    }

    /// Set value at 0..1
    void set(int idx, float value)
    {
        assert(isInRangeI(idx, 0, 1));

        switch(idx)
        {
            case 0:
                x = value;
                return;
            case 1:
                y = value;
                return;
            default:
                assert(0);
        }
    }

    /// return sum of 'this vec2 components
    /// Returns: float
    float sum() const
    {
        return x + y;
    }

    /// return dot product between 'this and 'other vec2
    /// Returns: float
    float dot(Vec2 other)
    {
        auto xx = x * other.x;
        auto yy = y * other.y;

        return xx + yy;
    }

    /// return length sqr of 'this vec2
    /// Returns: float
    float lengthSq()
    {
        auto x2 = sqrF(x);
        auto y2 = sqrF(y);

        return x2 + y2;
    }

    /// return length of 'this vec2
    /// Returns: float
    float length()
    {
        auto x2 = sqrF(x);
        auto y2 = sqrF(y);

        return sqrtF(x2 + y2);
    }

    /// returns the angle in radians between 'this and 'other
    /// Returns: float
    float angleBetween(Vec2 other)
    {
        auto d = sqrtF(lengthSq() * other.lengthSq());

        if(isZeroF(d))
        {
            return PHI;
        }

        auto t = dot(other) / d;

        return acosF(clampF(t, -1.0f, 1.0f));
    }

    /// return a negated copy of 'this vec2
    /// Returns: Vec2
    Vec2 negated()
    {
        Vec2 result;

        result.x = -x;
        result.y = -y;

        return result;
    }

    /// return 'this vec2 scaled scaled 'by float value
    /// Returns: Vec2
    Vec2 scaled(float by)
    {
        Vec2 result;

        result.x = x * by;
        result.y = y * by;

        return result;
    }


    /// return 'this vec2 added to 'other
    /// Returns: Vec2
    Vec2 added(Vec2 other)
    {
        Vec2 result;

        result.x = x + other.x;
        result.y = y + other.y;

        return result;
    }

    /// return 'this vec2 subbed from 'other
    /// Returns: Vec2
    Vec2 subbed(Vec2 other)
    {
        Vec2 result;

        result.x = x - other.x;
        result.y = y - other.y;

        return result;
    }

    /// return 'this vec2 with absolute values
    /// Returns: Vec2
    Vec2 abs()
    {
        Vec2 result;

        result.x = absF(x);
        result.y = absF(y);

        return result;
    }

    /// return lerp vec2 between 'this and 'to by weight value
    /// Returns: Vec2
    Vec2 lerp(Vec2 to, float weight)
    {
        Vec2 result;

        result.x = lerpF(x, to.x, weight);
        result.y = lerpF(y, to.y, weight);

        return result;
    }

    /// return linear vec2 between 'this and 'to by time
    /// Returns: Vec2
    Vec2 linear(Vec2 to, float dt)
    {
        auto by = 1.0f - dt;

        Vec2 result;

        result.x = (to.x - x) * by;
        result.y = (to.y - y) * by;

        return result;
    }

    /// return a normalized vec2 of 'this
    /// Returns: Vec2
    Vec2 normalized()
    {
        auto lsq = lengthSq();
        Vec2 result;

        if(isZeroF(lsq))
        {
            result.x = 0.0f;
            result.y = 0.0f;
        }
        else if(isOneF(lsq))
        {
            result.x = x;
            result.y = y;
        }
        else 
        {
            auto inv = invSqrtF(lsq);

            result.x = x * inv;
            result.y = y * inv;
        }

        return result;
    }

    /// check for equility between 'this and 'other vec2
    /// Returns: bool
    bool isEquil(Vec2 other) const
    {
        auto checkX = isEquilF(x, other.x);
        auto checkY = isEquilF(y, other.y);

        return checkX & checkY;
    }

    /// check if 'this vec2 is normalized
    /// Returns: bool
    bool isNormal()
    {
        return isOneF(lengthSq());
    }

    /// Returns: float[2]
    float[2] toArray()
    {
        const X = 0, Y = 1;

        float[2] result;

        result[X] = x;
        result[Y] = y;
        
        return result;
    }

    // -- override

    string toString() const pure
    {
        return format("V2 [%.2f, %.2f]", x, y);
    }
}