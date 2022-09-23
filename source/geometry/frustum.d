/// Frustum
module geometry.frustum;


import std.format;
import utils.bits;
import geometry.plane;
import geometry.aabb;
import maths.utils;
import maths.vec3;
import maths.mat4;


enum size_t PLANES = 6;
enum size_t VERTS = 8;


// TODO
struct Frustum
{
    Plane[PLANES] planes;
    Vec3[VERTS] verts;

    /// create a frustum using ortho values
    /// Returns: Frustum
    static Frustum ortho(float width, float height, float near, float far, Mat4 tr)
    {
        auto hw = width * 0.5f;
        auto hh = height * 0.5f;

        Frustum result;

        result.verts[0] = tr.transform(Vec3(hw, hh -near));
        result.verts[1] = tr.transform(Vec3(-hw, hh -near));
        result.verts[2] = tr.transform(Vec3(-hw, -hh -near));
        result.verts[3] = tr.transform(Vec3(hw, -hh -near));
        result.verts[4] = tr.transform(Vec3(hw, hh, -far));
        result.verts[5] = tr.transform(Vec3(-hw, hh, -far));
        result.verts[6] = tr.transform(Vec3(-hw, -hh, -far));
        result.verts[7] = tr.transform(Vec3(hw, -hh, -far));

        result.planes[0] = Plane.fromPoints(result.verts[1], result.verts[6], result.verts[5]);
        result.planes[1] = Plane.fromPoints(result.verts[3], result.verts[4], result.verts[7]);
        result.planes[2] = Plane.fromPoints(result.verts[6], result.verts[3], result.verts[7]);
        result.planes[3] = Plane.fromPoints(result.verts[0], result.verts[5], result.verts[4]);
        result.planes[4] = Plane.fromPoints(result.verts[2], result.verts[0], result.verts[3]);
        result.planes[5] = Plane.fromPoints(result.verts[7], result.verts[5], result.verts[6]);

        return result;
    }

    static Frustum fromAABB(AABB ab)
    {
        Frustum result;

        Vec3 pMin = ab.min();
        Vec3 pMax = ab.max();

        result.verts[0] = Vec3(pMin.x, pMax.y, pMin.z);
        result.verts[1] = Vec3(pMax.x, pMax.y, pMin.z);
        result.verts[2] = Vec3(pMax.x, pMin.y, pMin.z);
        result.verts[3] = Vec3(pMin.x, pMin.y, pMin.z);
        result.verts[4] = Vec3(pMin.x, pMax.y, pMax.z);
        result.verts[5] = Vec3(pMax.x, pMax.y, pMax.z);
        result.verts[6] = Vec3(pMax.x, pMin.y, pMax.z);
        result.verts[7] = Vec3(pMin.x, pMin.y, pMax.z);

        result.planes[0] = Plane.fromPoints(result.verts[1], result.verts[6], result.verts[5]);
        result.planes[1] = Plane.fromPoints(result.verts[3], result.verts[4], result.verts[7]);
        result.planes[2] = Plane.fromPoints(result.verts[6], result.verts[3], result.verts[7]);
        result.planes[3] = Plane.fromPoints(result.verts[0], result.verts[5], result.verts[4]);
        result.planes[4] = Plane.fromPoints(result.verts[2], result.verts[0], result.verts[3]);
        result.planes[5] = Plane.fromPoints(result.verts[7], result.verts[5], result.verts[6]);

        return result;
    }

    /// update planes based on view projection and inverse view projection
    /// Returns: Frustum
    Frustum updatedPlanes(Mat4 vp, Mat4 invVp)
    {
        auto m = vp.toArrayS();
        
        Frustum result;

        result.planes[0].normal = Vec3(m[3] + m[0], m[7] + m[4], m[11] + m[8]);
        result.planes[1].normal = Vec3(m[3] - m[0], m[7] - m[4], m[11] - m[8]);
        result.planes[2].normal = Vec3(m[3] + m[1], m[7] + m[5], m[11] + m[9]);
        result.planes[3].normal = Vec3(m[3] - m[1], m[7] - m[5], m[11] - m[9]);
        result.planes[4].normal = Vec3(m[3] + m[2], m[7] + m[6], m[11] + m[10]);
        result.planes[5].normal = Vec3(m[3] - m[2], m[7] - m[6], m[11] - m[10]);

        result.planes[0].d = -(m[15] + m[12]);
        result.planes[1].d = -(m[15] - m[12]);
        result.planes[2].d = -(m[15] + m[13]);
        result.planes[3].d = -(m[15] - m[13]);
        result.planes[4].d = -(m[15] + m[14]);
        result.planes[5].d = -(m[15] - m[14]);

        for(auto i = 0; i < PLANES; i++)
        {
            result.planes[i] = result.planes[i].normalized();
        }

        Vec3[VERTS] p;
        p[0] = Vec3(1.0f, 1.0f, 1.0f);
        p[1] = Vec3(-1.0f, 1.0f, 1.0f);
        p[2] = Vec3(-1.0f, -1.0f, 1.0f);
        p[3] = Vec3(1.0f, -1.0f, 1.0f);
        p[4] = Vec3(1.0f, 1.0f, -1.0f);
        p[5] = Vec3(-1.0f, 1.0f, -1.0f);
        p[6] = Vec3(-1.0f, -1.0f, -1.0f);
        p[7] = Vec3(1.0f, -1.0f, -1.0f);

        for(auto i = 0; i < VERTS; i++)
        {
            result.verts[i] = invVp.transform(p[i]);
        }

        return result;
    }

