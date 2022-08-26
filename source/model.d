module model;


import maths.vec3;
import maths.mat4;
import mesh;
import transform;
import shadercache;


class Model
{
    float[] verticies;
    int[] indicies;
    string shader;
    Transform transform;
    Mesh mesh;

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

    void translate(float x, float y, float z)
    {
        transform.translate(x, y, z);
    }

    void rotate(float rad, Vec3 axis)
    {
        transform.rotate(rad, axis);
    }

    void render(ShaderCache cache, Mat4 camMatrix)
    {
        cache.use(shader);
        cache.setMat4(shader, "model_Matrix", transform.matrix());
        cache.setMat4(shader, "cam_Matrix", camMatrix);
        
        mesh.render();
    }
}