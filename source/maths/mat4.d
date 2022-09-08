/// Mat4
module maths.mat4;


import std.format;
import maths.utils;
import maths.vec3;
import maths.vec4;
import maths.mat3;


struct Mat4
{
    float m00, m01, m02, m03;
    float m10, m11, m12, m13;
    float m20, m21, m22, m23;
    float m30, m31, m32, m33;

    /// create a identity mat4
    /// Returns: Mat4
    static Mat4 identity()
    {
        Mat4 result;

        result.m00 = 1.0f;
        result.m01 = 0.0f;
        result.m02 = 0.0f;
        result.m03 = 0.0f;
        result.m10 = 0.0f;
        result.m11 = 1.0f;
        result.m12 = 0.0f;
        result.m13 = 0.0f;
        result.m20 = 0.0f;
        result.m21 = 0.0f;
        result.m22 = 1.0f;
        result.m23 = 0.0f;
        result.m30 = 0.0f;
        result.m31 = 0.0f;
        result.m32 = 0.0f;
        result.m33 = 1.0f;

        return result;
    }

    /// create a zero mat4
    /// Returns: Mat4
    static Mat4 zero()
    {
        Mat4 result;

        result.m00 = 0.0f;
        result.m01 = 0.0f;
        result.m02 = 0.0f;
        result.m03 = 0.0f;
        result.m10 = 0.0f;
        result.m11 = 0.0f;
        result.m12 = 0.0f;
        result.m13 = 0.0f;
        result.m20 = 0.0f;
        result.m21 = 0.0f;
        result.m22 = 0.0f;
        result.m23 = 0.0f;
        result.m30 = 0.0f;
        result.m31 = 0.0f;
        result.m32 = 0.0f;
        result.m33 = 0.0f;

        return result;
    }

    /// create a rotation x mat4
    /// Returns: Mat4
    static Mat4 rotationX(float rad)
    {
        auto c = cosF(rad);
        auto s = sinF(rad);

        Mat4 result;

        result.m00 = 1.0f;
        result.m01 = 0.0f;
        result.m02 = 0.0f;
        result.m03 = 0.0f;
        result.m10 = 0.0f;
        result.m11 = c;
        result.m12 = -s;
        result.m13 = 0.0f;
        result.m20 = 0.0f;
        result.m21 = s;
        result.m22 = c;
        result.m23 = 0.0f;
        result.m30 = 0.0f;
        result.m31 = 0.0f;
        result.m32 = 0.0f;
        result.m33 = 1.0f;

        return result;
    }

    /// create a rotation y mat4
    /// Returns: Mat4
    static Mat4 rotationY(float rad)
    {
        auto c = cosF(rad);
        auto s = sinF(rad);

        Mat4 result;

        result.m00 = c;
        result.m01 = 0.0f;
        result.m02 = s;
        result.m03 = 0.0f;
        result.m10 = 0.0f;
        result.m11 = 1.0f;
        result.m12 = 0.0f;
        result.m13 = 0.0f;
        result.m20 = -s;
        result.m21 = 0.0f;
        result.m22 = c;
        result.m23 = 0.0f;
        result.m30 = 0.0f;
        result.m31 = 0.0f;
        result.m32 = 0.0f;
        result.m33 = 1.0f;

        return result;
    }

    /// create a rotation z mat4
    /// Returns: Mat4
    static Mat4 rotationZ(float rad)
    {
        auto c = cosF(rad);
        auto s = sinF(rad);

        Mat4 result;

        result.m00 = c;
        result.m01 = -s;
        result.m02 = 0.0f;
        result.m03 = 0.0f;
        result.m10 = s;
        result.m11 = c;
        result.m12 = 0.0f;
        result.m13 = 0.0f;
        result.m20 = 0.0f;
        result.m21 = 0.0f;
        result.m22 = 1.0f;
        result.m23 = 0.0f;
        result.m30 = 0.0f;
        result.m31 = 0.0f;
        result.m32 = 0.0f;
        result.m33 = 1.0f;

        return result;
    }

