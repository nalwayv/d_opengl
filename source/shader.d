/// Shader
module shader;


import std.string : toStringz;
import bindbc.opengl;
import utils.path;
import maths.vec3;
import maths.vec4;
import maths.mat3;
import maths.mat4;


class Shader
{
    private GLuint id;

    this(string vsPath, string fsPath)
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
        id = glCreateProgram();

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
    }

    ~this()
    {
        glDeleteProgram(id);
    }

    void use()
    {
        glUseProgram(id);
    }

    void disable()
    {
        glUseProgram(0);
    }

    /// Set global uniform mat4 value within shader
    public void setMat4(string name, Mat4 value)
    {
        auto at = glGetUniformLocation(id, name.ptr);
        assert(at != -1);

        auto arr = value.toArrayS();
        glUniformMatrix4fv(at, 1, GL_FALSE, arr.ptr);
    }

    /// Set global uniform mat4 value within shader
    public void setMat3(string name, Mat3 value)
    {
        auto at = glGetUniformLocation(id, name.ptr);
        assert(at != -1);

        auto arr = value.toArrayS();
        glUniformMatrix4fv(at, 1, GL_FALSE, arr.ptr);
    }

    /// Set global uniform mat4 value within shader
    public void setVec4(string name, Vec4 value)
    {
        auto at = glGetUniformLocation(id, name.ptr);
        assert(at != -1);

        glUniform4f(at, value.x, value.y, value.z, value.w);
    }

    /// Set global uniform mat4 value within shader
    public void setVec3(string name, Vec3 value)
    {
        auto at = glGetUniformLocation(id, name.ptr);
        assert(at != -1);

        glUniform3f(at, value.x, value.y, value.z);
    }

    /// Set global uniform float value within shader
    public void setFloat(string name, float value)
    {
        auto at = glGetUniformLocation(id, name.ptr);
        assert(at != -1);

        glUniform1f(at, value);
    }

    /// Set global uniform Int value within shader
    void setInt(string name, int value)
    {
        auto at = glGetUniformLocation(id, name.ptr);
        assert(at != -1);

        glUniform1i(at, value);
    }

    /// Set global uniform bool value within shader
    public void setBool(string name, bool value)
    {
        auto at = glGetUniformLocation(id, name.ptr);
        assert(at != -1);

        glUniform1i(at, (value == true) ? GL_TRUE : GL_FALSE);
    }
}