# version 430 core

in vec3 b_Color;

out vec4 c_Color;

void main(void)
{
    c_Color = vec4(b_Color, 1.0);
}