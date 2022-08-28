# version 430 core

layout (location = 0) in vec3 a_Position;

out vec3 b_Color;

uniform mat4 model_Mat4;
uniform mat4 cam_Mat4;
uniform vec3 color_Vec3;

void main(void)
{
    vec3 m_Position = vec3(model_Mat4 * vec4(a_Position , 1.0));

    gl_Position = cam_Mat4 * vec4(m_Position, 1.0);

    b_Color = color_Vec3;
}