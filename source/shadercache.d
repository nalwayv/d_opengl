/// Shader Cache
module shadercache;


import std.string : toStringz;
import bindbc.opengl;
import utils.path;
import maths.vec3;
import maths.vec4;
import maths.mat3;
import maths.mat4;


private struct Node
{
    GLuint id;

    /// create a new shader node
    static Node newNode(string vsPath, string fsPath)
    {
        // compile vertex shader
        auto vsSrc = toStringz(readFile(vsPath));
        auto vs = glCreateShader(GL_VERTEX_SHADER);
        int check;

        glShaderSource(vs, 1, &vsSrc, null);
        glCompileShader(vs);

        glGetShaderiv(vs, GL_COMPILE_STATUS, &check);
        assert(check == GL_TRUE);

        // compile fragment shader
        auto fsSrc = toStringz(readFile(fsPath));
        auto fs = glCreateShader(GL_FRAGMENT_SHADER);

        glShaderSource(fs, 1, &fsSrc, null);
        glCompileShader(fs);

        glGetShaderiv(fs, GL_COMPILE_STATUS, &check);
        assert(check == GL_TRUE);

        // link
        auto id = glCreateProgram();

        glAttachShader(id, vs);
        glAttachShader(id, fs);
        glLinkProgram(id);

        glGetProgramiv(id, GL_LINK_STATUS, &check);
        assert(check == GL_TRUE);

        // validate
        glValidateProgram(id);

        glGetProgramiv(id, GL_VALIDATE_STATUS, &check);
        assert(check == GL_TRUE);

        // clean
        glDetachShader(id, vs);
        glDetachShader(id, fs);
        glDeleteShader(vs);
        glDeleteShader(fs);

        Node result;
        result.id = id;
        return result;
    }

    /// delete this shader
    void deleteShader()
    {
        glDeleteProgram(id);
    }

    /// use this shader
    void use()
    {
        glUseProgram(id);
    }

    /// diable this shader
    void disable()
    {
        glUseProgram(0);
    }

    /// set global uniform mat4 value within shader
    void setMat4(string uniform, Mat4 value)
    {
        auto at = glGetUniformLocation(id, uniform.ptr);
        if(at != -1)
        {
            auto arr = value.toArrayS();
            glUniformMatrix4fv(at, 1, GL_FALSE, arr.ptr);
        }
    }

    /// set global uniform mat4 value within shader
    void setMat3(string uniform, Mat3 value)
    {
        auto at = glGetUniformLocation(id, uniform.ptr);
        if(at != -1)
        {
            auto arr = value.toArrayS();
            glUniformMatrix4fv(at, 1, GL_FALSE, arr.ptr);
        }
    }

    /// set global uniform mat4 value within shader
     void setVec4(string uniform, Vec4 value)
    {
        auto at = glGetUniformLocation(id, uniform.ptr);
        if(at != -1)
        {
            glUniform4f(at, value.x, value.y, value.z, value.w);
        }
    }

    /// set global uniform mat4 value within shader
    void setVec3(string uniform, Vec3 value)
    {
        auto at = glGetUniformLocation(id, uniform.ptr);
        if(at != -1)
        {
            glUniform3f(at, value.x, value.y, value.z);
        }
    }

    /// set global uniform float value within shader
    void setFloat(string uniform, float value)
    {
        auto at = glGetUniformLocation(id, uniform.ptr);
        if(at != -1)
        {
            glUniform1f(at, value);
        }
    }

    /// set global uniform Int value within shader
    void setInt(string uniform, int value)
    {
        auto at = glGetUniformLocation(id, uniform.ptr);
        if(at != -1)
        {
            glUniform1i(at, value);
        }
    }

    /// set global uniform bool value within shader
    void setBool(string uniform, bool value)
    {
        auto at = glGetUniformLocation(id, uniform.ptr);
        if(at != -1)
        {
            glUniform1i(at, (value == true) ? GL_TRUE : GL_FALSE);
        }
    }
}


class ShaderCache
{
    private Node[string] cache;

    this()
    {

    }

    ~this()
    {
        foreach(key; cache.byKey)
        {
            cache[key].deleteShader();
        }
        cache.clear;
    }

    /// check if shader is stored within cache
    public bool has(string key)
    {
        auto pt = key in cache;
        return pt !is null;
    }

    /// add a new shader to the cache if it is not already been added
    /// else remove old and update with new
    public void add(string key, string vpath, string fpath)
    {
        if(has(key))
        {
            cache[key].deleteShader();
            cache[key] = Node.newNode(vpath, fpath);
        }
        else
        {
            cache[key] = Node.newNode(vpath, fpath);
        }
    }

    /// use shader
    public void use(string key)
    {
        if(has(key))
        {
            cache[key].use();
        }
    }

    /// set shaders uniform mat4
    public void setMat4(string key, string uniform, Mat4 value)
    {
        if(has(key))
        {
            cache[key].setMat4(uniform, value);
        }
    }

    /// set shaders uniform mat3
    public void setMat3(string key, string uniform, Mat3 value)
    {
        if(has(key))
        {
            cache[key].setMat3(uniform, value);
        }
    }

    /// set shaders uniform vec4
    public void setVec4(string key, string uniform, Vec4 value)
    {
        if(has(key))
        {
            cache[key].setVec4(uniform, value);
        }

    }

    /// set shaders uniform vec3
    public void setVec3(string key, string uniform, Vec3 value)
    {
        if(has(key))
        {
            cache[key].setVec3(uniform, value);
        }
    }

    /// set shaders uniform float
    public void setFloat(string key, string uniform, float value)
    {
        if(has(key))
        {
            cache[key].setFloat(uniform, value);
        }
    }

    /// set shaders uniform int
    public void setInt(string key, string uniform, int value)
    {
        if(has(key))
        {
            cache[key].setInt(uniform, value);
        }
    }

    /// set shaders uniform bool
    public void setBool(string key, string uniform, bool value)
    {
        if(has(key))
        {
            cache[key].setBool(uniform, value);
        }
    }

    /// remove shader from cache
    public void remove(string key)
    {
        if(has(key))
        {
            cache.remove(key);
        }
    }
}