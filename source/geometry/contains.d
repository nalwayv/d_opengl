/// Contains
module geometry.contains;


import std.stdio : writeln;
import maths.utils;
import maths.vec3;
import geometry.aabb;
import geometry.sphere;
import geometry.plane;


bool containsAABBAABB(AABB a1, AABB a2)
{
    auto aa = a1.min();
    auto ab = a1.max();
    auto ba = a2.min();
    auto bb = a2.max();

    auto checkX = aa.x <= ba.x && ab.x >= bb.x;
    auto checkY = aa.y <= ba.y && ab.y >= bb.y;
    auto checkZ = aa.z <= ba.z && ab.z >= bb.z;

    return checkX && checkY && checkZ;
}