    /// create a translation mat4
    /// Returns: Mat4
    static Mat4 translation(float x, float y, float z)
    {
        Mat4 result;

        result.m00 = 1.0f;
        result.m01 = 0.0f;
        result.m02 = 0.0f;
        result.m03 = 0.0f;
        result.m10 = 0.0f;
        result.m11 = 1.0f;
        result.m12 = 0.0f;
        result.m13 = 0.0f;
        result.m20 = 0.0f;
        result.m21 = 0.0f;
        result.m22 = 1.0f;
        result.m23 = 0.0f;
        result.m30 = x;
        result.m31 = y;
        result.m32 = z;
        result.m33 = 1.0f;

        return result;
    }

    /// create a scaler mat4
    /// Returns: Mat4
    static Mat4 scaler(float x, float y, float z)
    {

        Mat4 result;

        result.m00 = x;
        result.m01 = 0.0f;
        result.m02 = 0.0f;
        result.m03 = 0.0f;
        result.m10 = 0.0f;
        result.m11 = y;
        result.m12 = 0.0f;
        result.m13 = 0.0f;
        result.m20 = 0.0f;
        result.m21 = 0.0f;
        result.m22 = z;
        result.m23 = 0.0f;
        result.m30 = 0.0f;
        result.m31 = 0.0f;
        result.m32 = 0.0f;
        result.m33 = 1.0f;

        return result;
    }

    /// create a axis rotation mat4
    /// Returns: Mat4
    static Mat4 fromAxis(float rad, Vec3 axis)
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

        Mat4 result;

        result.m00 = xx + c;
        result.m01 = xy - sz;
        result.m02 = xz + sy;
        result.m03 = 0.0f;
        result.m10 = xy + sz;
        result.m11 = yy + c;
        result.m12 = yz - sx;
        result.m13 = 0.0f;
        result.m20 = xz - sy;
        result.m21 = yz + sx;
        result.m22 = zz + c;
        result.m23 = 0.0f;
        result.m30 = 0.0f;
        result.m31 = 0.0f;
        result.m32 = 0.0f;
        result.m33 = 1.0f;

