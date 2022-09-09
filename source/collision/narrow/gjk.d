/// Gjk
// TODO()
module collision.narrow.gjk;


import std.algorithm.mutation : remove;
import collision.narrow.imeshcollider;
import maths.utils;
import maths.vec4;
import maths.vec3;


enum float EPA_OPTIMAL = 0.002f;
enum int GJK_ITERATIONS = 30;
enum int EPA_ITERATIONS = 30;


private struct SupportPt
{
    Vec3 pt;
    Vec3 spA;
    Vec3 spB;

    static SupportPt newSupportPt(Vec3 pt)
    {
        SupportPt result;

        result.pt = pt;
        result.spA = Vec3(0.0f, 0.0f, 0.0f);
        result.spB = Vec3(0.0f, 0.0f, 0.0f);

        return result;
    }

    Vec3 subbedPt(SupportPt other)
    {
        return pt.subbed(other.pt);
    }

    Vec3 negatedPt()
    {
        return pt.negated();
    }

    bool isEquilPt(SupportPt other)
    {
        return pt.isEquil(other.pt);
    }
}


private struct Edge
{
    SupportPt a;
    SupportPt b;

    /// check for equality between edges support points
    /// Returns: bool
    bool isEquil(Edge other)
    {
        return a.isEquilPt(other.a) && b.isEquilPt(other.b);
    }
}


private struct Triangle
{
    SupportPt a;
    SupportPt b;
    SupportPt c;

    /// return tri normal
    /// Returns: Vec3
    Vec3 n()
    {
        auto ab = b.subbedPt(a);
        auto ac = c.subbedPt(a);
        
        auto abc = ab.cross(ac).normalized();

        return abc;
    }
}


private struct Simplex 
{
    SupportPt[4] pts;
    int length;

    static Simplex newSimplex()
    {
        Simplex result;

        result.pts[0] = SupportPt.newSupportPt(Vec3.zero());
        result.pts[1] = SupportPt.newSupportPt(Vec3.zero());
        result.pts[2] = SupportPt.newSupportPt(Vec3.zero());
        result.pts[3] = SupportPt.newSupportPt(Vec3.zero());

        result.length = 0;

        return result;
    }

    void clear()
    { 
        length = 0; 
    }

    SupportPt a()
    { 
        return pts[0];
    }

    SupportPt b()
    { 
        return pts[1];
    }

    SupportPt c()
    { 
        return pts[2];
    }

    SupportPt d()
    { 
        return pts[3];
    }

    void set(SupportPt a, SupportPt b, SupportPt c, SupportPt d)
    {
        length = 4;

        pts[0] = a;
        pts[1] = b;
        pts[2] = c;
        pts[3] = d;
    }

    void set(SupportPt a, SupportPt b, SupportPt c)
    {
        length = 3;

        pts[0] = a;
        pts[1] = b;
        pts[2] = c;
    }

    void set(SupportPt a, SupportPt b)
    {
        length = 2;

        pts[0] = a;
        pts[1] = b;
    }

    void set(SupportPt a)
    {
        length = 1;

        pts[0] = a;
    }

    /// add support point to simplex
    void push(SupportPt p)
    {
        length = minI(length + 1, 4);

        for(auto i = length - 1; i > 0; i--)
        {
            pts[i] = pts[i - 1];
        }

        pts[0] = p;
    }
}


struct CollisionData
{
    Vec3 normal;
    Vec3 point;
    float depth;
}


private class Epa
{
    private
    {
        CollisionData collisionData;
        IMeshCollider mcA;
        IMeshCollider mcB;
        Simplex simplex;
    }

    this(IMeshCollider a, IMeshCollider b, Simplex simplex)
    {
        mcA = a;
        mcB = b;
        this.simplex = simplex;
    }

    public CollisionData getCollisionData()
    {
        return collisionData;
    }

    private SupportPt getSupport(Vec3 dir)
    {
        auto a = mcA.furthestPt(dir);
        auto b = mcB.furthestPt(dir.negated());

        auto ba = a.subbed(b);

        SupportPt result;

        result.pt = ba;
        result.spA = a;
        result.spB = b;

        return result;
    }

    /// check for same direction
    /// Returns: bool
    private bool sameDirection(Vec3 a, Vec3 b)
    {
        return a.dot(b) > 0.0f;
    }

    /// add/remove edge data from edges
    private void addEdge(Edge[] edges, SupportPt a, SupportPt b)
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

    /// update contact information
    /// Returns: bool
    private bool updateContactData(Triangle tri)
    {
        Vec3 tnormal = tri.n();
        auto dis = tnormal.dot(tri.a.pt);
        
        Vec3 a = tnormal.scaled(dis);
        Vec3 b = tri.a.pt;
        Vec3 c = tri.b.pt;
        Vec3 d = tri.c.pt;

        Vec3 bc = Vec3.barycenter(a, b, c, d);

        if(!isValidF(bc.x) || !isValidF(bc.y) || !isValidF(bc.z))
        {
            return false;
        }

        Vec3 pu = tri.a.spA.scaled(bc.x);
        Vec3 pv = tri.b.spA.scaled(bc.y);
        Vec3 pw = tri.c.spA.scaled(bc.z);

        Vec3 point = pu.added(pv).added(pw);
        Vec3 normal = tnormal.negated();
        auto depth = dis;

        collisionData.normal = normal;
        collisionData.point = point;
        collisionData.depth = depth + 0.001f;

        return true;
    }

