/// Ray
module geometry.ray;

import std.format;
import maths.utils;
import maths.vec3;
import geometry.aabb;
import geometry.sphere;
import geometry.capsule;
import geometry.plane;

struct Ray
{
    Vec3 origin;
    Vec3 direction;

    /// direction sould be normalized
    this(Vec3 origin, Vec3 direction)
    {
        if(!direction.isNormal())
        {
            direction = direction.normalized();
        }
        
        this.origin.x = origin.x;
        this.origin.y = origin.y;
        this.origin.z = origin.z;

        this.direction.x = direction.x;
        this.direction.y = direction.y;
        this.direction.z = direction.z;
    }

    static Ray fromPoints(Vec3 a, Vec3 b)
    {
        Vec3 o = a;
        Vec3 d = b.subbed(a).normalized();

        Ray result;

        result.origin = o;
        result.direction = d;
        
        return result;
    }

    /// Returns: Ray
    Ray normalized(Ray r)
    {
        Vec3 o = r.origin;
        Vec3 d = r.direction;

        if(!d.isNormal())
        {
            d = d.normalized();
        }

        Ray result;

        result.origin = o;
        result.direction = d;
        
        return result;
    }

    /// returns point on ray that is closest to given point
    /// Returns: Vec3
    Vec3 closestPoint(Vec3 pt)
    {
        Vec3 op = pt.subbed(origin);
        auto dis = op.dot(direction);
        auto t = maxF(dis, 0.0f);

        Vec3 result;

        result.x = origin.x + direction.x * t;
        result.y = origin.y + direction.y * t;
        result.z = origin.z + direction.z * t;

        return result;
    }

    /// cast 'this ray onto an aabb to check for collision.
    /// if value > 0 then a hit occurred
    /// Returns: float
    float castAABB(AABB ab)
    {
        Vec3 pmin = ab.min();
        Vec3 pmax = ab.max();

        auto tmin = 0.0f;
        auto tmax = MAXFLOAT;
        
        for(auto i = 0; i < 3; i++)
        {
            auto dirAt = direction.at(i);
            auto minAt = pmin.at(i);
            auto maxAt = pmax.at(i);
            auto oriAt = origin.at(i);

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

    /// cast 'this ray onto a sphere to check for collision.
    /// if value > 0 then a hit occurred
    /// Returns: float
    float castSphere(Sphere sph)
    {
        Vec3 a = origin.subbed(sph.origin);
        auto b = a.dot(direction);
        auto c = a.lengthSq() - sqrF(sph.radius);

        if(c > 0.0f && b > 0.0f)
        {
            return -1.0f;
        }

        auto d = sqrF(b) - c;
        if(d < 0.0f)
        {
            return -1.0f;
        }

        auto tmin = -b - sqrtF(d);
        if(tmin < 0.0)
        {
            tmin = 0.0f;
        }

        return tmin;
    }

    /// Returns: float
    float castCapsule(Capsule cap)
    {
        Vec3 ab = cap.b.subbed(cap.a);
        Vec3 ao = origin.subbed(cap.a);
        auto abLen = ab.lengthSq();

        if(isZeroF(abLen))
        {
            return castSphere(Sphere(cap.radius, cap.a));
        }

        auto inv = 1.0f / abLen;
        auto m = ab.dot(direction) * inv;
        auto n = ab.dot(ao) * inv;

        auto q = direction.subbed(ab.scaled(m));
        auto r = ao.subbed(ab.scaled(n));

        auto ca = q.lengthSq();
        auto cb = 2 * q.dot(r);
        auto cc = r.lengthSq() * sqrF(cap.radius);

        if(isZeroF(ca))
        {
            auto castA = castSphere(Sphere(cap.radius, cap.a));
            auto castB = castSphere(Sphere(cap.radius, cap.b));

            if(castA <= 0 && castB <= 0)
            {
                return 0.0f;
            }

            if(castB < castA)
            {
                return castB;
            }

            if(castA < castB)
            {
                return castA;
            }
        }

        auto d = cb * cb - 4.0f * ca * cc;

        if(d < 0.0f)
        {
            return -1.0f;
        }

        auto dSq = sqrtF(d);

        auto t1 = (-cb - dSq) / (2.0f * ca);
        auto t2 = (-cb + dSq) / (2.0f * ca);

        auto tMin = minF(t1, t2);

        auto tp = tMin * m + n;

        if(tp < 0.0f)
        {
            return castSphere(Sphere(cap.radius, cap.a));
        }
        else if(tp > 1.0f)
        {
            return castSphere(Sphere(cap.radius, cap.b));
        }
        else
        {
            auto i = origin.added(direction.scaled(tMin));
            return i.length();
        }
    }

    /// Returns: float
    float castPlane(Plane pla)
    {
        auto nd = direction.dot(pla.normal);
        auto no = origin.dot(pla.normal);
        
        if(nd >= 0.0f)
        {
            return -1.0f;
        }

        auto t = (pla.d - no) / nd;

        return (t > 0.0f) ? t : -1.0f;
    }

    /// return hit point based on t.
    /// use t returned from a cast_fn to get hit point
    /// Returns: Vec3
    Vec3 getHit(float t)
    {
        Vec3 result;

        result.x = origin.x + direction.x * t;
        result.y = origin.y + direction.y * t;
        result.z = origin.z + direction.z * t;

        return result;
    }

    /// Returns: string
    string toString() const pure
    {
        return format(
            "Ray [[%.2f, %.2f, %.2f], [%.2f, %.2f, %.2f]]",
            origin.x, origin.y, origin.z,
            direction.x, direction.y, direction.z,
        );
    }
}