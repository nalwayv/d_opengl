/// Mesh
module mesh;


import bindbc.opengl;
import utils.path;
import maths.utils;
import maths.vec3;


enum int COMPONENTS = 3;
enum int STRIDE = 3;
enum : int
{
    POSITION_IDX = 0,
    COLOR_IDX = 1
}


private struct Vbo
{
    GLuint id;

    static Vbo newVbo()
    {        
        GLuint vboID;
        glGenBuffers(1, &vboID);

        Vbo result;
        result.id = vboID;
        return result;
    }

    void bind()
    {
        glBindBuffer(GL_ARRAY_BUFFER, id);
    }

    void unbind()
    {
        glBindBuffer(GL_ARRAY_BUFFER, 0);
    }

    void destroy()
    {
        glDeleteBuffers(1, &id);
    }
}


private struct Vao
{
    GLuint id;

    static Vao newVao()
    {
        GLuint vaoID;
        glGenVertexArrays(1, &vaoID);

        Vao result;
        result.id = vaoID;
        return result;
    }

    void bind()
    {
        glBindVertexArray(id);
    }

    void unbind()
    {
        glBindVertexArray(0);
    }

    void destroy()
    {
        glDeleteVertexArrays(1, &id);
    }
}


private struct Ebo
{
    GLuint id;

    static Ebo newEbo()
    {
        GLuint eboID;
        glGenBuffers(1, &eboID);

        Ebo result;
        result.id = eboID;
        return result;
    }

    void bind()
    {
        glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, id);
    }

    void unbind()
    {
        glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, 0);
    }

    void destroy()
    {
        glDeleteBuffers(1, &id);
    }

}


class Mesh
{
    private 
    {
        Vbo vbo;
        Vao vao;
        Ebo ebo;
        Vec3[] points;
        int[] indices;
    }

    this(Vec3[] points, int[] indices)
    {
        vbo = Vbo.newVbo();
        vao = Vao.newVao();
        ebo = Ebo.newEbo();

        this.points = points.dup();
        this.indices = indices.dup();

        // setup
        vao.bind();
        vbo.bind();

       glBufferData(
            GL_ARRAY_BUFFER,
            cast(GLsizeiptr)(this.points.length * Vec3.sizeof),
            this.points.ptr,
            GL_STATIC_DRAW
        );

        // ebo set data
        ebo.bind();
        
        glBufferData(
            GL_ELEMENT_ARRAY_BUFFER,
            cast(GLsizeiptr)(this.indices.length * this.indices[0].sizeof),
            this.indices.ptr,
            GL_STATIC_DRAW
        );

        // vbo link
        glEnableVertexAttribArray(POSITION_IDX);
        glVertexAttribPointer(
            POSITION_IDX,
            COMPONENTS,
            GL_FLOAT,
            GL_FALSE,
            cast(GLsizei)(Vec3.sizeof),
            null
        );
        vbo.unbind();
        vao.unbind();
        ebo.unbind();
    }

    ~this()
    {
        vbo.destroy();
        vao.destroy();
        ebo.destroy();
    }

    public Vec3[] getPoints()
    {
        return points;
    }

    public int[] getIndices()
    {
        return indices;
    }

    public void render(bool dbg = false)
    {
        vao.bind();
        if(!dbg)
        {
            glDrawElements(GL_TRIANGLES, cast(int)indices.length, GL_UNSIGNED_INT, null);
        }
        else
        {
            glDrawElements(GL_LINE_LOOP, cast(int)indices.length, GL_UNSIGNED_INT, null);
        } 

        vao.unbind();
    }
}
