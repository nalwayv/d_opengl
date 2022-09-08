/// Contains
module geometry.contains;


// import maths.utils;
import maths.vec3;
import geometry.aabb;
// import geometry.sphere;
// import geometry.plane;


/// test if AABB 'a1 contains AABB 'a2
/// Returns: bool
bool containsAABBAABB(AABB a1, AABB a2)
{
    Vec3 aa = a1.min();
    Vec3 ab = a1.max();
    Vec3 ba = a2.min();
    Vec3 bb = a2.max();

    auto checkX = aa.x <= ba.x && ab.x >= bb.x;
    auto checkY = aa.y <= ba.y && ab.y >= bb.y;
    auto checkZ = aa.z <= ba.z && ab.z >= bb.z;

    return checkX && checkY && checkZ;
}
