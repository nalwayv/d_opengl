/// Line
module geometry.line;


import std.format;
import utils.bits;
import maths.utils;
import maths.vec3;
import maths.mat4;


struct Line
{
    Vec3 start;
    Vec3 end;

    /// Returns: float
    float lengthSq()
    {
        auto ab = end.subbed(start);

        auto x2 = sqrF(ab.x);
        auto y2 = sqrF(ab.y);
        auto z2 = sqrF(ab.z);
        
        return x2 + y2 + z2;
    }

    /// Returns: float
    float length()
    {
        auto ab = end.subbed(start);

        auto x2 = sqrF(ab.x);
        auto y2 = sqrF(ab.y);
        auto z2 = sqrF(ab.z);

        return sqrtF(x2 + y2 + z2);
    }

    /// Returns: Vec3
    Vec3 center()
    {
        return start.added(end).scaled(0.5);
    }

    /// returns closest point on line
    /// Returns: Vec3
    Vec3 closestPt(Vec3 pt)
    {
        Vec3 sp = pt.subbed(start);
        Vec3 se = end.subbed(start);

        auto d00 = se.lengthSq();
        auto d01 = se.dot(sp);

        auto t = d01 / d00;

        Vec3 result;

        if(t < 0.0f)
        {
           result = start; 
        }
        else if(t > 1)
        {
            result = end;
        }
        else
        {
            result = start.added(se).scaled(t);
        }

        return result;
    }

    /// Returns: Line
    Line transformed(Mat4 m4)
    {
        Line result;

        result.start = m4.transform(start);
        result.end = m4.transform(end);
        
        return result;
    }

    // -- override

    size_t toHash() const nothrow @safe
    {
        const prime = 31;
        size_t result = 1;
        size_t tmp;

        tmp = floatToBits(start.x);
        result = prime * result + (tmp ^ (tmp >>> 32));

        tmp = floatToBits(start.y);
        result = prime * result + (tmp ^ (tmp >>> 32));

        tmp = floatToBits(start.z);
        result = prime * result + (tmp ^ (tmp >>> 32));

        tmp = floatToBits(end.x);
        result = prime * result + (tmp ^ (tmp >>> 32));

        tmp = floatToBits(end.y);
        result = prime * result + (tmp ^ (tmp >>> 32));

        tmp = floatToBits(end.z);
        result = prime * result + (tmp ^ (tmp >>> 32));

        return result;
    }

    bool opEquals(ref const Line other) const pure
    {
        auto checkO = isEquilF(start.x, other.start.x) &&
                isEquilF(start.y, other.start.y) &&
                isEquilF(start.z, other.start.z);

        auto checkE = isEquilF(end.x, other.end.x) &&
                isEquilF(end.y, other.end.y) &&
                isEquilF(end.z, other.end.z);

        return checkO && checkE;
    }

    string toString() const pure
    {
        return format(
            "Line [[%.2f, %.2f, %.2f], [%.2f, %.2f, %.2f]]", 
            start.x, start.y, start.z, 
            end.x, end.y, end.z
        );
    }
}