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
import geometry.ray;
import geometry.frustum;
import geometry.raycast;


enum : int
{
    PLANE_FRONT = 0,
    PLANE_INTERSECT = 1,
    PLANE_BACK = -1,
}


/// line aabb intersection
/// Returns: int
int lineAabb(Line ln, AABB ab)
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
int lineSphere(Line ln, Sphere sph)
{
    Vec3 cp = ln.closestPoint(sph.origin);
    auto disSq = sph.origin.subbed(cp).lengthSq();

    return (disSq <= sqrF(sph.radius)) ? 1 : 0;
}

/// line obb intersection
/// Returns: int
int lineObb(Line ln, Obb ob)
{
    Ray r;
    r.origin = ln.start;
    r.direction = ln.segment.normalized();

    auto t = raycastObb(r, ob);
    
    return (t >= 0.0f && sqrF(t) <= ln.lengthSq()) ? 1 : 0;
}

/// line plane intersection
/// Returns: int
int linePlane(Line ln, Plane pl)
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
int sphereSphere(Sphere sph1, Sphere sph2)
{
    auto disSq = sph1.origin.subbed(sph2.origin).lengthSq();
    auto rSum = sph1.radius + sph2.radius;
    return (disSq < sqrF(rSum)) ? 1 : 0;
}

/// sphere aabb intersection
/// Returns: int
int sphereAabb(Sphere sph, AABB ab)
{
    Vec3 cp = ab.closestPoint(sph.origin);
    
    auto disSq = sph.origin.subbed(cp).lengthSq();

    return (disSq < sqrF(sph.radius)) ? 1 : 0;
}

/// tsphere obb intersection
/// Returns: int
int sphereObb(Sphere sph, Obb ob)
{
    Vec3 cp = ob.closestPoint(sph.origin);
    auto disSq = sph.origin.subbed(cp).lengthSq();
    return (disSq < sqrF(sph.radius)) ? 1 : 0;
}

/// sphere plane intersection
/// Returns: int
int spherePlane(Sphere sph, Plane pl)
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
int sphereFrustum(Sphere sph, Frustum fr)
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
int sphereFrustumAccurate(Sphere sph, Frustum fr)
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
int aabbAabb(AABB ab1, AABB ab2)
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
int aabbPlane(AABB ab, Plane pl)
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
int aabbFrustum(AABB ab, Frustum fr)
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

// --


/// obb obb intersection
/// Returns: int
int obbObb(Obb ob1, Obb ob2)
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
int obbPlane(Obb ob, Plane pl)
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