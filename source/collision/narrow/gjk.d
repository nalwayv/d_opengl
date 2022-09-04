/// Gjk
module collision.narrow.gjk;

// TODO()
import collision.narrow.imeshcollider;
import maths.vec3;

enum float GJK_OPTIMAL = 0.001f;
enum int GJK_ITERATIONS = 30;


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
    
    /// return support pt
    /// Returns: Vec3
    private Vec3 getSupport()
    {
        auto a = mcA.furthestPt(direction);
        auto b = mcB.furthestPt(direction.negated());

        return a.subbed(b);
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

    /// check line if length is 2
    /// Returns: bool
    private bool line()
    {
        if(simplex.length != 2) 
        {
            return false;
        }

        auto a = simplex[1];
        auto b = simplex[0];

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

        auto a = simplex[2];
        auto b = simplex[1];
        auto c = simplex[0];

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

        auto a = simplex[3];
        auto b = simplex[2];
        auto c = simplex[1];
        auto d = simplex[0];

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
                return true;
            }
        }

        return false;
    }
}   