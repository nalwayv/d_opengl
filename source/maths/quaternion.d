/// Quaternion
module maths.quaternion;


import std.format;
import maths.utils;
import maths.vec3;
import maths.vec4;
import maths.mat4;


struct Quaternion
{
    float x, y, z, w;

    static Quaternion fromAxis(float rad, Vec3 axis)
    {
        Quaternion result;
            
        if(!axis.isNormal())
        {
            axis = axis.normalized();
        }

        auto c = cosF(rad * 0.5f);
        auto s = sinF(rad * 0.5f);

        result.x = axis.x * s;
        result.y = axis.x * s;
        result.z = axis.x * s;
        result.w = c;

        return result;
    }    

    static Quaternion fromEuler(float x, float y, float z)
    {
        auto c1 = cosF(x * 0.5);
        auto c2 = cosF(y * 0.5);
        auto c3 = cosF(z * 0.5);
        
        auto s1 = sinF(x * 0.5);
        auto s2 = sinF(y * 0.5);
        auto s3 = sinF(z * 0.5);

        Quaternion result;

        result.w = (c1 * c2 * c3) - (s1 * s2 * s3);
        result.x = (s1 * c2 * c3) + (c1 * s2 * s3);
        result.y = (c1 * s2 * c3) - (s1 * c2 * s3);
        result.z = (c1 * c2 * s3) + (s1 * s2 * c3);
        
        return result;
    }

    static Quaternion identity()
    {
        Quaternion result;
        
        result.x = 0.0f;
        result.y = 0.0f;
        result.z = 0.0f;
        result.w = 1.0f;

        return result;
    }

    static Quaternion rotateTo(Vec3 from, Vec3 to)
    {
        auto d = from.dot(to);
        Quaternion result;

        if (d < -1.0f + EPSILON)
        {
            auto unitX = Vec3(1.0f, 0.0f, 0.0f);
            auto axis = unitX.cross(from);
            
            if (axis.length() < EPSILON)
            {
                auto unitY = Vec3(0.0f, 1.0f, 0.0f);
                axis = unitY.cross(from);
            }

            axis = axis.normalized();
            auto qaxis = Quaternion.fromAxis(PI, axis);

            result.x = qaxis.x;
            result.y = qaxis.y;
            result.z = qaxis.z;
            result.w = qaxis.w;
        }
        else if (d > absF(-1.0f + EPSILON))
        {
            result.x = 0.0f;
            result.y = 0.0f;
            result.z = 0.0f;
            result.w = 1.0f;
        }
        else 
        {
            auto axis = from.cross(to);

            result.x = axis.x;
            result.y = axis.y;
            result.z = axis.z;
            result.w = 1.0f + d;
        }
        
        return result;
    }

    static Quaternion fromMat4(Mat4 m4)
    {
        auto t = m4.trace();
        Quaternion result;

        if (t > 0.0f)
        {
            auto s = sqrtF(t + 1.0f) * 2.0f;
            auto invS = 1.0f / s;
            
            result.w = s * 0.25f;
            result.x = (m4.m21 - m4.m02) * invS;
            result.y = (m4.m02 - m4.m20) * invS;
            result.z = (m4.m10 - m4.m01) * invS;
        }
        else 
        {
            auto ax = m4.m00;    
            auto by = m4.m11;    
            auto cz = m4.m22;
            if (ax > by && ax > cz)
            {
                auto s = sqrtF(1.0f + ax - by - cz) * 2.0f;
                auto invS = 1.0f / s;

                result.w = (m4.m21 - m4.m12) * invS;
                result.x = s * 0.25f;
                result.y = (m4.m01 - m4.m10) * invS;
                result.z = (m4.m02 - m4.m20) * invS;
            }
            else if(ax > by)
            {
                auto s = sqrtF(1.0f + by - ax - cz) * 2.0f;
                auto invS = 1.0f / s;

                result.w = (m4.m02 - m4.m20) * invS;
                result.x = (m4.m01 - m4.m10) * invS;
                result.y = s * 0.25f;
                result.z = (m4.m12 - m4.m21) * invS;
            }
            else
            {
                auto s = sqrtF(1.0f + cz - ax - by) * 2.0f;
                auto invS = 1.0f / s;

                result.w = (m4.m10 - m4.m01) * invS;
                result.x = (m4.m02 - m4.m20) * invS;
                result.y = (m4.m12 - m4.m21) * invS;
                result.z = s * 0.25f;
            }
        }

        return result;
    }

