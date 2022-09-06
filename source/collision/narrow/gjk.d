/// Gjk
module collision.narrow.gjk;

// TODO()
import collision.narrow.imeshcollider;
import maths.utils;
import maths.vec3;


enum float EPA_OPTIMAL = 0.001f;
enum int GJK_ITERATIONS = 30;
enum : int
{
    A = 0,
    B = 1,
    C = 2,
    D = 3,
}


private struct EdgedData
{
    Vec3 normal;
    float distance;
    size_t idx;
}


class Gjk
{
    private 
    {
        Vec3[] simplex;
        Vec3 direction;
        IMeshCollider mcA;
        IMeshCollider mcB;
    }

    this(IMeshCollider a, IMeshCollider b)
    {
        mcA = a;
        mcB = b;
        direction = Vec3(1.0f, 0.0f, 0.0f);
    }

    public void setSupportA(IMeshCollider a)
    {
        mcA = a;
    }

    public void setSupportB(IMeshCollider b)
    {
        mcB = b;
    }
    
    // --- helpers

    /// return support pt
    /// Returns: Vec3
    private Vec3 getSupport()
    {
        auto a = mcA.furthestPt(direction);
        auto b = mcB.furthestPt(direction.negated());

        return a.subbed(b);
    }


    /// find nearest edge
    private EdgedData nearestEdge()
    {
        assert(simplex.length == 4);

        auto distance = MAXFLOAT;
        size_t idx = 0;
        Vec3 normal;

        for(auto i = 0; i < simplex.length; i++)
        {
            size_t j = (i+1) % simplex.length;
            Vec3 a = simplex[i];
            Vec3 b = simplex[j];
            
            auto edge = b.subbed(a);
            if(isZeroF(edge.lengthSq()))
            {
                continue;
            }

            auto n = Vec3.normalFromPts(edge, a, edge);

            if(isZeroF(n.lengthSq()))
            {
                n.y = -edge.x;
                n.x = n.y;

                auto center = Vec3.barycenter(simplex[D], simplex[C], simplex[B], simplex[A]);
                auto ac = a.subbed(center);
                if(n.dot(ac) < 0.0f)
                {
                    n.y = -n.y;
                    n.x = -n.x;
                }
            }

            auto d = absF(n.dot(a));
            if(d < distance)
            {
                distance = d;
                idx = j;
                normal = n;
            }
        }

        return EdgedData(normal, distance, idx);
    }

    /// return a triple cross product between 'a,'b and 'c
    /// Returns: Vec3
    private Vec3 tripleCross(Vec3 a, Vec3 b)
    {
        return a.cross(b).cross(a);
    }

    /// check for same direction
    /// Returns: bool
    private bool sameDirection(Vec3 a, Vec3 b)
    {
        return a.dot(b) > 0.0f;
    }

    
    /// push a vec3 into simplex while its length is still under 4
    public void push(Vec3 v3)
    {
        simplex ~= v3;
    }

    /// --- simplex

    /// check line if length is 2
    /// Returns: bool
    private bool line()
    {
        if(simplex.length != 2) 
        {
            return false;
        }

        auto a = simplex[B];
        auto b = simplex[A];

        auto ab = b.subbed(a);
        auto an = a.negated();        
        
        if(sameDirection(ab, an))
        {
            direction = tripleCross(ab, an);
        }
        else
        {
            simplex = [a];
            direction = an;
        }

        return false;
    }

    /// check triangle if length is 3
    /// Returns: bool
    private bool triangle()
    {
        if(simplex.length != 3)
        {
            return false;
        }

        auto a = simplex[C];
        auto b = simplex[B];
        auto c = simplex[A];

        auto ab = b.subbed(a);
        auto ac = c.subbed(a);
        auto an = a.negated();

        auto abc = ab.cross(ac);

        if(sameDirection(abc.cross(ac), an))
        {
            if(sameDirection(ac, an))
            {
                simplex = [c, a];
                direction = tripleCross(ac, an);
            }
            else
            {
                simplex = [b, a];
                return line();
            }
        }
        else
        {
            if(sameDirection(ab.cross(abc), an))
            {
                simplex = [b, a];
                return line();
            }
            else
            {
                if(sameDirection(abc, an))
                {
                    direction = abc;
                }
                else
                {
                    simplex = [b, c, a];
                    direction = abc.negated();
                }
            }
        }

        return false;
    }

    /// check tetrahedron if length is 4
    /// Returns: bool
    private bool tetrahedron()
    {
        if(simplex.length != 4)
        {
            return false;
        }

        auto a = simplex[D];
        auto b = simplex[C];
        auto c = simplex[B];
        auto d = simplex[A];

        auto ab = b.subbed(a);
        auto ac = c.subbed(a);
        auto ad = d.subbed(a);
        auto an = a.negated();

        auto abc = ab.cross(ac);
        auto acd = ac.cross(ad);
        auto adb = ad.cross(ab);

        if(sameDirection(abc, an))
        {
            simplex = [c, b, a];
            return triangle(); 
        }

        if(sameDirection(acd, an))
        {
            simplex = [d, c, a];
            return triangle();
        }

        if(sameDirection(adb, an))
        {
            simplex = [b, d, a];
            return triangle();
        }

        return true;
    }

    /// check what simplex is next based on length
    /// Returns: bool
    private bool evolve()
    {
        if(simplex.length == 2)
        {
            return line();
        }

        if(simplex.length == 3)
        {
            return triangle();
        }

        if(simplex.length == 4)
        {
            return tetrahedron();
        }

        return false;
    }
    
    /// --- gjk check

    /// check for a collision between two shapes
    /// Returns: bool
    public bool check()
    {
        simplex.length = 0;
        direction= Vec3(1.0f, 0.0f, 0.0f);

        auto support = getSupport();

        push(support);

        direction = support.negated();

        for(auto i = 0; i < GJK_ITERATIONS; i++)
        {
            support = getSupport();

            if(support.dot(direction) <= 0.0f)
            {
                return false;
            }

            push(support);

            if(evolve())
            {
                // epa();
                auto edge = nearestEdge();
                
                import std.stdio: writeln;

                writeln(edge.distance);
                writeln(edge.idx);
                writeln(edge.normal);
                return true;
            }
        }

        return false;
    }
    
    // --- epa
}   