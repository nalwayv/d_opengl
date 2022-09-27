/// Gjk
// TODO()
module collision.narrow.gjk;


import std.stdio : writeln;
import std.algorithm.mutation : remove;
import collision.narrow.imeshcollider;
import maths.utils;
import maths.vec4;
import maths.vec3;


enum float EPA_OPTIMAL = 0.002f;
enum float EPA_BUFFER = 0.001f;
enum int GJK_ITERATIONS = 30;
enum int EPA_ITERATIONS = 30;


private Vec3 tripleCross(Vec3 a, Vec3 b, Vec3 c)
{
    return a.cross(b).cross(c);
}

private bool sameDirection(Vec3 a, Vec3 b)
{
    return a.dot(b) > 0.0f;
}


private struct Edge
{
    Vec3 a;
    Vec3 b;
}


private struct Triangle
{
    Vec3 a;
    Vec3 b;
    Vec3 c;
    Vec3 n;

    this(Vec3 a, Vec3 b, Vec3 c)
    {
        this.a = a;
        this.b = b;
        this.c = c;

        Vec3 ab = b.subbed(a);
        Vec3 ac = c.subbed(a);
        this.n = ab.cross(ac).normalized();
    }
}


private struct NearestData
{
    float distance;
    int index;
}


private struct Simplex 
{
    Vec3[4] pts;
    int length;

    static Simplex newSimplex()
    {
        Simplex result;

        result.pts[0] = Vec3.zero();
        result.pts[1] = Vec3.zero();
        result.pts[2] = Vec3.zero();
        result.pts[3] = Vec3.zero();

        result.length = 0;

        return result;
    }

    void clear()
    { 
        length = 0; 
    }

    Vec3 a()
    { 
        return pts[0];
    }

    Vec3 b()
    { 
        return pts[1];
    }

    Vec3 c()
    { 
        return pts[2];
    }

    Vec3 d()
    { 
        return pts[3];
    }

    void set(Vec3 a, Vec3 b, Vec3 c, Vec3 d)
    {
        length = 4;

        pts[0] = a;
        pts[1] = b;
        pts[2] = c;
        pts[3] = d;
    }

    void set(Vec3 a, Vec3 b, Vec3 c)
    {
        length = 3;

        pts[0] = a;
        pts[1] = b;
        pts[2] = c;
    }

    void set(Vec3 a, Vec3 b)
    {
        length = 2;

        pts[0] = a;
        pts[1] = b;
    }

    void set(Vec3 a)
    {
        length = 1;

        pts[0] = a;
    }

    /// add support point to simplex
    void push(Vec3 p)
    {
        length = minI(length + 1, 4);

        for(auto i = length - 1; i > 0; i--)
        {
            pts[i] = pts[i - 1];
        }

        pts[0] = p;
    }
}


class Gjk
{
    private 
    {
        Simplex simplex;
        Vec3 direction;
        IMeshCollider mcA;
        IMeshCollider mcB;
    }

