/// CAMERA
// TODO(...)
module camera;


import bindbc.glfw;
import maths.utils;
import maths.vec3;
import maths.mat4;


enum float SPEED = 3.2f;
enum float SENSITIVITY = 1000.25f;
enum 
{
    CAM_FORWARD = 0,
    CAM_BACKWARD = 1,
    CAM_LEFT = 2,
    CAM_RIGHT = 3,
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
        farZ = 100.0f;

        yaw = -90.0f;
        pitch = 0.0f;
    }

    public void transform(float dt, int dir)
    {   
        Vec3 tr;

        // z forward
        if(dir == 0)
        {
            tr = front.scaled(SPEED * dt);
        }
        // z backward
        else if(dir == 1)
        {
            tr = front.negated().scaled(SPEED * dt);
        }
        // x left
        else if(dir == 2)
        {
            tr = front.cross(up).scaled(SPEED * dt);

        }
        // x right
        else if(dir == 3)
        {
            tr = front.cross(up).negated().scaled(SPEED * dt);
        }
        else 
        {
            tr.x = 0.0f;
            tr.y = 0.0f;
            tr.z = 0.0f;
        }

        position = position.added(tr);
    }

    public void rotate(float dt, float x, float y)
    {
        x *= SENSITIVITY * dt;
        y *= SENSITIVITY * dt;

        yaw += y;
        pitch += clampF(x, -89.0f, 89.0f);

        front.x = cosF(toRad(yaw)) * cosF(toRad(pitch));
        front.y = sinF(toRad(pitch));
        front.z = sinF(toRad(yaw)) * cosF(toRad(pitch));

        front = front.normalized();
        right = front.cross(Vec3(0, 1, 0)).normalized();
        up = right.cross(front);
    }

    public Mat4 matrix()
    {
        auto view =  Mat4.lookAt(position, position.added(front), up);
        auto projection =  Mat4.perspective(fov, screenWidth / screenHeight, nearZ, farZ);

        return view.multiplied(projection);
    }
}