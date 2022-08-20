/// Mesh
module mesh;


import bindbc.opengl;


enum VERT_POSITION_IDX = 0;
enum VERT_COLOR_IDX = 1;
enum COMPONENTS = 3;
enum STRIDE = 6;


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
    private Vbo vbo;
    private Vao vao;
    private Ebo ebo;
    private int indiciesLen;

    this(const float* vertData, int vertLen, const int* indiciesData, int indiciesLen)
    {
        vbo = Vbo.newVbo();
        vao = Vao.newVao();
        ebo = Ebo.newEbo();
        this.indiciesLen = indiciesLen;

        // setup
        vao.bind();
        vbo.bind();

        glBufferData(
            GL_ARRAY_BUFFER,
            vertLen * float.sizeof,
            vertData,
            GL_STATIC_DRAW
        );

        // ebo set data
        ebo.bind();
        glBufferData(
            GL_ELEMENT_ARRAY_BUFFER,
            indiciesLen * int.sizeof,
            indiciesData,
            GL_STATIC_DRAW
        );

        // vbo link
        glEnableVertexAttribArray(VERT_POSITION_IDX);
        glVertexAttribPointer(
            VERT_POSITION_IDX,
            COMPONENTS,
            GL_FLOAT,
            GL_FALSE,
            STRIDE * float.sizeof,
            null
        );

        glEnableVertexAttribArray(VERT_COLOR_IDX);
        glVertexAttribPointer(
            VERT_COLOR_IDX,
            COMPONENTS,
            GL_FLOAT,
            GL_FALSE,
            STRIDE * float.sizeof,
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

        glDrawElements(GL_TRIANGLES, indiciesLen, GL_UNSIGNED_INT, null);

        vao.unbind();
    }
}