/// CAMERA
// TODO(...)
module camera;


import bindbc.glfw;
import maths.utils;
import maths.vec3;
import maths.mat4;


enum float SPEED = 5.0f;
enum float SENSITIVITY = 2500.0f;
enum float ZOOM = 50.0f;
enum : int
{
    CAM_FORWARD = 0,
    CAM_BACKWARD = 1,
    CAM_LEFT = 2,
    CAM_RIGHT = 3,
}
enum : int
{
    CAM_IN = 0,
    CAM_OUT = 1
}


class Camera
{
    private
    {
        Vec3 position;
        Vec3 up;
        Vec3 front;
        Vec3 right;

        float screenWidth;
        float screenHeight;

        float fov;
        float nearZ;
        float farZ;

        float yaw;
        float pitch;

        float resetZ;
    }

    this(float x, float y, float z, float screenW, float screenH)
    {
        right = Vec3(1.0f, 0.0f,  0.0f);
        up = Vec3(0.0f, 1.0f,  0.0f);
        front = Vec3(0.0f, 0.0f, -1.0f);
        position = Vec3(x, y, z);

        screenWidth = screenW;
        screenHeight = screenH;

        fov = PHI;
        nearZ = 0.1f;
        farZ = 1000.0f;

        yaw = -90.0f;
        pitch = 0.0f;

        resetZ = position.z;
    }

    public void transform(int dir, float dt)
    {
        Vec3 tr;
        auto by = SPEED * dt;

        // z forward
        if(dir == CAM_FORWARD)
        {
            tr = front.scaled(by);
        }
        // z backward
        else if(dir == CAM_BACKWARD)
        {
            tr = front.negated().scaled(by);
        }
        // x left
        else if(dir == CAM_LEFT)
        {
            tr = front.cross(up).scaled(by);

        }
        // x right
        else if(dir == CAM_RIGHT)
        {
            tr = front.cross(up).negated().scaled(by);
        }
        else 
        {
            tr.x = 0.0f;
            tr.y = 0.0f;
            tr.z = 0.0f;
        }

        position = position.added(tr);
    }

    public void zoom(int dir, float dt)
    {
        float d;
        auto by = ZOOM * dt;

        if(dir == CAM_IN)
        {
            d = 1.0f;
        }
        else if(dir == CAM_OUT)
        {
            d = -1.0f;
        }
        else
        {
            d = 0.0f;
        }

        d *= by;
        fov -= toRad(d);
        fov = clampF(fov, toRad(5.0f), PHI);
    }

    public void rotate(float x, float y, float dt)
    {
        auto px = (y - screenHeight / 2) / screenHeight;
        auto py = (x - screenWidth / 2) / screenWidth;
        auto by = SENSITIVITY * dt;

        px *= by;
        py *= by;

        yaw -= py;
        pitch += px;

        pitch = clampF(pitch, -89.0f, 89.0f);

        front.x = cosF(toRad(yaw)) * cosF(toRad(pitch));
        front.y = sinF(toRad(pitch));
        front.z = sinF(toRad(yaw)) * cosF(toRad(pitch));

        front = front.normalized();
    }

    public void reset()
    {
        right = Vec3(1.0f, 0.0f,  0.0f);
        up = Vec3(0.0f, 1.0f,  0.0f);
        front = Vec3(0.0f, 0.0f, -1.0f);
        position = Vec3(0.0f, 0.0f, resetZ);

        fov = PHI;
        nearZ = 0.1f;
        farZ = 100.0f;

        yaw = -90.0f;
        pitch = 0.0f;
    }

    public Mat4 matrix()
    {
        auto view =  Mat4.lookAt(position, position.added(front), up);
        auto projection =  Mat4.perspective(fov, screenWidth/screenHeight, nearZ, farZ);

        return view.multiplied(projection);
    }
}
