/// Mat3
module maths.mat3;


import std.format;
import maths.utils;
import maths.vec3;


struct Mat3
{
    float m00, m01, m02;
    float m10, m11, m12;
    float m20, m21, m22;

    /// create a identity mat3
    /// Returns: Mat3
    static Mat3 identity()
    {
        Mat3 result;

        result.m00 = 1.0f;
        result.m01 = 0.0f;
        result.m02 = 0.0f;
        result.m10 = 0.0f;
        result.m11 = 1.0f;
        result.m12 = 0.0f;
        result.m20 = 0.0f;
        result.m21 = 0.0f;
        result.m22 = 1.0f;

        return result;
    }

    /// create a zero mat3
    /// Returns: Mat3
    static Mat3 zero()
    {
        Mat3 result;

        result.m00 = 0.0f;
        result.m01 = 0.0f;
        result.m02 = 0.0f;
        result.m10 = 0.0f;
        result.m11 = 0.0f;
        result.m12 = 0.0f;
        result.m20 = 0.0f;
        result.m21 = 0.0f;
        result.m22 = 0.0f;

        return result;
    }


    /// create a rotation x mat3
    /// Returns: Mat3
    static Mat3 rotationX(float rad)
    {
        auto c = cosF(rad);
        auto s = sinF(rad);

        Mat3 result;

        result.m00 = 1.0f;
        result.m01 = 0.0f;
        result.m02 = 0.0f;
        result.m10 = 0.0f;
        result.m11 = c;
        result.m12 = -s;
        result.m20 = 0.0f;
        result.m21 = s;
        result.m22 = c;

        return result;
    }

    /// create a rotation y mat3
    /// Returns: Mat3
    static Mat3 rotationY(float rad)
    {
        auto c = cosF(rad);
        auto s = sinF(rad);


        Mat3 result;

        result.m00 = c;
        result.m01 = 0.0f;
        result.m02 = s;
        result.m10 = 0.0f;
        result.m11 = 1.0f;
        result.m12 = 0.0f;
        result.m20 = -s;
        result.m21 = 0.0f;
        result.m22 = c;

        return result;
    }

    /// create a rotation z mat3
    /// Returns: Mat3
    static Mat3 rotationZ(float rad)
    {
        auto c = cosF(rad);
        auto s = sinF(rad);

        Mat3 result;

        result.m00 = c;
        result.m01 = -s;
        result.m02 = 0.0f;
        result.m10 = s;
        result.m11 = c;
        result.m12 = 0.0f;
        result.m20 = 0.0f;
        result.m21 = 0.0f;
        result.m22 = 1.0f;

        return result;
    }


    static Mat3 scaler(float x, float y, float z)
    {
        Mat3 result;

        result.m00 = x;
        result.m01 = 0.0f;
        result.m02 = 0.0f;
        result.m10 = 0.0f;
        result.m11 = y;
        result.m12 = 0.0f;
        result.m20 = 0.0f;
        result.m21 = 0.0f;
        result.m22 = z;

        return result;
    }

    /// create a axis rotation mat3
    /// Returns: Mat3
    static Mat3 fromAxis(float rad, Vec3 axis)
    {
        if(!axis.isNormal())
        {
            axis = axis.normalized();
        }

        auto c = cosF(rad);
        auto s = sinF(rad);
        auto t = 1.0 - c;

        auto xx = t * sqrF(axis.x);
        auto xy = t * axis.x * axis.y;
        auto xz = t * axis.x * axis.z;
        auto yy = t * sqrF(axis.y);
        auto yz = t * axis.y * axis.z;
        auto zz = t * sqrF(axis.z);

        auto sx = s * axis.x;
        auto sy = s * axis.y;
        auto sz = s * axis.z;

        Mat3 result;

        result.m00 = xx + c;
        result.m01 = xy - sz;
        result.m02 = xz + sy;
        result.m10 = xy + sz;
        result.m11 = yy + c;
        result.m12 = yz - sx;
        result.m20 = xz - sy;
        result.m21 = yz + sx;
        result.m22 = zz + c;

        return result;
    }

    /// create a look-at mat3
    /// Returns: Mat3
    static Mat3 lookAt(Vec3 target, Vec3 up)
    {
        auto col2 = target.scaled(-1.0).normalized();
        auto col0 = up.cross(col2).normalized();
        auto col1 = col2.cross(col0);

        Mat3 result;

        result.m00 = col0.x;
        result.m01 = col1.x;
        result.m02 = col2.x;
        result.m10 = col0.y;
        result.m11 = col1.y;
        result.m12 = col2.y;
        result.m20 = col0.z;
        result.m21 = col1.z;
        result.m22 = col2.z;

        return result;
    }

    /// return mat3 row 0 values
    /// Returns: Vec3
    Vec3 row0()
    {
        Vec3 result;

        result.x = m00;
        result.y = m01;
        result.z = m02;

        return result;
    }

