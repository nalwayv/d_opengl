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


private struct SupportPoint
{
    Vec3 pt;
    Vec3 spA;
    Vec3 spB;

    static SupportPoint newSupportPoint(Vec3 pt)
    {
        SupportPoint result;

        result.pt = pt;
        result.spA = Vec3(0.0f, 0.0f, 0.0f);
        result.spB = Vec3(0.0f, 0.0f, 0.0f);

        return result;
    }

    Vec3 subbedPoint(SupportPoint other)
    {
        return pt.subbed(other.pt);
    }

    Vec3 negatedPoint()
    {
        return pt.negated();
    }

    bool isEquilPoint(SupportPoint other)
    {
        return pt.isEquil(other.pt);
    }
}


private struct Edge
{
    SupportPoint a;
    SupportPoint b;

    /// check for equality between edges support points
    /// Returns: bool
    bool isEquil(Edge other)
    {
        return a.isEquilPoint(other.a) && b.isEquilPoint(other.b);
    }
}


private struct Triangle
{
    SupportPoint a;
    SupportPoint b;
    SupportPoint c;
    Vec3 n;

    this(SupportPoint a, SupportPoint b, SupportPoint c)
    {
        this.a = a;
        this.b = b;
        this.c = c;

        this.n = b.subbedPoint(this.a).cross(this.c.subbedPoint(this.a)).normalized();
    }
}


private struct Simplex 
{
    SupportPoint[4] pts;
    int length;

    static Simplex newSimplex()
    {
        Simplex result;

        result.pts[0] = SupportPoint.newSupportPoint(Vec3.zero());
        result.pts[1] = SupportPoint.newSupportPoint(Vec3.zero());
        result.pts[2] = SupportPoint.newSupportPoint(Vec3.zero());
        result.pts[3] = SupportPoint.newSupportPoint(Vec3.zero());

        result.length = 0;

        return result;
    }

    void clear()
    { 
        length = 0; 
    }

    SupportPoint a()
    { 
        return pts[0];
    }

    SupportPoint b()
    { 
        return pts[1];
    }

    SupportPoint c()
    { 
        return pts[2];
    }

    SupportPoint d()
    { 
        return pts[3];
    }

    void set(SupportPoint a, SupportPoint b, SupportPoint c, SupportPoint d)
    {
        length = 4;

        pts[0] = a;
        pts[1] = b;
        pts[2] = c;
        pts[3] = d;
    }

    void set(SupportPoint a, SupportPoint b, SupportPoint c)
    {
        length = 3;

        pts[0] = a;
        pts[1] = b;
        pts[2] = c;
    }

    void set(SupportPoint a, SupportPoint b)
    {
        length = 2;

        pts[0] = a;
        pts[1] = b;
    }

    void set(SupportPoint a)
    {
        length = 1;

        pts[0] = a;
    }

    /// add support point to simplex
    void push(SupportPoint p)
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

    /// Returns: CollisionData
    public CollisionData getCollisionData()
    {
        return collisionData;
    }

    // --- helpers

    /// return current support point based on models furest point in direction
    /// Returns: SupportPoint
    private SupportPoint getSupport(Vec3 dir)
    {
        auto a = mcA.farthestPoint(dir);
        auto b = mcB.farthestPoint(dir.negated());

        auto ba = a.subbed(b);

        SupportPoint result;

        result.pt = ba;
        result.spA = a;
        result.spB = b;

        return result;
    }

    /// just to make to code look cleaner
    ///
    /// tri.n.dot(tri.a.pt) => dot(tri.n, tri.a.pt)
    private float dot(Vec3 a, Vec3 b)
    {
        return a.dot(b);
    }

    /// compute barycentric
    /// Returns: Vec3
    private Vec3 barycentric(Vec3 p, Vec3 a, Vec3 b, Vec3 c)
    {
        Vec3 v0 = b.subbed(a);
        Vec3 v1 = c.subbed(a);
        Vec3 v2 = p.subbed(a);

        auto d00 = dot(v0, v0);
        auto d01 = dot(v0, v1);
        auto d11 = dot(v1, v1);
        auto d20 = dot(v2, v0);
        auto d21 = dot(v2, v1);

        auto denom = d00 * d11  - d01 * d01;
        auto v = (d11 * d20 - d01 * d21) / denom;
        auto w = (d00 * d21 - d01 * d20) / denom;
        auto u = 1.0f - v - w;

        Vec3 result;

        result.x = u;
        result.y = v;
        result.z = w;
        
        return result;
    }

