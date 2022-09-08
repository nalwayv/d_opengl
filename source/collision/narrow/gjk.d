/// Gjk
// TODO()
module collision.narrow.gjk;


import std.algorithm.mutation : remove;
import collision.narrow.imeshcollider;
import maths.utils;
import maths.vec3;


enum float EPA_OPTIMAL = 0.002f;
enum int GJK_ITERATIONS = 30;
enum int EPA_ITERATIONS = 30;


private struct SupportPt
{
    Vec3 pt;
    Vec3 a;
    Vec3 b;
}


private struct ContactData
{
    Vec3 p;
    Vec3 n;
    float d;
    bool valid;
}


private struct Edge
{
    Vec3 a;
    Vec3 b;

    bool isEquil(Edge other)
    {
        return a.isEquil(other.a) && b.isEquil(other.b);
    }
}


private struct Triangle
{
    Vec3 a;
    Vec3 b;
    Vec3 c;

    /// Returns: Vec3
    Vec3 n()
    {
        auto ab = b.subbed(a);
        auto ac = c.subbed(a);
        auto abc = ab.cross(ac).normalized();
        return abc;
    }

    /// Returns: bool
    bool isEquil(Triangle other)
    {
        return a.isEquil(other.a) && b.isEquil(other.b) && c.isEquil(other.c);
    }
}


private struct Simplex 
{
    Vec3[4] pts;
    int length;

