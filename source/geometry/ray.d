/// Ray
module geometry.ray;

import std.format;
import maths.utils;
import maths.vec3;
import geometry.aabb;
import geometry.sphere;
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
                    return 0.0f;
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
                    return 0.0f;
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
            return 0.0f;
        }

        auto d = sqrF(b) - c;
        if(d < 0.0f)
        {
            return 0.0f;
        }

        auto tmin = clampF(-b - sqrtF(d), 0.0f, MAXFLOAT);

        return tmin;
    }

    /// cast 'this ray onto a plane to check for collision.
    /// if value > 0 then a hit occurred
    /// Returns: float
    float castPlane(Plane pl)
    {
        auto nd = direction.dot(pl.normal);
        auto pn = origin.dot(pl.normal);
        auto t = (pl.d - pn) / nd;

        float result;

        if(nd >= 0.0)
        {
            result = 0.0f;
        }
        else if(t >= 0.0f)
        {
            result = t;
        }
        else 
        {
            result = 0.0;            
        }

        return result;
    }

    /// return hit point based on t.
    /// use t returned from a cast_fn to get hit point
    /// Returns: Vec3
    Vec3 hit(float t)
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