    /// check for same direction
    /// Returns: bool
    private bool sameDirection(Vec3 a, Vec3 b)
    {
        return dot(a, b) > 0.0f;
    }

    /// add/remove edge data from edges
    private void addEdge(Edge[] edges, SupportPoint a, SupportPoint b)
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
        auto dis = dot(tri.n, tri.a.pt);
        
        Vec3 a = tri.n.scaled(dis);
        Vec3 b = tri.a.pt;
        Vec3 c = tri.b.pt;
        Vec3 d = tri.c.pt;

        Vec3 bary = barycentric(a, b, c, d);

        // if bary fails
        if(!isValidF(bary.x) || !isValidF(bary.y) || !isValidF(bary.z))
        {
            return false;
        }
        if(absF(bary.x) > 1.0f || absF(bary.y) > 1.0f || absF(bary.z) > 1.0f)
        {
            return false;
        }

        Vec3 u = tri.a.spA.scaled(bary.x);
        Vec3 v = tri.b.spA.scaled(bary.y);
        Vec3 w = tri.c.spA.scaled(bary.z);

        Vec3 point = u.added(v).added(w);
        Vec3 normal = tri.n.negated();
        auto depth = dis;

        collisionData.normal = normal;
        collisionData.point = point;
        collisionData.depth = depth + EPA_BUFFER;

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
            // closest tri
            auto minDis = MAXFLOAT;
            Triangle minTri;
            for(auto j = 0; j < tris.length; j++)
            {
                Triangle current = tris[j];

                auto dis = dot(current.n, current.a.pt);
                if(dis < minDis)
                {
                    minDis = dis;
                    minTri = current;
                }
            }

            SupportPoint support = getSupport(minTri.n);
            auto newDis = dot(minTri.n, support.pt);

            if((newDis - minDis) < EPA_OPTIMAL)
            {
                return updateContactData(minTri);
            }
    
            for(auto it = 0; it < tris.length;)
            {
                Triangle current = tris[it];
                Vec3 sp = support.subbedPoint(current.a);

                if(sameDirection(current.n, sp))
                {
                    addEdge(edges, current.a, current.b);
                    addEdge(edges, current.b, current.c);
                    addEdge(edges, current.c, current.a);

                    tris = remove(tris, it);
                    continue;
                }
                
                it++;
            }

            // add new tris from edges
            for(auto j = 0; j < edges.length; j++)
            {
                Edge current = edges[j];
                tris ~= Triangle(support, current.a, current.b);
            }

            // clear old edges
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

    private float dot(Vec3 a, Vec3 b)
    {
        return a.dot(b);
    }

    /// return triple cross product
    /// Returns: Vec3
    public Vec3 tripleCross(Vec3 a, Vec3 b, Vec3 c)
    {
        return a.cross(b).cross(c);
    }

    /// return support pt from direction 'dir
    /// Returns: Vec3
    private SupportPoint getSupport(Vec3 dir)
    {
        auto a = mcA.farthestPoint(dir);
        auto b = mcB.farthestPoint(dir.negated());

        auto ba = a.subbed(b);

        SupportPoint result;

        result.pt = ba;
        result.spA = a;
        result.spB = b;

        return result;
    }

    /// check for same direction
    /// Returns: bool
    private bool sameDirection(Vec3 a, Vec3 b)
    {
        return dot(a, b) > 0.0f;
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

        SupportPoint a = simplex.a();
        SupportPoint b = simplex.b();

        Vec3 ab = b.subbedPoint(a);
        Vec3 an = a.negatedPoint();        
        
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

        SupportPoint a = simplex.a();
        SupportPoint b = simplex.b();
        SupportPoint c = simplex.c();

        Vec3 ab = b.subbedPoint(a);
        Vec3 ac = c.subbedPoint(a);
        Vec3 an = a.negatedPoint();

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

        SupportPoint a = simplex.a();
        SupportPoint b = simplex.b();
        SupportPoint c = simplex.c();
        SupportPoint d = simplex.d();

        Vec3 ab = b.subbedPoint(a);
        Vec3 ac = c.subbedPoint(a);
        Vec3 ad = d.subbedPoint(a);
        Vec3 an = a.negatedPoint();

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

        SupportPoint support = getSupport(direction);

        simplex.push(support);

        direction = support.pt.negated();

        for(auto i = 0; i < GJK_ITERATIONS; i++)
        {
            support = getSupport(direction);

            if(dot(support.pt, direction) <= 0.0f)
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