    Frustum transformed(Mat4 m4)
    {
        Frustum result;

        for(auto i = 0; i < VERTS; i++)
        {
            result.verts[i] = m4.transform(verts[i]);
        }

        result.planes[0] = Plane.fromPoints(result.verts[1], result.verts[6], result.verts[5]);
        result.planes[1] = Plane.fromPoints(result.verts[3], result.verts[4], result.verts[7]);
        result.planes[2] = Plane.fromPoints(result.verts[6], result.verts[3], result.verts[7]);
        result.planes[3] = Plane.fromPoints(result.verts[0], result.verts[5], result.verts[4]);
        result.planes[4] = Plane.fromPoints(result.verts[2], result.verts[0], result.verts[3]);
        result.planes[5] = Plane.fromPoints(result.verts[7], result.verts[5], result.verts[6]);

        return result;
    }

    // -- override

    size_t toHash() const nothrow @safe
    {
        const prime = 31;
        size_t result = 1;
        size_t tmp;

        for(auto i = 0; i < PLANES; i++)
        {
            tmp = floatToBits(planes[i].normal.x);
            result = prime * result + (tmp ^ (tmp >>> 32));

            tmp = floatToBits(planes[i].normal.y);
            result = prime * result + (tmp ^ (tmp >>> 32));

            tmp = floatToBits(planes[i].normal.z);
            result = prime * result + (tmp ^ (tmp >>> 32));

            tmp = floatToBits(planes[i].d);
            result = prime * result + (tmp ^ (tmp >>> 32));
        }

        for(auto i = 0; i < VERTS; i++)
        {
            tmp = floatToBits(verts[i].x);
            result = prime * result + (tmp ^ (tmp >>> 32));

            tmp = floatToBits(verts[i].y);
            result = prime * result + (tmp ^ (tmp >>> 32));

            tmp = floatToBits(verts[i].z);
            result = prime * result + (tmp ^ (tmp >>> 32));
        }

        return result;
    }

    bool opEquals(ref const Frustum other) const pure
    {
        for(auto i = 0; i < PLANES; i++)
        {
            if(!isEquilF(planes[i].normal.x, planes[i].normal.x)) return false;
            if(!isEquilF(planes[i].normal.y, planes[i].normal.y)) return false;
            if(!isEquilF(planes[i].normal.z, planes[i].normal.z)) return false;
            if(!isEquilF(planes[i].d, planes[i].d)) return false;
        }

        for(auto i = 0; i < VERTS; i++)
        {
            if(!isEquilF(verts[i].x, verts[i].x)) return false;
            if(!isEquilF(verts[i].y, verts[i].y)) return false;
            if(!isEquilF(verts[i].z, verts[i].z)) return false;
        }

        return true;
    }

    string toString() const pure
    {
        return format(
            "Frustum [
            [%.2f, %.2f, %.2f],
            [%.2f, %.2f, %.2f],
            [%.2f, %.2f, %.2f],
            [%.2f, %.2f, %.2f],
            [%.2f, %.2f, %.2f],
            [%.2f, %.2f, %.2f],
            [%.2f, %.2f, %.2f]
            ]", 
            verts[0].x, verts[0].y, verts[0].z,
            verts[1].x, verts[1].y, verts[1].z,
            verts[2].x, verts[2].y, verts[2].z,
            verts[3].x, verts[3].y, verts[3].z,
            verts[4].x, verts[4].y, verts[4].z,
            verts[5].x, verts[5].y, verts[5].z,
            verts[6].x, verts[6].y, verts[6].z,
            verts[7].x, verts[7].y, verts[7].z,
        );
    }
}