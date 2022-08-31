/// Simplex
module collision.narrow.simplex;


import maths.vec3;


enum : int
{
    A = 0,
    B = 1,
    C = 2,
    D = 3,
}


struct Simplex
{
    Vec3[4] pts;
    Vec3 dir;
    int length;

    static Simplex newSimplex(Vec3 direction)
    {
        Simplex result;

        result.pts = [
            Vec3(0.0f, 0.0f, 0.0f),
            Vec3(0.0f, 0.0f, 0.0f),
            Vec3(0.0f, 0.0f, 0.0f),
            Vec3(0.0f, 0.0f, 0.0f)
        ];
        result.dir = direction;
        result.length = 0;
        
        return result;
    }

    /// return a triple cross product between 'a,'b and 'c
    /// Returns: Vec3
    Vec3 tripleCross(Vec3 a, Vec3 b, Vec3 c)
    {
        return a.cross(b).cross(c);
    }

    /// check for same direction
    /// Returns: bool
    bool sameDirection(Vec3 a, Vec3 b)
    {
        return a.dot(b) > 0.0f;
    }

    /// push a vec3 into simplex while its length is still under 4
    void push(Vec3 v3)
    {
        if(length == 4)
        {
            return;
        }

        pts[length++] = v3;
    }

    /// check line if length is 2
    /// Returns: bool
    bool line()
    {
        if(length != 2) 
        {
            return false;
        }

        auto a = pts[B];
        auto b = pts[C];

        auto ab = b.subbed(a);
        auto an = a.negated();        
        
        if(sameDirection(ab, an))
        {
            dir = tripleCross(ab, an, ab);
        }
        else
        {
            length = 1;
            pts[A] = a;

            dir = an;
        }

        return false;
    }

    /// check triangle if length is 3
    /// Returns: bool
    bool triangle()
    {
        if(length != 3)
        {
            return false;
        }

        auto a = pts[C];
        auto b = pts[B];
        auto c = pts[A];

        auto ab = b.subbed(a);
        auto ac = c.subbed(a);
        auto an = a.negated();

        auto abc = ab.cross(ac);

        if(sameDirection(abc.cross(ac), an))
        {
            if(sameDirection(ac, an))
            {
                length = 2;
                pts[A] = a;
                pts[B] = c;

                dir = tripleCross(ac, an, ac);
            }
            else
            {
                length = 2;
                pts[A] = a;
                pts[B] = b;

                return line();
            }
        }
        else
        {
            if(sameDirection(ab.cross(abc), an))
            {
                length = 2;
                pts[A] = a;
                pts[B] = b;

                return line();
            }
            else
            {
                if(sameDirection(abc, an))
                {
                    dir = abc;
                }
                else
                {
                    length = 3;
                    pts[A] = a;
                    pts[B] = c;
                    pts[C] = b;

                    dir = abc.negated();
                }
            }
        }

        return false;
    }

    /// check tetrahedron if length is 4
    /// Returns: bool
    bool tetrahedron()
    {
        if(length != 4)
        {
            return false;
        }

        auto a = pts[D];
        auto b = pts[C];
        auto c = pts[B];
        auto d = pts[A];

        auto ab = b.subbed(a);
        auto ac = c.subbed(a);
        auto ad = d.subbed(a);
        auto an = a.negated();

        auto abc = ab.cross(ac);
        auto acd = ac.cross(ad);
        auto adb = ad.cross(ab);

        if(sameDirection(abc, an))
        {
            length = 3;
            pts[A] = a;
            pts[B] = b;
            pts[C] = c;

            return triangle(); 
        }

        if(sameDirection(acd, an))
        {
            length = 3;
            pts[A] = a;
            pts[B] = c;
            pts[C] = d;

            return triangle();
        }

        if(sameDirection(adb, an))
        {
            length = 3;
            pts[A] = a;
            pts[B] = d;
            pts[C] = b;

            return triangle();
        }

        return true;
    }
}   