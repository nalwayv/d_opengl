/// Mesh
module mesh;


import bindbc.opengl;
import maths.utils;
import utils.obj;


enum int COMPONENTS = 3;
enum int STRIDE = 3;
enum : int
{
    POSITION_IDX = 0,
    COLOR_IDX = 1
}


struct Vbo
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


struct Vao
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


struct Ebo
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
        Obj object;
    }

    this(string filePath)
    {
        vbo = Vbo.newVbo();
        vao = Vao.newVao();
        ebo = Ebo.newEbo();

        object = new Obj(filePath);

        auto vertex = object.getVertex();
        auto indicies = object.getIndicies();

        // setup
        vao.bind();
        vbo.bind();

        glBufferData(
            GL_ARRAY_BUFFER,
            cast(GLsizeiptr)(vertex.length * Vertex.sizeof),
            vertex.ptr,
            GL_STATIC_DRAW
        );

        // ebo set data
        ebo.bind();
        
        glBufferData(
            GL_ELEMENT_ARRAY_BUFFER,
            cast(GLsizeiptr)(indicies.length * indicies[0].sizeof),
            indicies.ptr,
            GL_STATIC_DRAW
        );

        // vbo link
        glEnableVertexAttribArray(POSITION_IDX);
        glVertexAttribPointer(
            POSITION_IDX,
            COMPONENTS,
            GL_FLOAT,
            GL_FALSE,
            cast(GLsizei)(Vertex.sizeof),
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

    /// Returns: Obj
    public Obj getObj()
    {
        return object;
    }

    public void render(bool dbg = false)
    {
        auto indicies = object.getIndicies();

        vao.bind();
        if(!dbg)
        {
            glDrawElements(GL_TRIANGLES, cast(int)indicies.length, GL_UNSIGNED_INT, null);
        }
        else
        {
            glDrawElements(GL_LINE_LOOP, cast(int)indicies.length, GL_UNSIGNED_INT, null);
        } 

        vao.unbind();
    }
}
