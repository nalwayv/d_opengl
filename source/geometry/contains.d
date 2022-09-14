/// Contains
module geometry.contains;


import maths.utils;
import maths.vec3;
import geometry.aabb;
import geometry.sphere;
import geometry.line;
import geometry.plane;
import geometry.ray;


/// test if AABB 'a1 contains AABB 'a2
/// Returns: bool
bool containsAABBAABB(AABB ab1, AABB ab2)
{
    Vec3 aa = ab1.min();
    Vec3 ab = ab1.max();
    Vec3 ba = ab2.min();
    Vec3 bb = ab2.max();

    auto checkX = aa.x <= ba.x && ab.x >= bb.x;
    auto checkY = aa.y <= ba.y && ab.y >= bb.y;
    auto checkZ = aa.z <= ba.z && ab.z >= bb.z;

    return checkX && checkY && checkZ;
}

/// test if aabb contains point
/// Returns: bool
bool containsAABBPoint(AABB ab, Vec3 pt)
{
    Vec3 pMin = ab.min();
    Vec3 pMax = ab.max();

    auto more = pt.x > pMin.x && pt.y > pMin.y && pt.z > pMin.z;
    auto less = pt.x < pMax.x && pt.y < pMax.y && pt.z < pMax.z;

    return more && less;
}

/// test if sphere contains point
/// Returns: bool
bool containsSpherePoint(Sphere sph, Vec3 pt)
{
    auto disSq = pt.subbed(sph.origin).lengthSq();
    return disSq < sqrF(sph.radius);
}

/// test if point is on plane
/// Returns: bool
bool onPlanePoint(Plane pl, Vec3 pt)
{
    auto dis = pt.dot(pl.normal);
    return isEquilF(dis - pl.d, 0.0f);
}

/// test if point is on line
/// Returns: bool
bool onLinePoint(Line ln, Vec3 pt)
{
    Vec3 close = ln.closestPt(pt);
    auto disSq = close.subbed(pt).lengthSq();
    return isZeroF(disSq);
}

/// test if point is on ray
/// Returns: bool
bool onRayPoint(Ray r, Vec3 pt)
{
    Vec3 op = pt.subbed(r.origin);
    if(!op.isNormal())
    {
        op = op.normalized();
    }

    auto dis = op.dot(r.direction);

    return isOneF(dis);
}