    static Simplex newSimplex()
    {
        Simplex result;

        result.pts[0] = Vec3(0.0f, 0.0f, 0.0f);
        result.pts[1] = Vec3(0.0f, 0.0f, 0.0f);
        result.pts[2] = Vec3(0.0f, 0.0f, 0.0f);
        result.pts[3] = Vec3(0.0f, 0.0f, 0.0f);

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

    /// return support pt
    /// Returns: Vec3
    private Vec3 getSupport()
    {
        auto a = mcA.furthestPt(direction);
        auto b = mcB.furthestPt(direction.negated());

        return a.subbed(b);
    }    
        
    /// return support pt from direction 'dir
    /// Returns: Vec3
    private Vec3 getSupport(Vec3 dir)
    {
        auto a = mcA.furthestPt(dir);
        auto b = mcB.furthestPt(dir.negated());

        return a.subbed(b);
    }


    /// check for same direction
    /// Returns: bool
    private bool sameDirection(Vec3 a, Vec3 b)
    {
        return a.dot(b) > 0.0f;
    }

    /// return triple cross product
    /// Returns: Vec3
    public Vec3 tripleCross(Vec3 a, Vec3 b, Vec3 c)
    {
        return a.cross(b).cross(c);
    }

    private void addEdge(Edge[] edges, Vec3 a, Vec3 b)
    {
        auto edge = Edge(a, b);

        for (auto i = 0; i < edges.length; i++)
        {
            if(edges[i].isEquil(edge))
            {
                edges = remove(edges, i);
                return;
            }
        }

        edges ~= edge;
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

        auto a = simplex.a();
        auto b = simplex.b();

        auto ab = b.subbed(a);
        auto an = a.negated();        
        
        if(sameDirection(ab, an))
        {
            direction = tripleCross(ab, an, ab);
        }
        else
        {
            // simplex = [a];
            simplex.set(a);
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

        auto a = simplex.a();
        auto b = simplex.b();
        auto c = simplex.c();

        auto ab = b.subbed(a);
        auto ac = c.subbed(a);
        auto an = a.negated();

        auto abc = ab.cross(ac);

        if(sameDirection(abc.cross(ac), an))
        {
            if(sameDirection(ac, an))
            {
                // simplex = [c, a];
                simplex.set(a, c);
                direction = tripleCross(ac, an, ac);
            }
            else
            {
                // simplex = [b, a];
                simplex.set(a, b);
                return line();
            }
        }
        else
        {
            if(sameDirection(ab.cross(abc), an))
            {
                // simplex = [b, a];
                simplex.set(a, b);
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
                    // simplex = [b, c, a];
                    simplex.set(a, c, b);
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

        auto a = simplex.a();
        auto b = simplex.b();
        auto c = simplex.c();
        auto d = simplex.d();

        auto ab = b.subbed(a);
        auto ac = c.subbed(a);
        auto ad = d.subbed(a);
        auto an = a.negated();

        auto abc = ab.cross(ac);
        auto acd = ac.cross(ad);
        auto adb = ad.cross(ab);

        if(sameDirection(abc, an))
        {
            // simplex = [c, b, a];
            simplex.set(a, b, c);
            return triangle(); 
        }

        if(sameDirection(acd, an))
        {
            // simplex = [d, c, a];
            simplex.set(a, c, d);
            return triangle();
        }

        if(sameDirection(adb, an))
        {
            // simplex = [b, d, a];
            simplex.set(a, d, b);
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
    
    /// --- epa

    private ContactData getContactData(Triangle minTriangle)
    {
        ContactData result;
        
        auto tn = minTriangle.n();
        auto dis = tn.dot(minTriangle.a);
        
        auto a = tn.scaled(dis);
        auto b = minTriangle.a;
        auto c = minTriangle.b;
        auto d = minTriangle.c;

        auto bc = Vec3.barycenter(a, b, c, d);

        if(!isValidF(bc.x) || !isValidF(bc.y) || !isValidF(bc.z))
        {
            result.valid = false;
            return;
        }

        if(absF(bc.x) > 1.0f || absF(bc.y) > 1.0f || absF(bc.z) > 1.0f)
        {
            result.valid = false;
            return;
        }


        // auto pt = Vec3(

        // )


    }

    private bool tmp()
    {
        assert(simplex.length == 4);
        // import std.stdio : writeln;
        
        Triangle[] tris = [
            Triangle(simplex.a(), simplex.b(), simplex.c()),
            Triangle(simplex.a(), simplex.c(), simplex.d()),
            Triangle(simplex.a(), simplex.d(), simplex.b()),
            Triangle(simplex.b(), simplex.d(), simplex.c()),
        ];

        Edge[] edges;

        for(auto i = 0; i < EPA_ITERATIONS; i++)
        {
            auto minDis = MAXFLOAT;
            Triangle minTri;

            for(auto j = 0; j < tris.length; j++)
            {
                auto current = tris[j];
                auto cn = current.n();

                auto dis = cn.dot(current.a);
                if(dis < minDis)
                {
                    minDis = dis;
                    minTri = current;
                }
            }

            auto tn = minTri.n();
            auto support = getSupport(tn);
            auto newDis = tn.dot(support);

            if((newDis - minDis) < EPA_OPTIMAL)
            {
                // writeln("A");
                getContactData(minTri);
                return true;
            }

            auto idx = 0;
            auto begin = tris.ptr;
            auto end = tris.ptr + tris.length;
            while(begin != end)
            {
                auto current = *begin;
                auto cn = current.n();
                auto sa = support.subbed(current.a);

                if(sameDirection(cn, sa))
                {
                    addEdge(edges, current.a, current.b);
                    addEdge(edges, current.b, current.c);
                    addEdge(edges, current.c, current.a);

                    tris = remove(tris, idx);
                    // tris = remove!(x => x.isEquil(current))(tris);

                    begin = tris.ptr;
                    end = tris.ptr + tris.length;
                    idx = 0;

                    continue;
                }

                idx++;
                begin++;
            }

            // auto s = 0;
            // auto e = tris.length;
            // while(s != e)
            // {
            //     auto current = tris[s];
            //     auto cn = current.n();
            //     auto sa = support.subbed(current.a);

            //     if(sameDirection(cn, sa))
            //     {
            //         addEdge(edges, current.a, current.b);
            //         addEdge(edges, current.b, current.c);
            //         addEdge(edges, current.c, current.a);

            //         tris = remove(tris, s);
            //         s = 0;
            //         e = tris.length;
            //         continue;
            //     }

            //     s++;
            // }

            for(auto j = 0; j < edges.length; j++)
            {
                auto current = edges[j];
                tris ~= Triangle(support, current.a, current.b);
            }

            edges = [];
        }

        // writeln("B");

        return false;
    }

    /// --- gjk check

    /// check for a collision between two shapes
    /// Returns: bool
    public bool check()
    {
        simplex.clear();
        direction= Vec3(1.0f, 0.0f, 0.0f);

        auto support = getSupport();

        simplex.push(support);

        direction = support.negated();

        for(auto i = 0; i < GJK_ITERATIONS; i++)
        {
            support = getSupport();

            if(support.dot(direction) <= 0.0f)
            {
                return false;
            }
    
            simplex.push(support);

            if(evolve())
            {
                tmp();
                return true;
            }
        }

        return false;
    }
}   