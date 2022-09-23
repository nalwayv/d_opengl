/// Plane
module geometry.plane;


import std.format;
import utils.bits;
import maths.utils;
import maths.vec3;
import maths.vec4;
import maths.mat4;
import maths.mat3;
import geometry.shapes;


struct Plane
{
    Vec3 normal;
    float d;

    this(Vec3 normal, float d)
    {
        this.normal.x = normal.x;
        this.normal.y = normal.y;
        this.normal.z = normal.z;
        this.d = d;
    }

    /// create a plane from three points
    /// Returns: Plane
    static Plane fromPoints(Vec3 a, Vec3 b, Vec3 c)
    {
        Vec3 ab = b.subbed(a);
        Vec3 ac = c.subbed(a);
        Vec3 abc = ab.cross(ac);

        if(!abc.isNormal())
        {
            abc = abc.normalized();
        }

        Plane result;

        result.normal = abc;
        result.d = -abc.dot(a);

        return result;
    }

    /// Returns: float
    float dot(Plane other)
    {
        auto xx = normal.x * other.normal.x;
        auto yy = normal.y * other.normal.y;
        auto zz = normal.z * other.normal.z;
        auto ww = d * other.d;

        return xx + yy + zz + ww;
    }

    /// classify point to plane
    /// Returns: float
    float classify(Vec3 pt)
    {
        auto d = normal.dot(pt) - d;

        float result;

        if(d > EPSILON)
        {
            result = 1.0f;
        }
        else if( d < -EPSILON)
        {
            result = -1.0f;
        }
        else 
        {
            result = 0.0f;
        }

        return result;
    }

    /// returns point on plane that is closest to given point
    /// Returns: Vec3
    Vec3 closestPoint(Vec3 pt)
    {
        auto dis = (normal.dot(pt) - d) / normal.lengthSq();
        Vec3 cp = pt.subbed(normal.scaled(dis));

        Vec3 result;

        result.x = cp.x;
        result.y = cp.y;
        result.z = cp.z;

        return result;
    }

    /// return a negated copy of 'this
    /// Returns: Plane
    Plane negate()
    {
        Plane result;

        result.normal.x = -normal.x;
        result.normal.y = -normal.y;
        result.normal.z = -normal.z;
        result.d = -d;

        return result;
    }

    /// return a copy of 'this plane normalized
    /// Returns: Plane
    Plane normalized()
    {
        auto lsq = normal.lengthSq();
        // auto t = 2.220446049250313e-16f;

        Plane result;

        if(isOneF(lsq))
        {
            result.normal.x = normal.x;
            result.normal.y = normal.y;
            result.normal.z = normal.z;
            result.d = d;
        }
        else if(isZeroF(lsq))
        {
            result.normal.x = 0.0f;
            result.normal.y = 0.0f;
            result.normal.z = 0.0f;
            result.d = 0.0f;
        }
        else 
        {
            auto inv = invSqrtF(lsq);

            result.normal.x = normal.x * inv;
            result.normal.y = normal.y * inv;
            result.normal.z = normal.z * inv;
            result.d = d * inv;
        }

        return result;
    }

    /// Returns: Plane
    Plane transformed(Mat4 m4)
    {
        Mat4 im4 = m4.inverse().transposed();
        Vec4 v4 = Vec4(normal.x, normal.y, normal.z, d);
        v4 = im4.transform(v4);

        Plane result;
        result.normal = Vec3(v4.x, v4.y, v4.z);
        result.d = v4.w;
        return result;
    }

    int type()
    {
        return SHAPE_PLANE;
    }

    // -- override

    size_t toHash() const nothrow @safe
    {
        const prime = 31;
        size_t result = 1;
        size_t tmp;

        tmp = floatToBits(normal.x);
        result = prime * result + (tmp ^ (tmp >>> 32));

        tmp = floatToBits(normal.y);
        result = prime * result + (tmp ^ (tmp >>> 32));

        tmp = floatToBits(normal.z);
        result = prime * result + (tmp ^ (tmp >>> 32));

        tmp = floatToBits(d);
        result = prime * result + (tmp ^ (tmp >>> 32));

        return result;
    }

    bool opEquals(ref const Plane other) const pure
    {
        if(!isEquilF(normal.x, other.normal.x)) return false;
        if(!isEquilF(normal.y, other.normal.y)) return false;
        if(!isEquilF(normal.z, other.normal.z)) return false;
        if(!isEquilF(d, other.d)) return false;
        
        return true;
    }

    /// Returns: string
    string toString() const pure
    {
        return format(
            "Plain [[%.2f, %.2f, %.2f], %.2f]",
            normal.x, normal.y, normal.z,
            d
        );
    }
}
