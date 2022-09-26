/// Object
module utils.obj;

import std.conv : to;
import std.stdio : File;
import std.exception : ErrnoException;
import std.string;
import maths.vec3;


enum size_t KB = 1 << 10;
enum : int
{
    X = 1,
    Y = 2,
    Z = 3
}
enum : int 
{
    A = 1,
    B = 2,
    C = 3,
    D = 4,
    E = 5,
    F = 6,
}


struct Vertex
{
    Vec3 vert;
}


class Obj
{
    private 
    {
        Vertex[] vertex;
        int[] indicies;
    }

    /// load a model from models file
    this(string filePath)
    {
        try
        {
            auto file = File(filePath, "r");

            char[] buffer = new char[32];
            char[] line = buffer;

            while(file.readln(line))
            {
                if(line.length > buffer.length)
                {
                    buffer = line;
                }

                if(indexOf(line, "v") == 0)
                {
                    readV(line);
                }
                else if(indexOf(line, "i") == 0)
                {
                    readI(line);
                }
            }
        }
        catch(ErrnoException e)
        {
            throw new Exception("ERROR: ", e.msg);
        }
    }

    private void readV(const char[] line)
    {
        try
        {
            auto arr = line.split();

            Vertex result;

            result.vert.x = to!float(arr[X]);
            result.vert.y = to!float(arr[Y]);
            result.vert.z = to!float(arr[Z]);

            vertex ~= result;
        }
        catch(ErrnoException e)
        {
            throw new Exception("ERROR: ", e.msg);
        }
    }

    private void readI(const char[] line)
    {
        try
        {
            auto arr = line.split();
            int[6] data = [
                to!int(arr[A]),
                to!int(arr[B]),
                to!int(arr[C]),
                to!int(arr[D]),
                to!int(arr[E]),
                to!int(arr[F])
            ];

            indicies ~= data;
        }
        catch(ErrnoException e)
        {
            throw new Exception("ERROR: ", e.msg);
        }
    }

    /// Returns: Vertex[]
    public Vertex[] getVertex() pure
    {
        return vertex;
    }

    /// Returns: int[]
    public int[] getIndicies() pure
    {
        return indicies;
    }
}
