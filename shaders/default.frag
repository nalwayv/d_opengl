# version 430 core

in vec3 bcol;
out vec4 ccol;

void main(void)
{
    ccol = vec4(bcol, 1.0);
}