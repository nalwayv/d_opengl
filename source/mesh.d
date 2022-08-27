/// Mesh
module mesh;

import core.memory : GC;
import bindbc.opengl;


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

// TODO(...)

class Mesh
{
    private
    {
        float* verticies;
        int* indicies;
        Vbo vbo;
        Vao vao;
        Ebo ebo;
        int vlen;
        int ilen;
    }

    this(const float[] verts, const int[] indis)    
    {
        // init
        verticies = cast(float*)GC.calloc(verts.length);
        vlen = cast(int)verts.length;
        for(auto i = 0; i < vlen; i++)
        {
            verticies[i] = verts[i];
        }

        indicies = cast(int*)GC.calloc(indis.length);
        ilen = cast(int)indis.length;
        for(auto i = 0; i < ilen; i++)
        {
            indicies[i] = indis[i];
        }

        vbo = Vbo.newVbo();
        vao = Vao.newVao();
        ebo = Ebo.newEbo();

        // setup
        vao.bind();
        vbo.bind();
    
        glBufferData(
            GL_ARRAY_BUFFER,
            cast(GLsizeiptr)(vlen * float.sizeof),
            verticies,
            GL_STATIC_DRAW
        );

        // ebo set data
        ebo.bind();
        
        glBufferData(
            GL_ELEMENT_ARRAY_BUFFER,
            cast(GLsizeiptr)(ilen * int.sizeof),
            indicies,
            GL_STATIC_DRAW
        );

        // vbo link
        glEnableVertexAttribArray(POSITION_IDX);

        glVertexAttribPointer(
            POSITION_IDX,
            COMPONENTS,
            GL_FLOAT,
            GL_FALSE,
            cast(GLsizei)(STRIDE * float.sizeof),
            null
        );

        glEnableVertexAttribArray(COLOR_IDX);
        glVertexAttribPointer(
            COLOR_IDX,
            COMPONENTS,
            GL_FLOAT,
            GL_FALSE,
            cast(GLsizei)(STRIDE * float.sizeof),
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

        if(verticies !is null)
        {
            GC.free(verticies);
        }
        if(indicies !is null)
        {
            GC.free(indicies);
        }
    }

    public void render()
    {
        vao.bind();

        glDrawElements(GL_TRIANGLES, ilen, GL_UNSIGNED_INT, null);

        vao.unbind();
    }
}