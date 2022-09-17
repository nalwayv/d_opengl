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
    Vec3 pMin = ab.min();
    Vec3 pMax = ab.max();
    Vec3 o = ray.origin;
    Vec3 d = ray.direction;
    
    auto invX = 1.0f / d.x;
    auto invY = 1.0f / d.y;
    auto invZ = 1.0f / d.z;

    auto t0 = (pMin.x - o.x) * invX;
    auto t1 = (pMax.x - o.x) * invX;
    auto t2 = (pMin.y - o.y) * invY;
    auto t3 = (pMax.y - o.y) * invY;
    auto t4 = (pMin.z - o.z) * invZ;
    auto t5 = (pMax.z - o.z) * invZ;

    auto tMin = maxF(maxF(minF(t0, t1), minF(t2, t3)), minF(t4, t5));
    auto tMax = minF(minF(maxF(t0, t1), maxF(t2, t3)), maxF(t4, t5));

    if(tMax < 0.0f || tMin > tMax)
    {
        return -1.0f;
    }

    return (tMin > 0.0f) ? tMin : tMax;
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
    Vec3 c = ob.origin;
    Vec3 o = ray.origin;
    Vec3 d = ray.direction;

    float[3] size;
    size[0] = ob.extents.x;
    size[1] = ob.extents.y;
    size[2] = ob.extents.z;

    Vec3 x = ob.axis.row0();
    Vec3 y = ob.axis.row1();
    Vec3 z = ob.axis.row2();
    Vec3 dir = c.subbed(o);

    float[3] f;
    f[0] = x.dot(d);
    f[1] = y.dot(d);
    f[2] = z.dot(d);

    float[3] e;
    e[0] = x.dot(dir);
    e[1] = y.dot(dir);
    e[2] = z.dot(dir);

    float[6] t;
    for(auto i = 0; i < 3; i++)
    {
        if(isEquilF(f[i], 0.0f))
        {
            if(-e[i] - size[i] > 0.0f || -e[i] + size[i] < 0.0f)
            {
                return -1.0f;
            }

            f[i] =  0.00001f;
        }

        t[i * 2 + 0] = (e[i] + size[i]) / f[i]; // min
        t[i * 2 + 1] = (e[i] - size[i]) / f[i]; // max
    }

    auto tMin = maxF(maxF(minF(t[0], t[1]), minF(t[2], t[3])), minF(t[4], t[5]));
    auto tMax = minF(minF(maxF(t[0], t[1]), maxF(t[2], t[3])), maxF(t[4], t[5]));

    if(tMax < 0.0f || tMin > tMax)
    {
        return -1.0f;
    }

    return (tMin > 0.0f) ? tMin : tMax;
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
