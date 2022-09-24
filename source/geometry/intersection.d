/// Intersect
module geometry.intersection;


import maths.utils;
import maths.vec3;
import maths.mat3;
import geometry.aabb;
import geometry.sphere;
import geometry.line;
import geometry.obb;
import geometry.plane;
import geometry.frustum;
import geometry.ray;


enum : int
{
    INTERSECTION = 1,
    NO_INTERSECTION = 0
}
enum : int
{
    PLANE_FRONT = 0,
    PLANE_INTERSECT = 1,
    PLANE_BACK = -1,
}


/// ray aabb intersection
/// Returns: float
float rayAabb(Ray ray, AABB ab)
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

/// ray sphere intersection
/// Returns: float
float raySphere(Ray ray, Sphere sph)
{
    auto r2 = sqrF(sph.radius);
    Vec3 dir = sph.origin.subbed(ray.origin);
    auto d2 = dir.lengthSq();

    auto dis = dir.dot(ray.direction);
    auto f2 = r2 - (d2 - sqrF(dis));

    if(f2 < 0.0)
    {
        return 0.0f;
    }

    auto f = sqrtF(f2);
    auto t = (d2 < r2) ? dis + f : dis - f;

    return (t < 0.0f) ? 0.0f : t;
}

/// ray obb intersection
/// Returns: float
float rayObb(Ray ray, Obb ob)
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

            f[i] = EPSILON;
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

/// ray plane intersection
/// Returns: float
float rayPlane(Ray ray, Plane pl)
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


// --


/// line aabb intersection
/// Returns: int
int testLineAabb(Line ln, AABB ab)
{
    Vec3 e = ab.extents;
    Vec3 m = ln.start.added(ln.end).scaled(0.5f);
    Vec3 d = ln.end.subbed(m);
    m = m.subbed(ab.origin);

    auto adx = absF(d.x);
    auto ady = absF(d.y);
    auto adz = absF(d.z);

    if(absF(m.x) > e.x + adx) return 0;
    if(absF(m.y) > e.y + ady) return 0;
    if(absF(m.z) > e.z + adz) return 0;

    adx += EPSILON;
    ady += EPSILON;
    adz += EPSILON;

    Vec3 cross = m.cross(d);

    if(absF(cross.x) > e.y * adz + e.z * ady) return 0;
    if(absF(cross.y) > e.x * adz + e.z * adx) return 0;
    if(absF(cross.z) > e.x * ady + e.y * adx) return 0;

    return 1;
}

/// line sphere intersection
/// Returns: int
int testLineSphere(Line ln, Sphere sph)
{
    Vec3 cp = ln.closestPoint(sph.origin);
    auto disSq = sph.origin.subbed(cp).lengthSq();

    return (disSq <= sqrF(sph.radius)) ? 1 : 0;
}

/// line obb intersection
/// Returns: int
int testLineObb(Line ln, Obb ob)
{
    Ray r;
    r.origin = ln.start;
    r.direction = ln.segment.normalized();

    auto t = rayObb(r, ob);
    
    return (t >= 0.0f && sqrF(t) <= ln.lengthSq()) ? 1 : 0;
}

/// line plane intersection
/// Returns: int
int testLinePlane(Line ln, Plane pl)
{   
    auto ab = ln.segment();
    auto na = pl.normal.dot(ln.start);
    auto nb = pl.normal.dot(ab);

    auto t = (pl.d - na) / nb;
    
    return (t >= 0.0f && t <= 1.0f) ? 1 : 0;
}


// --


/// sphere sphere intersection
/// Returns: int
int testSphereSphere(Sphere sph1, Sphere sph2)
{
    auto disSq = sph1.origin.subbed(sph2.origin).lengthSq();
    auto rSum = sph1.radius + sph2.radius;
    return (disSq < sqrF(rSum)) ? 1 : 0;
}

/// sphere aabb intersection
/// Returns: int
int testSphereAabb(Sphere sph, AABB ab)
{
    Vec3 cp = ab.closestPoint(sph.origin);
    
    auto disSq = sph.origin.subbed(cp).lengthSq();

    return (disSq < sqrF(sph.radius)) ? 1 : 0;
}

/// tsphere obb intersection
/// Returns: int
int testSphereObb(Sphere sph, Obb ob)
{
    Vec3 cp = ob.closestPoint(sph.origin);
    auto disSq = sph.origin.subbed(cp).lengthSq();
    return (disSq < sqrF(sph.radius)) ? 1 : 0;
}

/// sphere plane intersection
/// Returns: int
int testSpherePlane(Sphere sph, Plane pl)
{
    auto dis = pl.normal.dot(sph.origin);
    auto r = sph.radius * pl.normal.length();
    
    if(dis + r < pl.d) 
    {
        return PLANE_BACK;
    }
    
    if(dis - r > pl.d)
    {
        return PLANE_FRONT;
    }

    return PLANE_INTERSECT;
}

