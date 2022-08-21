# version 430 core

layout (location = 0) in vec3 a_Position;
layout (location = 1) in vec3 a_Color;

out vec3 b_Color;

// uniform mat4 cmatrix;
uniform mat4 model_Matrix;
uniform mat4 cam_Matrix;

void main(void)
{
    vec3 m_Position = vec3(model_Matrix * vec4(a_Position , 1.0));

    gl_Position = cam_Matrix * vec4(m_Position, 1.0);

    b_Color = a_Color;
}