    /// return mat3 row 1 values
    /// Returns: Vec3
    Vec3 row1()
    {
        Vec3 result;

        result.x = m10;
        result.y = m11;
        result.z = m12;
        
        return result;
    }

    /// return mat3 row 2 values
    /// Returns: Vec3
    Vec3 row2()
    {
        Vec3 result;

        result.x = m20;
        result.y = m21;
        result.z = m22;
        
        return result;
    }

    /// return mat3 col 0 values
    /// Returns: Vec3
    Vec3 col0()
    {
        Vec3 result;

        result.x = m00;
        result.y = m10;
        result.z = m20;
        
        return result;
    }

    /// return mat3 col 1 values
    /// Returns: Vec3
    Vec3 col1()
    {
        Vec3 result;

        result.x = m01;
        result.y = m11;
        result.z = m21;

        return result;
    }

    /// return mat3 col 2 values
    /// Returns: Vec3
    Vec3 col2()
    {
        Vec3 result;

        result.x = m02;
        result.y = m12;
        result.z = m22;

        return result;
    }

    /// return a vec3 transformed by 'this mat3
    /// Returns: Vec3
    Vec3 transform(Vec3 v3)
    {
        Vec3 result;

        result.x = (m00 * v3.x) + (m10 * v3.y) + (m20 * v3.z);
        result.y = (m01 * v3.x) + (m11 * v3.y) + (m21 * v3.z);
        result.z = (m02 * v3.x) + (m12 * v3.y) + (m22 * v3.z);

        return result;
    }

    /// get row at index
    /// Returns: Vec3
    Vec3 rowAt(size_t i)
    {
        assert(i < 3);
        if(i == 0)
        {
            return Vec3(m00, m01, m02);
        }

        if(i == 1)
        {
            return Vec3(m10, m11, m12);

        }

        if(i == 2)
        {
            return Vec3(m20, m21, m22);
        }

        assert(0);
    }


    /// get col at index
    /// Returns: Vec3
    Vec3 colAt(size_t i)
    {
        assert(i < 3);
        if(i == 0)
        {
            return Vec3(m00, m10, m20);
        }

        if(i == 1)
        {
            return Vec3(m01, m11, m21);

        }

        if(i == 2)
        {
            return Vec3(m02, m12, m22);
        }

        assert(0);
    }


    /// get the float value at coords 'row and 'col
    /// Returns: float
    float at(size_t row, size_t col) const
    {
        assert(row < 3);
        assert(col < 3);

        if(row == 0)
        {
            if (col == 0) return m00;
            if (col == 1) return m01;
            if (col == 2) return m02;
        }

        if(row == 1)
        {
            if (col == 0) return m10;
            if (col == 1) return m11;
            if (col == 2) return m12;
        }

        if(row == 2)
        {
            if (col == 0) return m20;
            if (col == 1) return m21;
            if (col == 2) return m22;
        }

        assert(0);
    }

    float trace() const
    {
        return m00 + m11 + m22;
    }

    /// return the determinant of 'this mat3
    /// Returns: float
    float determinant()
    {
        auto d0 = m00 * m11 * m21;
        auto d1 = m01 * m12 * m20;
        auto d2 = m02 * m10 * m22;
        auto d3 = m02 * m11 * m20;
        auto d4 = m00 * m12 * m21;
        auto d5 = m01 * m10 * m22;

        return d0 + d1 + d2 - d3 - d4 - d5;
    }

    /// return m4 with abs values
    /// Returns: Mat4
    Mat3 abs()
    {
        Mat3 result;

        result.m00 = absF(m00);
        result.m01 = absF(m01);
        result.m02 = absF(m02);
        result.m10 = absF(m10);
        result.m11 = absF(m11);
        result.m12 = absF(m12);
        result.m20 = absF(m20);
        result.m21 = absF(m21);
        result.m22 = absF(m22);

        return result;
    }

    /// return an inverse mat3 of 'this
    /// Returns: Mat3
    Mat3 inverse()
    {
        auto det = determinant();
        auto inv = 1.0f / det;

        Mat3 result;

        result.m00 = (m11 * m22 - m21 * m12) * inv;
        result.m01 = (m20 * m12 - m10 * m22) * inv;
        result.m02 = (m10 * m21 - m20 * m11) * inv;
        result.m10 = (m21 * m02 - m01 * m22) * inv;
        result.m11 = (m00 * m22 - m20 * m02) * inv;
        result.m12 = (m20 * m01 - m00 * m21) * inv;
        result.m20 = (m01 * m12 - m11 * m02) * inv;
        result.m21 = (m10 * m02 - m00 * m12) * inv;
        result.m22 = (m00 * m11 - m10 * m01) * inv;

        return result;
    }

