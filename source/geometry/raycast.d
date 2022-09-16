/// Raycast
module geometry.raycast;


import maths.utils;
import maths.vec3;
import geometry.aabb;
import geometry.sphere;
import geometry.obb;
import geometry.plane;
import geometry.ray;


/// cast ray against an aabb
/// Returns: float
float raycastAABB(Ray ray, AABB ab)
{
    Vec3 pmin = ab.min();
    Vec3 pmax = ab.max();

    auto tmin = 0.0f;
    auto tmax = MAXFLOAT;
    
    for(auto i = 0; i < 3; i++)
    {
        auto dirAt = ray.direction.at(i);
        auto minAt = pmin.at(i);
        auto maxAt = pmax.at(i);
        auto oriAt = ray.origin.at(i);

        if(isZeroF(dirAt))
        {
            if(oriAt < minAt || oriAt > maxAt)
            {
                return -1.0f;
            }
        }
        else
        {
            auto inv = 1.0f / dirAt;

            auto t1 = (minAt - oriAt) * inv;
            auto t2 = (maxAt - oriAt) * inv;

            if(t1 > t2)
            {
                swapF(t1, t2);
            }

            if(t1 > tmin)
            {
                tmin = t1;
            }

            if (t2 > tmax)
            {
                tmax = t2;
            }

            if(tmin > tmax)
            {
                return -1.0f;
            }
        }
    }

    return tmin;
}

/// raycast against a sphere
/// Returns: float
float raycastSphere(Ray ray, Sphere sph)
{
    Vec3 dir = sph.origin.subbed(ray.origin);
    auto rSq = sqrF(sph.radius);
    auto eSq = dir.lengthSq();

    auto dis = dir.dot(ray.direction);
    auto bSq = eSq - sqrF(dis);
    auto f = sqrtF(rSq - bSq);

    if(rSq - (eSq - sqrF(dis)) < 0.0f)
    {
        return -1.0f;
    }

    if(eSq < rSq)
    {
        return dis + f;
    }

    return dis - f;
}

// TODO
/// raycast against an obb
/// Returns: float
float raycastObb(Ray ray, Obb ob)
{

    import std.stdio : writeln;

    Vec3 rx = ob.axis.row0();
    Vec3 ry = ob.axis.row1();
    Vec3 rz = ob.axis.row2();

    float[3] ext;
    ext[0] = ob.extents.x;
    ext[1] = ob.extents.y;
    ext[2] = ob.extents.z;

    Vec3 dir = ob.origin.subbed(ray.origin);

    float[3] f;
    f[0] = rx.dot(ray.direction);
    f[1] = ry.dot(ray.direction);
    f[2] = rz.dot(ray.direction);

    float[3] e;
    e[0] = rx.dot(dir);
    e[1] = ry.dot(dir);
    e[2] = rz.dot(dir);

    float[6] t;
    for(auto i = 0; i < 3; i++)
    {
        if(isZeroF(f[i]))
        {
            if((-e[i] - ext[i]) > 0.0f || (-e[i] + ext[i]) < 0.0f)
            {
                writeln("A");
                return -1.0f;
            }
            f[i] = EPSILON;
        }

        t[i * 2 + 0] = (e[i] + ext[i]) / f[i];
        t[i * 2 + 1] = (e[i] - ext[i]) / f[i];
    }

    auto tMax = maxF(maxF(minF(t[0], t[1]), minF(t[2], t[3])), minF(t[4], t[5]));
    auto tMin = minF(minF(maxF(t[0], t[1]), maxF(t[2], t[3])), maxF(t[4], t[5]));

    if(tMax < 0.0f)
    {
        writeln("B");
        return -1.0f;
    }

    if(tMin > tMax) 
    {
        writeln("C");
        return -1.0f;
    }

    return (tMin < 0.0f) ? tMax : tMin;
}

/// raycast against a plane
/// Returns: float
float raycastPlane(Ray ray, Plane pl)
{
    auto disA = ray.direction.dot(pl.normal);
    auto disB = ray.origin.dot(pl.normal);
    
    if(disA >= 0.0f)
    {
        return -1.0f;
    }

    auto t = (pl.d - disB) / disA;

    return (t >= 0.0f) ? t : -1.0f;
}

/// check if value from raycast if valid
/// Returns: bool
bool raycastCheck(float castValue)
{
    return castValue != -1.0f;
}