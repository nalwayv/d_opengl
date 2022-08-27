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
        Mesh mesh;
        string shader;
    }

    this(const float[] verticies, const int[] indicies)
    {
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