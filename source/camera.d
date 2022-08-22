/// CAMERA
module camera;

import bindbc.glfw;

import maths.utils;
import maths.vec3;
import maths.mat3;
import maths.mat4;

// TODO(...)


enum ROTATION = 1.11701072127637092928; // 64 * RAD
enum SPEED = 1.6f;


class Camera
{
    private 
    {
        Mat3 basis;
        Vec3 position;
        float screenWidth;
        float screenHeight;
        float fov;
        float nearZ;
        float farZ;
        float speed;
    }

    this(float x, float y, float z, float screenW, float screenH)
    {
        basis = Mat3(
            1.0f, 0.0f,  0.0f, // 0: right
            0.0f, 1.0f,  0.0f, // 1: up
            0.0f, 0.0f, -1.0f  // 2: front
        );
        position = Vec3(x, y, z);

        screenWidth = screenW;
        screenHeight = screenH;
        fov = PHI;
        nearZ = 0.1f;
        farZ = 100.0f;
    }

    public void transform(float dt, float x, float y, float z)
    {   
        auto axis = Vec3(x, y, z).normalized();
        position = position.added(basis.transform(axis.scaled(SPEED * dt)));
    }

    public void rotate(float dt, float x, float y, float z)
    {
        auto axis = Vec3(x,y,z).normalized();
        basis = basis.rotated(ROTATION * dt, axis);

        // update basis
        auto right = basis.row0();
        auto up = basis.row1();
        Vec3 front = basis.row2();

        if(!front.isNormal())
        {
            front = front.normalized();
        }

        right = front.cross(Vec3(0.0f, 1.0f, 0.0f));
        if(!right.isNormal())
        {
            right = right.normalized();
        }

        up = right.cross(front);

        basis.m00 = right.x;
        basis.m01 = right.y;
        basis.m02 = right.z;
        basis.m10 = up.x;
        basis.m11 = up.y;
        basis.m12 = up.z;
        basis.m20 = front.x;
        basis.m21 = front.y;
        basis.m22 = front.z;
    }

    public Mat4 matrix()
    {
        auto up = basis.row1();
        auto front = basis.row2();

        auto view =  Mat4.lookAt(position, position.added(front), up);
        auto projection =  Mat4.perspective(fov, screenWidth / screenHeight, nearZ, farZ);

        return view.multiplied(projection);
    }
}