    this(IMeshCollider a, IMeshCollider b)
    {
        simplex = Simplex.newSimplex();
        direction = Vec3(1.0f, 0.0f, 0.0f);
        mcA = a;
        mcB = b;
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


    /// return support pt from direction 'dir
    /// Returns: Vec3
    private Vec3 getSupport(Vec3 dir)
    {
        auto a = mcA.farthestPoint(dir);
        auto b = mcB.farthestPoint(dir.negated());

        return a.subbed(b);
    }


    // --- simplex

    /// check line if length is 2
    /// Returns: bool
    private bool solve2()
    {
        if(simplex.length != 2) 
        {
            return false;
        }

        Vec3 a = simplex.a();
        Vec3 b = simplex.b();

        Vec3 ab = b.subbed(a);
        Vec3 ao = a.negated();
        
        if(sameDirection(ab, ao))
        {
            direction = tripleCross(ab, ao, ab);
        }
        else
        {
            simplex.set(a);

            direction = ao;
        }

        return false;
    }

    /// check triangle if length is 3
    /// Returns: bool
    private bool solve3()
    {
        if(simplex.length != 3)
        {
            return false;
        }

        Vec3 a = simplex.a();
        Vec3 b = simplex.b();
        Vec3 c = simplex.c();

        Vec3 ab = b.subbed(a);
        Vec3 ac = c.subbed(a);
        Vec3 ao = a.negated();

        Vec3 abc = ab.cross(ac);

        if(sameDirection(abc.cross(ac), ao))
        {
            if(sameDirection(ac, ao))
            {
                simplex.set(a, c);

                direction = tripleCross(ac, ao, ac);
            }
            else
            {
                simplex.set(a, b);

                return solve2();
            }
        }
        else
        {
            if(sameDirection(ab.cross(abc), ao))
            {
                simplex.set(a, b);

                return solve2();
            }
            else
            {
                if(sameDirection(abc, ao))
                {
                    direction = abc;
                }
                else
                {
                    simplex.set(a, c, b);

                    direction = abc.negated();
                }
            }
        }

        return false;
    }

    /// check tetrahedron if length is 4
    /// Returns: bool
    private bool solve4()
    {
        if(simplex.length != 4)
        {
            return false;
        }

        Vec3 a = simplex.a();
        Vec3 b = simplex.b();
        Vec3 c = simplex.c();
        Vec3 d = simplex.d();

        Vec3 ab = b.subbed(a);
        Vec3 ac = c.subbed(a);
        Vec3 ad = d.subbed(a);
        Vec3 an = a.negated();

        Vec3 abc = ab.cross(ac);
        Vec3 acd = ac.cross(ad);
        Vec3 adb = ad.cross(ab);

        if(sameDirection(abc, an))
        {
            simplex.set(a, b, c);

            return solve3(); 
        }

        if(sameDirection(acd, an))
        {
            simplex.set(a, c, d);

            return solve3();
        }

        if(sameDirection(adb, an))
        {
            simplex.set(a, d, b);

            return solve3();
        }

        return true;
    }

    /// check what simplex is next based on length
    /// Returns: bool
    private bool solve()
    {
        if(simplex.length == 2)
        {
            return solve2();
        }

        if(simplex.length == 3)
        {
            return solve3();
        }

        if(simplex.length == 4)
        {
            return solve4();
        }

        return false;
    }

    // --- gjk

    /// check for a collision between two shapes
    /// Returns: bool
    public bool check()
    {
        simplex.clear();

        direction = Vec3(1.0f, 0.0f, 0.0f);

        Vec3 support = getSupport(direction);

        simplex.push(support);

        direction = support.negated();

        for(auto i = 0; i < GJK_ITERATIONS; i++)
        {
            support = getSupport(direction);

            if(support.dot(direction) <= 0.0f)
            {
                return false;
            }
    
            simplex.push(support);

            if(solve())
            {
                return true;
            }
        }

        return false;
    }

    // --- epa

    private void addEdge(ref Edge[] edges, Edge edge)
    {
        for(auto i = 0; i < edges.length; i++)
        {
            Vec3 a = edges[i].a;
            Vec3 b = edges[i].b;
            if(a.isEquil(edge.b) && b.isEquil(edge.a))
            {
                edges = remove(edges, i);
                return;
            }
        }
        edges ~= edge;
    }

    private NearestData nearestTri(ref Triangle[] polytype)
    {
        auto distance = MAXFLOAT;
        auto index = -1;

        for(auto i = 0; i < polytype.length; i++)
        {
            Triangle t = polytype[i];
            auto dis = t.n.dot(t.a);
            if(dis < distance)
            {
                distance = dis;
                index = i;
            }
        }

        return NearestData(distance, index);
    }

    private bool triRespone(ref Triangle[] polytope, ref Vec3 value)
    {
        if(polytope.length == 0)
        {
            return false;
        } 

        NearestData nearest = nearestTri(polytope);
        Triangle tri = polytope[nearest.index];

        Vec3 sup = getSupport(tri.n);
        auto dis = absF(sup.dot(tri.n));
        
        if((dis - nearest.distance) <= EPA_OPTIMAL)
        {
            value = tri.n.scaled(nearest.distance);
            return true;
        }
        else
        {
            Edge[] edges;
            for(auto i = cast(int)(polytope.length) - 1; i >= 0; i--)
            {
                tri = polytope[i];
                if(sameDirection(tri.n, sup.subbed(polytope[i].a)))
                {
                    addEdge(edges, Edge(tri.a, tri.b));
                    addEdge(edges, Edge(tri.b, tri.c));
                    addEdge(edges, Edge(tri.c, tri.a));

                    polytope = remove(polytope, i);
                }
            }
            
            for(auto i = 0; i < edges.length; i++)
            {
                tri = Triangle(sup, edges[i].a, edges[i].b);
                if(tri.n.length() != 0.0f)
                {
                    polytope ~= tri;
                }
            }
        }

        return false;
    }

    /// ref value is vec3 depth
    /// Returns: bool
    public bool responce(ref Vec3 value)
    {
        Triangle[] tris = [
            Triangle(simplex.pts[0], simplex.pts[1], simplex.pts[2]),
            Triangle(simplex.pts[0], simplex.pts[2], simplex.pts[3]),
            Triangle(simplex.pts[0], simplex.pts[3], simplex.pts[1]),
            Triangle(simplex.pts[1], simplex.pts[3], simplex.pts[2]),
        ];

        for(auto it = 0; it < EPA_ITERATIONS; it++)
        {
            if(triRespone(tris, value))
            {
                Vec3 buffer = value.normalized().scaled(EPSILON);
                value = value.added(buffer);
                return true;
            }
        }

        return false;
    }
}