    Mat3 transposed()
    {
        Mat3 result;

        result.m00 = m00;
        result.m01 = m10;
        result.m02 = m20;
        result.m10 = m01;
        result.m11 = m11;
        result.m12 = m21;
        result.m20 = m02;
        result.m21 = m12;
        result.m22 = m22;

        return result;
    }

    Mat3 cofactor()
    {
        Mat3 result;

        result.m00 = +m00; 
        result.m01 = -m01; 
        result.m02 = +m02;
        result.m10 = -m10; 
        result.m11 = +m11; 
        result.m12 = -m12;
        result.m20 = +m20; 
        result.m21 = -m21; 
        result.m22 = +m22;

        return result;
    }

    Mat3 added(Mat3 other)
    {
        Mat3 result;

        result.m00 = m00 + other.m00;
        result.m01 = m01 + other.m01;
        result.m02 = m02 + other.m02;
        result.m10 = m10 + other.m10;
        result.m11 = m11 + other.m11;
        result.m12 = m12 + other.m12;
        result.m20 = m20 + other.m20;
        result.m21 = m21 + other.m21;
        result.m22 = m22 + other.m22;

        return result;
    }


    Mat3 subbed(Mat3 other)
    {
        Mat3 result;

        result.m00 = m00 - other.m00;
        result.m01 = m01 - other.m01;
        result.m02 = m02 - other.m02;
        result.m10 = m10 - other.m10;
        result.m11 = m11 - other.m11;
        result.m12 = m12 - other.m12;
        result.m20 = m20 - other.m20;
        result.m21 = m21 - other.m21;
        result.m22 = m22 - other.m22;
        
        return result;
    }

    /// return a mat3 multiplyed by 'other mat3 values
    /// Returns: Mat3
    Mat3 multiplied(Mat3 other)
    {
        Vec3 r0 = row0();
        Vec3 r1 = row1();
        Vec3 r2 = row2();
        Vec3 c0 = other.col0();
        Vec3 c1 = other.col1();
        Vec3 c2 = other.col2();

        Mat3 result;

        result.m00 = r0.dot(c0);
        result.m01 = r0.dot(c1);
        result.m02 = r0.dot(c2);
        result.m10 = r1.dot(c0);
        result.m11 = r1.dot(c1);
        result.m12 = r1.dot(c2);
        result.m20 = r2.dot(c0);
        result.m21 = r2.dot(c1);
        result.m22 = r2.dot(c2);
        
        return result;
    }
    
    /// return a normalized copy of 'this
    /// Returns: Mat3
    Mat3 normalized()
    {
        auto det = determinant();
        Mat3 result;

        if (isZeroF(det))
        {
            result.m00 = 0.0f;
            result.m01 = 0.0f;
            result.m02 = 0.0f;
            result.m10 = 0.0f;
            result.m11 = 0.0f;
            result.m12 = 0.0f;
            result.m20 = 0.0f;
            result.m21 = 0.0f;
            result.m22 = 0.0f;
        }
        else
        {
            auto inv = 1.0f / det;
            result.m00 = m00 * inv;
            result.m01 = m01 * inv;
            result.m02 = m02 * inv;
            result.m10 = m10 * inv;
            result.m11 = m11 * inv;
            result.m12 = m12 * inv;
            result.m20 = m20 * inv;
            result.m21 = m21 * inv;
            result.m22 = m22 * inv;
        }

        return result;
    }

    /// return 'this mat3 rotated by 'rad along the 'axis
    /// Returns: Mat3
    Mat3 rotated(float rad, Vec3 axis)
    {
        return multiplied(Mat3.fromAxis(rad, axis));
    }

    /// return 'this mat3 scaled along its x, y and z axis
    /// Returns: Mat3
    Mat3 scaled(float x, float y, float z)
    {
        return multiplied(Mat3.scaler(x, y, z));
    }

    float[3][3] toArrayM()
    {
        float[3][3] result;

        result[0][0] = m00;
        result[0][1] = m01;
        result[0][2] = m02;
        result[1][0] = m10;
        result[1][1] = m11;
        result[1][2] = m12;
        result[2][0] = m20;
        result[2][1] = m21;
        result[2][2] = m22;

        return result;
    }

    float[9] toArrayS()
    {
        float[9] result;

        result[0] = m00;
        result[1] = m01;
        result[2] = m02;
        result[3] = m10;
        result[4] = m11;
        result[5] = m12;
        result[6] = m20;
        result[7] = m21;
        result[8] = m22;

        return result;
    }

    // -- override 
    
    string toString() const pure
    {
        return format("M3 [[%.2f, %.2f, %.2f] [%.2f, %.2f, %.2f] [%.2f, %.2f, %.2f]]",
            m00, m01, m02,
            m10, m11, m12,
            m20, m21, m22,
        );
    }
}
