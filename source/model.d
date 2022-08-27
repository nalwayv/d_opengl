/// Model
module model;

import maths.utils;
import maths.vec3;
import maths.mat4;
import geometry.aabb;
import mesh;
import vertex;
import transform;
import shadercache;
import camera;

class Model
{
    private 
    {
        Transform transform;
        Vertex[] verts;
        int[] indic;
        Mesh mesh;
        string shader;
    }

    this(Vertex[] verticies, int[] indicies)
    {
        verts = verticies;
        indic = indicies;

        transform = Transform.newTransform(0.0f, 0.0f, 0.0f);
        mesh = new Mesh(verticies, indicies);
        shader = "default";
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

    public AABB compute()
    {
        const X = 0;
        const Y = 1;
        const Z = 2;

        auto pMin = Vec3(MAXFLOAT, MAXFLOAT, MAXFLOAT);
        auto pMax = Vec3(MINFLOAT, MINFLOAT, MINFLOAT);

        for(auto i = 0; i < verts.length; i++)
        {
            auto pos = verts[i].position;

            if(pos[X] < pMin.x)
            {
                pMin.x = pos[X];
            }
            if(pos[X] > pMax.x)
            {
                pMax.x = pos[X];
            }

            if(pos[Y] < pMin.x)
            {
                pMin.x = pos[Y];
            }
            if(pos[Y] > pMax.x)
            {
                pMax.x = pos[Y];
            }

            if(pos[Z] < pMin.x)
            {
                pMin.x = pos[Z];
            }
            if(pos[Z] > pMax.x)
            {
                pMax.x = pos[Z];
            }
        }

        // TODO transform
        return AABB.fromMinMax(pMin, pMax);
    }

    public void render(ShaderCache cache, Camera cam)
    {
        cache.use(shader);

        cache.setMat4(shader, "model_Matrix", transform.matrix());
        cache.setMat4(shader, "cam_Matrix", cam.matrix());
        
        mesh.render();
    }
}