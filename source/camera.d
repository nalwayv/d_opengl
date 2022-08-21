module camera;

import maths.utils;
import maths.vec3;
import maths.mat4;

// TODO(...)

class Camera
{
    private Vec3 position;
    private Vec3 orientation;
    private Vec3 up;
    private float screenWidth;
    private float screenHeight;
    private float fov;
    private float nearZ;
    private float farZ;
    private float speed;

    this(float x, float y, float z, float screenW, float screenH)
    {
        position = Vec3(x, y, z);
        orientation = Vec3(0.0f, 0.0f, -1.0f);
        up = Vec3(0.0f, 1.0f, 0.0f);
        screenWidth = screenW;
        screenHeight = screenH;
        fov = PHI;
        nearZ = 0.1f;
        farZ = 100.0f;
        speed = 1.6f;
    }

    void translateIn(float dt)
    {
        auto os = orientation.scaled(speed * dt);
        position = position.added(os);
    }

    void translateOut(float dt)
    {
        auto os = orientation.negated().scaled(speed * dt);
        position = position.added(os);
    }

    void translateRight(float dt)
    {
        auto os = orientation.cross(up).normalized().negated().scaled(speed * dt);
        position = position.added(os);
    }

    void translateLeft(float dt)
    {
        auto os = orientation.cross(up).normalized().scaled(speed * dt);
        position = position.added(os);
    }

    void translateUp(float dt)
    {
        auto ups = up.negated().scaled(speed * dt);
        position = position.added(ups);
    }

    void translateDown(float dt)
    {
        auto ups = up.scaled(speed * dt);
        position = position.added(ups);
    }

    Mat4 matrix()
    {
        auto v =  Mat4.lookAt(position, position.added(orientation), up);
        auto p =  Mat4.perspective(fov, screenWidth / screenHeight, nearZ, farZ);

        return v.multiplied(p);
    }
}