/// Bits
module utils.bits;


/// helper function to convert float value to size_t
/// Returns: size_t
size_t floatToBits(float value) pure nothrow @safe
{
    if (value == 0.0f)
    {
        return 0;
    }

    union data
    {
        size_t s;
        float f;
    }

    auto result = data();

    result.f = value;
    result.s = result.s ^ (result.s >> 32);

    return result.s;
}
