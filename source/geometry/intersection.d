/// Intersect
module geometry.intersection;


import maths.utils;
import maths.vec3;
import geometry.aabb;
import geometry.sphere;
import geometry.plane;


/// test if aabb intersects aabb
/// Returns: bool
bool intersectsAabbAabb(AABB a1, AABB a2)
{
    auto aa = a1.min();
    auto ab = a1.max();
    auto ba = a2.min();
    auto bb = a2.max();

    auto checkX = aa.x <= bb.x && ab.x >= ba.x;
    auto checkY = aa.y <= bb.y && ab.y >= ba.y;
    auto checkZ = aa.z <= bb.z && ab.z >= ba.z;

    return checkX && checkY && checkZ;
}

/// test if aabb intersects sphere
/// Returns: bool
bool intersectsAabbSphere(AABB a, Sphere s)
{
    return a.sqDistPt(s.origin) <= sqrF(s.radius);
}

/// test if aabb intersects plane
/// Returns: bool
bool intersectsAabbPlane(AABB a, Plane p)
{
    Vec3 c = a.origin;
    Vec3 e = a.max().subbed(c);

    auto x = e.x * absF(p.normal.x);
    auto y = e.y * absF(p.normal.y);
    auto z = e.z * absF(p.normal.z);

    auto r = x + y + z;
    auto s = p.normal.dot(c) - p.d;

    return absF(s) <= r;
}

/// test if sphere intersects sphere
/// Returns: bool
bool intersectSphereSphere(Sphere s1, Sphere s2)
{
    auto o1 = s1.origin;
    auto o2 = s2.origin;

    auto d = o1.subbed(o2).lengthSq();

    return d <= sqrF(s1.radius + s2.radius);
}

/// test if sphere intersects plane
/// Returns: bool
bool intersectSpherePlane(Sphere s, Plane p)
{
    auto d = s.origin.dot(p.normal) - p.d;
    return absF(d) <= s.radius;
}
