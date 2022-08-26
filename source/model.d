/// Model
module model;


import maths.vec3;
import maths.mat4;
import mesh;
import transform;
import shadercache;
import camera;


class Model
{
    private 
    {
        Transform transform;
        string shader;
        float[] verticies;
        int[] indicies;
        Mesh mesh;
    }

    this(const float[] verts, const int[] indic)
    {
        verticies = new float[verts.length];
        for(auto i = 0; i < verts.length; i++)
        {
            verticies[i] = verts[i];
        }

        indicies = new int[indic.length];
        for(auto i = 0; i < indic.length; i++)
        {
            indicies[i] = indic[i];
        }

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

    public void render(ShaderCache cache, Camera cam)
    {
        cache.use(shader);

        cache.setMat4(shader, "model_Matrix", transform.matrix());
        cache.setMat4(shader, "cam_Matrix", cam.matrix());
        
        mesh.render();
    }
}