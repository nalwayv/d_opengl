/// Utils
module maths.utils;


import std.math;



/// small float value near zero
enum float EPSILON = float.epsilon;

/// max float value
enum float MAXFLOAT = float.max;

/// min float value
enum float MINFLOAT = float.max * -1.0f;

/// infinity float value
enum float INFINITY = float.infinity;

/// pi
enum float PI = 3.14159265358979323846f;

/// pi / 2
enum float PHI = 1.57079632679489661923f;

/// pi * 2
enum float TAU = 6.28318530717958647693f;

/// radian value
enum float RAD = PI/180.0f;

/// degree value
enum float DEG = 180.0f/PI;



/// swap float values 'x and 'y using ref's
void swapF(ref float x, ref float y)
{
    const auto tmp = x;
    x = y;
    y = tmp;
}

/// convert deg to rad
float toRad(float value)
{
    return value * RAD;
}

/// convert rad to deg
float toDeg(float value)
{
    return value * DEG;
}

/// return the absolute 'value of float
float absF(float value) pure
{
    return abs!float(value);
}

/// check if float 'value is zero
bool isZeroF(float value)
{
    return absF(value) <= EPSILON;
}

/// check if float 'value one
bool isOneF(float value)
{
    return isZeroF(value - 1.0f);
}

/// check equality of between float values 'x and 'y
bool isEquilF(float x, float y) pure
{
    return absF(x - y) <= EPSILON;
}

/// return min float value between 'x and 'y
float minF(float x, float y)
{
    return (x < y) ? x : y;
}

/// return min int value between 'x and 'y
float minI(int x, int y)
{
    return (x < y) ? x : y;
}

/// return max float value between 'x and 'y
float maxF(float x, float y)
{
    return (x > y) ? x : y;
}

/// return max int value between 'x and 'y
int maxI(int x, int y)
{
    return (x > y) ? x : y;
}

/// return max float value between 'x and 'y
float floorF(float value)
{
    return floor(value);
}

/// clamp 'value between 'min and 'max float values
float clampF(float value, float min, float max)
{
    float result;
    
    if(value < min)
    {
        result = min;
    } 
    else if(value > max)
    {
        result = max;
    } 
    else 
    {
        result = value;
    }
    return result;
}

/// lerp value between 'from and 'to by 'weight
float lerpF(float from, float to, float weight)
{
    return from + weight * (to - from);
}

/// return 'value squared
float sqrF(float value)
{
    return value * value;
}

/// return 'value cubed
float cubeF(float value)
{
    return value * value * value;
}

/// return the sqrt of 'value
float sqrtF(float value)
{
    return sqrt(value);
}

/// return the inverse sqrt of 'value
float invSqrtF(float value)
{
    return 1.0 / sqrtF(value);
}

/// return a normalized float 'value between 'min and 'max
float normalizeF(float value, float min, float max)
{
    return (value - min) / (max - min);
}

/// return cos of 'value
float cosF(float value)
{
    return cos(value);
}

/// return sin of 'value
float sinF(float value)
{
    return sin(value);
}

/// return tan of 'value
float tanF(float value)
{
    return tan(value);
}

/// return arc cos of 'value
float acosF(float value)
{
    return acos(value);
}

/// return arc sin of 'value
float asinF(float value)
{
    return asin(value);
}

/// return arc tan of values 'y and 'x
float atan2F(float y, float x)
{
    return atan2(y, x);
}