    /// collect information bassed on gjk simplex
    /// Returns: bool
    private bool check()
    {
        assert(simplex.length == 4);
        
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
                Triangle current = tris[j];

                auto dis = current.n().dot(current.a.pt);
                if(dis < minDis)
                {
                    minDis = dis;
                    minTri = current;
                }
            }

            Vec3 tnormal = minTri.n();
            SupportPt support = getSupport(tnormal);
            auto newDis = tnormal.dot(support.pt);

            if((newDis - minDis) < EPA_OPTIMAL)
            {
                return updateContactData(minTri);
            }

            auto idx = 0;
            auto begin = tris.ptr;
            auto end = tris.ptr + tris.length;
            while(begin != end)
            {
                Triangle current = *begin;
                Vec3 cn = current.n();
                Vec3 sa = support.subbedPt(current.a);

                if(sameDirection(cn, sa))
                {
                    addEdge(edges, current.a, current.b);
                    addEdge(edges, current.b, current.c);
                    addEdge(edges, current.c, current.a);

                    tris = remove(tris, idx);

                    begin = tris.ptr;
                    end = tris.ptr + tris.length;
                    idx = 0;

                    continue;
                }

                idx++;
                begin++;
            }

            for(auto j = 0; j < edges.length; j++)
            {
                auto current = edges[j];
                tris ~= Triangle(support, current.a, current.b);
            }

            edges = [];
        }

        return false;
    }
}


class Gjk
{
    private 
    {
        Simplex simplex;
        Vec3 direction;
        CollisionData collisionData;
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

    public CollisionData getCollisionData()
    {
        return collisionData;
    }

    // --- helpers
        
    /// return support pt from direction 'dir
    /// Returns: Vec3
    private SupportPt getSupport(Vec3 dir)
    {
        auto a = mcA.furthestPt(dir);
        auto b = mcB.furthestPt(dir.negated());

        auto ba = a.subbed(b);

        SupportPt result;

        result.pt = ba;
        result.spA = a;
        result.spB = b;

        return result;
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

    /// --- simplex

    /// check line if length is 2
    /// Returns: bool
    private bool line()
    {
        if(simplex.length != 2) 
        {
            return false;
        }

        SupportPt a = simplex.a();
        SupportPt b = simplex.b();

        Vec3 ab = b.subbedPt(a);
        Vec3 an = a.negatedPt();        
        
        if(sameDirection(ab, an))
        {
            direction = tripleCross(ab, an, ab);
        }
        else
        {
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

        SupportPt a = simplex.a();
        SupportPt b = simplex.b();
        SupportPt c = simplex.c();

        Vec3 ab = b.subbedPt(a);
        Vec3 ac = c.subbedPt(a);
        Vec3 an = a.negatedPt();

        Vec3 abc = ab.cross(ac);

        if(sameDirection(abc.cross(ac), an))
        {
            if(sameDirection(ac, an))
            {
                simplex.set(a, c);

                direction = tripleCross(ac, an, ac);
            }
            else
            {
                simplex.set(a, b);

                return line();
            }
        }
        else
        {
            if(sameDirection(ab.cross(abc), an))
            {
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

        SupportPt a = simplex.a();
        SupportPt b = simplex.b();
        SupportPt c = simplex.c();
        SupportPt d = simplex.d();

        Vec3 ab = b.subbedPt(a);
        Vec3 ac = c.subbedPt(a);
        Vec3 ad = d.subbedPt(a);
        Vec3 an = a.negatedPt();

        Vec3 abc = ab.cross(ac);
        Vec3 acd = ac.cross(ad);
        Vec3 adb = ad.cross(ab);

        if(sameDirection(abc, an))
        {
            simplex.set(a, b, c);

            return triangle(); 
        }

        if(sameDirection(acd, an))
        {
            simplex.set(a, c, d);

            return triangle();
        }

        if(sameDirection(adb, an))
        {
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

    /// --- gjk

    /// check for a collision between two shapes
    /// Returns: bool
    public bool check()
    {
        simplex.clear();

        direction = Vec3(1.0f, 0.0f, 0.0f);

        SupportPt support = getSupport(direction);

        simplex.push(support);

        direction = support.pt.negated();

        for(auto i = 0; i < GJK_ITERATIONS; i++)
        {
            support = getSupport(direction);

            if(support.pt.dot(direction) <= 0.0f)
            {
                return false;
            }
    
            simplex.push(support);

            if(evolve())
            {
                Epa epa = new Epa(mcA, mcB, simplex);
                if(epa.check())
                {
                    collisionData = epa.getCollisionData();
                    return true;
                }
            }
        }

        return false;
    }
}
