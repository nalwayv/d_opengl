/// Contains
module geometry.contains;


import maths.utils;
import maths.vec3;
import geometry.aabb;
import geometry.sphere;
import geometry.line;
import geometry.obb;
import geometry.plane;
import geometry.ray;


/// is point on plane
/// Returns: bool
bool pointOnPlane(Vec3 pt, Plane pl)
{
    auto dis = pt.dot(pl.normal);
    return isEquilF(dis - pl.d, 0.0f);
}

/// is point on line
/// Returns: bool
bool pointOnLine(Vec3 pt, Line ln)
{
    Vec3 close = ln.closestPoint(pt);
    auto disSq = close.subbed(pt).lengthSq();
    return isZeroF(disSq);
}

/// is point on ray
/// Returns: bool
bool pointOnRay(Vec3 pt, Ray ray)
{
    Vec3 dir = pt.subbed(ray.origin);
    if(!dir.isNormal())
    {
        dir = dir.normalized();
    }

    auto dis = dir.dot(ray.direction);

    return isOneF(dis);
}


// --


/// aabb contains other aabb
/// Returns: bool
bool aabbConatinsAabb(AABB ab1, AABB ab2)
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

/// aabb contains sphere
/// Returns: bool
bool aabbContainsSphere(AABB ab, Sphere sph)
{
    Vec3 pMin = ab.min();
    Vec3 pMax = ab.max();

    if(sph.origin.x - pMin.x <= sph.radius) return false;
    if(sph.origin.y - pMin.y <= sph.radius) return false;
    if(sph.origin.z - pMin.z <= sph.radius) return false;

    if(pMax.x - sph.origin.x <= sph.radius) return false;
    if(pMax.y - sph.origin.y <= sph.radius) return false;
    if(pMax.z - sph.origin.z <= sph.radius) return false;

    return true;
}

/// aabb contains point
/// Returns: bool
bool aabbContainsPoint(AABB ab, Vec3 pt)
{
    Vec3 pMin = ab.min();
    Vec3 pMax = ab.max();

    auto more = pt.x > pMin.x && pt.y > pMin.y && pt.z > pMin.z;
    auto less = pt.x < pMax.x && pt.y < pMax.y && pt.z < pMax.z;

    return more && less;
}


// --

/// sphere contains sphere
/// Returns: bool
bool sphereContainsSphere(Sphere sph1, Sphere sph2)
{
    Vec3 c1 = sph1.origin;
    Vec3 c2 = sph2.origin;
    auto disSq = c2.subbed(c1).lengthSq();
    return disSq <= sqrF(sph1.radius - sph2.radius);
}

/// sphere contrains point
/// Returns: bool
bool sphereContainsPoint(Sphere sph, Vec3 pt)
{
    auto disSq = pt.subbed(sph.origin).lengthSq();
    return disSq < sqrF(sph.radius);
}


// --


/// obb contains point
/// Returns: bool
bool obbContainsPoint(Obb ob, Vec3 pt)
{
    Vec3 dir = pt.subbed(ob.origin);

    for(auto i = 0; i < 3; i++)
    {
        auto dis = dir.dot(ob.axis.rowAt(i));

        auto ext = ob.extents.at(i);
        if(dis > ext)
        {
            return false;
        }

        if(dis < -ext)
        {
            return false;
        }
    }

    return true;
}