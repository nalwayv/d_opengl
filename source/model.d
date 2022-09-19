/// Model
module model;


import maths.utils;
import maths.vec3;
import maths.mat4;
import geometry.aabb;
import collision.narrow.imeshcollider;
import utils.obj;
import mesh;
import color;
import transform;
import shadercache;
import camera;


class Model : IMeshCollider
{
    private 
    {
        Transform transform;
        Mesh mesh;
        Color color;
        string shader;
    }

    this(string filePath)
    {
        transform = Transform.newTransform(0.0f, 0.0f, 0.0f);
        mesh = new Mesh(filePath);
        shader = "default";
        color = Color(0.2f, 0.2f, 0.2f);
    }

    public Vec3 getPosition()
    {
        return transform.position;
    }

    public void translate(float x, float y, float z)
    {
        transform.translate(x, y, z);
    }

    public void translate(Vec3 by)
    {
        transform.translate(by.x, by.y, by.z);
    }

    public void rotate(float rad, Vec3 axis)
    {
        transform.rotate(rad, axis);
    }

    public void scale(float x, float y, float z)
    {
        transform.scale(x, y, z);
    }

    /// set color between 0.0f..1.0f
    public void setColor(float r, float g, float b)
    {
        color.r = clampF(r, 0.0f, 1.0f);
        color.g = clampF(g, 0.0f, 1.0f);
        color.b = clampF(b, 0.0f, 1.0f);
    }

    /// render model
    public void render(ShaderCache cache, Camera cam)
    {
        cache.use(shader);

        cache.setVec3(shader, "color_Vec3", color.vec3());
        cache.setMat4(shader, "model_Mat4", transform.getMatrix());
        cache.setMat4(shader, "cam_Mat4", cam.getMatrix());

        mesh.render();
    }

    /// get current transform matrix
    /// Returns: Mat4
    public Mat4 getMatrix()
    {
        return transform.getMatrix();
    }

    /// get face normals
    /// Returns: Vec3[]
    public Vec3[] faceNormals()
    {
        Vec3[] result;

        auto obj = mesh.getObj();
        auto vertex = obj.getVertex();
        auto ind = obj.getIndicies();

        for(auto i = 0;  i < ind.length; i += 3)
        {
            auto a = Vec3.fromArray(vertex[ind[i + 0]].vert); 
            auto b = Vec3.fromArray(vertex[ind[i + 1]].vert); 
            auto c = Vec3.fromArray(vertex[ind[i + 2]].vert); 

            auto ab = b.subbed(a);
            auto ac = c.subbed(a);

            auto normal = ab.cross(ac).normalized();

            auto distance = normal.dot(a);

            // flip
            if(distance < 0.0f)
            {
                normal = normal.negated();
                distance *= -1.0f;
            }

            result ~= normal;
        }

        return result;
    }

    /// get furthest point in given direction
    /// Returns: Vec3
    public Vec3 farthestPoint(Vec3 direction)
    {
        if(!direction.isNormal())
        {
            direction = direction.normalized();
        }

        auto maxDistance = MINFLOAT;

        Vec3 result;

        Mat4 m4 = transform.getMatrix();
        Obj obj = mesh.getObj();
        Vertex[] vertex = obj.getVertex();

        for(auto i = 0; i < vertex.length; i++)
        {
            auto vert = vertex[i].vert;
            Vec3 pt = Vec3.fromArray(vert);

            auto distance = pt.dot(direction);

            if(distance > maxDistance)
            {
                maxDistance = distance;
                result = pt;
            }
        }

        return m4.transform(result);
    }

    /// compute an AABB from this model based on its verts
    /// Returns: AABB
    public AABB computeAABB()
    {
        const x= 0, y= 1, z = 2;

        Vec3 pMin = Vec3(MAXFLOAT, MAXFLOAT, MAXFLOAT);
        Vec3 pMax = Vec3(MINFLOAT, MINFLOAT, MINFLOAT);

        Obj obj = mesh.getObj();
        foreach(ref vertex; obj.getVertex())
        {
            if(vertex.vert[x] < pMin.x) 
            {
                pMin.x = vertex.vert[x];
            }
            if(vertex.vert[x] > pMax.x) 
            {
                pMax.x = vertex.vert[x];
            }
            if(vertex.vert[y] < pMin.y) 
            {
                pMin.y = vertex.vert[y];
            }
            if(vertex.vert[y] > pMax.y) 
            {
                pMax.y = vertex.vert[y];
            }
            if(vertex.vert[z] < pMin.z) 
            {
                pMin.z = vertex.vert[z];
            }
            if(vertex.vert[z] > pMax.z) 
            {
                pMax.z = vertex.vert[z];
            }
        }

        AABB ab = AABB.fromMinMax(pMin, pMax);
        Mat4 m4 = transform.getMatrix();
        
        return ab.transformed(m4);
    }
}
