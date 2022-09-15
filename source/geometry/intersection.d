/// Intersect
module geometry.intersection;


import maths.utils;
import maths.vec3;
import geometry.aabb;
import geometry.sphere;
import geometry.line;
import geometry.plane;
import geometry.ray;


/// test if aabb and aabb intersect
/// Returns: bool
bool intersectsAabbAabb(AABB a1, AABB a2)
{
    Vec3 amin = a1.min();
    Vec3 amax = a1.max();
    Vec3 bmin = a2.min();
    Vec3 bmax = a2.max();

    if(amax.x < bmin.x || amin.x > bmax.x) return false;
    if(amax.y < bmin.y || amin.y > bmax.y) return false;
    if(amax.z < bmin.z || amin.z > bmax.z) return false;

    return true;
}

/// test if aabb and sphere intersect
/// Returns: bool
bool intersectsAabbSphere(AABB a, Sphere s)
{
    return a.sqDistPoint(s.origin) <= sqrF(s.radius);
}

/// test if aabb and line intersect
///Returns: bool
bool intersectAABBLine(AABB a, Line l)
{
    Ray r = Ray(l.start, l.end.normalized());
    auto t = r.castAABB(a);

    return t >= 0.0f && sqrF(t) <= l.lengthSq();
}

/// test if aabb and plane intersect
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


/// test if sphere and sphere intersect
/// Returns: bool
bool intersectSphereSphere(Sphere s1, Sphere s2)
{
    Vec3 o1 = s1.origin;
    Vec3 o2 = s2.origin;

    auto d = o1.subbed(o2).lengthSq();

    return d <= sqrF(s1.radius + s2.radius);
}

/// test if sphere and plane intersect
/// Returns: bool
bool intersectSpherePlane(Sphere s, Plane p)
{
    auto d = s.origin.dot(p.normal) - p.d;
    return absF(d) <= s.radius;
}

/// test if line and sphere are intersecting
/// Returns: bool
bool intersectSphereLine(Sphere s, Line l)
{
    Vec3 cp = l.closestPoint(s.origin);
    auto disSq = s.origin.subbed(cp).lengthSq();

    return disSq <= sqrF(s.radius);
}

/// test if line and plane intersect
bool intersectLinePlane(Line l, Plane p)
{   
    auto ab = l.segment();
    auto na = p.normal.dot(l.start);
    auto nb = p.normal.dot(ab);

    auto t = (p.d - na) / nb;
    
    return t >= 0.0f && t <= 1.0f;
}

/// test if plane and plane intersect
/// Returns: bool
bool intersectPlanePlane(Plane pl1, Plane pl2)
{
    Vec3 dir = pl1.normal.cross(pl2.normal);
    return dir.lengthSq() > EPSILON;
}