/// sphere frustum intersection
/// Returns: int
int testSphereFrustum(Sphere sph, Frustum fr)
{
    for(auto i = 0; i < 6; i++)
    {
        if(spherePlane(sph, fr.planes[i]) == PLANE_BACK)
        {
            return 0;
        }
    }

    return 1;
}

/// sphere frustum intersection accurate
/// Returns: int
int testSphereFrustumAccurate(Sphere sph, Frustum fr)
{
    auto pt = Vec3.zero();
    int[6] m = [1, -1, 1, -1, 1, -1];

    auto r = sph.radius;
    auto c = sph.origin;

    for(auto i = 0; i < 6; i++)
    {
        Plane pl = fr.planes[i];
        auto d = pl.d;
        auto n = pl.normal;
        auto dis = n.dot(c);

        if(dis + r < d)
        {
            return 0;
        }

        if(dis - r > d)
        {
            continue;
        }

        pt = c.added(n.scaled(r));
        
        for(auto j = 0; j < 6; j++)
        {
            if(j == i || j == (i + m[i]))
            {
                continue;
            }

            Vec3 tn = fr.planes[j].normal;
            auto td = fr.planes[j].d;

            if(tn.dot(pt) < td)
            {
                return 0;
            }
        }
    }

    return 1;
}


// --


/// aabb aabb intersection
/// Returns: int
int testAabbAabb(AABB ab1, AABB ab2)
{
    Vec3 amin = ab1.min();
    Vec3 amax = ab1.max();
    Vec3 bmin = ab2.min();
    Vec3 bmax = ab2.max();

    if(amax.x < bmin.x || amin.x > bmax.x)
    { 
        return 0;
    }
    if(amax.y < bmin.y || amin.y > bmax.y)
    { 
        return 0;
    }
    if(amax.z < bmin.z || amin.z > bmax.z)
    { 
        return 0;
    }

    return 1;
}

/// aabb plane intersection
/// Returns: int
int testAabbPlane(AABB ab, Plane pl)
{
    auto enx = ab.extents.x * absF(pl.normal.x);
    auto eny = ab.extents.y * absF(pl.normal.y);
    auto enz = ab.extents.z * absF(pl.normal.z);
    auto r = enx + eny + enz;
    auto dis = pl.normal.dot(ab.origin);

    if(dis + r < pl.d) 
    {
        return PLANE_BACK; 
    }
    if(dis - r > pl.d) 
    {
        return PLANE_FRONT; 
    }

    return PLANE_INTERSECT;
}

/// aabb frustum intersection
/// Returns: int
int testAabbFrustum(AABB ab, Frustum fr)
{
    for(auto i = 0; i < 6; i++)
    {
        if(aabbPlane(ab, fr.planes[i]) == PLANE_BACK)
        {
            return 0;
        }
    }

    return 1;
}

/// aabb frustum intersection accurate
///Returns: int
int testAabbFrustumAccurate(AABB ab, Frustum fr)
{
    const planes = 6;
    const verts = 8;
    auto result = 0;
    auto intersect = false;
    int a;
    int b;

    for(auto i = 0; i < planes; i++)
    {
        result = aabbPlane(ab, fr.planes[i]);

        if(result == PLANE_BACK)
        {
            return 0;
        }

        if(result == PLANE_INTERSECT)
        {
            intersect = true;
        }
    }

    if(!intersect)
    {
        return 1;
    }

    Vec3[verts] tmp;
    for(auto i = 0; i < verts; i++)
    {
        tmp[i] = fr.verts[i].subbed(ab.origin);
    }

    // x
    a = 0;
    b = 0;
    for(auto i = 0; i < verts; i++)
    {
        if(tmp[i].x > ab.extents.x)
        {
            a++;
        }
        else if(tmp[i].x < -ab.extents.x)
        {
            b++;
        }
    }

    if(a == 8 || b == 8)
    {
        return 0;
    }

    // y
    a = 0;
    b = 0;
    for(auto i = 0; i < verts; i++)
    {
        if(tmp[i].y > ab.extents.y)
        {
            a++;
        }
        else if(tmp[i].y < -ab.extents.y)
        {
            b++;
        }
    }

    if(a == 8 || b == 8)
    {
        return 0;
    }

    // z
    a = 0;
    b = 0;
    for(auto i = 0; i < 8; i++)
    {
        if(tmp[i].z > ab.extents.z)
        {
            a++;
        }
        else if(tmp[i].z < -ab.extents.z)
        {
            b++;
        }
    }

    if(a == 8 || b == 8)
    {
        return 0;
    }

    return 1;
}

// --


