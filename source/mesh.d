/// Mesh
module mesh;


import bindbc.opengl;
import maths.utils;
import vertex;


enum int COMPONENTS = 3;
enum int STRIDE = 6;
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
        int ilen;
    }

    this(Vertex[] verticies, int[] indicies)    
    {
        vbo = Vbo.newVbo();
        vao = Vao.newVao();
        ebo = Ebo.newEbo();
        
        ilen = cast(int)indicies.length;

        // setup
        vao.bind();
        vbo.bind();
    
        glBufferData(
            GL_ARRAY_BUFFER,
            cast(GLsizeiptr)(verticies.length * Vertex.sizeof),
            verticies.ptr,
            GL_STATIC_DRAW
        );

        // ebo set data
        ebo.bind();
        
        glBufferData(
            GL_ELEMENT_ARRAY_BUFFER,
            cast(GLsizeiptr)(indicies.length * int.sizeof),
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

        glEnableVertexAttribArray(COLOR_IDX);
        glVertexAttribPointer(
            COLOR_IDX,
            COMPONENTS,
            GL_FLOAT,
            GL_FALSE,
            cast(GLsizei)(Vertex.sizeof),
            cast(void*)(COMPONENTS * float.sizeof)
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

    public void render()
    {
        vao.bind();

        glDrawElements(GL_TRIANGLES, ilen, GL_UNSIGNED_INT, null);

        vao.unbind();
    }
}