    /// Return value at 0..3
    /// Returns: float
    float at(size_t idx) const
    {
        assert(idx < 4);
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

    /// return sum of 'this quaternions components
    /// Returns: float
    float sum() const
    {
        return x + y + z + w;
    }

    /// return dot product between 'this and 'other quaternion
    /// Returns: float
    float dot(Quaternion other)
    {
        auto xx = x * other.x;
        auto yy = y * other.y;
        auto zz = z * other.z;
        auto ww = w * other.w;

        return xx + yy + zz + ww;
    }

    float lengthSq()
    {
        auto x2 = sqrF(x);
        auto y2 = sqrF(x);
        auto z2 = sqrF(x);
        auto w2 = sqrF(x);
        
        return x2 + y2 + z2 + w2;
    }

    float length()
    {
        return sqrtF(lengthSq());
    }

    bool isNormal()
    {
        return isOneF(lengthSq());
    }

    Quaternion scaled(float by)
    {
        Quaternion result;

        result.x = x * by;
        result.y = y * by;
        result.z = z * by;
        result.w = w * by;
        
        return result;
    }
    
    Quaternion added(Quaternion other)
    {
        Quaternion result;

        result.x = x + other.x;
        result.y = y + other.y;
        result.z = z + other.z;
        result.w = w + other.w;
        
        return result;
    }

    Quaternion subbed(Quaternion other)
    {
        Quaternion result;

        result.x = x - other.x;
        result.y = y - other.y;
        result.z = z - other.z;
        result.w = w - other.w;
        
        return result;
    }

    Quaternion multiplyed(Quaternion other)
    {
        Quaternion result;

        result.x =  x * other.w + y * other.z - z * other.y + w * other.x;
        result.y = -x * other.z + y * other.w + z * other.x + w * other.y;
        result.z =  x * other.y - y * other.x + z * other.w + w * other.z;
        result.w = -x * other.x - y * other.y - z * other.z + w * other.w;

        return result;
    }

    /// lerp from 'this 'to by 'weight
    Quaternion lerp(Quaternion to, float weight)
    {
        Quaternion result;

        result.x = lerpF(x, to.x, weight);
        result.y = lerpF(y, to.y, weight);
        result.z = lerpF(z, to.z, weight);
        result.w = lerpF(w, to.w, weight);

        return result;
    }
    
    Quaternion slerp(Quaternion to, float weight)
    {
        Quaternion result;

        auto wa = 0.0f;
        auto wb = 0.0f;
        auto d = dot(to);

        if (d < 0.0f)
        {
            d *= -1.0f;
            to.x *= -1.0f;
            to.y *= -1.0f;
            to.z *= -1.0f;
            to.w *= -1.0f;
        }

        if(d < 0.99f)
        {
            auto omega = acosF(d);
            auto s = sinF(omega);
            auto invS = 1.0f / s;
            wa = sinF(omega * (1.0f - weight)) * invS;
            wb = sinF(omega * weight) * invS;
        }
        else 
        {
            wa = 1.0f - weight;
            wb = weight;    
        }

        result.x = wa * x + wb * to.x;
        result.y = wa * y + wb * to.y;
        result.z = wa * z + wb * to.z;
        result.w = wa * w + wb * to.w;

        if(!result.isNormal())
        {
            result.normalize();
        }

        return result;
    }

    Quaternion inverse()
    {
        Quaternion result;

        auto lsq = lengthSq();

        if(!isZeroF(lsq))
        {
            auto inv = 1.0f / lsq;

            result.x = x * -inv;
            result.x = y * -inv;
            result.x = z * -inv;
            result.x = w * inv;
        }
        else 
        {
            result.x = x;    
            result.y = y;    
            result.z = z;    
            result.w = w;    
        }

        return result;
    }

    Quaternion normalized()
    {
        auto lsq = lengthSq();
        Quaternion result;

        if (isZeroF(lsq))
        {
            result.x = 0.0f;
            result.y = 0.0f;
            result.z = 0.0f;
            result.w = 0.0f;
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

    void normalize()
    {
        auto n = normalized();

        x = n.x;
        y = n.y;
        z = n.z;
        w = n.w;
    }

    Mat4 toMat4()
    {
        auto x2 = sqrF(x);
        auto y2 = sqrF(y);
        auto z2 = sqrF(z);
        auto w2 = sqrF(w);

        auto xy = x * y;
        auto xz = x * z;
        auto xw = x * w;
        auto yz = y * z;
        auto yw = y * w;
        auto zw = z * w;

        auto s2 = 2.0f / (x2 + y2 + z2 + w2);

        Mat4 result;
        
        result.m00 = 1.0f - (s2 * (y2 + z2));
        result.m01 = s2 * (xy + zw);
        result.m02 = s2 * (xz - yw);
        result.m03 = 0.0f;
        result.m10 = s2 * (xy - zw);
        result.m11 = 1.0f - (s2 * (x2 + z2));
        result.m12 = s2 * (yz + xw);
        result.m13 = 0.0f;
        result.m20 = s2 * (xz + yw);
        result.m21 = s2 * (yz - xw);
        result.m22 = 1.0f - (s2 * (x2 + y2));
        result.m23 = 0.0f;
        result.m30 = 0.0f;
        result.m31 = 0.0f;
        result.m32 = 0.0f;
        result.m33 = 1.0f;

        return result;
    }

    Vec3 toEuler()
    {
        auto threshold = 0.4999995f;

        auto x2 = sqrF(x);
        auto y2 = sqrF(y);
        auto z2 = sqrF(z);
        auto w2 = sqrF(w);

        auto lsq = x2 + y2 + z2 + w2;
        auto test = (x * z) + (w * y);
        
        Vec3 result;
        
        if (test > (threshold * lsq))
        {
            result.x = 0.0f;
            result.y = PHI;
            result.z = 2.0f * atan2F(x, y);
        }

        if (test < (-threshold * lsq))
        {
            result.x = 0.0f;
            result.y = -PHI;
            result.z = -2.0f * atan2F(x, w);
        }

        auto xy = 2.0f * ((w * x) - (y * z));
        auto xx = w2 - x2 - y2 + z2;
        auto zy = 2.0f * ((w * z) - (z * y));
        auto zx = w2 + x2 - y2 - z2;

        result.x = atan2F(xy, xx);
        result.y = asinF(2.0 * test / lsq);
        result.z = atan2F(zy, zx);

        return result;
    }

    Vec3 toAxis()
    {
        auto q = Quaternion(x, y, z, w);

        if (absF(q.w) > 1.0f)
        {
            q.normalize();
        }

        Vec3 result;
        
        auto d = sqrtF(1.0f - sqrF(q.w));

        if (d > 1e-4)
        {
            auto inv = 1.0f / d;

            result.x = q.x * inv;
            result.y = q.y * inv;
            result.z = q.z * inv;
        }
        else 
        {
            result.x = 1.0f;
            result.y = 0.0f;
            result.z = 0.0f;
        }

        return result;
    }

    float[4] toArray()
    {
        float[4] result;

        result[0] = x;
        result[1] = y;
        result[2] = z;
        result[3] = w;
        
        return result;
    }

    // -- override

    string toString() const pure
    {
        return format("Quat [%.2f, %.2f, %.2f, %.2f]", x, y, z, w);
    }
}