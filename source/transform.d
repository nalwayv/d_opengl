/// Transform
module transform;

import maths.vec3;
import maths.mat3;
import maths.mat4;


struct Transform
{
    Mat3 basis;
    Vec3 position;

    static Transform newTransform(float x, float y, float z)
    {
        Transform result;

        result.position = Vec3(x, y, z);
        result.basis = Mat3.identity();

        return result;
    }

    /// translate along its x, y and z axis
    void translate(float x, float y, float z)
    {
        Vec3 p;
        
        p.x = x;
        p.y = y;
        p.z = z;

        auto tr = basis.transform(p);

        position = position.added(tr);
    }

    /// rotate around axis
    void rotate(float rad, Vec3 axis)
    {
        basis = basis.rotated(rad, axis);
    }

    /// scale along its x, y and z axis
    void scale(float x, float y, float z)
    {
        basis = basis.scaled(x, y, z);
    }

    /// reset basis
    void reset(float x, float y, float z)
    {
        position.x = x;
        position.y = y;
        position.z = z;
        basis = Mat3.identity();
    }

    /// return mat4 matrix of position, rotation and scale
    Mat4 matrix()
    {
        Mat4 result;

        result.m00 = basis.m00;
        result.m01 = basis.m01;
        result.m02 = basis.m02;
        result.m03 = 0.0f;

        result.m10 = basis.m10;
        result.m11 = basis.m11;
        result.m12 = basis.m12;
        result.m13 = 0.0f;

        result.m20 = basis.m20;
        result.m21 = basis.m21;
        result.m22 = basis.m22;
        result.m23 = 0.0f;

        result.m30 = position.x;
        result.m31 = position.y;
        result.m32 = position.z;
        result.m33 = 1.0f;

        return result;
    }
}