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

    this(Vec3 position, float screenW, float screenH)
    {
        this.position = position;
        orientation = Vec3(0.0f, 0.0f, -1.0f);
        up = Vec3(0.0f, 1.0f, 0.0f);

        screenWidth = screenW;
        screenHeight = screenH;
        fov = PHI;
        nearZ = 0.1f;
        farZ = 100.0f;
        speed = 0.1f;
    }

    void translateUp()
    {
        auto os = orientation.scaled(speed);
        position = position.added(os);
    }

    void translateDown()
    {
        auto os = orientation.negated().scaled(speed);
        position = position.added(os);
    }

    Mat4 matrix()
    {
        auto v =  Mat4.lookAt(position, position.added(orientation), up);
        auto p =  Mat4.perspective(fov, screenWidth/screenHeight, nearZ, farZ);

        return p.multiplied(v);
    }
}