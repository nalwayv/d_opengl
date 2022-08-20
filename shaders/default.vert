# version 430 core

layout (location = 0) in vec3 apos;
layout (location = 1) in vec3 acol;

out vec3 bcol;

// uniform mat4 cmatrix;

void main(void)
{

    gl_Position = vec4(apos, 1.0);

    bcol = acol;
}