        return result;
    }

    /// create a perspective offset mat4
    /// Returns: Mat4
    static Mat4 frustum(float left, float right, float bottom, float top, float znear, float zfar)
    {
        Mat4 result;

        result.m00 = 2.0f * znear / (right - left);
        result.m01 = 0.0f;
        result.m02 = 0.0f;
        result.m03 = 0.0f;
        result.m10 = 0.0f;
        result.m11 = 2.0f * znear / (top - bottom);
        result.m12 = 0.0f;
        result.m13 = 0.0f;
        result.m20 = (right + left) / (right - left);
        result.m21 = (top + bottom) / (top - bottom);
        result.m22 = -(zfar + znear) / (zfar - znear);
        result.m23 = -1.0f;
        result.m30 = 0.0f;
        result.m31 = 0.0f;
        result.m32 = -(2.0f * zfar * znear) / (zfar - znear);
        result.m33 = 0.0f;

        return result;
    }

    /// create a perspective projection mat4
    /// Returns: Mat4
    static Mat4 perspective(float fov, float aspect, float near, float far)
    {
        auto maxY = near * tanF(fov * 0.5f);
        auto minY = -maxY;
        auto minX = minY * aspect;
        auto maxX = maxY * aspect;

        return Mat4.frustum(minX, maxX, minY, maxY, near, far);
    }

    static Mat4 lookAt(Vec3 eye, Vec3 target, Vec3 up)
    {
        auto f = eye.subbed(target).normalized();
        auto s = up.cross(f).normalized();
        auto u = f.cross(s);

        Mat4 result;

        result.m00 = s.x;
        result.m01 = u.x;
        result.m02 = f.x;
        result.m03 = 0.0f;
        result.m10 = s.y;
        result.m11 = u.y;
        result.m12 = f.y;
        result.m13 = 0.0f;
        result.m20 = s.z;
        result.m21 = u.z;
        result.m22 = f.z;
        result.m23 = 0.0f;
        result.m30 = -s.dot(eye);
        result.m31 = -u.dot(eye);
        result.m32 = -f.dot(eye);
        result.m33 = 1.0f;

        return result;
    }

    /// return mat4 row 0 values
    /// Returns: Vec4
    Vec4 row0()
    {
        return Vec4(m00, m01, m02, m03);
    }

    /// return mat4 row 1 values
    /// Returns: Vec4
    Vec4 row1()
    {
        return Vec4(m10, m11, m12, m13);
    }

    /// return mat4 row 2 values
    /// Returns: Vec4
    Vec4 row2()
    {
        return Vec4(m20, m21, m22, m23);
    }

    /// return mat4 row 3 values
    /// Returns: Vec4
    Vec4 row3()
    {
        return Vec4(m30, m31, m32, m33);
    }

    /// return mat4 col 0 values
    /// Returns: Vec4
    Vec4 col0()
    {
        return Vec4(m00, m10, m20, m30);
    }

    /// return mat4 col 1 values
    /// Returns: Vec4
    Vec4 col1()
    {
        return Vec4(m01, m11, m21, m31);
    }

    /// return mat4 col 2 values
    /// Returns: Vec4
    Vec4 col2()
    {
        return Vec4(m02, m12, m22, m32);
    }

    /// return mat4 col 3 values
    /// Returns: Vec4
    Vec4 col3()
    {
        return Vec4(m03, m13, m23, m33);
    }

    /// return a vec4 transformed by this mat4
    /// Returns: Vec4
    Vec4 transform(Vec4 v4)
    {
        Vec4 result;

        result.x = (m00 * v4.x) + (m10 * v4.y) + (m20 * v4.z) + (m30 * v4.w);
        result.y = (m01 * v4.x) + (m11 * v4.y) + (m21 * v4.z) + (m31 * v4.w);
        result.z = (m02 * v4.x) + (m12 * v4.y) + (m22 * v4.z) + (m32 * v4.w);
        result.w = (m03 * v4.x) + (m13 * v4.y) + (m23 * v4.z) + (m33 * v4.w);

        return result;
    }

    /// return a vec3 transformed by this mat4
    /// Returns: Vec3
    Vec3 transform(Vec3 v3)
    {
        Vec3 result; 

        result.x = (m00 * v3.x) + (m10 * v3.y) + (m20 * v3.z) + m30;
        result.y = (m01 * v3.x) + (m11 * v3.y) + (m21 * v3.z) + m31;
        result.z = (m02 * v3.x) + (m12 * v3.y) + (m22 * v3.z) + m32;

        return result;
    }

    /// return the position vec3 from the mat4
    /// Returns: Vec3
    Vec3 getPosition()
    {
        Vec3 result;

        result.x = m30;
        result.y = m31;
        result.z = m32;

        return result;
    }

    /// get float value at 'row 'col
    /// Returns: float
    float at(size_t row, size_t col) const
    {
        assert(row < 4);
        assert(col < 4);

        if(row == 0)
        {
            if (col == 0) return m00;
            if (col == 1) return m01;
            if (col == 2) return m02;
            if (col == 3) return m03;
        }

        if(row == 1)
        {

            if (col == 0) return m10;
            if (col == 1) return m11;
            if (col == 2) return m12;
            if (col == 3) return m13;
        }

        if(row == 2)
        {
            if (col == 0) return m20;
            if (col == 1) return m21;
            if (col == 2) return m22;
            if (col == 3) return m23;
        }

        if(row == 3)
        {
            if (col == 0) return m30;
            if (col == 1) return m31;
            if (col == 2) return m32;
            if (col == 3) return m33;
        }

        assert(0);
    }

    float trace() const
    {
        return m00 + m11 + m22 + m33;
    }

    /// return the determinant of 'this mat4
    /// Returns: float
    float determinant()
    {
        auto d00 = m30 * m21 * m12 * m03;
        auto d01 = m20 * m31 * m12 * m03;
        auto d02 = m30 * m11 * m22 * m03;
        auto d03 = m10 * m31 * m22 * m03;
        auto d10 = m20 * m11 * m32 * m03;
        auto d11 = m10 * m21 * m32 * m03;
        auto d12 = m30 * m21 * m02 * m13;
        auto d13 = m20 * m31 * m02 * m13;
        auto d20 = m30 * m01 * m22 * m13;
        auto d21 = m00 * m31 * m22 * m13;
        auto d22 = m20 * m01 * m32 * m13;
        auto d23 = m00 * m21 * m32 * m13;
        auto d30 = m30 * m11 * m02 * m23;
        auto d31 = m10 * m31 * m02 * m23;
        auto d32 = m30 * m01 * m12 * m23;
        auto d33 = m00 * m31 * m12 * m23;
        auto d40 = m10 * m01 * m32 * m23;
        auto d41 = m00 * m11 * m32 * m23;
        auto d42 = m20 * m11 * m02 * m33;
        auto d43 = m10 * m21 * m02 * m33;
        auto d50 = m20 * m01 * m12 * m33;
        auto d51 = m00 * m21 * m12 * m33;
        auto d52 = m10 * m01 * m22 * m33;
        auto d53 = m00 * m11 * m22 * m33;

        auto a = d00 - d01 - d02 + d03;
        auto b = d10 - d11 - d12 + d13;
        auto c = d20 - d21 - d22 + d23;
        auto d = d30 - d31 - d32 + d33;
        auto e = d40 - d41 - d42 + d43;
        auto f = d50 - d51 - d52 + d53;

        return a + b + c + d + e + f;
    }

    /// return an inverse mat4 of 'this
    /// Returns: Mat4
    Mat4 inverse()
    {
        auto d00 = m00 * m11 - m01 * m10;
        auto d01 = m00 * m12 - m02 * m10;
        auto d02 = m00 * m13 - m03 * m10;
        auto d03 = m01 * m12 - m02 * m11;
        auto d04 = m01 * m13 - m03 * m11;
        auto d05 = m02 * m13 - m03 * m12;
        auto d06 = m20 * m31 - m21 * m30;
        auto d07 = m20 * m32 - m22 * m30;
        auto d08 = m20 * m33 - m23 * m30;
        auto d09 = m21 * m32 - m22 * m31;
        auto d10 = m21 * m33 - m23 * m31;
        auto d11 = m22 * m33 - m23 * m32;

        auto det = d00 * d11 - d01 * d10 + d02 * d09 + d03 * d08 - d04 * d07 + d05 * d06;

        assert(!isZeroF(det));

        auto inv = 1.0f / det;

        Mat4 result;

        result.m00 = (+m11 * d11 - m12 * d10 + m13 * d09) * inv;
        result.m01 = (-m01 * d11 + m02 * d10 - m03 * d09) * inv;
        result.m02 = (+m31 * d05 - m32 * d04 + m33 * d03) * inv;
        result.m03 = (-m21 * d05 + m22 * d04 - m23 * d03) * inv;
        result.m10 = (-m10 * d11 + m12 * d08 - m13 * d07) * inv;
        result.m11 = (+m00 * d11 - m02 * d08 + m03 * d07) * inv;
        result.m12 = (-m30 * d05 + m32 * d02 - m33 * d01) * inv;
        result.m13 = (+m20 * d05 - m22 * d02 + m23 * d01) * inv;
        result.m20 = (+m10 * d10 - m11 * d08 + m13 * d06) * inv;
        result.m21 = (-m00 * d10 + m01 * d08 - m03 * d06) * inv;
        result.m22 = (+m30 * d04 - m31 * d02 + m33 * d00) * inv;
        result.m23 = (-m20 * d04 + m21 * d02 - m23 * d00) * inv;
        result.m30 = (-m10 * d09 + m11 * d07 - m12 * d06) * inv;
        result.m31 = (+m00 * d09 - m01 * d07 + m02 * d06) * inv;
        result.m32 = (-m30 * d03 + m31 * d01 - m32 * d00) * inv;
        result.m33 = (+m20 * d03 - m21 * d01 + m22 * d00) * inv;

        return result;
    }

    Mat4 transposed()
    {
        Mat4 result;

        result.m00 = m00;
        result.m01 = m10;
        result.m02 = m20;
        result.m03 = m30;
        result.m10 = m01;
        result.m11 = m11;
        result.m12 = m21;
        result.m13 = m31;
        result.m20 = m02;
        result.m21 = m12;
        result.m22 = m22;
        result.m23 = m32;
        result.m30 = m03;
        result.m31 = m13;
        result.m32 = m23;
        result.m33 = m33;

        return result;
    }

    Mat4 cofactor()
    {
        Mat4 result;

        result.m00 = +m00;
        result.m01 = -m01;
        result.m02 = +m02;
        result.m03 = -m03;
        result.m10 = -m10;
        result.m11 = +m11;
        result.m12 = -m12;
        result.m13 = +m13;
        result.m20 = +m20;
        result.m21 = -m21;
        result.m22 = +m22;
        result.m23 = -m23;
        result.m30 = -m30;
        result.m31 = +m31;
        result.m32 = -m32;
        result.m33 = +m33;

        return result;
    }

    Mat4 added(Mat4 other)
    {
        Mat4 result;

        result.m00 = m00 + other.m00;
        result.m01 = m01 + other.m01;
        result.m02 = m02 + other.m02;
        result.m03 = m03 + other.m03;
        result.m10 = m10 + other.m10;
        result.m11 = m11 + other.m11;
        result.m12 = m12 + other.m12;
        result.m13 = m13 + other.m13;
        result.m20 = m20 + other.m20;
        result.m21 = m21 + other.m21;
        result.m22 = m22 + other.m22;
        result.m23 = m23 + other.m23;
        result.m30 = m30 + other.m30;
        result.m31 = m31 + other.m31;
        result.m32 = m32 + other.m32;
        result.m33 = m33 + other.m33;

        return result;
    }


    Mat4 subbed(Mat4 other)
    {
        Mat4 result;

        result.m00 = m00 - other.m00;
        result.m01 = m01 - other.m01;
        result.m02 = m02 - other.m02;
        result.m03 = m03 - other.m03;
        result.m10 = m10 - other.m10;
        result.m11 = m11 - other.m11;
        result.m12 = m12 - other.m12;
        result.m13 = m13 - other.m13;
        result.m20 = m20 - other.m20;
        result.m21 = m21 - other.m21;
        result.m22 = m22 - other.m22;
        result.m23 = m23 - other.m23;
        result.m30 = m30 - other.m30;
        result.m31 = m31 - other.m31;
        result.m32 = m32 - other.m32;
        result.m33 = m33 - other.m33;

        return result;
    }


    /// return a mat4 multiplyed by 'other mat4 values
    /// Returns: Mat4
    Mat4 multiplied(Mat4 other)
    {
        Vec4 r0 = row0();
        Vec4 r1 = row1();
        Vec4 r2 = row2();
        Vec4 r3 = row3();
        Vec4 c0 = other.col0();
        Vec4 c1 = other.col1();
        Vec4 c2 = other.col2();
        Vec4 c3 = other.col3();

        Mat4 result;

        result.m00 = r0.dot(c0);
        result.m01 = r0.dot(c1);
        result.m02 = r0.dot(c2);
        result.m03 = r0.dot(c3);
        result.m10 = r1.dot(c0);
        result.m11 = r1.dot(c1);
        result.m12 = r1.dot(c2);
        result.m13 = r1.dot(c3);
        result.m20 = r2.dot(c0);
        result.m21 = r2.dot(c1);
        result.m22 = r2.dot(c2);
        result.m23 = r2.dot(c3);
        result.m30 = r3.dot(c0);
        result.m31 = r3.dot(c1);
        result.m32 = r3.dot(c2);
        result.m33 = r3.dot(c3);

        return result;
    }

    Mat4 normalized()
    {
        auto det = determinant();
        Mat4 result;

        if (isZeroF(det))
        {
            result.m00 = 0.0f;
            result.m01 = 0.0f;
            result.m02 = 0.0f;
            result.m03 = 0.0f;

            result.m10 = 0.0f;
            result.m11 = 0.0f;
            result.m12 = 0.0f;
            result.m13 = 0.0f;

            result.m20 = 0.0f;
            result.m21 = 0.0f;
            result.m22 = 0.0f;
            result.m23 = 0.0f;

            result.m30 = 0.0f;
            result.m31 = 0.0f;
            result.m32 = 0.0f;
            result.m33 = 0.0f;
        }
        else
        {
            auto inv = 1.0f / det;
            result.m00 = m00 * inv;
            result.m01 = m01 * inv;
            result.m02 = m02 * inv;
            result.m03 = m03 * inv;

            result.m10 = m10 * inv;
            result.m11 = m11 * inv;
            result.m12 = m12 * inv;
            result.m13 = m13 * inv;

            result.m20 = m20 * inv;
            result.m21 = m21 * inv;
            result.m22 = m22 * inv;
            result.m23 = m23 * inv;

            result.m30 = m30 * inv;
            result.m31 = m31 * inv;
            result.m32 = m32 * inv;
            result.m33 = m33 * inv;
        }

        return result;
    }

    /// return 'this mat4 rotated by 'rad along the 'axis
    /// Returns: Mat4
    Mat4 rotated(float rad, Vec3 axis)
    {
        return multiplied(Mat4.fromAxis(rad, axis));
    }

    /// return 'this mat4 scaled along its x, y and z axis
    /// Returns: Mat4
    Mat4 scaled(float x, float y, float z)
    {
        return multiplied(Mat4.scaler(x, y, z));
    }

    /// Return this 'mat4 as a 'mat3
    /// Returns: Mat3
    Mat3 toMat3()
    {
        Mat3 result;

        result.m00 = m00;
        result.m01 = m01;
        result.m02 = m02;

        result.m10 = m10;
        result.m11 = m11;
        result.m12 = m12;

        result.m20 = m20;
        result.m21 = m21;
        result.m22 = m22;

        return result;
    }

    float[4][4] toArrayM()
    {
        float[4][4] result;

        result[0][0] = m00;
        result[0][1] = m01;
        result[0][2] = m02;
        result[0][3] = m03;
        result[1][0] = m10;
        result[1][1] = m11;
        result[1][2] = m12;
        result[1][3] = m13;
        result[2][0] = m20;
        result[2][1] = m21;
        result[2][2] = m22;
        result[2][3] = m23;
        result[3][0] = m30;
        result[3][1] = m31;
        result[3][2] = m32;
        result[3][3] = m33;

        return result;
    }   

    float[16] toArrayS()
    {
        float[16] result;

        result[0] = m00;
        result[1] = m01;
        result[2] = m02;
        result[3] = m03;
        result[4] = m10;
        result[5] = m11;
        result[6] = m12;
        result[7] = m13;
        result[8] = m20;
        result[9] = m21;
        result[10] = m22;
        result[11] = m23;
        result[12] = m30;
        result[13] = m31;
        result[14] = m32;
        result[15] = m33;

        return result;
    } 

    // -- ovcerride

    string toString() const pure
    {
        return format("M4 [[%.2f,%.2f,%.2f,%.2f] [%.2f,%.2f,%.2f,%.2f] [%.2f,%.2f,%.2f,%.2f] [%.2f,%.2f,%.2f,%.2f]]",
            m00, m01, m02, m03,
            m10, m11, m12, m13,
            m20, m21, m22, m23,
            m30, m31, m32, m33,
        );
    }
}