/// obb obb intersection
/// Returns: int
int testObbObb(Obb ob1, Obb ob2)
{
    float[3][3] r;
    float[3][3] absR;
    float[3] ae = ob1.extents.toArray();
    float[3] be = ob2.extents.toArray();
    float[3] t;

    for(auto i = 0; i < 3; i++)
    {
        for(auto j = 0; j < 3; j++)
        {
            Vec3 rowA = ob1.axis.rowAt(j);
            Vec3 rowB = ob2.axis.rowAt(j);
            r[i][j] = rowA.dot(rowB); 
        }
    }

    Vec3 dir = ob2.origin.subbed(ob1.origin);

    t[0] = dir.dot(ob1.axis.rowAt(0));
    t[1] = dir.dot(ob1.axis.rowAt(1));
    t[2] = dir.dot(ob1.axis.rowAt(2));

    for(auto i = 0; i < 3; i++)
    {
        for(auto j = 0; j < 3; j++)
        {
            absR[i][j] = absF(r[i][j]) + EPSILON;
        }
    }

    float ra, rb;
    for(auto i = 0; i < 3; i++)
    {
        ra = ae[i];
        
        rb = (
            be[0] * absR[i][0] + 
            be[1] * absR[i][1] + 
            be[2] * absR[i][2]
        );
        
        if(absF(t[i]) > ra + rb)
        {
            return 0;
        }
    }


    for(auto i = 0; i < 3; i++)
    {
        ra = (
            ae[0] * absR[0][i] + 
            ae[1] * absR[1][i] + 
            ae[2] * absR[2][i]
        );
        
        rb = be[i];
        
        auto check = (
            t[0] * r[0][i] +
            t[1] * r[1][i] +
            t[2] * r[2][i]
        );

        if(absF(check) > ra + rb)
        {
            return 0;
        }
    }

    ra = ae[1] * absR[2][0] + ae[2] * absR[1][0];
    rb = be[1] * absR[0][2] + be[2] * absR[0][1];
    if(absF(t[2] * r[1][0] - t[1] * r[2][0]) > ra + rb)
    {
        return 0;
    }

    ra = ae[1] * absR[2][1] + ae[2] * absR[1][1];
    rb = be[0] * absR[0][2] + be[2] * absR[0][0];
    if(absF(t[2] * r[1][1] - t[1] * r[2][1]) > ra + rb)
    {
        return 0;
    }

    ra = ae[1] * absR[2][2] + ae[2] * absR[1][2];
    rb = be[0] * absR[0][1] + be[1] * absR[0][0];
    if(absF(t[2] * r[1][2] - t[1] * r[2][2]) > ra + rb)
    {
        return 0;
    }

    ra = ae[0] * absR[2][0] + ae[2] * absR[0][0];
    ra = be[1] * absR[1][2] + be[2] * absR[1][1];
    if(absF(t[0] * r[2][0] - t[2] * r[0][0]) > ra + rb)
    {
        return 0;
    }

    ra = ae[0] * absR[2][1] + ae[2] * absR[0][1];
    rb = be[0] * absR[1][2] + be[2] * absR[1][0];
    if(absF(t[0] * r[2][1] - t[2] * r[0][1]) > ra + rb)
    {
        return 0;
    }

    ra = ae[0] * absR[2][2] + ae[2] * absR[0][2];
    rb = be[0] * absR[1][1] + be[1] * absR[1][0];
    if(absF(t[0] * r[2][2] - t[2] * r[0][2]) > ra + rb)
    {
        return 0;
    }

    ra = ae[0] * absR[1][0] + ae[1] * absR[0][0];
    rb = be[1] * absR[2][2] + be[2] * absR[2][1];
    if(absF(t[1] * r[0][0] - t[0] * r[1][0]) > ra + rb)
    {
        return 0;
    }

    ra = ae[0] * absR[1][1] + ae[1] * absR[0][1];
    rb = be[0] * absR[2][2] + be[2] * absR[2][0];
    if(absF(t[1] * r[0][1] - t[0] * r[1][1]) > ra + rb)
    {
        return 0;
    }

    ra = ae[0] * absR[1][2] + ae[1] * absR[0][2];
    rb = be[0] * absR[2][1] + be[1] * absR[2][0];
    if(absF(t[1] * r[0][2] - t[0] * r[1][2]) > ra + rb)
    {
        return 0;
    }

    return 1;
}

/// obb plane intersection
/// Returns: int
int testObbPlane(Obb ob, Plane pl)
{
    Vec3 ex = ob.extents;
    Vec3 n = pl.normal;
    Mat3 ax = ob.axis;

    auto rx = ex.x * absF(n.dot(ax.row0()));
    auto ry = ex.y * absF(n.dot(ax.row1()));
    auto rz = ex.z * absF(n.dot(ax.row2()));

    auto r = rx + ry + rz;
    auto dis = n.dot(ob.origin);
    
    if(dis + r < pl.d)
    {
        return PLANE_BACK;
    }
    if(dis - r > pl.d)
    {
        return PLANE_FRONT;
    }

    return PLANE_INTERSECT;
}