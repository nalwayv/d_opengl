/// Model
module model;


import maths.utils;
import maths.vec3;
import maths.mat4;
import geometry.aabb;
import mesh;
import color;
import transform;
import shadercache;
import camera;


class Model
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
        color = Color(0.3f, 0.4f, 1.0f);
    }

    public void setPosition(float x, float y, float z)
    {
        transform.setPosition(x, y, z);
    }

    public void translate(float x, float y, float z)
    {
        transform.translate(x, y, z);
    }

    public void rotate(float rad, Vec3 axis)
    {
        transform.rotate(rad, axis);
    }

    public void scale(float x, float y, float z)
    {
        transform.scale(x, y, z);
    }

    public void resetTransform()
    {
        auto p = transform.position;
        transform.reset(p.x, p.y, p.z);
    }

    /// set color between 0.0f..1.0f
    public void setColor(float r, float g, float b)
    {
        color.r = clampF(r, 0.0f, 1.0f);
        color.g = clampF(g, 0.0f, 1.0f);
        color.b = clampF(b, 0.0f, 1.0f);
    }

    public void render(ShaderCache cache, Camera cam)
    {
        cache.use(shader);

        cache.setVec3(shader, "color_Vec3", color.vec3());
        cache.setMat4(shader, "model_Mat4", transform.matrix());
        cache.setMat4(shader, "cam_Mat4", cam.matrix());
        
        mesh.render();
    }

    AABB computeAABB()
    {
        import std.stdio : writeln;
        const x= 0, y= 1, z = 2;

        Vec3 pMin = Vec3(MAXFLOAT, MAXFLOAT, MAXFLOAT);
        Vec3 pMax = Vec3(MINFLOAT, MINFLOAT, MINFLOAT);

        auto obj = mesh.getObj();
        foreach(ref vert; obj.getVerts())
        {
            if(vert.v[x] < pMin.x) pMin.x = vert.v[x];
            if(vert.v[x] > pMax.x) pMax.x = vert.v[x];
            if(vert.v[y] < pMin.y) pMin.y = vert.v[y];
            if(vert.v[y] > pMax.y) pMax.y = vert.v[y];
            if(vert.v[z] < pMin.z) pMin.z = vert.v[z];
            if(vert.v[z] > pMax.z) pMax.z = vert.v[z];
        }

        auto ab = AABB.fromMinMax(pMin, pMax).transformed(transform.matrix());

        AABB result;

        result.origin = ab.origin;
        result.extents = ab.extents;

        return result;
    }
}