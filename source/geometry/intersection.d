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
import geometry.raycast;


/// test if aabb and aabb intersect
/// Returns: bool
bool intersectsAabbAabb(AABB ab1, AABB ab2)
{
    Vec3 amin = ab1.min();
    Vec3 amax = ab1.max();
    Vec3 bmin = ab2.min();
    Vec3 bmax = ab2.max();

    if(amax.x < bmin.x || amin.x > bmax.x)
    { 
        return false;
    }
    if(amax.y < bmin.y || amin.y > bmax.y)
    { 
        return false;
    }
    if(amax.z < bmin.z || amin.z > bmax.z)
    { 
        return false;
    }

    return true;
}

/// test if aabb and sphere intersect
/// Returns: bool
bool intersectsAabbSphere(AABB ab, Sphere sph)
{
    Vec3 cp = ab.closestPoint(sph.origin);
    auto disSq = sph.origin.subbed(cp).lengthSq();
    return disSq < sqrF(sph.radius);
}

/// test if aabb and line intersect
/// Returns: bool
bool intersectAABBLine(AABB ab, Line ln)
{
    Vec3 e = ab.extents;
    Vec3 m = ln.start.added(ln.end).scaled(0.5f);
    Vec3 d = ln.end.subbed(m);
    m = m.subbed(ab.origin);

    auto adx = absF(d.x);
    auto ady = absF(d.y);
    auto adz = absF(d.z);

    if(absF(m.x) > e.x + adx) return false;
    if(absF(m.y) > e.y + ady) return false;
    if(absF(m.z) > e.z + adz) return false;

    adx += EPSILON;
    ady += EPSILON;
    adz += EPSILON;

    Vec3 cross = m.cross(d);

    if(absF(cross.x) > e.y * adz + e.z * ady) return false;
    if(absF(cross.y) > e.x * adz + e.z * adx) return false;
    if(absF(cross.z) > e.x * ady + e.y * adx) return false;

    return true;
}

/// test if aabb and plane intersect
/// Returns: bool
bool intersectsAabbPlane(AABB ab, Plane pl)
{
    auto enx = ab.extents.x * absF(pl.normal.x);
    auto eny = ab.extents.y * absF(pl.normal.y);
    auto enz = ab.extents.z * absF(pl.normal.z);
    auto r = enx + eny + enz;
    auto dis = pl.normal.dot(ab.origin);

    if(dis + r < pl.d) 
    {
        return false; 
    }
    if(dis - r > pl.d) 
    {
        return false; 
    }

    return true;
}

/// test if sphere and sphere intersect
/// Returns: bool
bool intersectSphereSphere(Sphere sph1, Sphere sph2)
{
    auto disSq = sph1.origin.subbed(sph2.origin).lengthSq();
    auto rSum = sph1.radius + sph2.radius;
    return disSq < sqrF(rSum);
}

/// test if line and sphere intersect
/// Returns: bool
bool intersectSphereLine(Sphere sph, Line ln)
{
    Vec3 cp = ln.closestPoint(sph.origin);
    auto disSq = sph.origin.subbed(cp).lengthSq();

    return disSq <= sqrF(sph.radius);
}

/// test if sphere and obb intersect
/// Returns: bool
bool intersectSphereObb(Sphere sph, Obb ob)
{
    Vec3 cp = ob.closestPoint(sph.origin);
    auto disSq = sph.origin.subbed(cp).lengthSq();
    return disSq < sqrF(sph.radius);
}

/// test if sphere and plane intersect
/// Returns: bool
bool intersectSpherePlane(Sphere sph, Plane pl)
{
    auto cp = pl.closestPoint(sph.origin);
    auto disSq = sph.origin.subbed(cp).lengthSq();
    return disSq < sqrF(sph.radius);
}

/// test if obb and obb intersect
/// Returns: bool
bool intersectObbObb(Obb ob1, Obb ob2)
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
            return false;
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
            return false;
        }
    }

    ra = ae[1] * absR[2][0] + ae[2] * absR[1][0];
    rb = be[1] * absR[0][2] + be[2] * absR[0][1];
    if(absF(t[2] * r[1][0] - t[1] * r[2][0]) > ra + rb)
    {
        return false;
    }

    ra = ae[1] * absR[2][1] + ae[2] * absR[1][1];
    rb = be[0] * absR[0][2] + be[2] * absR[0][0];
    if(absF(t[2] * r[1][1] - t[1] * r[2][1]) > ra + rb)
    {
        return false;
    }

    ra = ae[1] * absR[2][2] + ae[2] * absR[1][2];
    rb = be[0] * absR[0][1] + be[1] * absR[0][0];
    if(absF(t[2] * r[1][2] - t[1] * r[2][2]) > ra + rb)
    {
        return false;
    }

    ra = ae[0] * absR[2][0] + ae[2] * absR[0][0];
    ra = be[1] * absR[1][2] + be[2] * absR[1][1];
    if(absF(t[0] * r[2][0] - t[2] * r[0][0]) > ra + rb)
    {
        return false;
    }

    ra = ae[0] * absR[2][1] + ae[2] * absR[0][1];
    rb = be[0] * absR[1][2] + be[2] * absR[1][0];
    if(absF(t[0] * r[2][1] - t[2] * r[0][1]) > ra + rb)
    {
        return false;
    }

    ra = ae[0] * absR[2][2] + ae[2] * absR[0][2];
    rb = be[0] * absR[1][1] + be[1] * absR[1][0];
    if(absF(t[0] * r[2][2] - t[2] * r[0][2]) > ra + rb)
    {
        return false;
    }

    ra = ae[0] * absR[1][0] + ae[1] * absR[0][0];
    rb = be[1] * absR[2][2] + be[2] * absR[2][1];
    if(absF(t[1] * r[0][0] - t[0] * r[1][0]) > ra + rb)
    {
        return false;
    }

    ra = ae[0] * absR[1][1] + ae[1] * absR[0][1];
    rb = be[0] * absR[2][2] + be[2] * absR[2][0];
    if(absF(t[1] * r[0][1] - t[0] * r[1][1]) > ra + rb)
    {
        return false;
    }

    ra = ae[0] * absR[1][2] + ae[1] * absR[0][2];
    rb = be[0] * absR[2][1] + be[1] * absR[2][0];
    if(absF(t[1] * r[0][2] - t[0] * r[1][2]) > ra + rb)
    {
        return false;
    }

    return true;
}

/// test if obb and line intersect
/// Returns: bool
bool intersectObbLine(Obb ob, Line ln)
{
    Ray r;
    r.origin = ln.start;
    r.direction = ln.segment.normalized();

    auto t =  raycastObb(r, ob);
    
    return t >= 0.0f && sqrF(t) <= ln.lengthSq();
}


bool intersectObbPlane(Obb ob, Plane pl)
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
        return false;
    }
    if(dis - r > pl.d)
    {
        return false;
    }

    return true;
}

/// test if line and plane intersect
/// Returns: bool
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